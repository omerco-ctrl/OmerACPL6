# 📦 ACPaymentLinks

ACPaymentLinks is a lightweight, in-app iOS checkout SDK. This repository includes the source code, Cocoapods integration, and automated build & release flow.

---

## 🚧 Branching Workflow

- All development is done on **feature branches** pulled out of `develop`.
- When a feature is complete, it's merged into `develop`.
- Once QA approves a version, `develop` is merged into **`release/xcframework`**.
- From `release/xcframework`, we run the release script to:
  - Update version numbers
  - Build a new `.xcframework`
  - Tag and push to Git

---

## 🚀 Releasing a New Version

> ✅ **IMPORTANT:** Only run the release script from the `release/xcframework` branch, and only after QA approval.

### 1. ✅ Prerequisites

- Xcode command line tools
- Git
- macOS Terminal
- Permission to push to the repository

Ensure your branch is up to date:

```bash
git checkout release/xcframework
git pull
```

---

### 2. 🔐 Make the Script Executable

Run this once to allow the script to run:

```bash
chmod +x build.sh
```

---

### 3. 🏁 Run the Script

To build and release a new version:

```bash
./build.sh <version>
```

Example:

```bash
./build.sh 1.2.0
```

This will:

- Update the version in:
  - `ACPaymentLinks/Config/ACConfigManager.swift`
  - `ACPaymentLinks.podspec`
- Remove old builds
- Archive for iOS & iOS Simulator
- Create a fresh `.xcframework`
- Remove code signing metadata
- Unlock `Info.plist` files
- Commit, tag, and push to Git

---

## 🧰 Script Breakdown

Here’s what `build.sh` does step-by-step:

1. **Reads version argument**
2. **Updates**:
   - `sdkV = "X.X.X"` inside Swift file
   - `s.version = 'X.X.X'` inside `.podspec`
3. **Cleans** old archives & frameworks
4. **Archives**:
   - iOS device build
   - iOS simulator build
5. **Creates** a universal `.xcframework`
6. **Strips** code signing metadata
7. **Commits** changes and pushes a Git tag

Example output:
```
🛠️  Updating version in Swift file
📦 Creating XCFramework
📤 Committing and tagging version 1.2.0
✅ Done: SDK v1.2.0 built, unsigned, tagged, and pushed to Git
```

---

## 📁 Files Affected

- `ACPaymentLinks/Config/ACConfigManager.swift`
- `ACPaymentLinks.podspec`
- `ACPaymentLinks.xcframework`

---

## 🧯 Troubleshooting

| Error | Fix |
|------|-----|
| `Permission denied` | Run `chmod +x build.sh` |
| `No version specified` | Run with version argument: `./build.sh 1.2.0` |
| `File not found` | Make sure you're in the project root |
| `git push failed` | Check your branch and remote permissions |

---

# 🚀 Releasing a New Version (Internal → Public)

> ✅ **IMPORTANT:**\
> Only release from the **`release/xcframework`** branch, and only after
> QA approval.

---

## 1️⃣ Build the XCFramework (Private Repo)

Inside the **private repository**, generate the XCFramework using your
internal build script:

``` bash
./build_xcframework.sh
```

This outputs a new:

    ACPaymentLinks.xcframework

inside your internal `build/` directory.

---

## 2️⃣ Copy the XCFramework to the Public Repository

1.  Open the public repo:

```{=html}
<!-- -->
```
    github.com/omerco-ctrl/ACCheckoutSDK

2.  Replace the old framework:

```{=html}
<!-- -->
```
    ACPaymentLinks.xcframework

3.  Ensure the entire XCFramework folder is overwritten with the new
    one.
    
---

## 3️⃣ Update Release Notes

In the **public repo**, update:

    Notes.md

with the latest release notes for the version you are publishing.

These notes will be used for:

-   Git tag annotation\
-   GitHub Release\
-   Slack notifications

---

## 4️⃣ Validate the XCFramework

Inside the public repository, run:

``` bash
./check_xcframework.sh
```

> ❌ If this fails, **do not continue**.\
> Rebuild the XCFramework in the private repo, then replace it again.

---

## 5️⃣ Publish to CocoaPods (Normal Flow)

Set the Slack webhook once per terminal session:

``` bash
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
```

Publish the new version:

``` bash
./build.sh <VERSION> --allow-warnings --notes Notes.md
```

Example:

``` bash
./build.sh 3.1.2 --allow-warnings --notes Notes.md
```

`build.sh` will:

-   Update `ACPaymentLinks.podspec`
-   Commit changes (podspec, README.md, Notes.md, XCFramework)
-   Create Git tag `<VERSION>`
-   Push repo + tags to GitHub
-   Create/update the GitHub Release
-   Run `pod spec lint`
-   Push the podspec to CocoaPods via `pod trunk push`
-   Send a Slack notification

> ⚠️ CocoaPods does **not allow overwriting** an existing published
> version.\
> If `<VERSION>` already exists in CocoaPods, you must bump the version.

---

# 🧯 Fixing a Broken Release (Override Mode)

Use `override.sh` **only** when something is wrong in the public repo
**before the CocoaPods publish succeeds**, such as:

-   Incorrect podspec\
-   Corrupted XCFramework\
-   Wrong tag pushed\
-   Broken history

> ⚠️ **EXTREMELY DESTRUCTIVE:**\
> `override.sh` rewrites Git history and force-pushes to `master`.

Run:

``` bash
./override.sh <VERSION> --allow-warnings --notes Notes.md
```

Example:

``` bash
./override.sh 3.1.2 --allow-warnings --notes Notes.md
```

`override.sh` will:

-   Auto-commit any untracked or modified files\
-   Attempt to delete the version from CocoaPods trunk\
-   Rewrite the `master` branch into a **single clean commit**\
-   Delete the `<VERSION>` tag locally and on GitHub\
-   Force-push the cleaned branch

After using override:

``` bash
./build.sh <NEW_VERSION> --allow-warnings --notes Notes.md
```

---

# 🧪 Quick Summary

### ✔ Normal Release

``` bash
# Build in private repo
./build_xcframework.sh

# Copy to public repo
# Update Notes.md

./check_xcframework.sh
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
./build.sh <VERSION> --allow-warnings --notes Notes.md
```

---

### ✔ Emergency Fix

``` bash
./override.sh <VERSION> --allow-warnings --notes Notes.md
# fix issues
./build.sh <NEW_VERSION> --allow-warnings --notes Notes.md
```

---

# 📁 Files Used in Releases

Public repository contains:

-   `ACPaymentLinks.xcframework`
-   `ACPaymentLinks.podspec`
-   `README.md`
-   `Notes.md`
-   Release scripts (`build.sh`, `override.sh`, `check_xcframework.sh`)

---

## 📄 License

MIT

---

## 🙋 Questions?

If you’re unsure about the process, ask a team lead before running the script. This process affects production versioning.

---
