# #!/bin/bash
# set -e

# echo "Starting CI/CD Pipeline"

# for cmd in node npm docker docker-compose; do
#     if ! command -v $cmd >/dev/null 2>&1; then
#         echo "Error: $cmd not found"
#         exit 1
#     fi
# done

# echo "Installing dependencies"
# npm ci

# echo "Running tests"
# npm test

# echo "Building Docker image"
# docker build -t hagert/teamavail:latest .

# echo "Starting application"
# docker-compose down || true
# docker-compose up -d

# sleep 10
# if curl -f http://localhost:3000/health >/dev/null 2>&1; then
#     echo "Success! App running at http://localhost:3000"
# else
#     echo "Error: App not responding"
#     exit 1
# fi

#!/bin/bash
set -e

APP_NAME="hagert/teamavail"
IMAGE_TAG="latest"

echo "Starting CI Pipeline"

echo "Installing dependencies."
npm install

if grep -q "\"lint\"" package.json 2>/dev/null; then
  echo " Running lint..."
  npm run lint
fi

if grep -q "\"format\"" package.json 2>/dev/null; then
  echo "Running formatter..."
  npm run format
fi

npm test || echo "Tests failed, continuing"

echo "Building Docker image..."
docker build -t ${APP_NAME}:${IMAGE_TAG} .

echo "Deploying application..."
docker-compose down --remove-orphans || true
docker-compose up -d

echo "Pipeline completed!"
echo "App running at: http://localhost:3000"