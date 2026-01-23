# Firebase Security Configuration Guide

This document provides step-by-step instructions for securing your Firebase project for the Mehrab application.

## 🔐 CRITICAL: API Key Restriction

The Firebase API keys are currently visible in the source code (`lib/firebase_options.dart`). While this is normal for Firebase, you **MUST** restrict these keys to prevent abuse.

### Step 1: Restrict Android API Key

1. Go to [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials)
2. Select your project: `mehrab-a8e60`
3. Find the API key: `AIzaSyCTJRX6ZtamN2_thEmFJ0vhdunKm7u2CjA`
4. Click on the key to edit
5. Under "Application restrictions":
   - Select "Android apps"
   - Click "Add an item"
   - Package name: `com.mehrab.mehrab_quran`
   - SHA-1 certificate fingerprint: (Get this from your keystore)
     ```bash
     # For debug keystore:
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

     # For release keystore:
     keytool -list -v -keystore /path/to/your/release.keystore -alias your-alias
     ```
6. Under "API restrictions":
   - Select "Restrict key"
   - Select only the APIs you need:
     - Cloud Firestore API
     - Firebase Cloud Messaging API
     - Firebase Installations API
     - Firebase Storage API
     - Identity Toolkit API
     - Token Service API
7. Click "Save"

### Step 2: Restrict iOS API Key

1. Go to [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials)
2. Find the API key: `AIzaSyCmFp8H601On0RXCGgcCZmyxFSXgi8hlHM`
3. Click on the key to edit
4. Under "Application restrictions":
   - Select "iOS apps"
   - Click "Add an item"
   - Bundle ID: `com.shady.mehrab`
5. Under "API restrictions":
   - Select "Restrict key"
   - Select the same APIs as Android
6. Click "Save"

### Step 3: Get SHA-1 Fingerprints

#### Debug SHA-1 (for development):
```bash
cd android
./gradlew signingReport
```

#### Release SHA-1 (from your keystore):
```bash
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias
```

Add these SHA-1 fingerprints to your Firebase project:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `mehrab-a8e60`
3. Go to Project Settings
4. Select your Android app
5. Add SHA-1 fingerprints under "SHA certificate fingerprints"

---

## 🔒 Firebase Security Rules Deployment

### Deploy Firestore Security Rules

1. Install Firebase CLI if not already installed:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Initialize Firebase in your project (if not already done):
   ```bash
   cd /path/to/mehrab
   firebase init
   ```
   - Select "Firestore" and "Storage"
   - Use existing project: `mehrab-a8e60`
   - Use `firestore.rules` for Firestore rules
   - Use `storage.rules` for Storage rules

4. Deploy the security rules:
   ```bash
   firebase deploy --only firestore:rules
   firebase deploy --only storage:rules
   ```

### Verify Security Rules

After deployment, test your security rules:

1. Go to [Firebase Console - Firestore](https://console.firebase.google.com/project/mehrab-a8e60/firestore)
2. Click on "Rules" tab
3. Click "Rules Playground" to test various scenarios

---

## 🛡️ Firebase App Check Configuration

Firebase App Check is already implemented in the code. Configure it properly:

### Android - Play Integrity

1. Go to [Firebase Console - App Check](https://console.firebase.google.com/project/mehrab-a8e60/appcheck)
2. Click on your Android app
3. Select "Play Integrity" provider
4. Click "Save"
5. Enable enforcement for:
   - Cloud Firestore
   - Cloud Storage
   - Firebase Realtime Database (if used)

### iOS - DeviceCheck

1. In the same App Check settings
2. Click on your iOS app
3. DeviceCheck is automatically enabled
4. Enable enforcement for the same services

### Enforcement

After testing, enable App Check enforcement:
```bash
firebase appcheck:enable --project=mehrab-a8e60
```

---

## 📊 Firestore Security Rules Explanation

The deployed `firestore.rules` file implements:

### Authentication Requirements
- All operations require authentication (`request.auth != null`)
- Users can only access their own data or data they're authorized to see

### User Collection
- Users can read/update their own profile
- Users cannot change their own role
- Users cannot delete their profile

### Calls Collection
- Users can only see calls they're part of (caller or receiver)
- Users can create calls where they are the caller
- Participants can update call status

### Teachers/Students Collections
- Public read access (authenticated users)
- Users can only modify their own profiles
- Role-based creation validation

### Sessions Collection
- Only participants (teacher + student) can access
- Teachers create sessions
- Participants can update session data

### Privacy & Data Protection
- No cross-user data access
- Role-based access control (RBAC)
- Time-based deletion rules for calls

---

## 🗄️ Storage Security Rules Explanation

The deployed `storage.rules` file implements:

### File Type Validation
- Profile photos: Images only, max 5MB
- Videos/Attachments: Max 50MB
- Content-Type validation

### Access Control
- Users can only access their own uploaded files
- Teacher photos are publicly readable (authenticated users)
- School images are read-only (managed by admin)

### Upload Restrictions
- Size limits prevent abuse
- Type validation prevents malicious files
- User-based path isolation

---

## 🔍 Monitoring & Auditing

### Enable Firebase Security Monitoring

1. Go to [Firebase Console - App Check](https://console.firebase.google.com/project/mehrab-a8e60/appcheck)
2. Review metrics for:
   - Invalid requests
   - App Check failures
   - Suspicious activity

### Set Up Alerts

1. Go to [Firebase Console - Alerts](https://console.firebase.google.com/project/mehrab-a8e60/overview)
2. Configure alerts for:
   - Unusual API usage
   - High quota consumption
   - Security rule violations

---

## ✅ Security Checklist

After completing this guide, verify:

- [ ] Android API key restricted to package name and SHA-1
- [ ] iOS API key restricted to bundle ID
- [ ] API keys restricted to necessary APIs only
- [ ] SHA-1 fingerprints added to Firebase project
- [ ] Firestore security rules deployed
- [ ] Storage security rules deployed
- [ ] App Check enabled for Android (Play Integrity)
- [ ] App Check enabled for iOS (DeviceCheck)
- [ ] App Check enforcement enabled
- [ ] Security rules tested in Rules Playground
- [ ] Firebase monitoring and alerts configured

---

## 🚨 Emergency Response

If you suspect your API keys have been compromised:

1. **Immediately rotate API keys:**
   - Go to Google Cloud Console
   - Delete the compromised key
   - Create a new key with proper restrictions
   - Update `firebase_options.dart` with new key
   - Rebuild and redeploy your app

2. **Review Firebase usage:**
   - Check for unexpected quota usage
   - Review Firestore activity logs
   - Check Storage access logs

3. **Enable App Check enforcement:**
   - This blocks non-app traffic immediately

---

## 📚 Additional Resources

- [Firebase Security Rules Guide](https://firebase.google.com/docs/rules)
- [Firebase App Check Documentation](https://firebase.google.com/docs/app-check)
- [Google Cloud API Key Best Practices](https://cloud.google.com/docs/authentication/api-keys)
- [Firebase Security Best Practices](https://firebase.google.com/support/guides/security-checklist)

---

**Last Updated:** 2026-01-22
**Fixes:** CWE-798 (Hardcoded Credentials) - CRITICAL
