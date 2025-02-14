#!/bin/bash

# Exit on any error
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Checking dependencies...${NC}"

# Check dependencies
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud is not installed. Please install Google Cloud SDK.${NC}"
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed. Please install Terraform.${NC}"
    exit 1
fi

# Check gcloud auth
if ! gcloud auth list --format="value(account)" 2>/dev/null | grep -q "@"; then
    echo -e "${RED}Error: gcloud is not authenticated. Run 'gcloud auth login' first.${NC}"
    exit 1
fi

# Check for terraform.tfvars
if [ ! -f "terraform.tfvars" ]; then
    if [ -f "terraform.tfvars.example" ]; then
        echo -e "${YELLOW}terraform.tfvars is missing. Copying from example...${NC}"
        cp terraform.tfvars.example terraform.tfvars
        echo -e "${YELLOW}Please review and update terraform.tfvars before proceeding${NC}"
        exit 1
    else
        echo -e "${RED}Error: terraform.tfvars is missing and no example file found.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}All checks passed! Proceeding with Terraform setup...${NC}"

# Run Terraform Commands
echo -e "${GREEN}Initializing Terraform...${NC}"
terraform init

echo -e "${GREEN}Running Terraform Plan...${NC}"
terraform plan

echo -e "${GREEN}Applying Terraform Configuration...${NC}"
terraform apply -auto-approve

echo -e "${GREEN}Terraform setup completed successfully! 🚀${NC}"
