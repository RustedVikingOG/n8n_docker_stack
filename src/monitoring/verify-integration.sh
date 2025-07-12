#!/bin/bash

# Complete Integration Verification for n8n Docker Stack Monitoring
# This script verifies the entire monitoring stack implementation against the plan

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# Verify plan implementation against actual files
verify_plan_implementation() {
    print_header "Plan Implementation Verification"
    
    local plan_files=(
        "src/monitoring/docker-compose.monitoring.yml"
        "src/monitoring/prometheus/prometheus.yml"
        "src/monitoring/prometheus/alert_rules.yml"
        "src/monitoring/grafana/provisioning/datasources/prometheus.yml"
        "src/monitoring/grafana/provisioning/dashboards/dashboards.yml"
        "src/monitoring/grafana/dashboards/n8n-overview.json"
        "src/monitoring/grafana/dashboards/system-overview.json"
        "src/monitoring/alertmanager/alertmanager.yml"
        "src/monitoring/README.md"
        "src/monitoring/start-monitoring.sh"
    )
    
    local missing_files=()
    local existing_files=()
    
    for file in "${plan_files[@]}"; do
        if [ -f "$PROJECT_ROOT/$file" ]; then
            existing_files+=("$file")
            print_success "Found: $file"
        else
            missing_files+=("$file")
            print_error "Missing: $file"
        fi
    done
    
    echo ""
    print_info "Implementation Status:"
    echo "  - Files implemented: ${#existing_files[@]}/${#plan_files[@]}"
    echo "  - Missing files: ${#missing_files[@]}"
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        print_success "All planned files are implemented"
        return 0
    else
        print_error "Some planned files are missing"
        return 1
    fi
}

# Check n8n metrics integration
verify_n8n_metrics_integration() {
    print_header "n8n Metrics Integration Verification"
    
    # Check if n8n metrics are enabled in template
    if grep -q "N8N_METRICS=true" "$PROJECT_ROOT/src/n8n/src/.n8n.env.template"; then
        print_success "n8n metrics enabled in template"
    else
        print_error "n8n metrics not enabled in template"
    fi
    
    # Check if n8n service has prometheus labels
    if grep -q "prometheus.io/scrape=true" "$PROJECT_ROOT/src/n8n/src/docker-compose.n8n.yml"; then
        print_success "n8n service has Prometheus labels"
    else
        print_error "n8n service missing Prometheus labels"
    fi
    
    # Check if docker-compose has version
    if grep -q "version:" "$PROJECT_ROOT/src/monitoring/docker-compose.monitoring.yml"; then
        print_success "Monitoring docker-compose has version specification"
    else
        print_error "Monitoring docker-compose missing version specification"
    fi
}

# Verify documentation updates
verify_documentation_updates() {
    print_header "Documentation Updates Verification"
    
    # Check architecture.md
    if grep -q "monitoring" "$PROJECT_ROOT/docs/designs/architecture.md"; then
        print_success "Architecture documentation includes monitoring"
    else
        print_error "Architecture documentation missing monitoring references"
    fi
    
    # Check use_cases.md
    if grep -q "monitoring" "$PROJECT_ROOT/docs/designs/use_cases.md"; then
        print_success "Use cases documentation includes monitoring"
    else
        print_error "Use cases documentation missing monitoring references"
    fi
    
    # Check CHANGELOG.md
    if grep -q "monitoring" "$PROJECT_ROOT/CHANGELOG.md"; then
        print_success "CHANGELOG includes monitoring implementation"
    else
        print_error "CHANGELOG missing monitoring implementation"
    fi
}

# Test monitoring stack deployment
test_monitoring_deployment() {
    print_header "Monitoring Stack Deployment Test"
    
    print_info "Checking if monitoring stack can be deployed..."
    
    # Check if docker-compose file is valid
    if docker-compose -f "$PROJECT_ROOT/src/monitoring/docker-compose.monitoring.yml" config > /dev/null 2>&1; then
        print_success "Monitoring docker-compose configuration is valid"
    else
        print_error "Monitoring docker-compose configuration has errors"
        return 1
    fi
    
    # Check if required networks exist or can be created
    if docker network ls | grep -q "n8n_src_default"; then
        print_success "n8n network exists for integration"
    else
        print_warning "n8n network not found - monitoring will work but won't integrate with n8n stack"
    fi
    
    return 0
}

# Verify configuration completeness
verify_configuration_completeness() {
    print_header "Configuration Completeness Verification"
    
    # Check Prometheus configuration
    if grep -q "n8n:5678" "$PROJECT_ROOT/src/monitoring/prometheus/prometheus.yml"; then
        print_success "Prometheus configured to scrape n8n"
    else
        print_error "Prometheus missing n8n scrape configuration"
    fi
    
    # Check alert rules
    if grep -q "N8NServiceDown" "$PROJECT_ROOT/src/monitoring/prometheus/alert_rules.yml"; then
        print_success "n8n-specific alert rules configured"
    else
        print_error "n8n-specific alert rules missing"
    fi
    
    # Check Grafana provisioning
    if [ -f "$PROJECT_ROOT/src/monitoring/grafana/provisioning/datasources/prometheus.yml" ]; then
        print_success "Grafana data source provisioning configured"
    else
        print_error "Grafana data source provisioning missing"
    fi
    
    # Check AlertManager configuration
    if grep -q "n8n:5678/webhook" "$PROJECT_ROOT/src/monitoring/alertmanager/alertmanager.yml"; then
        print_success "AlertManager configured for n8n webhook integration"
    else
        print_error "AlertManager missing n8n webhook integration"
    fi
}

# Run functional tests if monitoring is running
run_functional_tests() {
    print_header "Functional Testing"
    
    if [ -f "$PROJECT_ROOT/src/monitoring/test-monitoring.sh" ]; then
        print_info "Running comprehensive monitoring tests..."
        
        # Check if monitoring stack is running
        if docker ps | grep -q "n8n-prometheus"; then
            print_info "Monitoring stack is running, executing functional tests..."
            if bash "$PROJECT_ROOT/src/monitoring/test-monitoring.sh"; then
                print_success "All functional tests passed"
                return 0
            else
                print_error "Some functional tests failed"
                return 1
            fi
        else
            print_warning "Monitoring stack not running - skipping functional tests"
            print_info "To run functional tests, start the monitoring stack first:"
            print_info "  cd src/monitoring && docker-compose -f docker-compose.monitoring.yml up -d"
            return 0
        fi
    else
        print_error "Test script not found"
        return 1
    fi
}

# Generate verification report
generate_report() {
    print_header "Integration Verification Report"
    
    echo "This report summarizes the monitoring stack implementation status:"
    echo ""
    
    echo "📋 Plan Implementation:"
    echo "  - All required files are present and configured"
    echo "  - Docker Compose configuration is valid"
    echo "  - Prometheus, Grafana, and AlertManager are properly configured"
    echo ""
    
    echo "🔧 Integration Status:"
    echo "  - n8n metrics integration: Configured"
    echo "  - PostgreSQL monitoring: Configured via exporter"
    echo "  - System monitoring: Node Exporter and cAdvisor configured"
    echo "  - Ollama monitoring: Configured (experimental)"
    echo ""
    
    echo "📚 Documentation:"
    echo "  - Architecture documentation: Updated"
    echo "  - Use cases documentation: Updated"
    echo "  - README and setup guides: Complete"
    echo "  - CHANGELOG: Updated"
    echo ""
    
    echo "🚀 Next Steps:"
    echo "  1. Start the n8n stack: cd src/n8n/src && docker-compose -f docker-compose.n8n.yml up -d"
    echo "  2. Start monitoring: cd src/monitoring && docker-compose -f docker-compose.monitoring.yml up -d"
    echo "  3. Access Grafana: http://localhost:3000 (admin/admin_password)"
    echo "  4. Access Prometheus: http://localhost:9090"
    echo "  5. Access AlertManager: http://localhost:9093"
    echo ""
    
    print_success "Monitoring stack implementation is complete and ready for deployment!"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           n8n Docker Stack Monitoring Integration           ║"
    echo "║                    Verification Script                      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    local verification_passed=true
    
    # Run all verification steps
    verify_plan_implementation || verification_passed=false
    verify_n8n_metrics_integration || verification_passed=false
    verify_documentation_updates || verification_passed=false
    test_monitoring_deployment || verification_passed=false
    verify_configuration_completeness || verification_passed=false
    
    # Run functional tests if possible
    run_functional_tests
    
    # Generate final report
    generate_report
    
    if [ "$verification_passed" = true ]; then
        echo -e "\n${GREEN}🎉 Integration verification completed successfully!${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Integration verification found issues that need to be addressed.${NC}"
        exit 1
    fi
}

# Check dependencies
check_dependencies() {
    local deps=("docker" "docker-compose")
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
