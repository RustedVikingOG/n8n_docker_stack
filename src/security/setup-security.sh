#!/bin/bash

# Security Setup Script for n8n Docker Stack
# Initializes security hardening components

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECURITY_DIR="$SCRIPT_DIR"
SECRETS_DIR="$SECURITY_DIR/secrets"
SSL_DIR="$SECURITY_DIR/nginx/ssl"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ✅ $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ⚠️ $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ❌ $1"
}

# Check prerequisites
check_prerequisites() {
    log "🔍 Checking prerequisites..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    # Check if Docker Compose is available
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not available"
        exit 1
    fi
    
    # Check if OpenSSL is installed
    if ! command -v openssl &> /dev/null; then
        log_error "OpenSSL is not installed or not in PATH"
        exit 1
    fi
    
    log_success "All prerequisites satisfied"
}

# Create directory structure
create_directories() {
    log "📁 Creating security directory structure..."
    
    mkdir -p "$SECRETS_DIR"
    mkdir -p "$SSL_DIR"
    mkdir -p "$SECURITY_DIR/nginx"
    mkdir -p "$SECURITY_DIR/fail2ban"
    mkdir -p "$(dirname "$SECURITY_DIR")/backup-restore/automated-backups"
    mkdir -p "$(dirname "$SECURITY_DIR")/backup-restore/restore-scripts"
    
    log_success "Directory structure created"
}

# Generate secrets
generate_secrets() {
    log "🔐 Generating security secrets..."
    
    if [ -f "$SECRETS_DIR/generate-secrets.sh" ]; then
        cd "$SECRETS_DIR"
        ./generate-secrets.sh
        cd "$SCRIPT_DIR"
        log_success "Secrets generated successfully"
    else
        log_error "Secrets generation script not found"
        exit 1
    fi
}

# Generate SSL certificates
generate_ssl_certificates() {
    log "🔒 Generating SSL certificates..."
    
    if [ -f "$SECURITY_DIR/nginx/generate-ssl.sh" ]; then
        cd "$SECURITY_DIR/nginx"
        ./generate-ssl.sh
        cd "$SCRIPT_DIR"
        log_success "SSL certificates generated successfully"
    else
        log_error "SSL generation script not found"
        exit 1
    fi
}

# Set proper permissions
set_permissions() {
    log "🔐 Setting security permissions..."
    
    # Secure secrets directory
    chmod 700 "$SECRETS_DIR"
    find "$SECRETS_DIR" -name "*.txt" -exec chmod 600 {} \;
    
    # Secure SSL directory
    chmod 700 "$SSL_DIR"
    find "$SSL_DIR" -name "*.key" -exec chmod 600 {} \;
    find "$SSL_DIR" -name "*.crt" -exec chmod 644 {} \;
    
    # Make scripts executable
    find "$SECURITY_DIR" -name "*.sh" -exec chmod +x {} \;
    find "$(dirname "$SECURITY_DIR")/backup-restore" -name "*.sh" -exec chmod +x {} \;
    
    log_success "Permissions set correctly"
}

# Validate configuration
validate_configuration() {
    log "🔍 Validating security configuration..."
    
    # Check if secrets exist
    if [ ! -f "$SECRETS_DIR/postgres_password.txt" ]; then
        log_error "PostgreSQL password secret not found at $SECRETS_DIR/postgres_password.txt"
        exit 1
    fi
    
    # Check if SSL certificates exist
    if [ ! -f "$SSL_DIR/nginx.crt" ] || [ ! -f "$SSL_DIR/nginx.key" ]; then
        log_error "SSL certificates not found"
        exit 1
    fi
    
    # Validate nginx configuration
    if [ -f "$SECURITY_DIR/nginx/nginx.conf" ]; then
        log "🔍 Validating nginx configuration..."
        docker run --rm -v "$SECURITY_DIR/nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro" nginx:alpine nginx -t
        log_success "Nginx configuration is valid"
    fi
    
    log_success "Configuration validation completed"
}

# Create backup directories
setup_backup_system() {
    log "💾 Setting up backup system..."
    
    # Create backup directory
    BACKUP_DIR="/tmp/n8n_backups"  # Change this to your preferred backup location
    mkdir -p "$BACKUP_DIR"
    
    # Update backup script with correct paths
    if [ -f "$(dirname "$SECURITY_DIR")/backup-restore/automated-backups/backup.sh" ]; then
        sed -i.bak "s|BACKUP_DIR=\"/backups\"|BACKUP_DIR=\"$BACKUP_DIR\"|g" "$(dirname "$SECURITY_DIR")/backup-restore/automated-backups/backup.sh"
        log_success "Backup system configured with directory: $BACKUP_DIR"
    fi
}

# Create systemd service (optional)
create_backup_service() {
    if command -v systemctl &> /dev/null; then
        log "⚙️ Creating systemd backup service..."
        
        # This would create a systemd service for automated backups
        # Implementation depends on system permissions and requirements
        log_warning "Systemd service creation requires manual setup with root privileges"
        log "💡 To create automated backups, consider adding to crontab:"
        echo "0 2 * * * $(dirname "$SECURITY_DIR")/backup-restore/automated-backups/backup.sh"
    fi
}

# Display security summary
display_summary() {
    log "📊 Security Setup Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    echo "🔐 SECRETS GENERATED:"
    echo "   • PostgreSQL credentials"
    echo "   • n8n authentication credentials"
    echo "   • Encryption keys"
    echo "   • Grafana admin credentials"
    
    echo ""
    echo "🔒 SSL CERTIFICATES:"
    echo "   • Self-signed certificate for localhost"
    echo "   • Certificate: $SSL_DIR/nginx.crt"
    echo "   • Private key: $SSL_DIR/nginx.key"
    
    echo ""
    echo "🚦 NETWORK SECURITY:"
    echo "   • Docker network isolation configured"
    echo "   • Nginx reverse proxy with security headers"
    echo "   • Fail2ban intrusion prevention"
    echo "   • Rate limiting enabled"
    
    echo ""
    echo "💾 BACKUP SYSTEM:"
    echo "   • Automated backup scripts created"
    echo "   • Restore procedures available"
    echo "   • Backup verification included"
    
    echo ""
    echo "🚀 NEXT STEPS:"
    echo "   1. Review generated secrets in: $SECRETS_DIR"
    echo "   2. Start security stack: docker compose -f docker-compose.security.yml up -d"
    echo "   3. Access n8n securely: https://localhost"
    echo "   4. Setup automated backups via cron"
    echo "   5. Configure monitoring alerts"
    
    echo ""
    echo "⚠️ IMPORTANT SECURITY NOTES:"
    echo "   • Change default passwords for production"
    echo "   • Use CA-signed certificates for production"
    echo "   • Regularly update Docker images"
    echo "   • Monitor security logs"
    echo "   • Test backup and restore procedures"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Setup security hardening for n8n Docker Stack

OPTIONS:
    --skip-secrets      Skip secrets generation
    --skip-ssl          Skip SSL certificate generation
    --skip-validation   Skip configuration validation
    -h, --help          Show this help message

EXAMPLES:
    $0                  # Full security setup
    $0 --skip-ssl       # Setup without generating new SSL certificates
    $0 --skip-secrets   # Setup without generating new secrets

EOF
}

# Main function
main() {
    local skip_secrets=false
    local skip_ssl=false
    local skip_validation=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-secrets)
                skip_secrets=true
                shift
                ;;
            --skip-ssl)
                skip_ssl=true
                shift
                ;;
            --skip-validation)
                skip_validation=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    echo "🛡️ n8n Docker Stack Security Hardening Setup"
    echo "=============================================="
    echo ""
    
    # Run setup steps
    check_prerequisites
    create_directories
    
    if [ "$skip_secrets" = false ]; then
        generate_secrets
    else
        log_warning "Skipping secrets generation"
    fi
    
    if [ "$skip_ssl" = false ]; then
        generate_ssl_certificates
    else
        log_warning "Skipping SSL certificate generation"
    fi
    
    set_permissions
    setup_backup_system
    
    if [ "$skip_validation" = false ]; then
        validate_configuration
    else
        log_warning "Skipping configuration validation"
    fi
    
    create_backup_service
    display_summary
    
    log_success "Security hardening setup completed successfully! 🎉"
}

# Run main function
main "$@"
