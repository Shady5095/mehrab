# Build Configuration Guide

This document explains how to configure the Mehrab app for different environments using build-time configuration.

## Overview

The app now uses `AppConfig` class to manage environment-specific settings. This allows you to:
- Change server URLs without modifying code
- Configure different settings for dev/staging/production
- Enable/disable features per environment
- Switch configurations at build time

**Security Fix:** Addresses CWE-547 (Hard-coded Security-relevant Constants)

---

## Environment Variables

### Available Configurations

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `ENVIRONMENT` | Environment name | `production` |
| `SIGNALING_SERVER_URL` | WebRTC signaling server | `https://signal.ahmedhany.dev` |
| `TURN_DOMAIN` | TURN server domain | `turn.ahmedhany.dev` |
| `API_BASE_URL` | API base URL | (empty) |
| `API_TIMEOUT` | API timeout in seconds | `60` |
| `ENABLE_ANALYTICS` | Enable analytics | `true` |
| `ENABLE_CRASH_REPORTING` | Enable crash reporting | `true` |
| `APP_VERSION` | App version | `2.6.0` |
| `BUILD_NUMBER` | Build number | `48` |

### Development-Only Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `DEV_SIGNALING_URL` | Dev signaling server | (uses SIGNALING_SERVER_URL) |
| `DEV_TURN_DOMAIN` | Dev TURN domain | (uses TURN_DOMAIN) |

---

## Build Commands

### Production Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

Uses default production configuration.

### Staging Build

```bash
# Android
flutter build apk --release \
  --dart-define=ENVIRONMENT=staging \
  --dart-define=SIGNALING_SERVER_URL=https://staging-signal.ahmedhany.dev \
  --dart-define=TURN_DOMAIN=turn-staging.ahmedhany.dev \
  --dart-define=API_BASE_URL=https://staging-api.mehrab.com

# iOS
flutter build ios --release \
  --dart-define=ENVIRONMENT=staging \
  --dart-define=SIGNALING_SERVER_URL=https://staging-signal.ahmedhany.dev \
  --dart-define=TURN_DOMAIN=turn-staging.ahmedhany.dev \
  --dart-define=API_BASE_URL=https://staging-api.mehrab.com
```

### Development Build

```bash
# Run on emulator with local servers
flutter run --debug \
  --dart-define=ENVIRONMENT=development \
  --dart-define=DEV_SIGNALING_URL=http://10.0.2.2:3000 \
  --dart-define=DEV_TURN_DOMAIN=10.0.2.2 \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=ENABLE_ANALYTICS=false

# Note: 10.0.2.2 is the Android emulator's host machine IP
# For iOS simulator, use: http://localhost:3000
```

### Custom Server Build

```bash
# Build with custom servers
flutter build apk --release \
  --dart-define=SIGNALING_SERVER_URL=https://custom-signal.example.com \
  --dart-define=TURN_DOMAIN=turn.example.com \
  --dart-define=API_BASE_URL=https://api.example.com
```

---

## Usage in Code

### Accessing Configuration

```dart
import 'package:mehrab/core/config/app_config.dart';

// WebRTC Configuration
final signalingUrl = AppConfig.signalingServerUrl;
final turnDomain = AppConfig.turnDomain;

// API Configuration
final apiUrl = AppConfig.apiBaseUrl;
final timeout = AppConfig.apiTimeout;

// Environment Checks
if (AppConfig.isDevelopment) {
  // Development-only code
}

if (AppConfig.isProduction) {
  // Production-only code
}

// Feature Flags
if (AppConfig.enableAnalytics) {
  // Send analytics
}
```

### Print Current Configuration (Debug Only)

```dart
import 'package:mehrab/core/config/app_config.dart';

void main() {
  AppConfig.printConfig(); // Only prints in debug mode
  runApp(MyApp());
}
```

---

## Migration from WebRTCConstants

### Old Code (Deprecated)

```dart
import 'package:mehrab/core/utilities/services/webrtc_constants.dart';

final url = WebRTCConstants.signalingServerUrl;
```

### New Code (Recommended)

```dart
import 'package:mehrab/core/config/app_config.dart';

final url = AppConfig.signalingServerUrl;
```

**Note:** `WebRTCConstants` is deprecated and will be removed in the next major version. It currently redirects to `AppConfig`.

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build Production APK

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'

      - name: Build APK
        run: |
          flutter build apk --release \
            --dart-define=ENVIRONMENT=production \
            --dart-define=SIGNALING_SERVER_URL=${{ secrets.SIGNALING_URL }} \
            --dart-define=TURN_DOMAIN=${{ secrets.TURN_DOMAIN }} \
            --dart-define=API_BASE_URL=${{ secrets.API_URL }} \
            --dart-define=APP_VERSION=${{ github.ref_name }} \
            --dart-define=BUILD_NUMBER=${{ github.run_number }}
```

### GitLab CI Example

```yaml
build:production:
  stage: build
  script:
    - flutter build apk --release
        --dart-define=ENVIRONMENT=production
        --dart-define=SIGNALING_SERVER_URL=$SIGNALING_URL
        --dart-define=TURN_DOMAIN=$TURN_DOMAIN
        --dart-define=API_BASE_URL=$API_URL
  only:
    - tags
```

---

## Environment Files (Optional)

You can create environment-specific files for easier management:

### Create `env/production.sh`

```bash
#!/bin/bash
flutter build apk --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=SIGNALING_SERVER_URL=https://signal.ahmedhany.dev \
  --dart-define=TURN_DOMAIN=turn.ahmedhany.dev \
  --dart-define=API_BASE_URL=https://api.mehrab.com \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols
```

### Create `env/development.sh`

```bash
#!/bin/bash
flutter run --debug \
  --dart-define=ENVIRONMENT=development \
  --dart-define=DEV_SIGNALING_URL=http://localhost:3000 \
  --dart-define=DEV_TURN_DOMAIN=localhost \
  --dart-define=API_BASE_URL=http://localhost:8000 \
  --dart-define=ENABLE_ANALYTICS=false
```

Make executable:
```bash
chmod +x env/*.sh
```

Run:
```bash
./env/production.sh
./env/development.sh
```

---

## Best Practices

### 1. Never Commit Secrets

❌ **Don't do this:**
```bash
# bad-script.sh
flutter build --dart-define=API_KEY=secret123  # DON'T COMMIT
```

✅ **Do this instead:**
```bash
# build.sh
flutter build --dart-define=API_KEY=$API_KEY  # Load from env
```

### 2. Use CI/CD Secrets

Store sensitive configuration in:
- GitHub Secrets
- GitLab CI/CD Variables
- Environment variables on build machine
- Vault/Secret management systems

### 3. Validate Configuration at Startup

```dart
void main() {
  // Validate required configuration
  assert(AppConfig.apiBaseUrl.isNotEmpty, 'API_BASE_URL not configured');
  assert(AppConfig.signalingServerUrl.startsWith('https'), 'Must use HTTPS');

  runApp(MyApp());
}
```

### 4. Document Environment Requirements

Create a `.env.example` file:
```env
# Example environment configuration
# Copy to .env and customize for your environment

ENVIRONMENT=production
SIGNALING_SERVER_URL=https://signal.example.com
TURN_DOMAIN=turn.example.com
API_BASE_URL=https://api.example.com
API_TIMEOUT=60
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
```

---

## Troubleshooting

### Issue: Configuration not taking effect

**Solution:** Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter build apk --release --dart-define=...
```

### Issue: Local development not working

**Solution:** Check network configuration:
- Android emulator: Use `10.0.2.2` for host machine
- iOS simulator: Use `localhost` or `127.0.0.1`
- Physical device: Use your machine's IP address

### Issue: Build fails with "undefined" errors

**Solution:** Ensure all required `--dart-define` flags are provided or have defaults in `AppConfig`.

---

## Security Considerations

1. **Never hardcode secrets** in AppConfig default values
2. **Use HTTPS** for all production URLs
3. **Validate URLs** at runtime to ensure they use secure protocols
4. **Rotate URLs** if they become compromised
5. **Monitor** unexpected configuration changes

---

## Migration Checklist

- [ ] Replace `WebRTCConstants.signalingServerUrl` with `AppConfig.signalingServerUrl`
- [ ] Replace `WebRTCConstants.turnDomain` with `AppConfig.turnDomain`
- [ ] Update CI/CD scripts with `--dart-define` flags
- [ ] Create environment-specific build scripts
- [ ] Document configuration requirements for team
- [ ] Test builds in all environments (dev/staging/production)
- [ ] Update deployment documentation

---

## Additional Resources

- [Flutter Build Modes](https://docs.flutter.dev/testing/build-modes)
- [Environment Variables in Flutter](https://docs.flutter.dev/deployment/flavors)
- [Dart Define Documentation](https://dart.dev/tools/dart-compile#--define)

---

**Last Updated:** 2026-01-22
**Fixes:** CWE-547 (Hardcoded Security Constants)
