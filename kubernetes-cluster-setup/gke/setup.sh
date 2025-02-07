#!/bin/bash

# Exit on any error
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Checking dependencies...${NC}"

# 1️⃣ Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud is not installed. Please install Google Cloud SDK.${NC}"
    exit 1
fi

# 2️⃣ Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed. Please install Terraform.${NC}"
    exit 1
fi

# 3️⃣ Check if gcloud is authenticated
if ! gcloud auth list --format="value(account)" | grep -q "@"; then
    echo -e "${RED}Error: gcloud is not authenticated. Run 'gcloud auth login' first.${NC}"
    exit 1
fi

# 4️⃣ Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${RED}Error: terraform.tfvars is missing.${NC}"
    echo -e "${YELLOW}Please copy terraform.tfvars.example to terraform.tfvars and update it before proceeding.${NC}"
    echo -e "${YELLOW}Run: cp terraform.tfvars.example terraform.tfvars${NC}"
    exit 1
fi

echo -e "${GREEN}All checks passed! Proceeding with Terraform setup...${NC}"

# 5️⃣ Run Terraform Commands
echo -e "${GREEN}Initializing Terraform...${NC}"
terraform init

echo -e "${GREEN}Running Terraform Plan...${NC}"
terraform plan

echo -e "${GREEN}Applying Terraform Configuration...${NC}"
terraform apply -auto-approve

echo -e "${GREEN}Terraform setup completed successfully! 🚀${NC}"
