# Code Obfuscation Guide

## Overview

Code obfuscation has been enabled for release builds to protect the app from reverse engineering and intellectual property theft.

**Security Fix:** CWE-656 (Reliance on Security Through Obscurity)
**CVSS Score:** 4.3 (Medium)

---

## What is Code Obfuscation?

Obfuscation makes decompiled code harder to understand by:
- Renaming classes, methods, and variables to meaningless names
- Removing unused code (dead code elimination)
- Optimizing bytecode
- Stripping debug information

---

## Building with Obfuscation

### Flutter (Dart Code)

```bash
# Build APK with obfuscation
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

# Build App Bundle with obfuscation
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols

# Build iOS with obfuscation
flutter build ios --release --obfuscate --split-debug-info=build/ios/outputs/symbols
```

**Important:** Always use `--split-debug-info` to save symbol maps for crash reports!

### Android (Native Code)

ProGuard/R8 is automatically enabled in release builds via `build.gradle`:

```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

---

## ProGuard Rules

The `proguard-rules.pro` file contains rules to:
- Keep Flutter framework classes
- Keep Firebase SDK classes
- Keep WebRTC classes
- Keep model classes with annotations
- Remove debug logging (Log.d, Log.v, Log.i)
- Preserve crash reporting info

### Important Rules

```pro
# Keep Flutter
-keep class io.flutter.** { *; }

# Keep Firebase
-keep class com.google.firebase.** { *; }

# Keep WebRTC
-keep class org.webrtc.** { *; }

# Remove debug logs
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}

# Keep model classes
-keep class com.mehrab.mehrab_quran.**.models.** { *; }
```

---

## Symbol Maps (Crash Deobfuscation)

### Saving Symbol Maps

Symbol maps are saved to `build/app/outputs/symbols/` when using `--split-debug-info`.

**CRITICAL:** Store these files securely! You need them to deobfuscate crash reports.

### Upload to Firebase Crashlytics

```bash
# Upload symbols to Crashlytics
firebase crashlytics:symbols:upload \
  --app=1:736983329149:android:7a1d0cf38ac37f2b1f4414 \
  build/app/outputs/symbols
```

### Upload to Google Play Console

When uploading an App Bundle to Play Console, upload the symbols:

1. Go to Play Console → Your App → App Bundle Explorer
2. Select the version
3. Click "Download" → "ProGuard mapping file"
4. Upload your `build/app/outputs/mapping/release/mapping.txt`

---

## Deobfuscating Crash Reports

### Using retrace (ProGuard)

```bash
# Deobfuscate Android stack trace
retrace build/app/outputs/mapping/release/mapping.txt crash-stack-trace.txt
```

### Using Flutter symbols

```bash
# Deobfuscate Flutter stack trace
flutter symbolize --input=crash-stack-trace.txt \
  --symbols=build/app/outputs/symbols
```

---

## Verifying Obfuscation

### Check APK

```bash
# Build APK
flutter build apk --release --obfuscate --split-debug-info=build/symbols

# Decompile APK
cd build/app/outputs/flutter-apk
apktool d app-release.apk

# Or use jadx
jadx -d decompiled app-release.apk

# Check decompiled code - should see obfuscated names like:
# - Class names: a, b, c, aa, ab
# - Methods: a(), b(), c()
# - Fields: d, e, f
```

### Check Build Output

Look for these messages in build output:

```
✓ Built build/app/outputs/flutter-apk/app-release.apk (XX MB).
  Obfuscation enabled, symbols saved to build/symbols
```

---

## Impact on App

### What Changes:

- **Release builds** are obfuscated
- **Debug builds** remain unobfuscated
- **App size** reduced (shrinkResources removes unused resources)
- **Performance** may slightly improve (optimization)

### What Doesn't Change:

- App functionality remains identical
- User experience unchanged
- No visible differences

---

## Troubleshooting

### Issue: Crash on release build but not debug

**Cause:** ProGuard removed or renamed a class that's needed

**Solution:** Add keep rule to `proguard-rules.pro`:

```pro
# Keep specific class
-keep class com.example.MyClass { *; }

# Keep all classes in package
-keep class com.example.mypackage.** { *; }

# Keep methods with specific annotation
-keepclasseswithmembers class * {
    @com.example.KeepThis <methods>;
}
```

### Issue: Reflection not working

**Cause:** ProGuard renamed classes accessed via reflection

**Solution:** Keep classes accessed via reflection:

```pro
-keep class com.example.MyReflectedClass { *; }
-keepclassmembers class com.example.MyClass {
    *** methodAccessedByReflection(...);
}
```

### Issue: Serialization/Deserialization fails

**Cause:** ProGuard renamed fields

**Solution:** Keep data classes:

```pro
-keep class com.example.models.** { *; }
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
}
```

---

## Testing Obfuscated Builds

### Before Release:

1. **Build obfuscated APK:**
   ```bash
   flutter build apk --release --obfuscate --split-debug-info=build/symbols
   ```

2. **Install on test device:**
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Test all features:**
   - Login/logout
   - API calls
   - WebRTC calls
   - Firebase operations
   - Image uploads
   - Notifications

4. **Check for crashes:**
   - Monitor logcat for errors
   - Test edge cases
   - Test on different Android versions

5. **Verify deobfuscation:**
   - Trigger a crash intentionally
   - Deobfuscate stack trace using saved symbols
   - Verify you can identify the issue

---

## CI/CD Integration

### GitHub Actions

```yaml
- name: Build Release APK
  run: |
    flutter build apk \
      --release \
      --obfuscate \
      --split-debug-info=build/symbols \
      --dart-define=ENVIRONMENT=production

- name: Upload Symbols
  uses: actions/upload-artifact@v2
  with:
    name: symbols
    path: build/symbols

- name: Upload APK
  uses: actions/upload-artifact@v2
  with:
    name: app-release
    path: build/app/outputs/flutter-apk/app-release.apk
```

### Store Symbols

**IMPORTANT:** Always store symbol maps for each release!

Options:
- Upload to Firebase Crashlytics
- Store in artifact repository
- Commit to private Git repository
- Store in secure cloud storage (S3, GCS)

---

## Security Considerations

### What Obfuscation Protects:

- ✅ Makes reverse engineering harder
- ✅ Hides business logic
- ✅ Protects API endpoints (partially)
- ✅ Reduces exposed class names

### What Obfuscation Doesn't Protect:

- ❌ Hardcoded strings (still visible)
- ❌ Assets and resources
- ❌ Network traffic (use HTTPS)
- ❌ Stored data (use encryption)
- ❌ Root/jailbreak detection

### Additional Security Measures:

1. **Never hardcode secrets** - Use secure storage
2. **Use certificate pinning** - Implemented in network_security_config.xml
3. **Encrypt sensitive data** - Use SecureCacheService
4. **Validate inputs** - Use InputValidator
5. **Use secure logging** - Use SecureLogger

---

## Maintenance

### When Updating Dependencies:

1. Build obfuscated release
2. Test thoroughly
3. Check ProGuard warnings
4. Add keep rules if needed
5. Update proguard-rules.pro

### ProGuard Warnings:

Review warnings in build output:

```
Warning: class X references unknown class Y
```

Add keep rules if necessary, or suppress warnings if safe:

```pro
-dontwarn com.example.SafeToIgnore.**
```

---

## Best Practices

1. **Always use obfuscation in production**
2. **Save symbol maps for every release**
3. **Test obfuscated builds before release**
4. **Keep ProGuard rules up to date**
5. **Document custom keep rules**
6. **Use ProGuard with R8 (default in Android Gradle Plugin 3.4+)**
7. **Monitor crash reports and deobfuscate**

---

## Resources

- [Flutter Obfuscation Guide](https://docs.flutter.dev/deployment/obfuscate)
- [ProGuard Manual](https://www.guardsquare.com/manual/home)
- [R8 Shrinking & Obfuscation](https://developer.android.com/studio/build/shrink-code)

---

**Last Updated:** 2026-01-22
**Fixes:** CWE-656 (Security Through Obscurity)
