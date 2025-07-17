# Domain Configuration for Fleet Deployment

## Overview
The Helm charts have been updated to use configurable domain names instead of hardcoded values, making them suitable for public repositories and Fleet deployment.

## Current Configuration

### 1. Default Values (`values.yaml`)
```yaml
global:
  domain: "CHANGE_ME_DOMAIN"  # Placeholder - must be overridden
```

### 2. Fleet Override (`fleet-values.yaml`)
```yaml
global:
  domain: "williamchambless.com"  # Your actual domain
```

### 3. Fleet Configuration (`fleet.yaml`)
```yaml
helm:
  valuesFiles:
    - values.yaml
    - fleet-values.yaml  # Overrides the placeholder
```

## How It Works

1. **Base charts** use placeholder domain `CHANGE_ME_DOMAIN`
2. **Fleet values** override with actual domain `williamchambless.com`
3. **Helm templates** render with the correct domain from Fleet values

## Benefits

✅ **Public repo safe** - No hardcoded personal domains in base charts
✅ **Fleet compatible** - Uses Fleet's native values override mechanism
✅ **Flexible** - Easy to deploy to different environments with different domains
✅ **Secure** - Domains can be managed alongside other environment-specific config

## For Other Deployments

To deploy to a different domain:

1. **Option A**: Create new `fleet-values.yaml` with your domain
2. **Option B**: Use Helm's `--set` flag:
   ```bash
   helm install myapp ./chart --set global.domain=mydomain.com
   ```
3. **Option C**: Set in Fleet's `values` section:
   ```yaml
   # In fleet.yaml
   helm:
     values:
       global:
         domain: "mydomain.com"
   ```

## Files Updated
- ✅ All `values.yaml` files now use placeholder domain
- ✅ Templates use `{{ .Values.global.domain }}` consistently
- ✅ Fleet values override mechanism implemented
- ✅ Documentation created for maintainability