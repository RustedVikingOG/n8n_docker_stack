# n8n Docker Stack Documentation

This directory contains comprehensive documentation for the n8n Docker Stack project, following established AI template standards for technical documentation.

## Documentation Structure

### Core Documentation

- **[1.COLLABORATION.md](./1.COLLABORATION.md)** - Primary collaboration guide with project overview, setup instructions, debugging strategies, and development guidelines
- **[designs/](./designs/)** - Technical design documentation following AI template standards

### Design Documentation

- **[designs/architecture.md](./designs/architecture.md)** - Complete system architecture with component definitions, interaction diagrams, and technical specifications
- **[designs/use_cases.md](./designs/use_cases.md)** - Detailed use cases with state diagrams, sequence flows, and data entity relationships
- **[designs/setup_guide.md](./designs/setup_guide.md)** - Comprehensive setup and configuration guide with environment file templates

## Quick Navigation

### For New Users
1. Start with [1.COLLABORATION.md](./1.COLLABORATION.md) for project overview
2. Follow [designs/setup_guide.md](./designs/setup_guide.md) for detailed setup
3. Review [designs/architecture.md](./designs/architecture.md) to understand system components

### For Developers
1. Review [designs/architecture.md](./designs/architecture.md) for technical architecture
2. Study [designs/use_cases.md](./designs/use_cases.md) for workflow patterns
3. Follow debugging strategies in [1.COLLABORATION.md](./1.COLLABORATION.md)

### For DevOps/Deployment
1. Use [designs/setup_guide.md](./designs/setup_guide.md) for environment configuration
2. Reference [1.COLLABORATION.md](./1.COLLABORATION.md) for build and deployment procedures
3. Follow troubleshooting guides for production issues

## Documentation Standards

This documentation follows the AI template standards defined in [.docs/ai/templates/](../.docs/ai/templates/):

- **Architecture Documentation**: Based on `__architecture.md` template
- **Use Cases Documentation**: Based on `__use_cases.md` template  
- **Collaboration Guide**: Based on `__COLLABORATION.md` template

### Key Features

- **Mermaid Diagrams**: All diagrams use proper Mermaid syntax with quoted multi-word names
- **Specific Implementation Details**: Documentation reflects actual codebase implementation
- **Comprehensive Coverage**: All system components, workflows, and configurations documented
- **Practical Examples**: Real-world usage scenarios and debugging strategies

## System Overview

The n8n Docker Stack provides:

- **Complete Automation Platform**: n8n workflow automation with web interface
- **Persistent Data Storage**: PostgreSQL database with health checks
- **AI Integration**: Ollama service with llama3.2:3b model
- **Automatic Workflow Import**: Pre-configured workflows from JSON files
- **Development Tools**: FastAPI example server for testing
- **Comprehensive Documentation**: Following AI template standards

## Key Components

| Component | Purpose | Documentation |
|-----------|---------|---------------|
| **n8n Service** | Workflow automation platform | [architecture.md](./designs/architecture.md) |
| **PostgreSQL** | Database for persistent storage | [architecture.md](./designs/architecture.md) |
| **Ollama AI** | Local AI model serving | [architecture.md](./designs/architecture.md) |
| **Workflow Importer** | Automatic workflow import | [use_cases.md](./designs/use_cases.md) |
| **FastAPI Server** | Development and testing | [use_cases.md](./designs/use_cases.md) |

## Configuration Files

| File | Purpose | Documentation |
|------|---------|---------------|
| `docker-compose.yml` | Service orchestration | [1.COLLABORATION.md](./1.COLLABORATION.md) |
| `.n8n.env.template` | n8n configuration template | [setup_guide.md](./designs/setup_guide.md) |
| `.postgresql.env.template` | Database configuration template | [setup_guide.md](./designs/setup_guide.md) |
| `import-workflows.sh` | Workflow import script | [architecture.md](./designs/architecture.md) |

## Workflow Collection

The system includes 9 pre-configured workflows:

- **GitHub Integration**: Repository synchronization and backup
- **Project Analysis**: Git tree generation and context building  
- **File Management**: ZIP archive creation and distribution
- **System Maintenance**: Workflow cleanup and management

See [designs/use_cases.md](./designs/use_cases.md) for detailed workflow documentation.

## Getting Started

1. **Quick Start**: Follow the setup instructions in [1.COLLABORATION.md](./1.COLLABORATION.md)
2. **Detailed Setup**: Use the comprehensive guide in [designs/setup_guide.md](./designs/setup_guide.md)
3. **Understanding the System**: Review the architecture in [designs/architecture.md](./designs/architecture.md)

## Support and Troubleshooting

- **Common Issues**: See debugging strategies in [1.COLLABORATION.md](./1.COLLABORATION.md)
- **Configuration Problems**: Reference [designs/setup_guide.md](./designs/setup_guide.md)
- **System Architecture**: Understand component interactions in [designs/architecture.md](./designs/architecture.md)

## Contributing

When contributing to this project:

1. Follow the collaboration guidelines in [1.COLLABORATION.md](./1.COLLABORATION.md)
2. Update documentation to reflect any changes
3. Validate workflow JSON files before committing
4. Test changes using the debugging strategies provided

## Documentation Maintenance

This documentation is maintained following the sync protocol defined in [.docs/ai/documenter-prompt.md](../.docs/ai/documenter-prompt.md) to ensure:

- **Accuracy**: Documentation reflects actual implementation
- **Completeness**: All features and components are documented
- **Consistency**: Following established AI template standards
- **Usability**: Clear navigation and practical examples
