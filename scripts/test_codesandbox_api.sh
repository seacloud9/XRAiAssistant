#!/bin/bash

# Test CodeSandbox API without authentication (public sandbox)
# This tests if the CodeSandbox Define API is accessible from this network

echo "🧪 Testing CodeSandbox Define API..."
echo ""

# Create a simple test sandbox
TEST_JSON='{
  "files": {
    "package.json": {
      "content": "{\"name\":\"test-sandbox\",\"version\":\"1.0.0\",\"main\":\"index.js\",\"dependencies\":{\"react\":\"^18.2.0\",\"react-dom\":\"^18.2.0\"}}",
      "isBinary": false
    },
    "index.js": {
      "content": "console.log(\"Hello from XRAiAssistant test!\");",
      "isBinary": false
    },
    "public/index.html": {
      "content": "<!DOCTYPE html><html><head><title>Test</title></head><body><div id=\"root\"></div></body></html>",
      "isBinary": false
    }
  }
}'

echo "📤 Sending POST request to CodeSandbox API..."
echo "📦 Payload size: $(echo "$TEST_JSON" | wc -c) bytes"
echo ""

# Make the API call
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "https://codesandbox.io/api/v1/sandboxes/define" \
  -H "Content-Type: application/json" \
  -d "$TEST_JSON")

# Extract HTTP status code (last line)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
# Extract response body (everything except last line)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "📥 HTTP Status: $HTTP_CODE"
echo ""

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo "✅ CodeSandbox API is accessible!"
    echo ""
    echo "Response:"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
    
    # Extract sandbox_id if available
    SANDBOX_ID=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('sandbox_id', 'N/A'))" 2>/dev/null)
    if [ "$SANDBOX_ID" != "N/A" ]; then
        echo ""
        echo "🎉 Sandbox created successfully!"
        echo "🔗 URL: https://codesandbox.io/s/$SANDBOX_ID"
    fi
else
    echo "❌ CodeSandbox API request failed"
    echo ""
    echo "Response:"
    echo "$BODY"
    echo ""
    echo "💡 Possible issues:"
    echo "  - Network connectivity problems"
    echo "  - Firewall blocking codesandbox.io"
    echo "  - CodeSandbox API is down"
    echo "  - Invalid JSON format"
fi

echo ""
echo "🔍 Testing connectivity to codesandbox.io..."
if ping -c 1 codesandbox.io >/dev/null 2>&1; then
    echo "✅ codesandbox.io is reachable"
else
    echo "❌ Cannot reach codesandbox.io"
fi
