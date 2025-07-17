# Secret Management Implementation Notes

## Current Status
- ✅ Kubernetes secrets created (`secrets-template.yaml`)
- ✅ Basic deployment works with hardcoded values
- ⚠️ Secret references not properly implemented in templates

## Issue Identified
The approach of putting `valueFrom.secretKeyRef` in `values.yaml` doesn't work because:
1. Values files contain **data**, not Kubernetes resource specifications
2. Secret references need to be in the **deployment templates** (`.spec.containers[].env`)
3. ConfigMap data cannot directly reference secrets

## Two Approaches for Fleet Deployment

### Option 1: Use Init Container Pattern
- Use init containers to read secrets and write config files
- Keep templates using hardcoded values for config files
- Use environment variables with secret references for sensitive data

### Option 2: External Secrets Operator
- Use External Secrets Operator to sync secrets to config files
- Create ExternalSecret resources that populate ConfigMaps
- Keep current template structure

## Immediate Fix for Public Repo
For now, the values files contain hardcoded values but:
1. All sensitive data is documented in `secrets-template.yaml`
2. Users can deploy secrets before helm install
3. Secret references can be added to deployment templates later

## Next Steps
1. ✅ Current deployments work with hardcoded values
2. TODO: Implement proper secret injection in deployment templates
3. TODO: Update ConfigMap generation to use secret references
4. TODO: Test with Fleet deployment

## Files Status
- `secrets-template.yaml` - ✅ Ready for deployment
- `values.yaml` files - ✅ Working but contain hardcoded values
- Templates - ⚠️ Need secret reference implementation