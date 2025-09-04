#!/bin/bash
# Dockerfile validation script for SageAttention
set -e

echo "🔍 Validating Dockerfiles with hadolint..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run hadolint
validate_dockerfile() {
    local dockerfile=$1
    echo "Validating $dockerfile..."
    
    if docker run --rm -i hadolint/hadolint:latest-debian --config /.hadolint.yaml < "$dockerfile" 2>&1; then
        echo -e "${GREEN}✅ $dockerfile passed validation${NC}"
        return 0
    else
        echo -e "${RED}❌ $dockerfile failed validation${NC}"
        return 1
    fi
}

# Main validation
failed=0

echo "Dockerfile validation results:"
echo "==============================="

# Validate Linux Dockerfile
if ! validate_dockerfile "dockerfile.builder.linux"; then
    failed=1
fi

echo ""

# Validate Windows Dockerfile
if ! validate_dockerfile "dockerfile.builder.windows"; then
    failed=1
fi

echo ""
echo "==============================="

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}🎉 All Dockerfiles passed validation!${NC}"
    exit 0
else
    echo -e "${RED}💥 Some Dockerfiles failed validation${NC}"
    exit 1
fi