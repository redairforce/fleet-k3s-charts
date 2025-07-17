#!/bin/bash

# Fleet Repository GitHub Preparation Script
# This script helps prepare the repository for public GitHub upload

echo "🚀 Fleet Repository GitHub Preparation"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check for potential secrets
check_secrets() {
    echo -e "\n${YELLOW}🔍 Checking for potential secrets...${NC}"
    
    # Check for API keys (excluding placeholders and documentation)
    echo "Checking for API keys..."
    API_KEYS=$(grep -r -i "api.*key.*:" . | grep -v PLACEHOLDER | grep -v "api_key:" | grep -v "base64-encoded" | grep -v "README.md" | grep -v "SECURITY.md" | grep -v "prepare-for-github.sh" | head -5)
    if [ -n "$API_KEYS" ]; then
        echo -e "${RED}⚠️  Potential API keys found:${NC}"
        echo "$API_KEYS"
        return 1
    fi
    
    # Check for passwords (excluding placeholders and documentation)
    echo "Checking for passwords..."
    PASSWORDS=$(grep -r -i "password.*:" . | grep -v PLACEHOLDER | grep -v "password:" | grep -v "base64-encoded" | grep -v "README.md" | grep -v "SECURITY.md" | grep -v "prepare-for-github.sh" | grep -v "password masked" | head -5)
    if [ -n "$PASSWORDS" ]; then
        echo -e "${RED}⚠️  Potential passwords found:${NC}"
        echo "$PASSWORDS"
        return 1
    fi
    
    # Check for tokens (excluding placeholders and documentation)
    echo "Checking for tokens..."
    TOKENS=$(grep -r -i "token.*:" . | grep -v PLACEHOLDER | grep -v "api-token:" | grep -v "base64-encoded" | grep -v "README.md" | grep -v "SECURITY.md" | grep -v "prepare-for-github.sh" | grep -v "API token" | head -5)
    if [ -n "$TOKENS" ]; then
        echo -e "${RED}⚠️  Potential tokens found:${NC}"
        echo "$TOKENS"
        return 1
    fi
    
    echo -e "${GREEN}✅ No obvious secrets found${NC}"
    return 0
}

# Function to verify placeholders are in place
check_placeholders() {
    echo -e "\n${YELLOW}🔍 Verifying placeholders are in place...${NC}"
    
    # Check for placeholders
    PLACEHOLDERS=$(grep -r "PLACEHOLDER" apps/ | wc -l)
    CHANGE_ME=$(grep -r "CHANGE_ME" apps/ | wc -l)
    
    if [ "$PLACEHOLDERS" -eq 0 ] && [ "$CHANGE_ME" -eq 0 ]; then
        echo -e "${RED}⚠️  No placeholders found - this might indicate missing secret management${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Found $PLACEHOLDERS placeholder(s) and $CHANGE_ME CHANGE_ME pattern(s)${NC}"
    return 0
}

# Function to check file structure
check_structure() {
    echo -e "\n${YELLOW}🔍 Checking repository structure...${NC}"
    
    # Check for required files
    if [ ! -f "README.md" ]; then
        echo -e "${RED}⚠️  README.md not found${NC}"
        return 1
    fi
    
    if [ ! -f ".gitignore" ]; then
        echo -e "${RED}⚠️  .gitignore not found${NC}"
        return 1
    fi
    
    if [ ! -f "SECURITY.md" ]; then
        echo -e "${RED}⚠️  SECURITY.md not found${NC}"
        return 1
    fi
    
    # Check for fleet-values.yaml files
    FLEET_VALUES=$(find apps/ -name "fleet-values.yaml" | wc -l)
    if [ "$FLEET_VALUES" -eq 0 ]; then
        echo -e "${RED}⚠️  No fleet-values.yaml files found${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Repository structure looks good${NC}"
    echo -e "${GREEN}✅ Found $FLEET_VALUES fleet-values.yaml files${NC}"
    return 0
}

# Function to check for excluded files
check_excluded_files() {
    echo -e "\n${YELLOW}🔍 Checking for files that should be excluded...${NC}"
    
    # Check for sensitive files that should be in .gitignore
    SENSITIVE_FILES=""
    
    if [ -f "secrets-template.yaml" ]; then
        SENSITIVE_FILES="$SENSITIVE_FILES secrets-template.yaml"
    fi
    
    if [ -f "exported.txt" ]; then
        SENSITIVE_FILES="$SENSITIVE_FILES exported.txt"
    fi
    
    if [ -f "import.txt" ]; then
        SENSITIVE_FILES="$SENSITIVE_FILES import.txt"
    fi
    
    if [ -f "scrubbed.txt" ]; then
        SENSITIVE_FILES="$SENSITIVE_FILES scrubbed.txt"
    fi
    
    if [ -f "export_import.sh" ]; then
        SENSITIVE_FILES="$SENSITIVE_FILES export_import.sh"
    fi
    
    if [ -d "scrubbed_apps" ]; then
        SENSITIVE_FILES="$SENSITIVE_FILES scrubbed_apps/"
    fi
    
    if [ -n "$SENSITIVE_FILES" ]; then
        echo -e "${RED}⚠️  Sensitive files found that should be excluded:${NC}"
        echo "$SENSITIVE_FILES"
        echo -e "${YELLOW}These files should be removed or added to .gitignore${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ No sensitive files found${NC}"
    return 0
}

# Function to show summary
show_summary() {
    echo -e "\n${YELLOW}📋 Repository Summary${NC}"
    echo "===================="
    
    APP_COUNT=$(ls -1 apps/ | wc -l)
    CHART_COUNT=$(find apps/ -name "Chart.yaml" | wc -l)
    
    echo "📁 Applications: $APP_COUNT"
    echo "📊 Helm Charts: $CHART_COUNT"
    echo "🔐 Secret Management: Init container pattern"
    echo "🌐 Domain Management: Fleet values override"
    echo "📚 Documentation: README.md, SECURITY.md"
}

# Function to provide next steps
show_next_steps() {
    echo -e "\n${YELLOW}🚀 Next Steps for GitHub Upload${NC}"
    echo "==============================="
    echo "1. Review all security checks above"
    echo "2. Initialize git repository:"
    echo "   git init"
    echo "   git add ."
    echo "   git commit -m 'Initial commit: Fleet Helm charts for k3s deployment'"
    echo ""
    echo "3. Create GitHub repository and push:"
    echo "   git remote add origin https://github.com/your-username/fleet-k3s-charts.git"
    echo "   git branch -M main"
    echo "   git push -u origin main"
    echo ""
    echo "4. Configure Fleet to use your GitHub repository"
    echo "5. Deploy secrets to your cluster (see README.md)"
    echo "6. Test deployments before production use"
}

# Main execution
main() {
    # Run all checks
    FAILED=0
    
    check_secrets || FAILED=1
    check_placeholders || FAILED=1
    check_structure || FAILED=1
    check_excluded_files || FAILED=1
    
    show_summary
    
    if [ $FAILED -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All checks passed! Repository is ready for GitHub upload.${NC}"
        show_next_steps
    else
        echo -e "\n${RED}❌ Some checks failed. Please address the issues above before uploading to GitHub.${NC}"
        exit 1
    fi
}

# Run main function
main