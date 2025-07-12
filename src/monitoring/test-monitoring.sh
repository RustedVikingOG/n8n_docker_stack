#!/bin/bash

# Integration Test Script for n8n Docker Stack Monitoring
# This script verifies that all monitoring components are working correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
PROMETHEUS_URL="http://localhost:9090"
GRAFANA_URL="http://localhost:3000"
ALERTMANAGER_URL="http://localhost:9093"
NODE_EXPORTER_URL="http://localhost:9100"
CADVISOR_URL="http://localhost:8080"
POSTGRES_EXPORTER_URL="http://localhost:9187"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Helper functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_test() {
    echo -e "${YELLOW}Testing: $1${NC}"
    ((TOTAL_TESTS++))
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((TESTS_PASSED++))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((TESTS_FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Test if service is responding
test_service_health() {
    local service_name=$1
    local url=$2
    local expected_status=${3:-200}
    
    print_test "$service_name health check"
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "$expected_status"; then
        print_success "$service_name is healthy"
        return 0
    else
        print_error "$service_name is not responding"
        return 1
    fi
}

# Test Prometheus targets
test_prometheus_targets() {
    print_test "Prometheus targets status"
    
    local targets_response=$(curl -s "$PROMETHEUS_URL/api/v1/targets")
    local active_targets=$(echo "$targets_response" | jq -r '.data.activeTargets[] | select(.health == "up") | .labels.job' 2>/dev/null | wc -l)
    
    if [ "$active_targets" -gt 0 ]; then
        print_success "Prometheus has $active_targets active targets"
        
        # List active targets
        echo "Active targets:"
        echo "$targets_response" | jq -r '.data.activeTargets[] | select(.health == "up") | "  - " + .labels.job + " (" + .labels.instance + ")"' 2>/dev/null || echo "  Could not parse target details"
        
        return 0
    else
        print_error "No active Prometheus targets found"
        return 1
    fi
}

# Test Grafana data sources
test_grafana_datasources() {
    print_test "Grafana data sources"
    
    # Test with basic auth (admin:admin_password)
    local datasources_response=$(curl -s -u admin:admin_password "$GRAFANA_URL/api/datasources")
    local prometheus_ds=$(echo "$datasources_response" | jq -r '.[] | select(.type == "prometheus") | .name' 2>/dev/null)
    
    if [ -n "$prometheus_ds" ]; then
        print_success "Grafana Prometheus data source configured: $prometheus_ds"
        return 0
    else
        print_error "Grafana Prometheus data source not found"
        return 1
    fi
}

# Test AlertManager configuration
test_alertmanager_config() {
    print_test "AlertManager configuration"
    
    local config_response=$(curl -s "$ALERTMANAGER_URL/api/v1/status")
    local config_status=$(echo "$config_response" | jq -r '.status' 2>/dev/null)
    
    if [ "$config_status" = "success" ]; then
        print_success "AlertManager configuration is valid"
        return 0
    else
        print_error "AlertManager configuration issue"
        return 1
    fi
}

# Test metrics collection
test_metrics_collection() {
    print_test "Metrics collection from exporters"
    
    local metrics_found=0
    
    # Test Node Exporter metrics
    if curl -s "$NODE_EXPORTER_URL/metrics" | grep -q "node_cpu_seconds_total"; then
        print_success "Node Exporter metrics available"
        ((metrics_found++))
    else
        print_error "Node Exporter metrics not found"
    fi
    
    # Test cAdvisor metrics
    if curl -s "$CADVISOR_URL/metrics" | grep -q "container_cpu_usage_seconds_total"; then
        print_success "cAdvisor metrics available"
        ((metrics_found++))
    else
        print_error "cAdvisor metrics not found"
    fi
    
    # Test PostgreSQL Exporter metrics
    if curl -s "$POSTGRES_EXPORTER_URL/metrics" | grep -q "pg_up"; then
        print_success "PostgreSQL Exporter metrics available"
        ((metrics_found++))
    else
        print_error "PostgreSQL Exporter metrics not found"
    fi
    
    if [ "$metrics_found" -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

# Test Docker containers
test_docker_containers() {
    print_test "Monitoring Docker containers status"
    
    local containers=(
        "n8n-prometheus"
        "n8n-grafana"
        "n8n-alertmanager"
        "n8n-node-exporter"
        "n8n-cadvisor"
        "n8n-postgres-exporter"
    )
    
    local running_containers=0
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$container"; then
            print_success "$container is running"
            ((running_containers++))
        else
            print_error "$container is not running"
        fi
    done
    
    if [ "$running_containers" -eq "${#containers[@]}" ]; then
        return 0
    else
        return 1
    fi
}

# Test network connectivity
test_network_connectivity() {
    print_test "Network connectivity between services"
    
    # Test if monitoring network exists
    if docker network ls | grep -q "monitoring"; then
        print_success "Monitoring network exists"
    else
        print_error "Monitoring network not found"
        return 1
    fi
    
    # Test if n8n_src_default network exists
    if docker network ls | grep -q "n8n_src_default"; then
        print_success "n8n default network exists"
    else
        print_warning "n8n default network not found (n8n stack may not be running)"
    fi
    
    return 0
}

# Test alert rules
test_alert_rules() {
    print_test "Prometheus alert rules"
    
    local rules_response=$(curl -s "$PROMETHEUS_URL/api/v1/rules")
    local rules_count=$(echo "$rules_response" | jq -r '.data.groups | length' 2>/dev/null)
    
    if [ "$rules_count" -gt 0 ]; then
        print_success "Prometheus has $rules_count alert rule groups loaded"
        return 0
    else
        print_error "No alert rules found in Prometheus"
        return 1
    fi
}

# Main test execution
main() {
    print_header "n8n Docker Stack Monitoring Integration Tests"
    
    echo "Starting comprehensive monitoring stack verification..."
    echo "This will test all monitoring components and their integration."
    echo ""
    
    # Check if monitoring stack is running
    print_header "Docker Container Status"
    test_docker_containers
    
    # Test network setup
    print_header "Network Configuration"
    test_network_connectivity
    
    # Test service health
    print_header "Service Health Checks"
    test_service_health "Prometheus" "$PROMETHEUS_URL/-/healthy"
    test_service_health "Grafana" "$GRAFANA_URL/api/health"
    test_service_health "AlertManager" "$ALERTMANAGER_URL/-/healthy"
    test_service_health "Node Exporter" "$NODE_EXPORTER_URL/metrics" 200
    test_service_health "cAdvisor" "$CADVISOR_URL/metrics" 200
    test_service_health "PostgreSQL Exporter" "$POSTGRES_EXPORTER_URL/metrics" 200
    
    # Test monitoring functionality
    print_header "Monitoring Functionality"
    test_prometheus_targets
    test_grafana_datasources
    test_alertmanager_config
    test_alert_rules
    test_metrics_collection
    
    # Print summary
    print_header "Test Summary"
    echo -e "Total tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    
    if [ "$TESTS_FAILED" -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All monitoring tests passed! The monitoring stack is working correctly.${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Some tests failed. Please check the monitoring configuration.${NC}"
        exit 1
    fi
}

# Check dependencies
check_dependencies() {
    local deps=("curl" "jq" "docker")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}Missing dependencies: ${missing_deps[*]}${NC}"
        echo "Please install the missing dependencies and try again."
        exit 1
    fi
}

# Script entry point
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    check_dependencies
    main "$@"
fi
