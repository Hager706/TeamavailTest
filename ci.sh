
#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' 

echo -e "${YELLOW} Starting CI/CD Pipeline...${NC}"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${YELLOW} Checking prerequisites...${NC}"
if ! command_exists node; then
    echo -e "${RED} Node.js not found. Please install Node.js first.${NC}"
    exit 1
fi

if ! command_exists npm; then
    echo -e "${RED}npm not found. Please install npm first.${NC}"
    exit 1
fi

if ! command_exists docker; then
    echo -e "${RED}Docker not found. Please install Docker first.${NC}"
    exit 1
fi

echo -e "${GREEN}All prerequisites found${NC}"

echo -e "${YELLOW}Installing dependencies...${NC}"
npm install
if [ $? -ne 0 ]; then
    echo -e "${RED} Failed to install dependencies${NC}"
    exit 1
fi
echo -e "${GREEN}Dependencies installed${NC}"

if npm run --silent lint 2>/dev/null; then
    echo -e "${YELLOW}Running linting...${NC}"
    npm run lint
    echo -e "${GREEN}Linting passed${NC}"
else
    echo -e "${YELLOW}⚠️  No lint script found, skipping linting${NC}"
fi

if npm run --silent test 2>/dev/null; then
    echo -e "${YELLOW} Running tests...${NC}"
    npm test
    if [ $? -ne 0 ]; then
        echo -e "${RED} Tests failed${NC}"
        exit 1
    fi
    echo -e "${GREEN} Tests passed${NC}"
else
    echo -e "${YELLOW}⚠️  No test script found, skipping tests${NC}"
fi

echo -e "${YELLOW}Building Docker image...${NC}"
docker build -t availability-tracker .
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to build Docker image${NC}"
    exit 1
fi
echo -e "${GREEN}Docker image built successfully${NC}"

echo -e "${YELLOW} Starting application with Docker Compose...${NC}"
docker-compose down 
docker-compose up -d
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to start application${NC}"
    exit 1
fi

echo -e "${GREEN}Pipeline completed successfully!${NC}"
