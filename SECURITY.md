# Security Guidelines

## 🔐 Pre-Upload Security Checklist

Before pushing this repository to GitHub, ensure:

### ✅ Secrets Externalized
- [x] All API keys use placeholder patterns (e.g., `SONARR_API_KEY_PLACEHOLDER`)
- [x] All passwords use placeholder patterns (e.g., `POSTGRES_PASSWORD_PLACEHOLDER`)
- [x] All sensitive data referenced via Kubernetes secrets
- [x] Init containers handle secret substitution at runtime

### ✅ Domain Configuration
- [x] All hardcoded domains replaced with `CHANGE_ME_DOMAIN` in values.yaml
- [x] Fleet values override files contain real domain (acceptable for private use)
- [x] Ingress templates use `{{ .Values.global.domain }}` pattern

### ✅ File Exclusions
- [x] .gitignore includes all sensitive file patterns
- [x] No secrets-template.yaml or similar files with real secrets
- [x] No backup files with sensitive information
- [x] No utility scripts with embedded credentials

### ✅ Repository Structure
- [x] All apps follow standardized secret injection pattern
- [x] Documentation includes secret management instructions
- [x] README provides clear setup instructions
- [x] Each app has fleet-values.yaml for domain override

## 🚨 Critical Security Patterns

### Safe Patterns (✅ OK to commit)
```yaml
# Placeholder in values.yaml
apiKey: "SONARR_API_KEY_PLACEHOLDER"

# Template reference
hostname: "sonarr.CHANGE_ME_DOMAIN"

# Fleet override
global:
  domain: "yourdomain.com"  # This is OK in fleet-values.yaml
```

### Dangerous Patterns (❌ NEVER commit)
```yaml
# Real API key
apiKey: "a1b2c3d4e5f6g7h8i9j0"

# Real password
password: "mySecretPassword123"

# Real hardcoded domain in values.yaml
hostname: "sonarr.williamchambless.com"
```

## 🛡️ Secret Management Implementation

### 1. Placeholder Pattern
All sensitive values use descriptive placeholders:
- `POSTGRES_PASSWORD_PLACEHOLDER`
- `SONARR_API_KEY_PLACEHOLDER`
- `CHANGE_ME_DOMAIN`

### 2. Init Container Pattern
Runtime secret substitution via init containers:
```yaml
initContainers:
- name: init-config
  image: busybox
  command: [sh, -c]
  args:
    - sed "s/PLACEHOLDER/$REAL_SECRET/g" /tmp/config > /shared/config
  env:
    - name: REAL_SECRET
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: secret-key
```

### 3. Fleet Values Override
Domain configuration via Fleet:
```yaml
# fleet-values.yaml
global:
  domain: "yourdomain.com"
```

## 📋 Deployment Prerequisites

### Required Secrets
Before deploying, create these secrets in your cluster:

1. **postgres-credentials** (namespaces: arr, tdarr, web, downloader, default)
2. **app-api-keys** (namespaces: arr, tdarr, web, downloader, default)
3. **cloudflare-api-token** (namespace: kube-system)
4. **qbittorrent-secret** (namespace: downloader)
5. **gluetun-secrets** (namespace: vpn)

See README.md for detailed secret specifications.

## 🔍 Security Validation Commands

### Check for Secrets
```bash
# Scan for potential API keys
grep -r -i "api.*key.*:" . | grep -v PLACEHOLDER

# Check for passwords
grep -r -i "password.*:" . | grep -v PLACEHOLDER

# Look for hardcoded tokens
grep -r -i "token.*:" . | grep -v PLACEHOLDER
```

### Validate Placeholders
```bash
# Ensure placeholders are used
grep -r "PLACEHOLDER" apps/
grep -r "CHANGE_ME" apps/
```

## 🚀 GitHub Upload Process

1. **Final Security Scan**: Run validation commands above
2. **Test Deployment**: Deploy to test cluster first
3. **Review .gitignore**: Ensure all sensitive patterns excluded
4. **Create Repository**: Initialize git repository
5. **Initial Commit**: Commit all prepared files
6. **Push to GitHub**: Upload to public repository

## 🔄 Ongoing Security

### Regular Maintenance
- Review and rotate secrets quarterly
- Update placeholders if patterns change
- Monitor for accidental secret commits
- Keep .gitignore updated

### Secret Rotation
When rotating secrets:
1. Update Kubernetes secrets in cluster
2. Restart affected applications
3. Never commit real secrets to repository
4. Use proper secret management tools

---

**Remember: This repository is designed for public sharing. Always verify no real secrets are committed!**