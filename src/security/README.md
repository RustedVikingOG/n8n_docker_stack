# Security Hardening Documentation

## Overview

This document describes the security hardening implementation for the n8n Docker Stack, providing comprehensive security measures including HTTPS/TLS termination, secrets management, network isolation, intrusion prevention, and automated backup systems.

## Security Components

### 1. Reverse Proxy with SSL/TLS Termination

**Component**: Nginx reverse proxy with SSL/TLS certificates

**Features**:
- HTTPS enforcement with HTTP to HTTPS redirect
- Modern SSL/TLS configuration (TLS 1.2/1.3)
- Security headers implementation
- Rate limiting for authentication and API endpoints
- WebSocket support for n8n
- Custom error pages

**Configuration**:
- `src/security/nginx/nginx.conf` - Main nginx configuration
- `src/security/nginx/ssl/` - SSL certificates directory
- `src/security/nginx/generate-ssl.sh` - SSL certificate generation script

### 2. Secrets Management

**Component**: Docker secrets for secure credential management

**Features**:
- Encrypted credential storage
- Runtime secret injection
- No plaintext credentials in environment variables
- Automated secret generation

**Secrets**:
- PostgreSQL database credentials
- n8n authentication credentials
- Encryption keys
- SSL certificates
- Monitoring credentials

**Configuration**:
- `src/security/secrets/docker-secrets.yml` - Docker secrets definition
- `src/security/secrets/generate-secrets.sh` - Secret generation script

### 3. Network Security & Isolation

**Component**: Docker network segmentation with multiple isolated networks

**Networks**:
- **Frontend Network**: External access (nginx, fail2ban)
- **Backend Network**: Internal services (n8n, ollama)
- **Database Network**: Database access only (postgres)

**Features**:
- Service-to-service communication control
- Network policy enforcement
- Port exposure management
- Internal network isolation

### 4. Intrusion Prevention

**Component**: Fail2ban for intrusion detection and prevention

**Features**:
- Nginx authentication failure detection
- Rate limit violation monitoring
- Automatic IP blocking
- Configurable ban times and retry limits

**Configuration**:
- `src/security/fail2ban/jail.local` - Fail2ban jail configuration
- `src/security/fail2ban/filter-*.conf` - Custom filter definitions

### 5. Backup & Disaster Recovery

**Component**: Automated backup system with integrity verification

**Features**:
- PostgreSQL database backups
- n8n data volume backups
- Configuration backups
- Workflow export/import
- Backup integrity verification
- Automated cleanup of old backups

**Scripts**:
- `src/backup-restore/automated-backups/backup.sh` - Backup automation
- `src/backup-restore/restore-scripts/restore.sh` - Restore procedures

## Security Configuration

### SSL/TLS Security

```nginx
# Modern SSL configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
```

### Security Headers

```nginx
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
add_header X-Content-Type-Options nosniff;
add_header X-Frame-Options DENY;
add_header X-XSS-Protection "1; mode=block";
add_header Referrer-Policy "strict-origin-when-cross-origin";
add_header Content-Security-Policy "default-src 'self'; ...";
```

### Rate Limiting

```nginx
limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
limit_req_zone $binary_remote_addr zone=api:10m rate=30r/m;
```

### Container Security

```yaml
security_opt:
  - no-new-privileges:true
read_only: true
user: "1000:1000"
```

## Deployment Instructions

### Initial Setup

1. **Run Security Setup Script**:
   ```bash
   cd src/security
   ./setup-security.sh
   ```

2. **Review Generated Secrets**:
   ```bash
   ls -la src/security/secrets/
   ```

3. **Start Security Stack**:
   ```bash
   docker compose -f src/security/docker-compose.security.yml up -d
   ```

### Verification

1. **Check HTTPS Access**:
   ```bash
   curl -k https://localhost
   ```

2. **Verify SSL Certificate**:
   ```bash
   openssl s_client -connect localhost:443 -servername localhost
   ```

3. **Test Security Headers**:
   ```bash
   curl -I -k https://localhost
   ```

### Backup Operations

1. **Manual Backup**:
   ```bash
   ./src/backup-restore/automated-backups/backup.sh
   ```

2. **List Available Backups**:
   ```bash
   ./src/backup-restore/restore-scripts/restore.sh --list
   ```

3. **Restore from Backup**:
   ```bash
   ./src/backup-restore/restore-scripts/restore.sh --timestamp 20240714_143000
   ```

## Security Monitoring

### Log Locations

- **Nginx Access Logs**: `/var/log/nginx/access.log`
- **Nginx Error Logs**: `/var/log/nginx/error.log`
- **Fail2ban Logs**: Container logs for `n8n_fail2ban`
- **PostgreSQL Logs**: Container logs for `n8n_postgres`

### Monitoring Commands

```bash
# Check container status
docker ps

# View nginx logs
docker logs n8n_nginx

# View fail2ban status
docker exec n8n_fail2ban fail2ban-client status

# Check banned IPs
docker exec n8n_fail2ban fail2ban-client status nginx-auth
```

## Security Best Practices

### Production Deployment

1. **Use CA-Signed Certificates**:
   - Replace self-signed certificates with certificates from a trusted CA
   - Consider using Let's Encrypt for automatic certificate management

2. **Change Default Credentials**:
   - Generate new secrets for production
   - Use strong, unique passwords
   - Implement password rotation policies

3. **Network Security**:
   - Configure firewall rules on the host system
   - Use VPN or private networks for administrative access
   - Implement network monitoring

4. **Regular Updates**:
   - Keep Docker images updated
   - Apply security patches promptly
   - Monitor security advisories

### Monitoring & Alerting

1. **Security Metrics**:
   - Monitor failed authentication attempts
   - Track unusual network traffic
   - Alert on security policy violations

2. **Log Analysis**:
   - Implement centralized logging
   - Use log analysis tools
   - Set up automated log monitoring

3. **Backup Verification**:
   - Test restore procedures regularly
   - Verify backup integrity
   - Monitor backup success/failure

## Troubleshooting

### Common Issues

1. **SSL Certificate Errors**:
   ```bash
   # Regenerate certificates
   cd src/security/nginx
   ./generate-ssl.sh
   ```

2. **Permission Issues**:
   ```bash
   # Fix permissions
   chmod 600 src/security/secrets/*.txt
   chmod 600 src/security/nginx/ssl/*.key
   ```

3. **Container Start Issues**:
   ```bash
   # Check logs
   docker logs n8n_nginx
   docker logs n8n_postgres
   
   # Validate configuration
   docker run --rm -v "$(pwd)/src/security/nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro" nginx:alpine nginx -t
   ```

### Security Incident Response

1. **Suspected Breach**:
   - Stop all containers immediately
   - Preserve logs and evidence
   - Change all credentials
   - Review access logs

2. **Recovery Procedures**:
   - Restore from known good backup
   - Update all security configurations
   - Strengthen monitoring
   - Implement additional security measures

## Compliance Considerations

### Data Protection

- Encryption at rest and in transit
- Secure credential management
- Access logging and monitoring
- Data backup and retention policies

### Security Standards

- Follows OWASP security guidelines
- Implements defense in depth
- Regular security assessments
- Incident response procedures

---

**Note**: This security implementation provides a strong foundation for production deployment. Additional security measures may be required based on specific organizational requirements and compliance standards.
