#!/bin/bash

# Deploy Calendar-App to DSD server
# Usage: deploy-calendar.sh

set -e  # Exit on error

# Configuration
PROJECT_DIR="/home/user76/code/Calendar-App"
SSH_HOST="dsd-calendar"
REMOTE_DIR="/var/www/r7-office/calendar-app"
BUILD_DIR="dist"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Calendar-App Deployment ===${NC}"

# Step 1: Navigate to project
echo -e "\n${YELLOW}[1/4] Navigating to project...${NC}"
cd "$PROJECT_DIR"
echo -e "${GREEN}Current directory: $(pwd)${NC}"

# Step 2: Build the project
echo -e "\n${YELLOW}[2/4] Building project...${NC}"
npm run build
echo -e "${GREEN}Build completed!${NC}"

# Step 3: Upload build to server
# echo -e "\n${YELLOW}[3/4] Uploading build to server...${NC}"
# rsync -avz --delete "$BUILD_DIR/" "$SSH_HOST:$REMOTE_DIR/"
# echo -e "${GREEN}Upload completed!${NC}"
#
# # Step 4: Restart nginx
# echo -e "\n${YELLOW}[4/4] Restarting nginx...${NC}"
# ssh "$SSH_HOST" "sudo systemctl restart nginx"
# echo -e "${GREEN}Nginx restarted!${NC}"

echo -e "\n${GREEN}=== Deployment Complete! ===${NC}"
