# CHANGELOG

## Previous entries (newest on top)

**2025-07-14 - AI Assistant**
feat: implement comprehensive security hardening for n8n Docker stack
- Add complete security stack with nginx reverse proxy and SSL/TLS termination
- Implement Docker secrets management for secure credential storage
- Configure network isolation with segmented Docker networks (frontend, backend, database)
- Add fail2ban intrusion prevention system with nginx integration
- Create automated SSL certificate generation with self-signed certificates for development
- Implement comprehensive security headers (HSTS, CSP, X-Frame-Options, etc.)
- Add rate limiting for authentication and API endpoints
- Configure automated backup system with PostgreSQL, n8n data, and configuration backups
- Create disaster recovery procedures with automated restore scripts
- Add backup integrity verification and automated cleanup
- Implement security monitoring with nginx access/error logs
- Create security-enhanced Docker Compose configuration with read-only containers
- Add comprehensive security documentation and setup procedures
- Update architecture documentation with security components integration
- Git commit ID: [automated commit pending]

**2025-07-12 - AI Assistant**
feat: implement comprehensive monitoring stack for n8n Docker stack
- Add complete observability solution with Prometheus, Grafana, and AlertManager
- Configure Prometheus metrics collection for all services (n8n, PostgreSQL, Ollama, system)
- Create pre-configured Grafana dashboards for n8n stack overview and system monitoring
- Implement AlertManager with intelligent alert routing and notification system
- Add Node Exporter for system metrics (CPU, memory, disk, network)
- Add cAdvisor for container metrics and resource monitoring
- Add PostgreSQL Exporter for database performance metrics
- Configure automated dashboard provisioning and data source setup
- Create comprehensive alert rules for service health, resource usage, and database performance
- Integrate monitoring network with existing n8n Docker stack
- Add automated startup script with health checks and service verification
- Create detailed documentation with configuration and troubleshooting guides
- Update n8n docker-compose configuration for monitoring network integration

**2025-06-24 - Wikus Bergh**
feat: implement smart workflow import with duplicate detection
- Add custom Dockerfile extending n8n base image with jq for JSON parsing
- Update docker-compose to use custom build instead of official image
- Rewrite import script to check existing workflows before importing
- Add duplicate detection to prevent re-importing existing workflows
- Support both JSON and table format parsing from n8n list command
- Add sample test workflow for validation

