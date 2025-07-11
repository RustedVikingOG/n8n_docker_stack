# n8n Docker Stack Setup Guide

This document provides a comprehensive setup guide for the n8n Docker Stack, ensuring all required configuration files are properly created and configured.

## Prerequisites

Before starting the setup, ensure you have the following installed:

- Docker Engine 20.10+ and Docker Compose V2
- Git for repository cloning
- 4GB+ available RAM for containers
- Ports 5678 (n8n) and 11434 (Ollama) available
- Basic understanding of n8n workflow automation concepts

## Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd n8n_docker_stack
```

### 2. Navigate to the n8n Source Directory

```bash
cd src/n8n/src
```

### 3. Create Required Environment Files

The system requires two environment files that must be created from the provided templates:

#### Create n8n Environment File

```bash
cp .n8n.env.template .n8n.env
```

Edit `.n8n.env` and customize the following critical settings:

- `N8N_BASIC_AUTH_USER`: Change from default 'admin'
- `N8N_BASIC_AUTH_PASSWORD`: Change from default 'admin_password'
- `DB_POSTGRESDB_PASSWORD`: Must match PostgreSQL password
- `N8N_ENCRYPTION_KEY`: Generate a secure encryption key
- `N8N_HOST`: Set to your domain for production

#### Create PostgreSQL Environment File

```bash
cp .postgresql.env.template .postgresql.env
```

Edit `.postgresql.env` and customize:

- `POSTGRES_PASSWORD`: Must match `DB_POSTGRESDB_PASSWORD` in .n8n.env
- `POSTGRES_USER`: Should match `DB_POSTGRESDB_USER` in .n8n.env (default: n8n)
- `POSTGRES_DB`: Should match `DB_POSTGRESDB_DATABASE` in .n8n.env (default: n8n)

### 4. Security Configuration

**⚠️ IMPORTANT SECURITY NOTES:**

1. **Change Default Credentials**: Never use default passwords in production
2. **Generate Encryption Key**: Use a strong, unique encryption key
3. **Secure Environment Files**: Add `.n8n.env` and `.postgresql.env` to `.gitignore`
4. **Network Security**: Configure firewall rules for production deployment

### 5. Start the Stack

```bash
# Build and start all services
docker-compose up -d

# Verify services are running
docker-compose ps

# Check logs for any issues
docker-compose logs -f
```

### 6. Verify Installation

1. **Check n8n Web Interface**: Open http://localhost:5678
2. **Login**: Use credentials from `.n8n.env`
3. **Verify Workflows**: Check that pre-configured workflows are imported
4. **Test Ollama**: Verify AI service is running on port 11434

### 7. Post-Installation Steps

#### Check Workflow Import Status

```bash
# View workflow import logs
docker-compose logs workflow-importer

# List imported workflows
docker-compose exec n8n n8n list:workflow
```

#### Verify Database Connection

```bash
# Test database connectivity
docker-compose exec postgres psql -U n8n -d n8n -c "\dt"
```

#### Test Ollama AI Service

```bash
# Check Ollama status
curl http://localhost:11434/api/tags
```

## Configuration Details

### Environment File Locations

- **n8n Configuration**: `src/n8n/src/.n8n.env`
- **PostgreSQL Configuration**: `src/n8n/src/.postgresql.env`
- **Templates**: `src/n8n/src/.n8n.env.template` and `src/n8n/src/.postgresql.env.template`

### Key Configuration Options

#### n8n Settings

| Variable | Description | Default | Production Recommendation |
|----------|-------------|---------|---------------------------|
| `N8N_BASIC_AUTH_USER` | Admin username | admin | Change to unique username |
| `N8N_BASIC_AUTH_PASSWORD` | Admin password | admin_password | Use strong password |
| `N8N_HOST` | n8n hostname | localhost | Set to your domain |
| `N8N_ENCRYPTION_KEY` | Data encryption key | your-encryption-key-here | Generate secure key |
| `DB_POSTGRESDB_PASSWORD` | Database password | n8n_password | Use strong password |

#### PostgreSQL Settings

| Variable | Description | Default | Notes |
|----------|-------------|---------|-------|
| `POSTGRES_PASSWORD` | Database password | n8n_password | Must match n8n config |
| `POSTGRES_USER` | Database user | n8n | Should match n8n config |
| `POSTGRES_DB` | Database name | n8n | Should match n8n config |

### Volume Mounts

The system uses several volume mounts for data persistence:

- **n8n_data**: Persistent n8n application data
- **postgres_data**: PostgreSQL database storage
- **ollama-data**: Ollama AI model storage
- **./localfiles**: Host directory mounted to `/files` in n8n container
- **./workflows**: Workflow JSON files for automatic import

## Troubleshooting

### Common Issues

1. **Environment Files Missing**: Ensure `.n8n.env` and `.postgresql.env` exist
2. **Password Mismatch**: Verify database passwords match between files
3. **Port Conflicts**: Check that ports 5678 and 11434 are available
4. **Permission Issues**: Ensure Docker has proper volume permissions

### Debugging Commands

```bash
# Check service status
docker-compose ps

# View all logs
docker-compose logs

# Check specific service logs
docker-compose logs n8n
docker-compose logs postgres
docker-compose logs ollama

# Restart specific service
docker-compose restart n8n

# Rebuild and restart
docker-compose down && docker-compose up -d --build
```

## Next Steps

After successful setup:

1. **Configure Workflows**: Customize the imported workflows for your needs
2. **Set Up Credentials**: Configure API credentials for external services
3. **Enable Monitoring**: Set up logging and monitoring for production
4. **Backup Strategy**: Implement regular backups of PostgreSQL data
5. **Security Hardening**: Review and implement additional security measures

For detailed information about the system architecture and use cases, refer to:
- [Architecture Documentation](./architecture.md)
- [Use Cases Documentation](./use_cases.md)
- [Collaboration Guide](../1.COLLABORATION.md)
