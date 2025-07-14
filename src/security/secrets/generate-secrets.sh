#!/bin/bash

# Secrets Generation Script for n8n Docker Stack
# Generates secure random passwords and encryption keys

set -e

SECRETS_DIR="."
SSL_DIR="../nginx/ssl"

echo "🔐 Generating secure secrets for n8n Docker Stack..."

# Create secrets directory
mkdir -p "$SECRETS_DIR"
mkdir -p "$SSL_DIR"

# Function to generate random password
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Function to generate encryption key
generate_encryption_key() {
    openssl rand -hex 32
}

# Generate database credentials
echo "📊 Generating database credentials..."
echo "n8n_user" > "$SECRETS_DIR/postgres_user.txt"
generate_password > "$SECRETS_DIR/postgres_password.txt"
echo "n8n_db" > "$SECRETS_DIR/postgres_db.txt"

# Generate n8n credentials
echo "🔧 Generating n8n credentials..."
echo "admin" > "$SECRETS_DIR/n8n_basic_auth_user.txt"
generate_password > "$SECRETS_DIR/n8n_basic_auth_password.txt"
generate_encryption_key > "$SECRETS_DIR/n8n_encryption_key.txt"

# Generate monitoring credentials
echo "📊 Generating monitoring credentials..."
echo "admin" > "$SECRETS_DIR/grafana_admin_user.txt"
generate_password > "$SECRETS_DIR/grafana_admin_password.txt"

# Set proper permissions (read-only for owner)
chmod 600 "$SECRETS_DIR"/*.txt

echo "✅ Secrets generated successfully!"
echo ""
echo "🔑 Generated secrets:"
echo "   Database User: $(cat $SECRETS_DIR/postgres_user.txt)"
echo "   Database Password: [HIDDEN]"
echo "   Database Name: $(cat $SECRETS_DIR/postgres_db.txt)"
echo "   n8n Auth User: $(cat $SECRETS_DIR/n8n_basic_auth_user.txt)"
echo "   n8n Auth Password: [HIDDEN]"
echo "   n8n Encryption Key: [HIDDEN]"
echo "   Grafana Admin User: $(cat $SECRETS_DIR/grafana_admin_user.txt)"
echo "   Grafana Admin Password: [HIDDEN]"
echo ""
echo "⚠️  IMPORTANT SECURITY NOTES:"
echo "   • Store these credentials securely"
echo "   • Do not commit secrets to version control"
echo "   • Rotate passwords regularly"
echo "   • Use environment-specific secrets for production"
echo ""
echo "📁 Secrets stored in: $SECRETS_DIR/"

# Create .gitignore to prevent accidental commits
cat > "$SECRETS_DIR/.gitignore" << EOF
# Ignore all secret files
*.txt
*.key
*.crt
*.pem

# But track this .gitignore file
!.gitignore
EOF

echo "🛡️  Created .gitignore to protect secrets from version control"
