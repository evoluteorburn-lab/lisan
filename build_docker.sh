#!/bin/bash

# Build Lisan APK using Docker (with sudo support)
# Usage: ./build_docker.sh

set -e

echo "================================"
echo "LISAN APK BUILDER (Docker)"
echo "================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first:"
    echo "   https://docs.docker.com/get-docker/"
    exit 1
fi

echo "✅ Docker found"

# Detect if we need sudo
DOCKER_CMD="docker"
if ! docker info &> /dev/null; then
    echo "⚠️  Docker requires sudo, trying with sudo..."
    if sudo docker info &> /dev/null; then
        DOCKER_CMD="sudo docker"
        echo "✅ Sudo access confirmed"
    else
        echo "❌ Cannot access Docker. Try:"
        echo "   sudo usermod -aG docker $USER"
        echo "   Then logout and login again"
        exit 1
    fi
fi

# Build Docker image
echo ""
echo "🔨 Building Docker image..."
echo "This may take 5-10 minutes on first run"
echo ""

$DOCKER_CMD build -t lisan-builder .

# Run container and extract APK
echo ""
echo "📦 Building APK inside container..."
echo ""

# Create output directory
mkdir -p build_output

$DOCKER_CMD run --rm \
    -v "$(pwd)/build_output:/output" \
    lisan-builder \
    bash -c "cp /app/build/app/outputs/flutter-apk/app-release.apk /output/"

# Check if APK was created
if [ -f "build_output/app-release.apk" ]; then
    echo ""
    echo "✅ SUCCESS! APK built:"
    ls -lh build_output/app-release.apk
    echo ""
    echo "📱 Install on your phone:"
    echo "   adb install build_output/app-release.apk"
    echo "   or copy to phone and install manually"
    echo ""
    echo "🔑 Don't forget to add your API keys to .env before building!"
else
    echo "❌ Build failed. Check logs above."
    exit 1
fi