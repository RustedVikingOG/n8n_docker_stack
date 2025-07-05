# Workflows Index

This document provides an index of all n8n workflows available in this folder, with their names and purposes clearly documented.

## Workflows

### github_repo_workflows_sync
**File:** `github_repo_workflows_sync.json`
**Status:** Active
**Last Updated:** 2025-06-21T07:16:07.972Z
**Purpose:** Automatically synchronizes n8n workflows between the n8n instance and this GitHub repository. Runs weekly (every Monday) to ensure bidirectional sync, maintaining backups and resolving conflicts by keeping the most recently updated version.

### delete_archived_workflows
**File:** `delete_archived_workflows.json`
**Status:** Inactive
**Last Updated:** 2025-06-20T19:45:32.280Z
**Purpose:** Utility workflow for cleaning up archived workflows from the n8n instance. Manually triggered to remove workflows that have been marked as archived.

### github_workflows_backup
**File:** `github_workflows_backup.json`
**Status:** Inactive
**Last Updated:** 2025-06-20T20:19:01.649Z
**Purpose:** Creates backups of n8n workflows to GitHub repository. This appears to be a scheduled backup workflow that complements the sync functionality.

### gtree_build_context
**File:** `gtree_build_context.json`
**Status:** Inactive
**Last Updated:** 2025-06-24T20:04:15.999Z
**Purpose:** Builds context information using gtree (Git tree) functionality. This workflow is executed by other workflows and works with repository structure analysis.

### gtree_creator
**File:** `gtree_creator.json`
**Status:** Inactive
**Last Updated:** 2025-06-24T19:34:06.348Z
**Purpose:** Creates Git tree representations for repositories. Takes inputs for path, owner, and repo parameters to generate tree structures for repository analysis.

### gtree_get
**File:** `gtree_get.json`
**Status:** Inactive
**Last Updated:** 2025-06-24T19:52:20.192Z
**Purpose:** Retrieves Git tree information from repositories. Works with owner and repo parameters to fetch repository tree data, likely used by other gtree workflows.

### test
**File:** `test.json`
**Status:** Inactive
**Last Updated:** 2025-06-20T20:58:22.335Z
**Purpose:** Simple test workflow for development and debugging purposes. Contains basic manual trigger and set operations for testing workflow functionality.

### zip_make
**File:** `zip_make.json`
**Status:** Inactive
**Last Updated:** 2025-06-24T05:26:37.091Z
**Purpose:** Creates ZIP archives from files in the `/files` directory. Manually triggered workflow that compresses files for download or distribution.

### zip_send
**File:** `zip_send.json`
**Status:** Inactive
**Last Updated:** 2025-06-24T05:26:28.273Z
**Purpose:** Serves ZIP files via webhook endpoints. Provides download functionality for ZIP files created by other workflows, accessible via HTTP endpoints.

## Workflow Categories

### 🔄 Synchronization & Backup
- `github_repo_workflows_sync` - Main sync workflow (Active)
- `github_workflows_backup` - Backup functionality
- `delete_archived_workflows` - Cleanup utility

### 🌳 Git Tree Analysis
- `gtree_creator` - Tree creation
- `gtree_build_context` - Context building
- `gtree_get` - Tree retrieval

### 📦 File Management
- `zip_make` - Archive creation
- `zip_send` - Archive distribution

### 🧪 Development
- `test` - Testing and debugging

## Usage Notes

- **Active workflows** run automatically based on their configured triggers
- **Inactive workflows** require manual execution or activation
- Most workflows are designed to work together as part of larger automation pipelines
- The `github_repo_workflows_sync` workflow is the core component that maintains this repository

## File Management

All workflow files follow the naming convention: `{workflow-name}.json`

For detailed information about the purpose and functionality of this workflows folder, see `purpose.md`.