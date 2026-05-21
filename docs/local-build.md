# Local Build & Install Guide

## Prerequisites

- macOS with Xcode installed (full Xcode, not just Command Line Tools)

## Steps

### 1. Generate a self-signed code signing certificate

```bash
./scripts/codesign/setup_local.sh
```

This creates a certificate named "Local Self-Signed" and imports it into your login keychain.

### 2. Create `config/local.xcconfig`

```bash
cat > config/local.xcconfig <<'EOF'
CODE_SIGN_IDENTITY = Local Self-Signed
APPCENTER_SECRET = 6b453477-5608-4083-afa1-f88d696a061d
CURRENT_PROJECT_VERSION = 99.0.0
EOF
```

- `CODE_SIGN_IDENTITY` — matches the CN of the self-signed cert created above
- `APPCENTER_SECRET` — required for crash reporting (extract from an official build's Info.plist if needed)
- `CURRENT_PROJECT_VERSION` — any semver; without it the app crashes on launch

### 3. Build

```bash
xcodebuild -project alt-tab-macos.xcodeproj \
  -scheme Release -configuration Release \
  -derivedDataPath DerivedData clean build
```

### 4. Install

```bash
rm -rf /Applications/AltTab.app
cp -R DerivedData/Build/Products/Release/AltTab.app /Applications/
xattr -cr /Applications/AltTab.app
```

The `xattr -cr` removes the quarantine flag so Gatekeeper doesn't block the self-signed app.

### 5. Fix Accessibility permissions

Because the code signature differs from the official release, macOS won't recognize existing Accessibility grants. Reset and re-grant:

```bash
tccutil reset Accessibility com.lwouis.alt-tab-macos
```

Then launch the app:

```bash
open /Applications/AltTab.app
```

When prompted, grant Accessibility access in **System Settings → Privacy & Security → Accessibility**.

## Notes

- `config/local.xcconfig` is gitignored — it's for per-developer overrides only.
- If you change the bundle ID or signing identity later, you'll need to repeat step 5.
