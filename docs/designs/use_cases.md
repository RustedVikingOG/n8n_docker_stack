# n8n Docker Stack Use Cases

Note: This use_case.md is specific to the n8n Docker Stack implementation. Each use-case describes specific functionality implemented in this automation platform.

**project directories**
- src/n8n/src/docker-compose.yml - Multi-service orchestration configuration
- src/n8n/src/Dockerfile - Custom n8n image with jq and zip utilities
- src/n8n/src/scripts/ - Workflow import automation scripts
- src/n8n/src/workflows/ - Pre-configured workflow JSON definitions
- src/n8n/src/localfiles/ - File operations directory with FastAPI example server
- src/monitoring/ - Comprehensive monitoring stack with Prometheus, Grafana, and AlertManager

This project provides a complete Docker-based n8n workflow automation platform with PostgreSQL database, automatic workflow import, AI integration capabilities, and comprehensive monitoring and observability stack.

## USE-CASE: Automated Workflow Platform Deployment

**Feature 1: Complete Stack Deployment**

|| definition |
|--|--|
| GIVEN | A user has Docker and Docker Compose installed on their system |
| WHEN | They run `docker-compose up -d` in the src/ directory |
| THEN | A complete n8n automation platform is deployed with PostgreSQL database, workflow import, and AI integration |

**State Diagram: Logic flow within feature**

This diagram shows the deployment sequence and service dependencies for the complete n8n stack.

```mermaid
---
title: n8n Stack Deployment State Flow
---
stateDiagram-v2
    [*] --> DockerComposeStart
    DockerComposeStart --> PostgreSQLStarting
    PostgreSQLStarting --> PostgreSQLHealthCheck
    PostgreSQLHealthCheck --> PostgreSQLReady
    PostgreSQLReady --> WorkflowImporterStart
    WorkflowImporterStart --> WorkflowImportProcess
    WorkflowImportProcess --> WorkflowImportComplete
    WorkflowImportComplete --> N8NServiceStart
    PostgreSQLReady --> OllamaServiceStart
    OllamaServiceStart --> OllamaModelDownload
    OllamaModelDownload --> OllamaReady
    N8NServiceStart --> N8NReady
    N8NReady --> [*]
    OllamaReady --> [*]
```

**Sequence Diagram: Interactions between systems to enable Feature**

This flowchart shows the interaction between Docker Compose services during deployment.

```mermaid
---
title: Service Deployment Interaction Flow
---
flowchart TD
    A["Docker Compose Command"] --> B["PostgreSQL Container Start"]
    B --> C["Health Check Execution"]
    C --> D{"Database Ready?"}
    D -->|No| C
    D -->|Yes| E["Workflow Importer Start"]
    E --> F["Import Script Execution"]
    F --> G["JSON Workflow Processing"]
    G --> H["n8n Service Start"]
    B --> I["Ollama Container Start"]
    I --> J["AI Model Download"]
    J --> K["Ollama Service Ready"]
    H --> L["n8n Web Interface Available"]
    L --> M["Complete Stack Ready"]
    K --> M
```

**Data Entity Relationship: Data structure for entities in Feature**

This diagram shows the data relationships between n8n components and storage systems.

```mermaid
---
title: n8n Stack Data Entity Relationships
---
erDiagram
    DOCKER_COMPOSE ||--o{ SERVICES : orchestrates
    SERVICES ||--|| POSTGRESQL : "depends on"
    SERVICES ||--|| N8N : "includes"
    SERVICES ||--|| OLLAMA : "includes"
    SERVICES ||--|| WORKFLOW_IMPORTER : "includes"
    
    POSTGRESQL ||--o{ WORKFLOWS : stores
    POSTGRESQL ||--o{ CREDENTIALS : stores
    POSTGRESQL ||--o{ EXECUTIONS : stores
    POSTGRESQL ||--o{ USERS : stores
    
    N8N ||--o{ WORKFLOWS : executes
    N8N ||--o{ API_ENDPOINTS : exposes
    N8N ||--o{ WEB_INTERFACE : provides
    
    WORKFLOW_IMPORTER ||--o{ JSON_FILES : processes
    JSON_FILES ||--|| WORKFLOWS : "imports to"
    
    OLLAMA ||--o{ AI_MODELS : serves
    AI_MODELS ||--|| WORKFLOWS : "integrates with"
    
    DOCKER_VOLUMES ||--|| POSTGRESQL : "persists data"
    DOCKER_VOLUMES ||--|| N8N : "persists data"
    DOCKER_VOLUMES ||--|| OLLAMA : "persists models"
```

## USE-CASE: Automatic Workflow Import and Management

**Feature 1: JSON Workflow Import Automation**

|| definition |
|--|--|
| GIVEN | JSON workflow files are placed in the src/workflows directory |
| WHEN | The Docker stack is started or restarted |
| THEN | All workflow files are automatically imported into n8n with duplicate detection |

**State Diagram: Logic flow within feature**

This diagram shows the workflow import process with duplicate detection logic.

```mermaid
---
title: Workflow Import Process State Flow
---
stateDiagram-v2
    [*] --> ImporterStart
    ImporterStart --> ScanWorkflowDirectory
    ScanWorkflowDirectory --> CheckExistingWorkflows
    CheckExistingWorkflows --> ProcessJSONFile
    ProcessJSONFile --> ExtractWorkflowID
    ExtractWorkflowID --> CheckDuplicate
    CheckDuplicate --> DuplicateFound
    CheckDuplicate --> NewWorkflow
    DuplicateFound --> SkipImport
    NewWorkflow --> ImportWorkflow
    ImportWorkflow --> NextFile
    SkipImport --> NextFile
    NextFile --> MoreFiles
    MoreFiles --> ProcessJSONFile
    MoreFiles --> ImportComplete
    ImportComplete --> [*]
```

## USE-CASE: AI-Powered Workflow Automation

**Feature 1: Ollama AI Integration for Workflows**

|| definition |
|--|--|
| GIVEN | The Ollama service is running with llama3.2:3b model |
| WHEN | An n8n workflow includes AI processing nodes |
| THEN | The workflow can leverage local AI capabilities for text processing and generation |

**State Diagram: Logic flow within feature**

This diagram shows the AI integration workflow execution process.

```mermaid
---
title: AI Workflow Execution State Flow
---
stateDiagram-v2
    [*] --> WorkflowTrigger
    WorkflowTrigger --> ProcessingNode
    ProcessingNode --> AINodeReached
    AINodeReached --> OllamaAPICall
    OllamaAPICall --> ModelProcessing
    ModelProcessing --> AIResponse
    AIResponse --> ContinueWorkflow
    ContinueWorkflow --> WorkflowComplete
    WorkflowComplete --> [*]
```

## USE-CASE: GitHub Repository Workflow Synchronization

**Feature 1: Bidirectional GitHub Workflow Sync**

|| definition |
|--|--|
| GIVEN | A GitHub repository contains n8n workflow JSON files and GitHub PAT is configured |
| WHEN | The github_repo_workflows_sync workflow is triggered (weekly or manually) |
| THEN | Workflows are synchronized bidirectionally between n8n instance and GitHub repository |

**State Diagram: Logic flow within feature**

This diagram shows the GitHub synchronization process with conflict resolution.

```mermaid
---
title: GitHub Workflow Sync State Flow
---
stateDiagram-v2
    [*] --> SyncTrigger
    SyncTrigger --> FetchGitHubWorkflows
    FetchGitHubWorkflows --> FetchN8NWorkflows
    FetchN8NWorkflows --> CompareTimestamps
    CompareTimestamps --> ConflictDetected
    CompareTimestamps --> NoConflict
    ConflictDetected --> ResolveByTimestamp
    ResolveByTimestamp --> UpdateRepository
    NoConflict --> UpdateRepository
    UpdateRepository --> CommitChanges
    CommitChanges --> SyncComplete
    SyncComplete --> [*]
```

## USE-CASE: Project Tree Generation and Management

**Feature 1: Automated Project Tree Creation**

|| definition |
|--|--|
| GIVEN | A project directory structure exists with various files and folders |
| WHEN | The gtree_creator workflow is executed with project path input |
| THEN | A comprehensive project tree structure is generated and stored for documentation purposes |

**State Diagram: Logic flow within feature**

This diagram shows the project tree generation workflow process.

```mermaid
---
title: Project Tree Generation State Flow
---
stateDiagram-v2
    [*] --> TreeGenerationStart
    TreeGenerationStart --> ScanProjectDirectory
    ScanProjectDirectory --> FilterFiles
    FilterFiles --> BuildTreeStructure
    BuildTreeStructure --> FormatOutput
    FormatOutput --> StoreTreeData
    StoreTreeData --> TreeComplete
    TreeComplete --> [*]
```

## USE-CASE: File Archive Management

**Feature 1: Automated ZIP Archive Creation and Distribution**

|| definition |
|--|--|
| GIVEN | Files need to be archived and distributed from the local file system |
| WHEN | The zip_make and zip_send workflows are triggered with file specifications |
| THEN | Files are compressed into ZIP archives and distributed to specified destinations |

**State Diagram: Logic flow within feature**

This diagram shows the file archiving and distribution process.

```mermaid
---
title: File Archive Management State Flow
---
stateDiagram-v2
    [*] --> ArchiveRequest
    ArchiveRequest --> SelectFiles
    SelectFiles --> CreateZipArchive
    CreateZipArchive --> ValidateArchive
    ValidateArchive --> DistributionReady
    DistributionReady --> SendArchive
    SendArchive --> ArchiveComplete
    ArchiveComplete --> [*]
```

## USE-CASE: Workflow Cleanup and Maintenance

**Feature 1: Archived Workflow Deletion**

|| definition |
|--|--|
| GIVEN | n8n instance contains archived or obsolete workflows |
| WHEN | The delete_archived_workflows workflow is executed |
| THEN | Archived workflows are identified and safely removed from the n8n instance |

**State Diagram: Logic flow within feature**

This diagram shows the workflow cleanup process with safety checks.

```mermaid
---
title: Workflow Cleanup State Flow
---
stateDiagram-v2
    [*] --> CleanupStart
    CleanupStart --> IdentifyArchivedWorkflows
    IdentifyArchivedWorkflows --> SafetyCheck
    SafetyCheck --> ConfirmDeletion
    ConfirmDeletion --> DeleteWorkflows
    DeleteWorkflows --> LogDeletions
    LogDeletions --> CleanupComplete
    CleanupComplete --> [*]
```

## USE-CASE: External Service Integration and Testing

**Feature 1: FastAPI Server Integration for Workflow Testing**

|| definition |
|--|--|
| GIVEN | A FastAPI server is available in the localfiles/someserver directory with sample endpoints |
| WHEN | n8n workflows need to test HTTP requests or integrate with external APIs |
| THEN | The FastAPI server provides test endpoints (/ and /items/{item_id}) for development and validation of HTTP-based workflow nodes |

**State Diagram: Logic flow within feature**

This diagram shows the external service integration process for workflow testing with the actual FastAPI endpoints.

```mermaid
---
title: External Service Integration State Flow
---
stateDiagram-v2
    [*] --> ServiceRequest
    ServiceRequest --> HTTPNodeExecution
    HTTPNodeExecution --> EndpointSelection
    EndpointSelection --> RootEndpoint
    EndpointSelection --> ItemsEndpoint
    RootEndpoint --> HelloWorldResponse
    ItemsEndpoint --> ItemDataResponse
    HelloWorldResponse --> WorkflowContinuation
    ItemDataResponse --> WorkflowContinuation
    WorkflowContinuation --> [*]
```

**Sequence Diagram: Interactions between systems to enable Feature**

This flowchart shows the interaction between n8n workflows and the FastAPI server for testing HTTP operations.

```mermaid
---
title: FastAPI Integration Sequence Flow
---
flowchart TD
    A["n8n HTTP Request Node"] --> B["FastAPI Server :8010"]
    B --> C{"Endpoint Selection"}
    C -->|GET /| D["Root Endpoint Handler"]
    C -->|GET /items/{id}| E["Items Endpoint Handler"]
    D --> F["Return Hello World JSON"]
    E --> G["Return Item Data JSON"]
    F --> H["n8n Response Processing"]
    G --> H
    H --> I["Continue Workflow Execution"]
```

**Data Entity Relationship: Data structure for entities in Feature**

This diagram shows the data relationships for the FastAPI server integration.

```mermaid
---
title: FastAPI Server Data Entity Relationships
---
erDiagram
    N8N_WORKFLOW ||--o{ HTTP_REQUEST_NODE : contains
    HTTP_REQUEST_NODE ||--|| FASTAPI_SERVER : "calls"
    FASTAPI_SERVER ||--o{ API_ENDPOINTS : exposes
    API_ENDPOINTS ||--|| ROOT_ENDPOINT : includes
    API_ENDPOINTS ||--|| ITEMS_ENDPOINT : includes

    ROOT_ENDPOINT {
        string method "GET"
        string path "/"
        json response "Hello World"
    }

    ITEMS_ENDPOINT {
        string method "GET"
        string path "/items/{item_id}"
        int item_id "path parameter"
        string q "optional query parameter"
        json response "item data"
    }

    FASTAPI_SERVER {
        string host "0.0.0.0"
        int port "8010"
        string framework "FastAPI"
        string server "uvicorn"
    }
```

## USE-CASE: Comprehensive Workflow Collection Management

**Feature 1: Pre-configured Workflow Ecosystem**

|| definition |
|--|--|
| GIVEN | The system contains 9 pre-configured workflows covering GitHub sync, project analysis, file management, and cleanup operations |
| WHEN | The Docker stack is deployed and workflows are automatically imported |
| THEN | A complete automation ecosystem is available including GitHub synchronization, project tree generation, file archiving, and workflow maintenance |

**State Diagram: Logic flow within feature**

This diagram shows the comprehensive workflow ecosystem initialization and operation.

```mermaid
---
title: Workflow Ecosystem Management State Flow
---
stateDiagram-v2
    [*] --> WorkflowImport
    WorkflowImport --> GitHubSyncActive
    WorkflowImport --> ProjectAnalysisReady
    WorkflowImport --> FileManagementReady
    WorkflowImport --> CleanupUtilitiesReady

    GitHubSyncActive --> WeeklySync
    WeeklySync --> ConflictResolution
    ConflictResolution --> BackupComplete

    ProjectAnalysisReady --> TreeGeneration
    TreeGeneration --> ContextBuilding
    ContextBuilding --> TreeRetrieval

    FileManagementReady --> ArchiveCreation
    ArchiveCreation --> ArchiveDistribution

    CleanupUtilitiesReady --> ArchivedWorkflowDeletion

    BackupComplete --> [*]
    TreeRetrieval --> [*]
    ArchiveDistribution --> [*]
    ArchivedWorkflowDeletion --> [*]
```

**Sequence Diagram: Interactions between systems to enable Feature**

This flowchart shows how the different workflow categories interact within the ecosystem.

```mermaid
---
title: Workflow Ecosystem Interaction Flow
---
flowchart TD
    A["Workflow Import System"] --> B["GitHub Sync Workflows"]
    A --> C["Project Analysis Workflows"]
    A --> D["File Management Workflows"]
    A --> E["Cleanup Workflows"]

    B --> F["github_repo_workflows_sync"]
    B --> G["github_workflows_backup"]

    C --> H["gtree_creator"]
    C --> I["gtree_build_context"]
    C --> J["gtree_get"]

    D --> K["zip_make"]
    D --> L["zip_send"]

    E --> M["delete_archived_workflows"]

    F --> N["Weekly Automation"]
    G --> O["Backup Operations"]
    H --> P["Repository Analysis"]
    I --> P
    J --> P
    K --> Q["File Distribution"]
    L --> Q
    M --> R["System Maintenance"]

    N --> S["Continuous Sync"]
    O --> S
    P --> T["Project Documentation"]
    Q --> U["File Operations"]
    R --> V["Clean Environment"]
```

**Data Entity Relationship: Data structure for entities in Feature**

This diagram shows the relationships between different workflow categories and their data dependencies.

```mermaid
---
title: Workflow Ecosystem Data Entity Relationships
---
erDiagram
    WORKFLOW_ECOSYSTEM ||--o{ GITHUB_WORKFLOWS : contains
    WORKFLOW_ECOSYSTEM ||--o{ PROJECT_WORKFLOWS : contains
    WORKFLOW_ECOSYSTEM ||--o{ FILE_WORKFLOWS : contains
    WORKFLOW_ECOSYSTEM ||--o{ CLEANUP_WORKFLOWS : contains

    GITHUB_WORKFLOWS ||--|| REPO_SYNC : includes
    GITHUB_WORKFLOWS ||--|| BACKUP_AUTOMATION : includes

    PROJECT_WORKFLOWS ||--|| TREE_CREATOR : includes
    PROJECT_WORKFLOWS ||--|| CONTEXT_BUILDER : includes
    PROJECT_WORKFLOWS ||--|| TREE_RETRIEVER : includes

    FILE_WORKFLOWS ||--|| ZIP_CREATOR : includes
    FILE_WORKFLOWS ||--|| ZIP_DISTRIBUTOR : includes

    CLEANUP_WORKFLOWS ||--|| ARCHIVE_CLEANER : includes

    REPO_SYNC {
        string status "Active"
        string schedule "Weekly"
        string purpose "Bidirectional sync"
    }

    TREE_CREATOR {
        string status "Inactive"
        string trigger "Manual"
        string purpose "Git tree generation"
    }

    ZIP_CREATOR {
        string status "Inactive"
        string trigger "Manual"
        string purpose "Archive creation"
    }

    ARCHIVE_CLEANER {
        string status "Inactive"
        string trigger "Manual"
        string purpose "Workflow cleanup"
    }
```

## USE-CASE: Comprehensive Monitoring and Observability

**Feature 1: Complete Stack Monitoring with Prometheus, Grafana, and AlertManager**

|| definition |
|--|--|
| GIVEN | The n8n Docker stack is running with monitoring services deployed |
| WHEN | Users access Grafana dashboards and Prometheus metrics |
| THEN | Complete observability is provided for all services including n8n, PostgreSQL, Ollama, and system resources |

**State Diagram: Logic flow within feature**

This diagram shows the monitoring stack initialization and data collection process.

```mermaid
---
title: Monitoring Stack State Flow
---
stateDiagram-v2
    [*] --> MonitoringStart
    MonitoringStart --> PrometheusInit
    PrometheusInit --> MetricsCollection
    MetricsCollection --> GrafanaInit
    GrafanaInit --> DashboardProvisioning
    DashboardProvisioning --> AlertManagerInit
    AlertManagerInit --> AlertRulesLoaded
    AlertRulesLoaded --> MonitoringReady
    MonitoringReady --> ContinuousMonitoring
    ContinuousMonitoring --> AlertEvaluation
    AlertEvaluation --> AlertTriggered
    AlertEvaluation --> NormalOperation
    AlertTriggered --> NotificationSent
    NotificationSent --> ContinuousMonitoring
    NormalOperation --> ContinuousMonitoring
```

**Sequence Diagram: Interactions between systems to enable Feature**

This flowchart shows the interaction between monitoring components and monitored services.

```mermaid
---
title: Monitoring System Interaction Flow
---
flowchart TD
    A["Monitoring Stack Start"] --> B["Prometheus Service"]
    B --> C["Metrics Scraping"]
    C --> D["n8n Metrics :5678/metrics"]
    C --> E["PostgreSQL Exporter :9187"]
    C --> F["Node Exporter :9100"]
    C --> G["cAdvisor :8080"]
    C --> H["Ollama Metrics :11434/metrics"]

    D --> I["Application Metrics"]
    E --> J["Database Metrics"]
    F --> K["System Metrics"]
    G --> L["Container Metrics"]
    H --> M["AI Service Metrics"]

    I --> N["Prometheus Storage"]
    J --> N
    K --> N
    L --> N
    M --> N

    N --> O["Grafana Dashboards"]
    N --> P["AlertManager Rules"]

    O --> Q["Visual Monitoring"]
    P --> R["Alert Notifications"]

    R --> S["Email/Webhook Alerts"]
    Q --> T["Operational Insights"]
```

## USE-CASE: Real-time Performance Monitoring and Alerting

**Feature 1: Automated Alert System with Multi-channel Notifications**

|| definition |
|--|--|
| GIVEN | Monitoring stack is configured with alert rules for service health, resource usage, and database performance |
| WHEN | System metrics exceed defined thresholds or services become unavailable |
| THEN | Alerts are automatically triggered and routed to appropriate notification channels (email, webhooks, n8n workflows) |

**State Diagram: Logic flow within feature**

This diagram shows the alert processing and notification workflow.

```mermaid
---
title: Alert Processing State Flow
---
stateDiagram-v2
    [*] --> MetricEvaluation
    MetricEvaluation --> ThresholdCheck
    ThresholdCheck --> WithinLimits
    ThresholdCheck --> ThresholdExceeded
    WithinLimits --> MetricEvaluation
    ThresholdExceeded --> AlertGenerated
    AlertGenerated --> AlertRouting
    AlertRouting --> CriticalAlert
    AlertRouting --> WarningAlert
    AlertRouting --> DatabaseAlert
    AlertRouting --> N8NAlert
    CriticalAlert --> ImmediateNotification
    WarningAlert --> GroupedNotification
    DatabaseAlert --> DBANotification
    N8NAlert --> WorkflowNotification
    ImmediateNotification --> AlertSent
    GroupedNotification --> AlertSent
    DBANotification --> AlertSent
    WorkflowNotification --> AlertSent
    AlertSent --> AlertResolution
    AlertResolution --> MetricEvaluation
```

## USE-CASE: Historical Data Analysis and Capacity Planning

**Feature 1: Long-term Metrics Storage and Trend Analysis**

|| definition |
|--|--|
| GIVEN | Prometheus is configured with 30-day data retention and Grafana dashboards show historical trends |
| WHEN | Administrators need to analyze system performance over time or plan for capacity changes |
| THEN | Historical metrics data is available for trend analysis, capacity planning, and performance optimization |

**Data Entity Relationship: Data structure for entities in Feature**

This diagram shows the relationships between monitoring components and their data storage.

```mermaid
---
title: Monitoring Data Entity Relationships
---
erDiagram
    MONITORING_STACK ||--o{ PROMETHEUS : includes
    MONITORING_STACK ||--o{ GRAFANA : includes
    MONITORING_STACK ||--o{ ALERTMANAGER : includes
    MONITORING_STACK ||--o{ EXPORTERS : includes

    PROMETHEUS ||--o{ METRICS_STORAGE : manages
    PROMETHEUS ||--o{ SCRAPE_TARGETS : monitors
    PROMETHEUS ||--o{ ALERT_RULES : evaluates

    SCRAPE_TARGETS ||--|| N8N_SERVICE : includes
    SCRAPE_TARGETS ||--|| POSTGRESQL_EXPORTER : includes
    SCRAPE_TARGETS ||--|| NODE_EXPORTER : includes
    SCRAPE_TARGETS ||--|| CADVISOR : includes
    SCRAPE_TARGETS ||--|| OLLAMA_SERVICE : includes

    GRAFANA ||--o{ DASHBOARDS : provides
    GRAFANA ||--|| PROMETHEUS : "queries"
    DASHBOARDS ||--|| N8N_OVERVIEW : includes
    DASHBOARDS ||--|| SYSTEM_OVERVIEW : includes

    ALERTMANAGER ||--o{ NOTIFICATION_CHANNELS : manages
    ALERTMANAGER ||--|| PROMETHEUS : "receives alerts from"
    NOTIFICATION_CHANNELS ||--|| EMAIL_ALERTS : includes
    NOTIFICATION_CHANNELS ||--|| WEBHOOK_ALERTS : includes
    NOTIFICATION_CHANNELS ||--|| N8N_WEBHOOKS : includes

    EXPORTERS ||--|| POSTGRES_EXPORTER : includes
    EXPORTERS ||--|| NODE_EXPORTER : includes
    EXPORTERS ||--|| CADVISOR : includes

    METRICS_STORAGE {
        string retention "30 days"
        string format "time-series"
        string compression "enabled"
    }

    ALERT_RULES {
        string service_health "critical"
        string cpu_usage "warning > 80%"
        string memory_usage "warning > 85%"
        string disk_space "critical > 90%"
        string database_connections "warning > 80%"
    }
```
