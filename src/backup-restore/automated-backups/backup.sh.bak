#!/bin/bash

# Automated Backup Script for n8n Docker Stack
# Backs up PostgreSQL database, n8n data, and configurations

set -e

# Configuration
BACKUP_DIR="/tmp/n8n_backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RETENTION_DAYS=30
POSTGRES_CONTAINER="n8n_postgres"
N8N_CONTAINER="n8n_app"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$BACKUP_DIR/backup.log"
}

# Initialize backup directory
initialize_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log "✅ Created backup directory: $BACKUP_DIR"
    fi
}

# Database backup
backup_database() {
    log "🗄️ Starting PostgreSQL database backup..."
    
    # Get database credentials from secrets
    DB_USER=$(docker exec $POSTGRES_CONTAINER cat /run/secrets/postgres_user)
    DB_NAME=$(docker exec $POSTGRES_CONTAINER cat /run/secrets/postgres_db)
    
    # Create database dump
    docker exec $POSTGRES_CONTAINER pg_dump -U "$DB_USER" -d "$DB_NAME" --clean --if-exists > "$BACKUP_DIR/postgres_backup_$TIMESTAMP.sql"
    
    # Compress the backup
    gzip "$BACKUP_DIR/postgres_backup_$TIMESTAMP.sql"
    
    log "✅ Database backup completed: postgres_backup_$TIMESTAMP.sql.gz"
}

# n8n data backup
backup_n8n_data() {
    log "📁 Starting n8n data backup..."
    
    # Create tar archive of n8n data
    docker run --rm \
        -v n8n_data:/data \
        -v "$BACKUP_DIR:/backup" \
        alpine:latest \
        tar czf "/backup/n8n_data_backup_$TIMESTAMP.tar.gz" -C /data .
    
    log "✅ n8n data backup completed: n8n_data_backup_$TIMESTAMP.tar.gz"
}

# Configuration backup
backup_configurations() {
    log "⚙️ Starting configuration backup..."
    
    # Create backup directory for configs
    CONFIG_BACKUP_DIR="$BACKUP_DIR/configs_$TIMESTAMP"
    mkdir -p "$CONFIG_BACKUP_DIR"
    
    # Copy configuration files (excluding secrets)
    cp -r /Users/viking/github_portfolio/n8n_docker_stack/src/n8n/src/*.yml "$CONFIG_BACKUP_DIR/" 2>/dev/null || true
    cp -r /Users/viking/github_portfolio/n8n_docker_stack/src/security/nginx "$CONFIG_BACKUP_DIR/" 2>/dev/null || true
    cp -r /Users/viking/github_portfolio/n8n_docker_stack/src/monitoring "$CONFIG_BACKUP_DIR/" 2>/dev/null || true
    
    # Create archive
    tar czf "$BACKUP_DIR/configs_backup_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" "configs_$TIMESTAMP"
    rm -rf "$CONFIG_BACKUP_DIR"
    
    log "✅ Configuration backup completed: configs_backup_$TIMESTAMP.tar.gz"
}

# Workflow backup
backup_workflows() {
    log "🔄 Starting workflow backup..."
    
    # Export workflows from n8n
    if docker exec $N8N_CONTAINER command -v n8n &> /dev/null; then
        docker exec $N8N_CONTAINER n8n export:workflow --all --output="/data/localfiles/workflows_export_$TIMESTAMP.json" || true
        
        # Copy exported workflows to backup directory
        docker cp "$N8N_CONTAINER:/data/localfiles/workflows_export_$TIMESTAMP.json" "$BACKUP_DIR/" 2>/dev/null || true
        
        log "✅ Workflow backup completed: workflows_export_$TIMESTAMP.json"
    else
        log "⚠️ n8n CLI not available, skipping workflow export"
    fi
}

# Backup verification
verify_backups() {
    log "🔍 Verifying backup integrity..."
    
    # Check database backup
    if [ -f "$BACKUP_DIR/postgres_backup_$TIMESTAMP.sql.gz" ]; then
        if gzip -t "$BACKUP_DIR/postgres_backup_$TIMESTAMP.sql.gz"; then
            log "✅ Database backup integrity verified"
        else
            log "❌ Database backup integrity check failed"
            exit 1
        fi
    fi
    
    # Check n8n data backup
    if [ -f "$BACKUP_DIR/n8n_data_backup_$TIMESTAMP.tar.gz" ]; then
        if tar -tzf "$BACKUP_DIR/n8n_data_backup_$TIMESTAMP.tar.gz" > /dev/null; then
            log "✅ n8n data backup integrity verified"
        else
            log "❌ n8n data backup integrity check failed"
            exit 1
        fi
    fi
    
    log "✅ All backups verified successfully"
}

# Cleanup old backups
cleanup_old_backups() {
    log "🧹 Cleaning up old backups (older than $RETENTION_DAYS days)..."
    
    find "$BACKUP_DIR" -name "*.gz" -type f -mtime +$RETENTION_DAYS -delete
    find "$BACKUP_DIR" -name "*.json" -type f -mtime +$RETENTION_DAYS -delete
    
    log "✅ Old backups cleaned up"
}

# Generate backup report
generate_report() {
    log "📊 Generating backup report..."
    
    REPORT_FILE="$BACKUP_DIR/backup_report_$TIMESTAMP.txt"
    
    cat > "$REPORT_FILE" << EOF
N8N DOCKER STACK BACKUP REPORT
===============================
Backup Date: $(date)
Backup Directory: $BACKUP_DIR

BACKUP FILES CREATED:
$(ls -lah "$BACKUP_DIR"/*_$TIMESTAMP.* 2>/dev/null || echo "No backup files found")

BACKUP SIZES:
$(du -sh "$BACKUP_DIR"/*_$TIMESTAMP.* 2>/dev/null || echo "No backup files found")

TOTAL BACKUP SIZE:
$(du -sh "$BACKUP_DIR" | cut -f1)

AVAILABLE DISK SPACE:
$(df -h "$BACKUP_DIR" | tail -1)

DOCKER CONTAINERS STATUS:
$(docker ps --format "table {{.Names}}\t{{.Status}}")

EOF
    
    log "✅ Backup report generated: backup_report_$TIMESTAMP.txt"
}

# Main backup function
main() {
    log "🚀 Starting n8n Docker Stack backup process..."
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        log "❌ Docker is not running or not accessible"
        exit 1
    fi
    
    # Check if containers are running
    if ! docker ps | grep -q "$POSTGRES_CONTAINER"; then
        log "❌ PostgreSQL container is not running"
        exit 1
    fi
    
    # Initialize and run backups
    initialize_backup_dir
    backup_database
    backup_n8n_data
    backup_configurations
    backup_workflows
    verify_backups
    cleanup_old_backups
    generate_report
    
    log "🎉 Backup process completed successfully!"
    log "📁 Backup location: $BACKUP_DIR"
    log "🏷️ Backup timestamp: $TIMESTAMP"
}

# Run main function
main "$@"
