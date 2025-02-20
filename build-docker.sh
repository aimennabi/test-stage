#!/bin/bash

set -e  # Exit immediately if any command fails

echo "🛠 Building Docker image..."
docker build -t lambda-app .

echo "🚀 Running Lambda container..."
docker run -d -p 3001:8080 --name lambda-app-container lambda-app

echo "⏳ Waiting for Lambda to be ready..."
sleep 5  # Allow the container to start

echo "🔎 Invoking Lambda function with curl..."
curl -d @events/event.json http://localhost:3001/2015-03-31/functions/function/invocations -o response.json

echo "📄 Checking response..."
if grep -q '"statusCode": 200' response.json; then
    echo "✅ Lambda function is working correctly!"
    docker stop lambda-app-container
    docker rm lambda-app-container
    exit 0
else
    echo "❌ Lambda function test failed!"
    docker stop lambda-app-container
    docker rm lambda-app-container
    exit 1
fi
