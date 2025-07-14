# n8n Docker Stack Architecture

This document contains the architectural design of the n8n Docker Stack solution with the focus on the high level components and how they interact. Use of the names and their appropriate technologies are required.

## Project Structure Overview

**Core project directories**
- src/n8n/src/docker-compose.yml - Multi-service orchestration configuration with PostgreSQL, n8n, Ollama, and workflow-importer services
- src/n8n/src/Dockerfile - Custom n8n image extending official n8n image with jq and zip utilities
- src/n8n/src/scripts/import-workflows.sh - Intelligent workflow import script with duplicate detection
- src/n8n/src/workflows/ - Pre-configured workflow JSON definitions automatically imported on startup
- src/n8n/src/localfiles/ - File operations directory mounted to n8n container with FastAPI example server
- src/security/ - **NEW** Security hardening stack with nginx reverse proxy, SSL/TLS, secrets management, and intrusion prevention
- src/security/docker-compose.security.yml - **NEW** Security-enhanced Docker orchestration with nginx, fail2ban, and network isolation
- src/security/nginx/ - **NEW** Nginx reverse proxy configuration with SSL termination and security headers
- src/security/secrets/ - **NEW** Docker secrets management for secure credential storage
- src/security/fail2ban/ - **NEW** Intrusion prevention system configuration
- src/backup-restore/ - **NEW** Automated backup and disaster recovery system
- src/backup-restore/automated-backups/ - **NEW** Automated backup scripts with integrity verification
- src/backup-restore/restore-scripts/ - **NEW** Comprehensive restore procedures and scripts
- src/monitoring/ - Comprehensive monitoring stack with Prometheus, Grafana, and AlertManager
- src/monitoring/docker-compose.monitoring.yml - Multi-service monitoring orchestration (Prometheus, Grafana, AlertManager, exporters)
- src/monitoring/prometheus/ - Prometheus configuration with alert rules and service discovery
- src/monitoring/grafana/ - Grafana dashboards and provisioning configuration for visualization
- src/monitoring/alertmanager/ - AlertManager configuration for intelligent alert routing and notifications
- docs/designs/ - Architecture and use case documentation following AI template standards
- docs/1.COLLABORATION.md - Comprehensive collaboration guide with setup and debugging instructions

This project provides a complete Docker-based n8n workflow automation platform with PostgreSQL database, automatic workflow import, Ollama AI integration, **comprehensive security hardening with HTTPS/TLS termination, secrets management, network isolation, intrusion prevention, and automated backup systems**, comprehensive monitoring and observability stack with Prometheus/Grafana/AlertManager, and extensive documentation following established AI template standards.

## System Overview Architecture

**Complete System Integration Diagram**

```mermaid
---
title: n8n Docker Stack Complete System Architecture
---
flowchart TD
    A["Docker Compose Orchestration"] --> B["PostgreSQL Database Service"]
    A --> C["Workflow Import Service"]
    A --> D["n8n Automation Platform"]
    A --> E["Ollama AI Service"]
    A --> F["FastAPI Example Server"]
    A --> G["Monitoring Stack"]

    B --> H["Health Check System"]
    H --> I["Service Dependencies"]

    C --> J["Workflow JSON Processing"]
    J --> K["Duplicate Detection Logic"]
    K --> L["n8n CLI Integration"]

    D --> M["Web Interface :5678"]
    D --> N["Workflow Execution Engine"]
    D --> O["API Endpoints"]
    D --> P["File System Operations"]

    E --> Q["AI Model Serving :11434"]
    Q --> R["llama3.2:3b Model"]

    F --> S["Development API :8010"]
    S --> T["HTTP Testing Endpoints"]

    G --> U["Prometheus :9090"]
    G --> V["Grafana :3000"]
    G --> W["AlertManager :9093"]
    G --> X["Node Exporter :9100"]
    G --> Y["cAdvisor :8080"]
    G --> Z["PostgreSQL Exporter :9187"]

    U --> AA["Metrics Collection"]
    AA --> AB["Service Discovery"]
    AB --> AC["Alert Rules Engine"]

    V --> AD["Dashboard Provisioning"]
    AD --> AE["Data Visualization"]
    AE --> AF["User Interface"]

    W --> AG["Alert Routing"]
    AG --> AH["Notification Delivery"]
    AH --> AI["Alert Grouping"]

    H --> C
    H --> D

    K --> D
    O --> T["Local Files Mount"]
    T --> U["Workflow File Operations"]

    M --> P
    M --> R

    V["Persistent Volumes"] --> B
    V --> D
    V --> E

    W["Environment Configuration"] --> B
    W --> D

    X["Host File System"] --> T
    X --> Y["Workflow JSON Files"]
    Y --> C
```

## High-level Component definitions & use

Describes the definitions and use of each component in the design, its technology and the scope of the use of any services.

**System components**

**PostgreSQL Database Service**

A PostgreSQL 15 database service that provides persistent storage for n8n workflows, credentials, execution data, and user configurations. This component serves as the central data repository for the entire n8n automation platform.

**Core Functionality: PostgreSQL Database Service**

- **Data Persistence**: Stores n8n workflows, credentials, execution history, and user settings in a relational database format
- **Health Monitoring**: Implements health checks to ensure database readiness before dependent services start
- **Volume Management**: Uses Docker volumes for persistent data storage across container restarts and updates
- **Connection Management**: Provides secure database connections with configurable credentials and connection parameters

**Architecture Diagram of component: PostgreSQL Database Service**

```mermaid
---
title: PostgreSQL Database Service Architecture
---
flowchart TD
    A["PostgreSQL 15 Container"] --> B["Health Check System"]
    A --> C["Persistent Volume Storage"]
    A --> D["Database Schema"]
    
    B --> E["pg_isready Command"]
    E --> F["Service Ready Signal"]
    
    C --> G["postgres_data Volume"]
    G --> H["Workflow Data"]
    G --> I["Credential Data"]
    G --> J["Execution History"]
    
    D --> K["n8n Database"]
    K --> L["User Tables"]
    K --> M["Workflow Tables"]
    K --> N["Execution Tables"]
    
    F --> O["Dependent Services Start"]
```

**n8n Workflow Automation Platform**

The main n8n service that provides the workflow automation platform with web interface, API endpoints, and workflow execution engine. This component handles all user interactions and workflow processing.

**Core Functionality: n8n Workflow Automation Platform**

- **Web Interface**: Provides browser-based workflow editor and management interface accessible on port 5678
- **Workflow Execution**: Processes and executes automated workflows with support for triggers, actions, and data transformations
- **API Integration**: Offers REST API endpoints for external integrations and programmatic workflow management
- **File Operations**: Supports file processing through mounted volume access to local file system
- **Authentication**: Implements basic authentication with configurable user credentials

**Architecture Diagram of component: n8n Workflow Automation Platform**

```mermaid
---
title: n8n Workflow Automation Platform Architecture
---
flowchart TD
    A["n8n Container"] --> B["Web Interface :5678"]
    A --> C["Workflow Engine"]
    A --> D["API Endpoints"]
    A --> E["File System Access"]
    
    B --> F["Browser Access"]
    F --> G["Workflow Editor"]
    F --> H["Execution Monitor"]
    
    C --> I["Trigger Processing"]
    C --> J["Action Execution"]
    C --> K["Data Transformation"]
    
    D --> L["REST API"]
    L --> M["External Integrations"]
    
    E --> N["Local Files Mount"]
    N --> O["File Operations"]
    
    A --> P["Database Connection"]
    P --> Q["PostgreSQL Service"]
```

**Workflow Import Service**

A specialized one-time service that automatically imports JSON workflow definitions from the workflows directory into the n8n instance during startup. This component ensures pre-configured workflows are available immediately.

**Core Functionality: Workflow Import Service**

- **Automatic Import**: Scans workflows directory and imports all JSON workflow files into n8n instance
- **Duplicate Detection**: Checks existing workflows to prevent duplicate imports and conflicts
- **Startup Coordination**: Runs after database is ready but before main n8n service starts
- **Import Validation**: Validates JSON workflow format and handles import errors gracefully

**Architecture Diagram of component: Workflow Import Service**

```mermaid
---
title: Workflow Import Service Architecture
---
flowchart TD
    A["Workflow Importer Container"] --> B["Import Script"]
    A --> C["Workflow Directory Scan"]
    A --> D["n8n CLI Integration"]
    
    B --> E["import-workflows.sh"]
    E --> F["Duplicate Check Logic"]
    E --> G["Import Execution"]
    
    C --> H["JSON File Discovery"]
    H --> I["Workflow Validation"]
    
    D --> J["n8n list:workflow"]
    D --> K["n8n import:workflow"]
    
    F --> L["Existing ID Check"]
    L --> M["Skip or Import Decision"]
    
    G --> N["Import Status Logging"]
    N --> O["Service Completion"]
```

**Ollama AI Integration Service**

An AI model serving platform that provides local LLM capabilities for AI-powered workflow automation. This component enables n8n workflows to leverage artificial intelligence for text processing, analysis, and generation tasks.

**Core Functionality: Ollama AI Integration Service**

- **AI Model Serving**: Hosts and serves the llama3.2:3b language model for workflow AI operations
- **API Interface**: Provides REST API endpoints on port 11434 for AI model interactions
- **Memory Management**: Implements 4GB memory limits for efficient AI model operations
- **Model Management**: Automatically downloads and initializes AI models on container startup

**Architecture Diagram of component: Ollama AI Integration Service**

```mermaid
---
title: Ollama AI Integration Service Architecture
---
flowchart TD
    A["Ollama Container"] --> B["AI Model Server"]
    A --> C["Model Storage"]
    A --> D["API Interface :11434"]

    B --> E["llama3.2:3b Model"]
    E --> F["Text Processing"]
    E --> G["AI Generation"]

    C --> H["ollama-data Volume"]
    H --> I["Model Files"]
    H --> J["Model Cache"]

    D --> K["REST API Endpoints"]
    K --> L["n8n Workflow Integration"]

    A --> M["Memory Limits"]
    M --> N["4GB Resource Constraint"]

    B --> O["Automatic Model Download"]
    O --> P["Startup Initialization"]
```

**Example FastAPI Server Component**

A sample FastAPI server included in the localfiles/someserver directory that demonstrates how external services can be integrated with n8n workflows. This component serves as a reference implementation for custom API endpoints that can be called from n8n workflows.

**Core Functionality: Example FastAPI Server Component**

- **API Endpoints**: Provides sample REST API endpoints (root "/" and "/items/{id}") for testing n8n HTTP request nodes
- **File System Integration**: Located in localfiles/someserver directory for easy access from n8n container via /files mount
- **Development Reference**: Serves as a template for building custom services that integrate with n8n workflows
- **Containerized Deployment**: Includes Dockerfile with Python 3.12-slim base image for independent deployment
- **FastAPI Framework**: Uses FastAPI with uvicorn server running on port 8010 for high-performance API operations

**Architecture Diagram of component: Example FastAPI Server Component**

```mermaid
---
title: Example FastAPI Server Component Architecture
---
flowchart TD
    A["FastAPI Server Container"] --> B["REST API Endpoints"]
    A --> C["Local File System Mount"]
    A --> D["Python 3.12 Runtime"]

    B --> E["Root Endpoint /"]
    B --> F["Items Endpoint /items/{item_id}"]

    C --> G["src/n8n/src/localfiles/someserver/"]
    G --> H["main.py - FastAPI Application"]
    G --> I["requirements.txt - Dependencies"]
    G --> J["Dockerfile - Container Build"]

    D --> K["uvicorn ASGI Server"]
    K --> L["Port 8010 Exposed"]

    A --> M["n8n Container HTTP Requests"]
    M --> N["/files Mount Integration"]
    N --> O["Workflow File Operations"]

    F --> P["Optional Query Parameters"]
    P --> Q["JSON Response Format"]
```

**Monitoring Stack Architecture**

The comprehensive monitoring and observability platform that provides complete visibility into the n8n Docker stack performance, health, and resource usage. This component ensures operational excellence through metrics collection, visualization, and intelligent alerting.

**Core Functionality: Monitoring Stack Architecture**

- **Metrics Collection**: Prometheus scrapes metrics from all services including n8n, PostgreSQL, system resources, and containers with 30-day retention
- **Visualization Platform**: Grafana provides pre-configured dashboards for n8n overview, system monitoring, and database performance with automatic provisioning
- **Intelligent Alerting**: AlertManager routes alerts based on configurable rules for service health, resource thresholds, and database performance
- **Multi-Service Monitoring**: Comprehensive observability across n8n application, PostgreSQL database, Ollama AI service, system resources, and container metrics
- **Integration Ready**: Webhook support for sending alerts back to n8n workflows and external notification systems

**Architecture Diagram of component: Monitoring Stack Architecture**

```mermaid
---
title: Comprehensive Monitoring Stack Architecture
---
flowchart TD
    A["Monitoring Stack Deployment"] --> B["Prometheus Service :9090"]
    A --> C["Grafana Service :3000"]
    A --> D["AlertManager Service :9093"]
    A --> E["Exporters Collection"]
    
    B --> F["Metrics Storage"]
    B --> G["Scrape Configuration"]
    B --> H["Alert Rules Engine"]
    
    G --> I["n8n Service :5678/metrics"]
    G --> J["PostgreSQL Exporter :9187"]
    G --> K["Node Exporter :9100"]
    G --> L["cAdvisor :8080"]
    G --> M["Ollama Service :11434/metrics"]
    
    C --> N["Dashboard Provisioning"]
    C --> O["Data Source Configuration"]
    C --> P["User Interface"]
    
    N --> Q["n8n Overview Dashboard"]
    N --> R["System Overview Dashboard"]
    N --> S["Database Performance Dashboard"]
    
    D --> T["Alert Routing"]
    D --> U["Notification Channels"]
    D --> V["Alert Grouping"]
    
    U --> W["Email Notifications"]
    U --> X["Webhook Integrations"]
    U --> Y["n8n Workflow Triggers"]
    
    E --> J
    E --> K
    E --> L
    
    H --> D
    F --> C
    
    I --> Z["Application Metrics"]
    J --> AA["Database Metrics"]
    K --> BB["System Metrics"]
    L --> CC["Container Metrics"]
    M --> DD["AI Service Metrics"]
    
    Z --> F
    AA --> F
    BB --> F
    CC --> F
    DD --> F
    
    P --> EE["admin/admin_password"]
    T --> FF["Alert Severity Routing"]
    V --> GG["Alert Deduplication"]
```

**Prometheus Metrics Collection Service**

A time-series database and monitoring system that collects, stores, and processes metrics from all components of the n8n Docker stack. This component serves as the central metrics repository with intelligent scraping and alert rule evaluation.

**Core Functionality: Prometheus Metrics Collection Service**

- **Service Discovery**: Automatically discovers and monitors all configured services including n8n, PostgreSQL, system resources, and containers
- **Metrics Storage**: Stores time-series data with 30-day retention period and efficient compression for optimal performance
- **Alert Processing**: Evaluates alert rules for service health, resource usage thresholds, and database performance metrics
- **API Interface**: Provides REST API endpoints for metrics queries, configuration management, and status monitoring

**Architecture Diagram of component: Prometheus Metrics Collection Service**

```mermaid
---
title: Prometheus Metrics Collection Architecture
---
flowchart TD
    A["Prometheus Container :9090"] --> B["Configuration Management"]
    A --> C["Metrics Storage Engine"]
    A --> D["Scrape Target Manager"]
    A --> E["Alert Rules Processor"]
    
    B --> F["prometheus.yml Configuration"]
    B --> G["alert_rules.yml Rules"]
    
    D --> H["n8n Application Scraping"]
    D --> I["PostgreSQL Exporter Scraping"]
    D --> J["Node Exporter Scraping"]
    D --> K["cAdvisor Scraping"]
    D --> L["Ollama Service Scraping"]
    
    H --> M["Workflow Execution Metrics"]
    H --> N["API Response Times"]
    H --> O["Service Health Status"]
    
    I --> P["Database Connection Metrics"]
    I --> Q["Query Performance Data"]
    I --> R["Database Size Statistics"]
    
    J --> S["CPU Usage Metrics"]
    J --> T["Memory Utilization Data"]
    J --> U["Disk Space Statistics"]
    J --> V["Network Traffic Metrics"]
    
    K --> W["Container Resource Usage"]
    K --> X["Container Health Status"]
    K --> Y["Container Restart Counts"]
    
    L --> Z["AI Model Response Times"]
    L --> AA["AI Service Availability"]
    
    C --> BB["Time Series Database"]
    BB --> CC["30-Day Retention"]
    BB --> DD["Data Compression"]
    
    E --> EE["Service Health Alerts"]
    E --> FF["Resource Threshold Alerts"]
    E --> GG["Database Performance Alerts"]
    
    EE --> HH["AlertManager Integration"]
    FF --> HH
    GG --> HH
```

**Grafana Visualization Platform**

A comprehensive dashboard and visualization platform that transforms Prometheus metrics into actionable insights through pre-configured dashboards, real-time monitoring, and user-friendly interfaces for the n8n Docker stack.

**Core Functionality: Grafana Visualization Platform**

- **Dashboard Provisioning**: Automatically provisions pre-configured dashboards for n8n overview, system monitoring, and database performance
- **Data Source Integration**: Seamlessly connects to Prometheus for real-time metrics visualization and historical trend analysis
- **User Interface**: Provides web-based interface (admin/admin_password) for dashboard viewing, customization, and alert management
- **Alert Visualization**: Displays alert status, historical alert data, and alert rule configurations for operational awareness

**Architecture Diagram of component: Grafana Visualization Platform**

```mermaid
---
title: Grafana Visualization Platform Architecture
---
flowchart TD
    A["Grafana Container :3000"] --> B["Authentication System"]
    A --> C["Dashboard Manager"]
    A --> D["Data Source Connector"]
    A --> E["Provisioning Engine"]
    
    B --> F["Local Admin Authentication"]
    F --> G["admin/admin_password"]
    
    C --> H["Pre-configured Dashboards"]
    H --> I["n8n Stack Overview"]
    H --> J["System Resources Overview"]
    H --> K["Database Performance"]
    
    D --> L["Prometheus Data Source"]
    L --> M["Metrics Query Engine"]
    M --> N["Real-time Data Updates"]
    
    E --> O["Automatic Dashboard Provisioning"]
    E --> P["Data Source Provisioning"]
    
    O --> Q["dashboards.yml Configuration"]
    P --> R["prometheus.yml Data Source"]
    
    I --> S["Workflow Execution Panels"]
    I --> T["Service Health Panels"]
    I --> U["API Performance Panels"]
    
    J --> V["CPU Utilization Graphs"]
    J --> W["Memory Usage Graphs"]
    J --> X["Disk Space Monitoring"]
    J --> Y["Network Traffic Graphs"]
    
    K --> Z["Connection Pool Status"]
    K --> AA["Query Performance Metrics"]
    K --> BB["Database Size Trends"]
    
    A --> CC["Persistent Volume Storage"]
    CC --> DD["grafana_data Volume"]
    DD --> EE["Dashboard Configurations"]
    DD --> FF["User Settings"]
    DD --> GG["Alert Configurations"]
```

**AlertManager Notification System**

An intelligent alert routing and notification management system that processes alerts from Prometheus and delivers notifications through multiple channels including email, webhooks, and n8n workflow integrations.

**Core Functionality: AlertManager Notification System**

- **Alert Routing**: Routes alerts based on severity, service type, and custom labels to appropriate notification channels
- **Notification Delivery**: Supports multiple notification channels including email, webhooks, and direct n8n workflow triggers
- **Alert Grouping**: Groups related alerts to prevent notification spam and provides consolidated alert summaries
- **Integration Ready**: Webhook endpoints configured for sending alerts back to n8n workflows for automated response procedures

**Architecture Diagram of component: AlertManager Notification System**

```mermaid
---
title: AlertManager Notification System Architecture
---
flowchart TD
    A["AlertManager Container :9093"] --> B["Alert Reception"]
    A --> C["Routing Engine"]
    A --> D["Notification Manager"]
    A --> E["Alert Grouping"]
    
    B --> F["Prometheus Alert Ingestion"]
    F --> G["Alert Validation"]
    G --> H["Alert Processing Queue"]
    
    C --> I["Routing Rules"]
    I --> J["Severity-based Routing"]
    I --> K["Service-type Routing"]
    I --> L["Label-based Routing"]
    
    D --> M["Email Notifications"]
    D --> N["Webhook Notifications"]
    D --> O["n8n Workflow Triggers"]
    
    E --> P["Alert Deduplication"]
    E --> Q["Alert Consolidation"]
    E --> R["Time-based Grouping"]
    
    M --> S["SMTP Configuration"]
    S --> T["Critical Alert Emails"]
    S --> U["Warning Alert Summaries"]
    
    N --> V["HTTP Webhook Endpoints"]
    V --> W["External System Integration"]
    V --> X["Custom Alert Handlers"]
    
    O --> Y["n8n Webhook Endpoints"]
    Y --> Z["Automated Response Workflows"]
    Y --> AA["Alert Processing Workflows"]
    
    A --> BB["Configuration Management"]
    BB --> CC["alertmanager.yml"]
    CC --> DD["Routing Configuration"]
    CC --> EE["Notification Templates"]
    CC --> FF["Grouping Rules"]
```

**Exporter Services Collection**

A comprehensive collection of specialized metric exporters that gather detailed performance and health data from system resources, containers, and database services for complete observability of the n8n Docker stack infrastructure.

**Core Functionality: Exporter Services Collection**

- **System Monitoring**: Node Exporter collects comprehensive system metrics including CPU, memory, disk, and network statistics
- **Container Monitoring**: cAdvisor provides detailed container resource usage, health status, and performance metrics
- **Database Monitoring**: PostgreSQL Exporter gathers database-specific metrics including connections, queries, and performance data
- **Service Integration**: All exporters expose metrics in Prometheus format for seamless integration with the monitoring stack

**Architecture Diagram of component: Exporter Services Collection**

```mermaid
---
title: Exporter Services Collection Architecture
---
flowchart TD
    A["Exporter Services"] --> B["Node Exporter :9100"]
    A --> C["cAdvisor :8080"]
    A --> D["PostgreSQL Exporter :9187"]
    
    B --> E["System Metrics Collection"]
    E --> F["CPU Usage Statistics"]
    E --> G["Memory Utilization Data"]
    E --> H["Disk Space Monitoring"]
    E --> I["Network Interface Statistics"]
    E --> J["System Load Averages"]
    
    C --> K["Container Metrics Collection"]
    K --> L["Container Resource Usage"]
    K --> M["Container Health Status"]
    K --> N["Container Restart Counts"]
    K --> O["Container Performance Data"]
    
    D --> P["Database Metrics Collection"]
    P --> Q["Connection Pool Status"]
    P --> R["Active Query Statistics"]
    P --> S["Database Size Metrics"]
    P --> T["Replication Status"]
    P --> U["Lock Statistics"]
    
    F --> V["Prometheus Metrics Format"]
    G --> V
    H --> V
    I --> V
    J --> V
    
    L --> W["Prometheus Metrics Format"]
    M --> W
    N --> W
    O --> W
    
    Q --> X["Prometheus Metrics Format"]
    R --> X
    S --> X
    T --> X
    U --> X
    
    V --> Y["Prometheus Scraping"]
    W --> Y
    X --> Y
    
    Y --> Z["Metrics Storage"]
    Z --> AA["Grafana Visualization"]
    Z --> BB["Alert Processing"]
```

**Testing and Validation Infrastructure**

A comprehensive testing and validation system that ensures monitoring stack functionality, service health, and integration integrity through automated testing scripts and validation procedures.

**Core Functionality: Testing and Validation Infrastructure**

- **Automated Testing**: Comprehensive test suite for monitoring stack components with health validation and integration testing
- **Service Validation**: Individual service health checks for Prometheus, Grafana, AlertManager, and all exporters with endpoint verification
- **Integration Verification**: Complete stack integration testing with network connectivity, metrics flow, and dashboard functionality validation
- **Configuration Validation**: Docker Compose configuration validation, service dependency verification, and deployment readiness testing

**Architecture Diagram of component: Testing and Validation Infrastructure**

```mermaid
---
title: Testing and Validation Infrastructure Architecture
---
flowchart TD
    A["Testing Infrastructure"] --> B["test-monitoring.sh"]
    A --> C["verify-integration.sh"]
    A --> D["start-monitoring.sh"]
    
    B --> E["Container Status Tests"]
    B --> F["Service Health Tests"]
    B --> G["Metrics Collection Tests"]
    B --> H["Dashboard Tests"]
    B --> I["Alert System Tests"]
    
    E --> J["Docker Container Validation"]
    J --> K["n8n-prometheus"]
    J --> L["n8n-grafana"]
    J --> M["n8n-alertmanager"]
    J --> N["n8n-node-exporter"]
    J --> O["n8n-cadvisor"]
    J --> P["n8n-postgres-exporter"]
    
    F --> Q["Health Endpoint Validation"]
    Q --> R["Prometheus /-/healthy"]
    Q --> S["Grafana /api/health"]
    Q --> T["AlertManager /-/healthy"]
    Q --> U["Exporter /metrics"]
    
    G --> V["Metrics Flow Validation"]
    V --> W["Prometheus Targets Check"]
    V --> X["Node Exporter Metrics"]
    V --> Y["cAdvisor Metrics"]
    V --> Z["PostgreSQL Exporter Metrics"]
    
    H --> AA["Dashboard Functionality"]
    AA --> BB["Grafana Data Sources"]
    AA --> CC["Dashboard Rendering"]
    AA --> DD["Query Execution"]
    
    I --> EE["Alert Rules Validation"]
    EE --> FF["AlertManager Configuration"]
    EE --> GG["Notification Channels"]
    
    C --> HH["Plan Implementation Verification"]
    C --> II["Documentation Updates Check"]
    C --> JJ["Configuration Completeness"]
    C --> KK["Functional Tests Execution"]
    
    D --> LL["Automated Startup"]
    D --> MM["Health Check Validation"]
    D --> NN["Service Readiness"]
    D --> OO["Access Information Display"]
```

# Security Stack Architecture

The comprehensive security hardening framework that transforms the development n8n Docker Stack into a production-ready deployment with enterprise-grade security measures, network isolation, and credential protection.

**Core Functionality: Security Stack Architecture**

- **SSL/TLS Termination**: Nginx reverse proxy with automated SSL certificate generation for secure HTTPS communication on port 443
- **Network Isolation**: Multi-tier network architecture with frontend, backend, and database networks providing defense in depth
- **Secrets Management**: Docker secrets integration for secure credential storage and distribution across all services
- **Intrusion Prevention**: Fail2ban integration with custom filters for nginx authentication failures and rate limit violations
- **Security Headers**: Comprehensive HTTP security headers including HSTS, CSP, and XSS protection through nginx configuration
- **Rate Limiting**: Configurable rate limiting to prevent abuse and DDoS attacks with fail2ban integration

**Architecture Diagram of component: Security Stack Architecture**

```mermaid
---
title: Comprehensive Security Stack Architecture
---
flowchart TD
    A["Security Stack Deployment"] --> B["Frontend Network"]
    A --> C["Backend Network"]
    A --> D["Database Network"]
    A --> E["Docker Secrets Manager"]
    A --> F["Nginx Reverse Proxy"]
    A --> G["Fail2ban Intrusion Prevention"]
    
    B --> H["External HTTPS Access :443"]
    B --> I["External HTTP Access :80"]
    B --> J["Public Internet Traffic"]
    
    C --> K["n8n Application Service"]
    C --> L["Internal Service Communication"]
    C --> M["API Gateway Layer"]
    
    D --> N["PostgreSQL Database"]
    D --> O["Database Storage"]
    D --> P["Most Restricted Access"]
    
    E --> Q["PostgreSQL Credentials"]
    E --> R["n8n Authentication"]
    E --> S["Encryption Keys"]
    E --> T["Grafana Admin Credentials"]
    
    F --> U["SSL Certificate Management"]
    F --> V["Security Headers"]
    F --> W["Rate Limiting"]
    F --> X["WebSocket Support"]
    
    G --> Y["Authentication Failure Detection"]
    G --> Z["Rate Limit Violation Detection"]
    G --> AA["IP Blocking and Filtering"]
    G --> BB["Automated Response"]
    
    H --> F
    I --> F
    F --> K
    
    Q --> N
    R --> K
    S --> K
    T --> CC["Grafana Service"]
    
    U --> DD["Self-signed Development"]
    U --> EE["CA-signed Production"]
    
    V --> FF["HSTS Headers"]
    V --> GG["CSP Headers"]
    V --> HH["XSS Protection"]
    
    Y --> II["nginx-auth Filter"]
    Z --> JJ["nginx-limit-req Filter"]
    
    AA --> KK["iptables Rules"]
    BB --> LL["Service Restart"]
    
    A --> MM["Security Monitoring"]
    MM --> NN["Log Analysis"]
    MM --> OO["Alert Generation"]
    MM --> PP["Security Metrics"]
```

**Nginx Reverse Proxy Service**

A production-grade reverse proxy that provides SSL termination, security headers, and load balancing for the n8n application with WebSocket support and comprehensive security configurations.

**Core Functionality: Nginx Reverse Proxy Service**

- **SSL/TLS Termination**: Handles all HTTPS encryption/decryption with configurable SSL certificates for secure communication
- **Security Headers**: Implements comprehensive HTTP security headers including HSTS, Content Security Policy, and XSS protection
- **Rate Limiting**: Configurable request rate limiting to prevent abuse and ensure service availability under load
- **WebSocket Support**: Native WebSocket proxying for real-time n8n workflow execution and monitoring
- **Load Balancing**: Backend service distribution and health checking for high availability deployments

**Architecture Diagram of component: Nginx Reverse Proxy Service**

```mermaid
---
title: Nginx Reverse Proxy Service Architecture
---
flowchart TD
    A["Nginx Container :443/:80"] --> B["SSL Configuration"]
    A --> C["Security Headers"]
    A --> D["Rate Limiting Engine"]
    A --> E["Reverse Proxy Logic"]
    
    B --> F["SSL Certificate Loading"]
    B --> G["TLS Protocol Configuration"]
    B --> H["Cipher Suite Selection"]
    
    F --> I["Self-signed Development"]
    F --> J["CA-signed Production"]
    
    C --> K["HSTS Implementation"]
    C --> L["Content Security Policy"]
    C --> M["XSS Protection Headers"]
    C --> N["Frame Options Security"]
    
    D --> O["Request Rate Monitoring"]
    D --> P["IP-based Rate Limiting"]
    D --> Q["Burst Control"]
    
    E --> R["Backend Health Checking"]
    E --> S["WebSocket Upgrade Handling"]
    E --> T["Load Distribution"]
    
    R --> U["n8n Service :5678"]
    S --> U
    T --> U
    
    A --> V["Access Logging"]
    A --> W["Error Logging"]
    
    V --> X["Security Log Analysis"]
    W --> Y["Error Monitoring"]
    
    X --> Z["Fail2ban Integration"]
    Y --> Z
```

**Fail2ban Intrusion Prevention System**

An advanced intrusion prevention system that monitors nginx logs and automatically blocks malicious IP addresses based on configurable attack patterns and thresholds.

**Core Functionality: Fail2ban Intrusion Prevention System**

- **Log Monitoring**: Real-time analysis of nginx access and error logs for attack pattern detection
- **Custom Filters**: Specialized filters for detecting n8n authentication failures and rate limit violations
- **Automated IP Blocking**: Dynamic iptables rules for blocking malicious IP addresses with configurable ban times
- **Attack Response**: Intelligent response to various attack types including brute force, DoS, and unauthorized access attempts

**Architecture Diagram of component: Fail2ban Intrusion Prevention System**

```mermaid
---
title: Fail2ban Intrusion Prevention Architecture
---
flowchart TD
    A["Fail2ban Service"] --> B["Log File Monitoring"]
    A --> C["Filter Engine"]
    A --> D["Action Engine"]
    A --> E["Jail Configuration"]
    
    B --> F["Nginx Access Log"]
    B --> G["Nginx Error Log"]
    B --> H["Real-time Log Parsing"]
    
    C --> I["Authentication Failure Filter"]
    C --> J["Rate Limit Violation Filter"]
    C --> K["Custom Attack Patterns"]
    
    I --> L["nginx-auth.conf"]
    J --> M["nginx-limit-req.conf"]
    K --> N["User-defined Rules"]
    
    D --> O["IP Blocking Actions"]
    D --> P["Notification Actions"]
    D --> Q["Logging Actions"]
    
    O --> R["iptables Rules"]
    O --> S["Docker Network Rules"]
    O --> T["Temporary Bans"]
    O --> U["Permanent Bans"]
    
    E --> V["nginx-auth Jail"]
    E --> W["nginx-limit-req Jail"]
    E --> X["Jail Configuration"]
    
    V --> Y["Max Retry Threshold"]
    V --> Z["Ban Time Configuration"]
    V --> AA["Find Time Window"]
    
    W --> Y
    W --> Z
    W --> AA
    
    P --> BB["Email Notifications"]
    P --> CC["Webhook Alerts"]
    P --> DD["n8n Workflow Triggers"]
    
    Q --> EE["Ban/Unban Logging"]
    Q --> FF["Statistics Tracking"]
    Q --> GG["Attack Analysis"]
```

**Docker Secrets Management System**

A comprehensive secrets management solution that provides secure storage and distribution of sensitive credentials across all services in the n8n Docker Stack.

**Core Functionality: Docker Secrets Management System**

- **Credential Generation**: Automated generation of strong passwords and encryption keys for all services
- **Secure Distribution**: Docker secrets mechanism for distributing credentials to containers without environment variable exposure
- **Access Control**: Service-specific secret access with minimal privilege principles
- **Rotation Support**: Framework for credential rotation and secret updates across the entire stack

**Architecture Diagram of component: Docker Secrets Management System**

```mermaid
---
title: Docker Secrets Management Architecture
---
flowchart TD
    A["Docker Secrets Manager"] --> B["Secret Generation"]
    A --> C["Secret Storage"]
    A --> D["Secret Distribution"]
    A --> E["Access Control"]
    
    B --> F["Password Generation"]
    B --> G["Encryption Key Generation"]
    B --> H["Username Generation"]
    
    F --> I["Strong Password Policies"]
    F --> J["Cryptographic Randomness"]
    
    G --> K["n8n Encryption Key"]
    G --> L["Database Encryption"]
    
    C --> M["postgres_user.txt"]
    C --> N["postgres_password.txt"]
    C --> O["postgres_db.txt"]
    C --> P["n8n_basic_auth_user.txt"]
    C --> Q["n8n_basic_auth_password.txt"]
    C --> R["n8n_encryption_key.txt"]
    C --> S["grafana_admin_user.txt"]
    C --> T["grafana_admin_password.txt"]
    
    D --> U["PostgreSQL Container"]
    D --> V["n8n Container"]
    D --> W["Grafana Container"]
    
    M --> U
    N --> U
    O --> U
    
    P --> V
    Q --> V
    R --> V
    
    S --> W
    T --> W
    
    E --> X["Service-specific Access"]
    E --> Y["Read-only Mount"]
    E --> Z["Runtime Security"]
    
    X --> AA["Minimal Privilege"]
    Y --> BB["Immutable Secrets"]
    Z --> CC["No Environment Exposure"]
```

**Network Isolation Architecture**

A multi-tier network security architecture that implements defense in depth through network segmentation and access control for the n8n Docker Stack.

**Core Functionality: Network Isolation Architecture**

- **Frontend Network**: Public-facing network for external access through nginx reverse proxy with controlled internet exposure
- **Backend Network**: Internal application network for service communication with restricted external access
- **Database Network**: Highly restricted network for database operations with no external connectivity
- **Network Policies**: Docker network isolation with subnet separation and traffic flow control

**Architecture Diagram of component: Network Isolation Architecture**

```mermaid
---
title: Multi-tier Network Isolation Architecture
---
flowchart TD
    A["Network Isolation System"] --> B["Frontend Network"]
    A --> C["Backend Network"]
    A --> D["Database Network"]
    A --> E["Network Policies"]
    
    B --> F["Subnet: 172.20.0.0/16"]
    B --> G["External Access Allowed"]
    B --> H["Internet Connectivity"]
    
    F --> I["Nginx Reverse Proxy"]
    G --> I
    H --> I
    
    C --> J["Subnet: 172.21.0.0/16"]
    C --> K["Internal Access Only"]
    C --> L["Service Communication"]
    
    J --> M["n8n Application"]
    J --> N["Ollama AI Service"]
    J --> O["Monitoring Services"]
    
    K --> M
    K --> N
    K --> O
    
    D --> P["Subnet: 172.22.0.0/16"]
    D --> Q["No External Access"]
    D --> R["Database Operations Only"]
    
    P --> S["PostgreSQL Database"]
    Q --> S
    R --> S
    
    E --> T["Inter-network Communication"]
    E --> U["Access Control Rules"]
    E --> V["Traffic Filtering"]
    
    T --> W["Frontend to Backend"]
    T --> X["Backend to Database"]
    T --> Y["No Direct Frontend-Database"]
    
    U --> Z["Service-specific Access"]
    U --> AA["Port-based Filtering"]
    U --> BB["Protocol Restrictions"]
    
    V --> CC["Firewall Rules"]
    V --> DD["Network Monitoring"]
    V --> EE["Intrusion Detection"]
    
    I --> M
    M --> S
    
    style B fill:#ffcccc
    style C fill:#ffffcc
    style D fill:#ccffcc
```

**Automated Backup and Recovery System**

A comprehensive backup and disaster recovery solution that provides automated data protection with integrity verification and selective restore capabilities for the entire n8n Docker Stack.

**Core Functionality: Automated Backup and Recovery System**

- **Comprehensive Backup**: Automated backup of PostgreSQL database, n8n data volumes, configuration files, and workflow definitions
- **Integrity Verification**: Backup integrity checking with checksums and validation to ensure reliable restore operations
- **Retention Management**: Configurable backup retention policies with automated cleanup of old backups
- **Selective Restore**: Granular restore options for database, n8n data, configurations, or complete system recovery

**Architecture Diagram of component: Automated Backup and Recovery System**

```mermaid
---
title: Automated Backup and Recovery Architecture
---
flowchart TD
    A["Backup and Recovery System"] --> B["Backup Engine"]
    A --> C["Restore Engine"]
    A --> D["Integrity Verification"]
    A --> E["Storage Management"]
    
    B --> F["Database Backup"]
    B --> G["Volume Backup"]
    B --> H["Configuration Backup"]
    B --> I["Workflow Backup"]
    
    F --> J["PostgreSQL pg_dump"]
    F --> K["SQL Export Compression"]
    F --> L["Database Schema Backup"]
    
    G --> M["n8n Data Volume"]
    G --> N["Ollama Model Data"]
    G --> O["Monitoring Data"]
    
    H --> P["Docker Compose Files"]
    H --> Q["Environment Files"]
    H --> R["Nginx Configuration"]
    H --> S["Security Settings"]
    
    I --> T["JSON Workflow Files"]
    I --> U["Workflow Metadata"]
    I --> V["Credential Backup"]
    
    C --> W["Database Restore"]
    C --> X["Volume Restore"]
    C --> Y["Configuration Restore"]
    C --> Z["Selective Recovery"]
    
    W --> AA["SQL Import Process"]
    W --> BB["Schema Recreation"]
    W --> CC["Data Consistency Check"]
    
    X --> DD["Volume Extraction"]
    X --> EE["File System Restore"]
    X --> FF["Permission Restoration"]
    
    Y --> GG["Config File Restoration"]
    Y --> HH["Environment Rebuilding"]
    Y --> II["Service Reconfiguration"]
    
    Z --> JJ["--database Option"]
    Z --> KK["--n8n-data Option"]
    Z --> LL["--configs Option"]
    Z --> MM["--workflows Option"]
    
    D --> NN["Checksum Verification"]
    D --> OO["Archive Integrity"]
    D --> PP["Backup Validation"]
    
    NN --> QQ["SHA256 Checksums"]
    OO --> RR["Compression Test"]
    PP --> SS["Restore Test"]
    
    E --> TT["Retention Policy"]
    E --> UU["Cleanup Automation"]
    E --> VV["Storage Monitoring"]
    
    TT --> WW["30-Day Retention"]
    UU --> XX["Old Backup Removal"]
    VV --> YY["Disk Space Monitoring"]
    
    A --> ZZ["Backup Reporting"]
    ZZ --> AAA["Backup Status"]
    ZZ --> BBB["Size Statistics"]
    ZZ --> CCC["Error Logging"]
```
