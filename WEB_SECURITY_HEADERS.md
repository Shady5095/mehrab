# Web Security Headers Guide

This document provides guidance for implementing security headers when deploying the Mehrab web platform.

**Security Fix:** CWE-16 (Configuration)
**CVSS Score:** 3.7 (Low)
**Status:** DOCUMENTATION ONLY - Implement when web platform is deployed

---

## Overview

Security headers provide an additional layer of defense-in-depth for web applications. While the Flutter mobile app doesn't require these, the web platform deployment will benefit from proper header configuration.

---

## Required Security Headers

### 1. Content Security Policy (CSP)

**Purpose:** Prevents XSS attacks by controlling which resources can be loaded

```
Content-Security-Policy: default-src 'self';
  script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.gstatic.com;
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  font-src 'self' https://fonts.gstatic.com;
  img-src 'self' data: https: blob:;
  connect-src 'self' https://signal.ahmedhany.dev wss://signal.ahmedhany.dev https://*.firebaseio.com wss://*.firebaseio.com https://*.googleapis.com;
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self'
```

**Note:** `'unsafe-inline'` and `'unsafe-eval'` are required for Flutter web. Consider using nonces or hashes in production.

---

### 2. X-Frame-Options

**Purpose:** Prevents clickjacking attacks

```
X-Frame-Options: DENY
```

Or use CSP `frame-ancestors 'none'` (preferred, more flexible)

---

### 3. X-Content-Type-Options

**Purpose:** Prevents MIME type sniffing

```
X-Content-Type-Options: nosniff
```

---

### 4. Strict-Transport-Security (HSTS)

**Purpose:** Forces HTTPS connections

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

**Important:** Only enable after ensuring all resources load over HTTPS

---

### 5. X-XSS-Protection

**Purpose:** Enables browser XSS filter (legacy, but still useful)

```
X-XSS-Protection: 1; mode=block
```

---

### 6. Referrer-Policy

**Purpose:** Controls referrer information sent with requests

```
Referrer-Policy: strict-origin-when-cross-origin
```

---

### 7. Permissions-Policy

**Purpose:** Controls browser features and APIs

```
Permissions-Policy: camera=*, microphone=*, geolocation=(self), payment=()
```

Allows camera and microphone for WebRTC, allows geolocation for prayer times, blocks payment APIs.

---

## Implementation Methods

### Option 1: Web Server Configuration (Recommended)

#### Nginx

```nginx
server {
    listen 443 ssl http2;
    server_name mehrab.example.com;

    # SSL configuration
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    # Security Headers
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.gstatic.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https: blob:; connect-src 'self' https://signal.ahmedhany.dev wss://signal.ahmedhany.dev https://*.firebaseio.com wss://*.firebaseio.com https://*.googleapis.com; frame-ancestors 'none'; base-uri 'self'; form-action 'self'" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "camera=*, microphone=*, geolocation=(self), payment=()" always;

    root /var/www/mehrab/web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

#### Apache

```apache
<VirtualHost *:443>
    ServerName mehrab.example.com

    SSLEngine on
    SSLCertificateFile /path/to/cert.pem
    SSLCertificateKeyFile /path/to/key.pem

    DocumentRoot /var/www/mehrab/web

    # Security Headers
    Header always set Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.gstatic.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https: blob:; connect-src 'self' https://signal.ahmedhany.dev wss://signal.ahmedhany.dev https://*.firebaseio.com wss://*.firebaseio.com https://*.googleapis.com; frame-ancestors 'none'; base-uri 'self'; form-action 'self'"
    Header always set X-Frame-Options "DENY"
    Header always set X-Content-Type-Options "nosniff"
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Permissions-Policy "camera=*, microphone=*, geolocation=(self), payment=()"

    <Directory /var/www/mehrab/web>
        AllowOverride All
        Require all granted

        # Flutter web routing
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ /index.html [L]
    </Directory>
</VirtualHost>
```

---

### Option 2: Firebase Hosting

Create or update `firebase.json`:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "Content-Security-Policy",
            "value": "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.gstatic.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https: blob:; connect-src 'self' https://signal.ahmedhany.dev wss://signal.ahmedhany.dev https://*.firebaseio.com wss://*.firebaseio.com https://*.googleapis.com; frame-ancestors 'none'; base-uri 'self'; form-action 'self'"
          },
          {
            "key": "X-Frame-Options",
            "value": "DENY"
          },
          {
            "key": "X-Content-Type-Options",
            "value": "nosniff"
          },
          {
            "key": "Strict-Transport-Security",
            "value": "max-age=31536000; includeSubDomains; preload"
          },
          {
            "key": "X-XSS-Protection",
            "value": "1; mode=block"
          },
          {
            "key": "Referrer-Policy",
            "value": "strict-origin-when-cross-origin"
          },
          {
            "key": "Permissions-Policy",
            "value": "camera=*, microphone=*, geolocation=(self), payment=()"
          }
        ]
      }
    ]
  }
}
```

Deploy:
```bash
firebase deploy --only hosting
```

---

## Testing Security Headers

### Online Tools

1. **Security Headers** - https://securityheaders.com
   - Enter your web URL
   - Get comprehensive report and grade

2. **Mozilla Observatory** - https://observatory.mozilla.org
   - Detailed security assessment
   - Recommendations for improvements

3. **CSP Evaluator** - https://csp-evaluator.withgoogle.com
   - Check CSP configuration
   - Identify potential bypasses

### Manual Testing

```bash
# Check headers with curl
curl -I https://mehrab.example.com

# Check specific header
curl -I https://mehrab.example.com | grep Content-Security-Policy
```

### Browser DevTools

1. Open Developer Tools (F12)
2. Go to Network tab
3. Reload page
4. Click on the main document request
5. View Response Headers

---

## Flutter Web Specific Considerations

### CSP Challenges

Flutter web requires `'unsafe-inline'` and `'unsafe-eval'` for:
- Dart runtime initialization
- Hot reload in development
- Some framework features

**Mitigation:**
- Use nonces or hashes where possible
- Keep CSP as restrictive as possible
- Monitor for violations

### CanvasKit vs HTML Renderer

Both renderers work with security headers, but:
- CanvasKit may need `wasm-eval` in CSP
- HTML renderer works with standard CSP

### WebRTC Considerations

Ensure CSP allows:
- `connect-src` includes WebRTC signaling server
- `media-src` allows camera/microphone access (if using media elements)

---

## Monitoring and Reporting

### CSP Reporting

Add `report-uri` or `report-to` to CSP:

```
Content-Security-Policy: default-src 'self'; ...; report-uri https://mehrab.example.com/csp-report
```

Implement endpoint to collect violations:

```javascript
// Express.js example
app.post('/csp-report', express.json({ type: 'application/csp-report' }), (req, res) => {
  console.log('CSP Violation:', req.body);
  // Log to monitoring system
  res.status(204).send();
});
```

### Log Analysis

Monitor logs for:
- CSP violations
- Unusual patterns
- Blocked resources
- Failed loading attempts

---

## Gradual Rollout

### Phase 1: Report-Only Mode

```
Content-Security-Policy-Report-Only: default-src 'self'; ...
```

- Collect violations without breaking functionality
- Identify legitimate resources that need whitelisting
- Adjust policy based on reports

### Phase 2: Enforcement

```
Content-Security-Policy: default-src 'self'; ...
```

- Enable enforcement after verifying no critical breakages
- Monitor for issues
- Have rollback plan ready

---

## Checklist

Before deploying web platform:

- [ ] Configure web server with security headers
- [ ] Test all headers are present in responses
- [ ] Verify CSP doesn't break functionality
- [ ] Test on multiple browsers (Chrome, Firefox, Safari, Edge)
- [ ] Verify WebRTC calls work with CSP
- [ ] Test camera/microphone permissions
- [ ] Set up CSP reporting endpoint
- [ ] Monitor CSP violation reports
- [ ] Configure HSTS preload (optional but recommended)
- [ ] Run security header scanners
- [ ] Document any exceptions or workarounds

---

## Maintenance

Security headers require ongoing maintenance:

1. **Review CSP violations monthly**
2. **Update headers when adding new services**
3. **Test headers after major updates**
4. **Keep up with security best practices**
5. **Monitor for new attack vectors**

---

## Additional Resources

- [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/)
- [MDN Web Security](https://developer.mozilla.org/en-US/docs/Web/Security)
- [Content Security Policy Reference](https://content-security-policy.com/)
- [Security Headers Best Practices](https://securityheaders.com/blog/)

---

**Last Updated:** 2026-01-22
**Status:** Ready for web platform deployment
**Priority:** Low (web platform not yet released)

---

**Note:** This is documentation only. Implement these headers when deploying the web version of Mehrab. Mobile app does not require HTTP security headers.
