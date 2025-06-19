#!/bin/sh

echo "🚀 Starting workflow import process..."

# Wait for n8n to be fully initialized
echo "⏳ Waiting for n8n database to be ready..."
sleep 15

# Check if workflows directory exists and has files
if [ ! -d "/workflows" ]; then
    echo "❌ Workflows directory not found at /workflows"
    exit 0
fi

# Count workflow files
workflow_count=$(find /workflows -name "*.json" -type f | wc -l)
echo "📁 Found $workflow_count workflow files to import"

if [ "$workflow_count" -eq 0 ]; then
    echo "ℹ️  No workflow files found in /workflows directory"
    exit 0
fi

# Import all workflows from directory
echo "📥 Importing all workflows from /workflows directory..."
if n8n import:workflow --input=/workflows --separate 2>&1; then
    echo "✅ Successfully imported workflows from directory"
    imported=$workflow_count
    failed=0
else
    echo "❌ Failed to import workflows"
    imported=0
    failed=$workflow_count
fi

echo ""
echo "📊 Import Summary:"
echo "   ✅ Successfully imported: $imported workflows"
echo "   ❌ Failed to import: $failed workflows"
echo "   📁 Total processed: $((imported + failed)) workflows"
echo ""

if [ "$imported" -gt 0 ]; then
    echo "🎉 Workflow import completed successfully!"
else
    echo "⚠️  No workflows were imported"
fi

echo "🏁 Import process finished"
