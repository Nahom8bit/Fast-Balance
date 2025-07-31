#!/bin/bash

# Mini Mercado Release Script
# Usage: ./scripts/release.sh <version> <release_notes>

if [ $# -lt 2 ]; then
    echo "Usage: $0 <version> <release_notes>"
    echo "Example: $0 1.1.0 'Added new dashboard features'"
    exit 1
fi

VERSION=$1
RELEASE_NOTES=$2

echo "🚀 Starting release process for version $VERSION..."

# Update version in update_service.dart
echo "📝 Updating version in update_service.dart..."
sed -i "s/static const String _currentVersion = '.*';/static const String _currentVersion = '$VERSION';/" lib/update_service.dart

# Update version in pubspec.yaml
echo "📝 Updating version in pubspec.yaml..."
sed -i "s/version: .*/version: $VERSION+1/" pubspec.yaml

# Build the application
echo "🔨 Building Windows executable..."
flutter clean
flutter pub get
flutter build windows --release

# Check if build was successful
if [ ! -f "build/windows/x64/runner/Release/salaries_app.exe" ]; then
    echo "❌ Build failed! Executable not found."
    exit 1
fi

echo "✅ Build successful!"

# Create git tag
echo "🏷️ Creating git tag v$VERSION..."
git add .
git commit -m "Release version $VERSION

$RELEASE_NOTES"
git tag -a "v$VERSION" -m "Release version $VERSION

$RELEASE_NOTES"

# Push changes
echo "📤 Pushing changes to GitHub..."
git push origin main
git push origin "v$VERSION"

echo "🎉 Release process completed!"
echo "📋 Next steps:"
echo "1. Go to https://github.com/Nahom8bit/Fast-Balance/releases"
echo "2. Edit the release v$VERSION"
echo "3. Upload the executable: build/windows/x64/runner/Release/salaries_app.exe"
echo "4. Add release notes: $RELEASE_NOTES"
echo "5. Publish the release"

echo "📁 Executable location: build/windows/x64/runner/Release/salaries_app.exe" 