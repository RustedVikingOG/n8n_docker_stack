# CHANGELOG

## Previous entries (newest on top)

**2025-06-24 - Wikus Bergh**
feat: implement smart workflow import with duplicate detection
- Add custom Dockerfile extending n8n base image with jq for JSON parsing
- Update docker-compose to use custom build instead of official image
- Rewrite import script to check existing workflows before importing
- Add duplicate detection to prevent re-importing existing workflows
- Support both JSON and table format parsing from n8n list command
- Add sample test workflow for validation

