#!/bin/bash

# Start Monitoring Stack for n8n Docker Stack
# This script starts the complete monitoring infrastructure

set -e

echo "🚀 Starting n8n Docker Stack Monitoring..."

# Check if n8n stack is running
echo "📋 Checking if n8n stack is running..."
if ! docker network ls | grep -q "n8n_src_default"; then
    echo "❌ n8n stack network not found. Please start the n8n stack first:"
    echo "   cd ../n8n/src && docker-compose -f docker-compose.n8n.yml up -d"
    exit 1
fi

# Check if required directories exist
echo "📁 Checking monitoring configuration..."
if [ ! -f "prometheus/prometheus.yml" ]; then
    echo "❌ Prometheus configuration not found!"
    exit 1
fi

if [ ! -f "grafana/provisioning/datasources/prometheus.yml" ]; then
    echo "❌ Grafana datasource configuration not found!"
    exit 1
fi

# Start monitoring stack
echo "🔧 Starting monitoring services..."
docker-compose -f docker-compose.monitoring.yml up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check service health
echo "🏥 Checking service health..."

# Check Prometheus
if curl -s http://localhost:9090/-/healthy > /dev/null; then
    echo "✅ Prometheus is healthy"
else
    echo "⚠️  Prometheus health check failed"
fi

# Check Grafana
if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ Grafana is healthy"
else
    echo "⚠️  Grafana health check failed"
fi

# Check AlertManager
if curl -s http://localhost:9093/-/healthy > /dev/null; then
    echo "✅ AlertManager is healthy"
else
    echo "⚠️  AlertManager health check failed"
fi

# Display access information
echo ""
echo "🎉 Monitoring stack started successfully!"
echo ""
echo "📊 Access Points:"
echo "   Grafana:      http://localhost:3000 (admin/admin_password)"
echo "   Prometheus:   http://localhost:9090"
echo "   AlertManager: http://localhost:9093"
echo "   Node Exporter: http://localhost:9100"
echo "   cAdvisor:     http://localhost:8080"
echo ""
echo "📈 Available Dashboards:"
echo "   - n8n Stack Overview"
echo "   - System Overview"
echo ""
echo "🔔 Alerts are configured for:"
echo "   - Service health monitoring"
echo "   - Resource usage thresholds"
echo "   - Database performance"
echo ""
echo "📚 For more information, see README.md"
