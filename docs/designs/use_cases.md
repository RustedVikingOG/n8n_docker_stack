# n8n Docker Stack Use Cases

Note: This use_case.md is specific to the n8n Docker Stack implementation. Each use-case describes specific functionality implemented in this automation platform.

**project directories**
- src/docker-compose.yml - Multi-service orchestration configuration
- src/Dockerfile - Custom n8n image with utilities
- src/scripts/ - Workflow import automation scripts
- src/workflows/ - Pre-configured workflow JSON definitions
- src/localfiles/ - File operations directory

This project provides a complete Docker-based n8n workflow automation platform with PostgreSQL database, automatic workflow import, and AI integration capabilities.

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
| GIVEN | A FastAPI server is available in the localfiles directory with sample endpoints |
| WHEN | n8n workflows need to test HTTP requests or integrate with external APIs |
| THEN | The FastAPI server provides test endpoints for development and validation of HTTP-based workflow nodes |

**State Diagram: Logic flow within feature**

This diagram shows the external service integration process for workflow testing.

```mermaid
---
title: External Service Integration State Flow
---
stateDiagram-v2
    [*] --> ServiceRequest
    ServiceRequest --> HTTPNodeExecution
    HTTPNodeExecution --> APIEndpointCall
    APIEndpointCall --> FastAPIProcessing
    FastAPIProcessing --> ResponseGeneration
    ResponseGeneration --> WorkflowContinuation
    WorkflowContinuation --> [*]
```
