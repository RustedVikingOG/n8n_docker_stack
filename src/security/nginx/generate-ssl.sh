#!/bin/bash

# SSL Certificate Generation Script for n8n Docker Stack
# Generates self-signed certificates for development/testing
# For production, replace with Let's Encrypt or your CA-signed certificates

set -e

SSL_DIR="./ssl"
COUNTRY="US"
STATE="CA"
CITY="San Francisco"
ORG="n8n Docker Stack"
OU="IT Department"
CN="localhost"
EMAIL="admin@localhost"

echo "🔐 Generating SSL certificates for n8n Docker Stack..."

# Create SSL directory if it doesn't exist
mkdir -p "$SSL_DIR"

# Generate private key
echo "📝 Generating private key..."
openssl genrsa -out "$SSL_DIR/nginx.key" 2048

# Generate certificate signing request
echo "📋 Generating certificate signing request..."
openssl req -new -key "$SSL_DIR/nginx.key" -out "$SSL_DIR/nginx.csr" -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$OU/CN=$CN/emailAddress=$EMAIL"

# Generate self-signed certificate valid for 365 days
echo "🏆 Generating self-signed certificate..."
openssl x509 -req -days 365 -in "$SSL_DIR/nginx.csr" -signkey "$SSL_DIR/nginx.key" -out "$SSL_DIR/nginx.crt"

# Create certificate with Subject Alternative Names for localhost and container names
echo "🌐 Creating certificate with SAN for multiple hostnames..."
cat > "$SSL_DIR/cert.conf" << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = $COUNTRY
ST = $STATE
L = $CITY
O = $ORG
OU = $OU
CN = $CN
emailAddress = $EMAIL

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = n8n
DNS.3 = nginx
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

# Generate new certificate with SAN
openssl req -new -key "$SSL_DIR/nginx.key" -out "$SSL_DIR/nginx_san.csr" -config "$SSL_DIR/cert.conf"
openssl x509 -req -days 365 -in "$SSL_DIR/nginx_san.csr" -signkey "$SSL_DIR/nginx.key" -out "$SSL_DIR/nginx.crt" -extensions v3_req -extfile "$SSL_DIR/cert.conf"

# Set proper permissions
chmod 600 "$SSL_DIR/nginx.key"
chmod 644 "$SSL_DIR/nginx.crt"

# Display certificate information
echo "✅ SSL certificate generated successfully!"
echo "📄 Certificate details:"
openssl x509 -in "$SSL_DIR/nginx.crt" -text -noout | grep -E "(Subject:|DNS:|IP Address:|Not Before|Not After)"

echo ""
echo "🚀 Certificate files created:"
echo "   Certificate: $SSL_DIR/nginx.crt"
echo "   Private Key: $SSL_DIR/nginx.key"
echo ""
echo "⚠️  NOTE: This is a self-signed certificate for development/testing."
echo "   For production, use Let's Encrypt or a CA-signed certificate."
echo "   Browsers will show a security warning for self-signed certificates."

# Cleanup temporary files
rm -f "$SSL_DIR/nginx.csr" "$SSL_DIR/nginx_san.csr" "$SSL_DIR/cert.conf"

echo "🧹 Cleanup completed."
