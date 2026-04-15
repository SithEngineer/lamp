#!/bin/bash

# Release script for Lamp Flutter app
# Creates a release branch, updates version, and opens a PR
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

# Check if working directory is dirty
if ! git diff --quiet; then
    echo "Error: Working directory has uncommitted changes."
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

# Show confirmation prompt
echo ""
read -p "Create release branch for v$NEW_VERSION? (y/N): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Aborted."
    exit 1
fi

# Create release branch
BRANCH_NAME="release/v$NEW_VERSION"
echo "Creating branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME"

# Update pubspec.yaml
sed -i.bak "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
rm -f pubspec.yaml.bak

# Commit changes
git add pubspec.yaml
git commit -m "Release v$NEW_VERSION"

# Push branch
echo "Pushing branch to origin..."
git push origin "$BRANCH_NAME"

# Create PR using gh CLI
echo "Creating pull request..."
gh pr create \
    --title "Release v$NEW_VERSION" \
    --body "Automated release PR for version $NEW_VERSION.

This PR updates the pubspec.yaml version.

**Next steps:**
1. Review and merge this PR
2. A tag will be automatically created upon merge
3. CI/CD will deploy the release" \
    --base main \
    --head "$BRANCH_NAME"

echo ""
echo "✓ Release branch created: $BRANCH_NAME"
echo "✓ Pull request opened"
echo ""
echo "Next steps:"
echo "1. Review the PR on GitHub"
echo "2. Merge the PR"
echo "3. Tag and deployment will happen automatically"

# Switch back to main
git checkout main
