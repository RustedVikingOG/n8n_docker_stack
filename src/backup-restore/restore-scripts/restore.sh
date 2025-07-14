#!/bin/bash

# Restore Script for n8n Docker Stack
# Restores PostgreSQL database, n8n data, and configurations from backup

set -e

# Configuration
BACKUP_DIR="/backups"
POSTGRES_CONTAINER="n8n_postgres"
N8N_CONTAINER="n8n_app"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Restore n8n Docker Stack from backup

OPTIONS:
    -t, --timestamp TIMESTAMP    Restore from specific backup timestamp (YYYYMMDD_HHMMSS)
    -d, --database              Restore database only
    -n, --n8n-data              Restore n8n data only
    -c, --configs               Restore configurations only
    -w, --workflows             Restore workflows only
    -a, --all                   Restore everything (default)
    -l, --list                  List available backups
    -h, --help                  Show this help message

EXAMPLES:
    $0 --list                           # List available backups
    $0 --timestamp 20240714_143000      # Restore from specific backup
    $0 --database --timestamp 20240714_143000    # Restore database only
    $0 --all --timestamp 20240714_143000         # Restore everything

EOF
}

# List available backups
list_backups() {
    log "📋 Available backups in $BACKUP_DIR:"
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR")" ]; then
        log "❌ No backups found in $BACKUP_DIR"
        exit 1
    fi
    
    # Group backups by timestamp
    timestamps=$(ls "$BACKUP_DIR" | grep -E '_[0-9]{8}_[0-9]{6}\.' | sed 's/.*_\([0-9]\{8\}_[0-9]\{6\}\)\..*/\1/' | sort -u)
    
    for timestamp in $timestamps; do
        echo "🗓️ Backup: $timestamp"
        ls -lah "$BACKUP_DIR"/*_$timestamp.* 2>/dev/null | awk '{print "   " $5 " " $9}' | sed 's|.*/||'
        echo ""
    done
}

# Validate backup files exist
validate_backup_files() {
    local timestamp=$1
    local missing_files=()
    
    if [ "$RESTORE_DATABASE" = true ] && [ ! -f "$BACKUP_DIR/postgres_backup_$timestamp.sql.gz" ]; then
        missing_files+=("postgres_backup_$timestamp.sql.gz")
    fi
    
    if [ "$RESTORE_N8N_DATA" = true ] && [ ! -f "$BACKUP_DIR/n8n_data_backup_$timestamp.tar.gz" ]; then
        missing_files+=("n8n_data_backup_$timestamp.tar.gz")
    fi
    
    if [ "$RESTORE_CONFIGS" = true ] && [ ! -f "$BACKUP_DIR/configs_backup_$timestamp.tar.gz" ]; then
        missing_files+=("configs_backup_$timestamp.tar.gz")
    fi
    
    if [ "$RESTORE_WORKFLOWS" = true ] && [ ! -f "$BACKUP_DIR/workflows_export_$timestamp.json" ]; then
        log "⚠️ Workflow export file not found (this is optional): workflows_export_$timestamp.json"
    fi
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        log "❌ Missing backup files for timestamp $timestamp:"
        for file in "${missing_files[@]}"; do
            log "   - $file"
        done
        exit 1
    fi
}

# Stop containers
stop_containers() {
    log "🛑 Stopping containers for restore..."
    
    docker-compose -f /Users/viking/github_portfolio/n8n_docker_stack/src/security/docker-compose.security.yml down
    
    log "✅ Containers stopped"
}

# Start containers
start_containers() {
    log "🚀 Starting containers after restore..."
    
    docker-compose -f /Users/viking/github_portfolio/n8n_docker_stack/src/security/docker-compose.security.yml up -d
    
    log "✅ Containers started"
}

# Restore database
restore_database() {
    local timestamp=$1
    
    log "🗄️ Restoring PostgreSQL database from backup..."
    
    # Start only PostgreSQL for restore
    docker-compose -f /Users/viking/github_portfolio/n8n_docker_stack/src/security/docker-compose.security.yml up -d postgres
    
    # Wait for PostgreSQL to be ready
    log "⏳ Waiting for PostgreSQL to be ready..."
    timeout=60
    while [ $timeout -gt 0 ]; do
        if docker exec $POSTGRES_CONTAINER pg_isready -U postgres; then
            break
        fi
        sleep 2
        timeout=$((timeout - 2))
    done
    
    if [ $timeout -le 0 ]; then
        log "❌ PostgreSQL failed to start within timeout"
        exit 1
    fi
    
    # Get database credentials
    DB_USER=$(docker exec $POSTGRES_CONTAINER cat /run/secrets/postgres_user)
    DB_NAME=$(docker exec $POSTGRES_CONTAINER cat /run/secrets/postgres_db)
    
    # Restore database
    log "📥 Importing database backup..."
    gunzip -c "$BACKUP_DIR/postgres_backup_$timestamp.sql.gz" | docker exec -i $POSTGRES_CONTAINER psql -U "$DB_USER" -d "$DB_NAME"
    
    log "✅ Database restore completed"
}

# Restore n8n data
restore_n8n_data() {
    local timestamp=$1
    
    log "📁 Restoring n8n data from backup..."
    
    # Remove existing n8n data volume
    docker volume rm n8n_data 2>/dev/null || true
    
    # Create new volume and restore data
    docker volume create n8n_data
    
    docker run --rm \
        -v n8n_data:/data \
        -v "$BACKUP_DIR:/backup" \
        alpine:latest \
        tar xzf "/backup/n8n_data_backup_$timestamp.tar.gz" -C /data
    
    log "✅ n8n data restore completed"
}

# Restore configurations
restore_configurations() {
    local timestamp=$1
    
    log "⚙️ Restoring configurations from backup..."
    
    # Create temporary directory for extraction
    TEMP_DIR=$(mktemp -d)
    
    # Extract configurations
    tar xzf "$BACKUP_DIR/configs_backup_$timestamp.tar.gz" -C "$TEMP_DIR"
    
    # Copy configurations back (user should review these manually)
    log "📁 Configuration files extracted to: $TEMP_DIR/configs_$timestamp"
    log "⚠️ Please review and manually copy configuration files as needed"
    log "🔍 Extracted configurations:"
    find "$TEMP_DIR" -type f -name "*.yml" -o -name "*.conf" | head -10
    
    log "✅ Configuration restore prepared (manual review required)"
}

# Restore workflows
restore_workflows() {
    local timestamp=$1
    
    if [ ! -f "$BACKUP_DIR/workflows_export_$timestamp.json" ]; then
        log "⚠️ Workflow backup not found, skipping workflow restore"
        return
    fi
    
    log "🔄 Restoring workflows from backup..."
    
    # Wait for n8n to be ready
    log "⏳ Waiting for n8n to be ready..."
    timeout=120
    while [ $timeout -gt 0 ]; do
        if docker exec $N8N_CONTAINER wget --quiet --tries=1 --spider http://localhost:5678/healthz 2>/dev/null; then
            break
        fi
        sleep 5
        timeout=$((timeout - 5))
    done
    
    if [ $timeout -le 0 ]; then
        log "❌ n8n failed to start within timeout"
        return
    fi
    
    # Copy workflow backup to container
    docker cp "$BACKUP_DIR/workflows_export_$timestamp.json" "$N8N_CONTAINER:/tmp/"
    
    # Import workflows (this is a placeholder - actual implementation would depend on n8n CLI capabilities)
    log "📥 Workflow backup prepared for import: /tmp/workflows_export_$timestamp.json"
    log "⚠️ Please manually import workflows using n8n interface or CLI"
    
    log "✅ Workflow restore prepared"
}

# Confirm restore operation
confirm_restore() {
    local timestamp=$1
    
    echo ""
    log "⚠️ RESTORE CONFIRMATION REQUIRED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "📅 Restore timestamp: $timestamp"
    log "🗄️ Database restore: $RESTORE_DATABASE"
    log "📁 n8n data restore: $RESTORE_N8N_DATA"
    log "⚙️ Configuration restore: $RESTORE_CONFIGS"
    log "🔄 Workflow restore: $RESTORE_WORKFLOWS"
    echo ""
    log "⚠️ WARNING: This operation will OVERWRITE existing data!"
    log "🔒 Current containers will be stopped during restore"
    echo ""
    
    read -p "Do you want to continue? (yes/no): " confirmation
    if [ "$confirmation" != "yes" ]; then
        log "❌ Restore cancelled by user"
        exit 0
    fi
}

# Main restore function
main() {
    local timestamp=""
    
    # Default options
    RESTORE_ALL=true
    RESTORE_DATABASE=false
    RESTORE_N8N_DATA=false
    RESTORE_CONFIGS=false
    RESTORE_WORKFLOWS=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--timestamp)
                timestamp="$2"
                shift 2
                ;;
            -d|--database)
                RESTORE_ALL=false
                RESTORE_DATABASE=true
                shift
                ;;
            -n|--n8n-data)
                RESTORE_ALL=false
                RESTORE_N8N_DATA=true
                shift
                ;;
            -c|--configs)
                RESTORE_ALL=false
                RESTORE_CONFIGS=true
                shift
                ;;
            -w|--workflows)
                RESTORE_ALL=false
                RESTORE_WORKFLOWS=true
                shift
                ;;
            -a|--all)
                RESTORE_ALL=true
                shift
                ;;
            -l|--list)
                list_backups
                exit 0
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log "❌ Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Set default restore options if --all is selected
    if [ "$RESTORE_ALL" = true ]; then
        RESTORE_DATABASE=true
        RESTORE_N8N_DATA=true
        RESTORE_CONFIGS=true
        RESTORE_WORKFLOWS=true
    fi
    
    # Validate timestamp
    if [ -z "$timestamp" ]; then
        log "❌ Timestamp is required. Use --list to see available backups."
        show_usage
        exit 1
    fi
    
    # Validate timestamp format
    if ! [[ "$timestamp" =~ ^[0-9]{8}_[0-9]{6}$ ]]; then
        log "❌ Invalid timestamp format. Expected: YYYYMMDD_HHMMSS"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        log "❌ Docker is not running or not accessible"
        exit 1
    fi
    
    # Validate backup files
    validate_backup_files "$timestamp"
    
    # Confirm restore operation
    confirm_restore "$timestamp"
    
    log "🚀 Starting restore process for timestamp: $timestamp"
    
    # Stop containers
    stop_containers
    
    # Perform restore operations
    if [ "$RESTORE_DATABASE" = true ]; then
        restore_database "$timestamp"
    fi
    
    if [ "$RESTORE_N8N_DATA" = true ]; then
        restore_n8n_data "$timestamp"
    fi
    
    if [ "$RESTORE_CONFIGS" = true ]; then
        restore_configurations "$timestamp"
    fi
    
    # Start containers
    start_containers
    
    # Restore workflows after containers are running
    if [ "$RESTORE_WORKFLOWS" = true ]; then
        restore_workflows "$timestamp"
    fi
    
    log "🎉 Restore process completed successfully!"
    log "📁 Restored from timestamp: $timestamp"
}

# Run main function
main "$@"
