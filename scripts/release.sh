#!/bin/bash

# Release script for Lamp Flutter app
# Usage: ./scripts/release.sh [TYPE]
# TYPE can be: release (default), patch, minor, major

set -e

TYPE="${1:-release}"

echo "Checking prerequisites..."

# Check if on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Error: Must be on main branch. Current branch: $CURRENT_BRANCH"
    exit 1
fi

# Check if working directory is dirty (excluding pubspec.yaml which we'll modify)
if ! git diff --quiet -- . ':(exclude)pubspec.yaml'; then
    echo "Error: Working directory has uncommitted changes (excluding pubspec.yaml)."
    echo "Please commit or stash changes before releasing."
    git status --short
    exit 1
fi

# Read current version from pubspec.yaml
CURRENT_VERSION=$(grep "^version: " pubspec.yaml | sed 's/version: //')
echo "Current version: $CURRENT_VERSION"

# Parse version components (format: major.minor.patch+build)
MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)
PATCH_BUILD=$(echo "$CURRENT_VERSION" | cut -d. -f3)
PATCH=$(echo "$PATCH_BUILD" | cut -d+ -f1)
BUILD=$(echo "$PATCH_BUILD" | cut -d+ -f2)

# Calculate new version based on TYPE
case "$TYPE" in
    release)
        NEW_BUILD=$((BUILD + 1))
        NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}+${NEW_BUILD}"
        echo "Incrementing build number: $CURRENT_VERSION -> $NEW_VERSION"
        ;;
    patch)
        NEW_PATCH=$((PATCH + 1))
        NEW_VERSION="${MAJOR}.${MINOR}.${NEW_PATCH}+1"
        echo "Incrementing patch version: $CURRENT_VERSION -> $NEW_VERSION"
        ;;
    minor)
        NEW_MINOR=$((MINOR + 1))
        NEW_VERSION="${MAJOR}.${NEW_MINOR}.0+1"
        echo "Incrementing minor version: $CURRENT_VERSION -> $NEW_VERSION"
        ;;
    major)
        NEW_MAJOR=$((MAJOR + 1))
        NEW_VERSION="${NEW_MAJOR}.0.0+1"
        echo "Incrementing major version: $CURRENT_VERSION -> $NEW_VERSION"
        ;;
    *)
        echo "Error: Unknown TYPE '$TYPE'. Use: release, patch, minor, or major"
        exit 1
        ;;
esac

# Update pubspec.yaml
sed -i.bak "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
rm -f pubspec.yaml.bak

# Show confirmation prompt
echo ""
read -p "Proceed with release v$NEW_VERSION? (y/N): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Aborted. Reverting pubspec.yaml..."
    git checkout pubspec.yaml
    exit 1
fi

# Commit changes
git add pubspec.yaml
git commit -m "Release v$NEW_VERSION"

# Create annotated tag
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"

# Push to origin
git push origin main
git push origin "v$NEW_VERSION"

echo ""
echo "✓ Released v$NEW_VERSION"
echo "✓ CI/CD will deploy automatically"
