#!/bin/bash

# Build script for React project
set -e

# Change to the directory where this script is located
cd "$(dirname "${BASH_SOURCE[0]}")"

# Navigate to the frontend directory (parent of scripts)
cd ".."

echo "Building React project..."

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Run linting
echo "Running linter..."
npm run lint

# Build the project
echo "Building project..."
npm run build

echo "Build completed successfully!"