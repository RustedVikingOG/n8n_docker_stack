echo "🔁 Checking existing workflows in n8n..."

# Wait for n8n to be ready
echo "😴 Sleeping for 15 seconds while waiting for n8n..."
sleep 15

# Get existing workflow IDs from n8n instance
echo "🔍 Checking n8n list:workflow command..."
RAW_OUTPUT=$(n8n list:workflow 2>/dev/null)
echo "Raw n8n output (first 200 chars): ${RAW_OUTPUT:0:200}"
echo "Raw n8n output (full):"
echo "$RAW_OUTPUT"

if [ $? -eq 0 ] && [ -n "$RAW_OUTPUT" ]; then
  # Try to check if it's JSON format
  if echo "$RAW_OUTPUT" | jq empty 2>/dev/null; then
    echo "✅ Output is valid JSON, parsing..."
    EXISTING_IDS=$(echo "$RAW_OUTPUT" | jq -r '.[].id // empty' 2>/dev/null)
  else
    echo "⚠️  Output is not JSON format, trying to parse as table..."
    # Extract IDs from pipe-separated format (ID|name)
    EXISTING_IDS=$(echo "$RAW_OUTPUT" | grep '|' | cut -d'|' -f1)
  fi
else
  echo "⚠️  n8n list:workflow failed or returned empty"
  EXISTING_IDS=""
fi

# Loop over local workflow files
for file in /workflows/*.json; do
  # Extract workflow ID from JSON (handle potential parsing errors)
  LOCAL_ID=$(jq -r '.id // empty' "$file" 2>/dev/null)

  # Skip if null or empty
  if [ -z "$LOCAL_ID" ] || [ "$LOCAL_ID" = "null" ]; then
    echo "⚠️  No ID found in $file, uploading as new..."
    n8n import:workflow --input="$file"
    continue
  fi

  # Check if ID already exists
  echo "🔍 Checking if LOCAL_ID '$LOCAL_ID' exists in EXISTING_IDS:"
  if echo "$EXISTING_IDS" | grep -Fxq "$LOCAL_ID"; then
    echo "⏭️  Workflow $LOCAL_ID already exists, skipping $file"
  else
    echo "📥 Importing new workflow $file with ID $LOCAL_ID"
    n8n import:workflow --input="$file"
  fi
done

echo "✅ Workflow import check complete"
