# Purpose of the Workflows Folder

## Overview
This `workflows` folder serves as a **centralized repository for n8n workflow definitions** stored as JSON files. It acts as a version-controlled backup and synchronization point between your n8n instance and GitHub repository.

## What's Stored Here
- **n8n workflow JSON files**: Complete workflow definitions exported from n8n
- **Automated backups**: Workflows synchronized via the `github_repo_workflows_sync` automation
- **Version history**: Git-tracked changes to workflow configurations over time

## How It Works
This folder is automatically managed by the **n8n ↔ GitHub Workflow Sync** automation that:

1. **Monitors changes** in both your n8n instance and this GitHub repository
2. **Synchronizes bidirectionally** to ensure consistency between both systems
3. **Maintains backups** of all your n8n workflows as JSON files
4. **Resolves conflicts** by keeping the most recently updated version
5. **Runs weekly** (every Monday) to check for synchronization needs

## File Naming Convention
Workflow files are automatically named using the pattern:
```
{workflow-name-lowercase-with-dashes}.json
```

For example:
- "My Data Processing Workflow" → `my-data-processing-workflow.json`
- "GitHub Repo Workflows Sync" → `github-repo-workflows-sync.json`

## Benefits
- **🔄 Automatic Backup**: Never lose your n8n workflows
- **📝 Version Control**: Track changes and revert if needed
- **🔀 Team Collaboration**: Share workflows via Git
- **🚀 Deployment**: Easily restore workflows to new n8n instances
- **📊 Audit Trail**: See when and how workflows changed

## Usage Scenarios

### For Developers
- Clone this repository to get all team workflows
- Make changes to workflows in n8n, and they'll automatically sync here
- Review workflow changes through GitHub pull requests

### For DevOps
- Use these JSON files to deploy workflows to different environments
- Implement CI/CD pipelines that include workflow deployment
- Monitor workflow changes through GitHub notifications

### For Backup & Recovery
- Restore individual workflows by importing JSON files into n8n
- Recover from n8n instance failures using these backup files
- Migrate workflows between different n8n installations

## Important Notes
- **Do not manually edit** JSON files in this folder - changes should be made in n8n
- **Files are automatically managed** by the sync workflow
- **Commit messages** include timestamps for tracking when syncs occurred
- **Placeholder workflows** are automatically filtered out during sync

## Related Files
- `workflow.md` - Documentation for the sync automation workflow
- `t.json` - Example of the sync workflow definition itself

This folder represents a **living backup** of your n8n automation infrastructure, ensuring your workflows are always safe, versioned, and accessible.
