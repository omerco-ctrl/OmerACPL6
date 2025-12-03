#!/usr/bin/env bash
set -euo pipefail

##############################################
# publish.sh — First-time repo setup + publish
##############################################

VERSION="$1"
PODSPEC=$(ls *.podspec | head -n 1)
REPO="git@github.com:omerco-ctrl/OmerACPL6.git"
REPO_NAME="OmerACPL6"

if [[ -z "${VERSION:-}" ]]; then
  echo "❌ Version missing"
  echo "Usage: ./publish.sh <version>"
  exit 1
fi

echo "🚀 Starting first-time setup + publish for $REPO_NAME v$VERSION"


###########################################################
# STEP 1 — FIRST TIME REPOSITORY INITIALIZATION (if empty)
###########################################################
if [[ ! -d .git ]]; then
  echo "📦 Initializing new Git repo..."

  echo "# $REPO_NAME" > README.md
  git init
  git add README.md
  git commit -m "first commit"

  git branch -M main
  git remote add origin "$REPO"
  git push -u origin main

  echo "✔ main pushed to GitHub"

  # Create master branch
  echo "📌 Creating branch master..."
  git checkout -b master
  git push -u origin master

  echo "✔ master branch pushed"

  # Set default branch = master (requires gh CLI)
  if command -v gh >/dev/null 2>&1; then
    echo "⚙️ Setting GitHub default branch to master..."
    gh repo edit "$REPO_NAME" --default-branch master || true
  else
    echo "⚠️ gh not installed → set default branch manually in GitHub UI"
  fi

  echo "🎉 First-time repo setup completed!"
fi


###########################################################
# STEP 2 — UPDATE VERSION INSIDE PODSPEC
###########################################################
echo "🔧 Updating $PODSPEC version to $VERSION"

sed -i '' -E \
  "/^[[:space:]]*s\.version[[:space:]]*=/ s/['\"][^'\"]+['\"]/\"${VERSION}\"/" \
  "$PODSPEC"

echo "✔ Podspec updated"


###########################################################
# STEP 3 — ADD FILES BUT EXCLUDE ALL .sh FILES
###########################################################
echo "📦 Staging allowed files..."

git rm -r --cached . >/dev/null 2>&1 || true

# Add everything EXCEPT .sh scripts
git add -f \
  ACPaymentLinks.xcframework \
  "$PODSPEC" \
  README.md \
  LICENSE \
  Notes.md || true

echo "✔ Allowed files staged (scripts excluded)"


###########################################################
# STEP 4 — COMMIT
###########################################################
echo "📝 Committing..."

git commit -m "Release $VERSION" || echo "⚠ Nothing to commit"
echo "✔ Commit done"


###########################################################
# STEP 5 — TAG HANDLING
###########################################################
echo "🏷 Removing old tag if exists..."

git tag -d "$VERSION" 2>/dev/null || true
git push origin ":refs/tags/$VERSION" 2>/dev/null || true

echo "✔ Old tag removed"


echo "🏷 Creating new tag: $VERSION"
git tag "$VERSION"
git push
git push --tags

echo "✔ Tag pushed"


###########################################################
# STEP 6 — VALIDATE XCFRAMEWORK INSIDE THE TAG
###########################################################
echo "🔍 Checking Info.plist inside tag..."

if git show "$VERSION":ACPaymentLinks.xcframework/Info.plist >/dev/null 2>&1; then
  echo "✔ Framework OK inside tag"
else
  echo "❌ ERROR: Missing Info.plist inside tag"
  exit 1
fi


###########################################################
# STEP 7 — pod spec lint
###########################################################
echo "🧪 Running pod spec lint…"

pod spec lint "$PODSPEC" --allow-warnings --verbose --no-clean

echo "✔ pod spec lint passed"


###########################################################
# STEP 8 — READY FOR TRUNK PUSH
###########################################################
echo ""
echo "🎉 Publish flow complete!"
echo "👉 To push to trunk:"
echo "    pod trunk push $PODSPEC --allow-warnings"
echo ""
echo "Version $VERSION is prepared successfully!"


###########################################################
# STEP 9 — AUTO TRUNK PUSH (added as requested)
###########################################################
echo "🚚 Now pushing to CocoaPods trunk…"
pod trunk push "$PODSPEC" --allow-warnings
echo "✔ Successfully pushed to trunk!"
echo ""
echo "🎉 Version $VERSION fully published!"
echo ""
