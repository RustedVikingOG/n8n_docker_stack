# n8n Docker Stack Monitoring

A comprehensive monitoring solution for the n8n Docker Stack using Prometheus, Grafana, and AlertManager.

## Overview

This monitoring stack provides:

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization dashboards and alerting
- **AlertManager**: Alert routing and notifications
- **Node Exporter**: System metrics collection
- **cAdvisor**: Container metrics collection
- **PostgreSQL Exporter**: Database metrics collection

## Quick Start

### Prerequisites

1. Ensure the main n8n stack is running:
   ```bash
   cd ../n8n/src
   docker-compose up -d
   ```

2. Start the monitoring stack:
   ```bash
   cd monitoring
   docker-compose -f docker-compose.monitoring.yml up -d
   ```

### Access Points

- **Grafana**: http://localhost:3000
  - **Username**: `admin`
  - **Password**: `admin_password`
  - **Note**: This is a local development instance, not connected to Grafana Cloud
- **Prometheus**: http://localhost:9090
- **AlertManager**: http://localhost:9093
- **Node Exporter**: http://localhost:9100
- **cAdvisor**: http://localhost:8080

## Configuration

### Environment Variables

The monitoring stack uses the following default configurations:

- **Grafana Admin**: admin/admin_password
- **PostgreSQL Connection**: Configured to connect to the n8n PostgreSQL instance
- **Data Retention**: Prometheus retains data for 30 days

### Customization

1. **Prometheus Configuration**: Edit `prometheus/prometheus.yml`
2. **Alert Rules**: Modify `prometheus/alert_rules.yml`
3. **AlertManager**: Configure `alertmanager/alertmanager.yml`
4. **Grafana Dashboards**: Add JSON files to `grafana/dashboards/`

## Monitoring Targets

### Automatically Monitored Services

- **n8n Service**: Application health and performance
- **PostgreSQL**: Database metrics via postgres-exporter
- **System Resources**: CPU, memory, disk via node-exporter
- **Containers**: Docker container metrics via cAdvisor
- **Ollama AI**: AI service health (if metrics available)

### Available Metrics

#### System Metrics
- CPU usage and load
- Memory utilization
- Disk space and I/O
- Network traffic

#### Container Metrics
- Container resource usage
- Container restart counts
- Container health status

#### Database Metrics
- Connection counts
- Query performance
- Database size and growth
- Lock statistics

## Alerting

### Pre-configured Alerts

- **Service Down**: Any monitored service becomes unavailable
- **High CPU Usage**: CPU usage > 80% for 5 minutes
- **High Memory Usage**: Memory usage > 85% for 5 minutes
- **Low Disk Space**: Disk usage > 90% on any filesystem
- **Database Issues**: Connection limits, slow queries
- **n8n Service Down**: n8n automation platform unavailable
- **PostgreSQL Down**: Database service unavailable

**Alert Template Variables**: All alerts include contextual information such as:
- `{{ $labels.instance }}`: The specific instance/service affected
- `{{ $labels.mountpoint }}`: Filesystem mount point (for disk alerts)
- `{{ $value }}`: Current metric value that triggered the alert

### Alert Channels

Configure notification channels in `alertmanager/alertmanager.yml`:

- **Email**: SMTP configuration for email alerts
- **Webhooks**: HTTP endpoints for custom integrations
- **n8n Integration**: Send alerts back to n8n workflows

## Dashboards

### Included Dashboards

1. **n8n Stack Overview**: Service health and status
2. **System Resources**: CPU, memory, disk monitoring
3. **Database Performance**: PostgreSQL metrics
4. **Container Metrics**: Docker container monitoring

### Adding Custom Dashboards

1. Create dashboard in Grafana UI
2. Export as JSON
3. Save to `grafana/dashboards/`
4. Restart Grafana service

## Troubleshooting

### Common Issues

1. **Grafana login issues**:
   - **Default credentials**: admin / admin_password
   - **Your Grafana Cloud account won't work** - this is a local instance
   - **To change credentials**: Edit `.grafana.env` file and restart Grafana
   ```bash
   # Restart Grafana after changing credentials
   docker-compose -f docker-compose.monitoring.yml restart grafana
   ```

2. **Prometheus targets down**:
   ```bash
   # Check service connectivity
   docker-compose -f docker-compose.monitoring.yml logs prometheus
   ```

3. **Grafana dashboard not loading**:
   ```bash
   # Verify data source configuration
   docker-compose -f docker-compose.monitoring.yml logs grafana
   ```

4. **PostgreSQL exporter connection issues**:
   ```bash
   # Check database credentials
   docker-compose -f docker-compose.monitoring.yml logs postgres-exporter
   ```

### Debugging Commands

```bash
# View all monitoring services
docker-compose -f docker-compose.monitoring.yml ps

# Check Prometheus configuration
curl http://localhost:9090/api/v1/status/config

# Test AlertManager configuration
curl http://localhost:9093/api/v1/status

# View Grafana logs
docker-compose -f docker-compose.monitoring.yml logs grafana
```

## Data Persistence

The monitoring stack uses Docker volumes for data persistence:

- `prometheus_data`: Prometheus metrics storage
- `grafana_data`: Grafana dashboards and settings
- `alertmanager_data`: AlertManager configuration and state

## Security Considerations

1. **Change default passwords** in production
2. **Configure HTTPS** for external access
3. **Restrict network access** to monitoring ports
4. **Use secrets management** for sensitive configuration

## Integration with n8n

The monitoring stack can integrate with n8n workflows:

1. **Webhook Alerts**: Send alerts to n8n webhook endpoints
2. **Metrics Collection**: Create n8n workflows that query Prometheus
3. **Automated Responses**: Build workflows that respond to alerts

## Scaling

For larger deployments:

1. **External Prometheus**: Use external Prometheus instance
2. **HA AlertManager**: Deploy AlertManager in HA mode
3. **Remote Storage**: Configure remote storage for metrics
4. **Load Balancing**: Use load balancer for Grafana access

## Maintenance

### Regular Tasks

1. **Monitor disk usage**: Prometheus data grows over time
2. **Update images**: Keep monitoring components updated
3. **Review alerts**: Tune alert thresholds based on experience
4. **Backup dashboards**: Export and backup custom dashboards

### Cleanup

```bash
# Stop monitoring stack
docker-compose -f docker-compose.monitoring.yml down

# Remove volumes (WARNING: This deletes all monitoring data)
docker-compose -f docker-compose.monitoring.yml down -v
```
