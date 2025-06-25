# n8n Docker Stack

A complete Docker Compose setup for running n8n with PostgreSQL database.

## Features

- **n8n**: Latest version with persistent data storage
- **PostgreSQL**: Dedicated database for n8n data
- **Volume Mounts**: Persistent storage for workflows, credentials, and data
- **Health Checks**: Ensures database is ready before starting n8n
- **Environment Variables**: Configurable setup
- **Automatic Workflow Import**: Pre-configured workflows from `./workflows` folder are automatically imported on startup

## Quick Start

1. **Clone and navigate to the repository:**
   ```bash
   git clone <your-repo-url>
   cd n8n_docker_stack
   ```

2. **Create environment file (optional):**
   ```bash
   cp .env.example .env
   # Edit .env with your preferred settings
   ```

3. **Start the stack:**
   ```bash
   docker-compose up -d
   ```

4. **Access n8n:**
   - Open your browser and go to `http://localhost:5678`
   - Default credentials: `admin` / `admin_password`
   - **⚠️ Change these credentials in production!**

## Configuration

### Environment Variables

Key environment variables you can customize:

- `N8N_BASIC_AUTH_USER`: Username for basic authentication
- `N8N_BASIC_AUTH_PASSWORD`: Password for basic authentication
- `POSTGRES_PASSWORD`: Database password
- `N8N_HOST`: Hostname for n8n (change for production)
- `WEBHOOK_URL`: Base URL for webhooks

### Volumes

The setup includes several mounted volumes:

- `n8n_data`: Main n8n data directory
- `./local-files`: Local files directory (mapped to `/files` in container)
- `./workflows`: Workflow JSON files (automatically imported on startup)
- `postgres_data`: PostgreSQL data

### Automatic Workflow Import

Any `.json` workflow files placed in the `./workflows` directory will be automatically imported into n8n when the containers start. This includes:

- **Existing workflows**: The `mcp_example.json` and `hello-world.json` are imported automatically
- **New workflows**: Simply add new `.json` workflow files to the `./workflows` folder
- **Import process**: A dedicated `workflow-importer` container runs before n8n starts and imports all workflows
- **Import status**: Check the container logs to see which workflows were successfully imported

## Commands

```bash
# Start the stack
docker-compose up -d

# View logs
docker-compose logs -f n8n
docker-compose logs -f postgres

# Check container status
docker-compose ps

# Stop the stack
docker-compose down

# Stop and remove volumes (⚠️ This will delete all data!)
docker-compose down -v

# Restart n8n only
docker-compose restart n8n

# Test if n8n is accessible
curl -I http://localhost:5678

# View workflow import logs
docker-compose logs workflow-importer
```

## Adding New Workflows

To add pre-configured workflows to your n8n instance:

1. **Export from existing n8n**: Export workflows as JSON from any n8n instance
2. **Add to workflows folder**: Place the `.json` files in the `./workflows` directory
3. **Restart containers**: Run `docker-compose down && docker-compose up -d`
4. **Check import logs**: View the import process with `docker-compose logs workflow-importer`

**Example workflow structure:**
```
./workflows/
├── hello-world.json          # Simple example workflow
├── mcp_example.json          # Complex MCP workflow
└── your-custom-workflow.json # Your workflow here
```

**Note**: Workflows are imported with their original IDs, so duplicate imports are handled gracefully.

## Troubleshooting

### Common Issues

1. **"command n8n not found" error**:
   - This was fixed by using the official Docker registry image `docker.n8n.io/n8nio/n8n`
   - Make sure you don't have a custom `command` in the docker-compose.yml

2. **Database connection issues**:
   - Check if PostgreSQL is healthy: `docker-compose ps`
   - View PostgreSQL logs: `docker-compose logs postgres`

3. **Permission warnings**:
   - The warning about file permissions is normal and can be ignored
   - To fix it, add `N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true` to environment variables

4. **Port already in use**:
   - Change the port mapping in docker-compose.yml from `5678:5678` to `8080:5678`
   - Then access n8n at `http://localhost:8080`

5. **Workflow import issues**:
   - Check import logs: `docker-compose logs workflow-importer`
   - Ensure JSON files are valid n8n workflow exports
   - Workflows with missing credentials will import but may need credential setup
   - Re-run import: `docker-compose up workflow-importer --force-recreate`

## Security Notes

- Change default passwords before production use
- Consider using environment files for sensitive data
- Set up proper firewall rules if exposing to the internet
- Use HTTPS in production (consider adding a reverse proxy like Traefik or nginx)

## Backup

To backup your n8n data:

```bash
# Backup workflows and credentials
tar -czf n8n-backup-$(date +%Y%m%d).tar.gz workflows/ credentials/

# Backup database
docker-compose exec postgres pg_dump -U n8n n8n > n8n-db-backup-$(date +%Y%m%d).sql
```


## Env Vars used

### for n8n:
#### Database configuration
- DB_TYPE
- DB_POSTGRESDB_HOST
- DB_POSTGRESDB_PORT
- DB_POSTGRESDB_DATABASE
- DB_POSTGRESDB_USER
- DB_POSTGRESDB_PASSWORD

#### n8n configuration
- N8N_HOST
- N8N_PORT
- N8N_PROTOCOL
- WEBHOOK_URL

#### Security
- N8N_BASIC_AUTH_ACTIVE
- N8N_BASIC_AUTH_USER
- N8N_BASIC_AUTH_PASSWORD

#### Execution settings
- EXECUTIONS_PROCESS
- EXECUTIONS_DATA_SAVE_ON_ERROR
- EXECUTIONS_DATA_SAVE_ON_SUCCESS
- EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS

#### Timezone
- GENERIC_TIMEZONE
- TZ

#### Production environment
- NODE_ENV

#### Custom nodes
- N8N_COMMUNITY_PACKAGES_ENABLED
- N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE

### for postgres:
- POSTGRES_DB
- POSTGRES_USER
- POSTGRES_PASSWORD