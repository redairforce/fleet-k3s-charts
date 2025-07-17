# Fleet Helm Charts Repository

This repository contains Helm charts for deploying applications via Fleet on Kubernetes. All charts have been prepared for GitOps deployment with proper secret management.

## 🚀 Quick Start

1. **Clone this repository**
2. **Set up secrets** (see [Secret Management](#secret-management) below)
3. **Configure Fleet** to point to this repository
4. **Deploy applications** using Fleet

## 📁 Repository Structure

```
├── apps/                    # Application Helm charts
│   ├── bazarr/             # Subtitle management
│   ├── sonarr/             # TV series management
│   ├── radarr/             # Movie management
│   ├── readarr/            # Book management
│   ├── lidarr/             # Music management
│   ├── prowlarr/           # Indexer management
│   ├── tautulli/           # Plex analytics
│   ├── qbittorrent/        # Torrent client
│   ├── sabnzbd/            # Usenet downloader
│   ├── channels/           # TV streaming
│   ├── organizr/           # Dashboard
│   ├── tdarr/              # Media transcoding
│   ├── huntarr/            # Arr-family app
│   ├── cleanuparr/         # Cleanup utility
│   ├── configarr/          # Configuration management
│   ├── cloudflare-ddns/    # Dynamic DNS
│   ├── gluetun-daemon/     # VPN daemon
│   └── openvscode-server/  # VS Code server
├── fleet.yaml              # Fleet configuration
└── README.md               # This file
```

## 🔐 Secret Management

### Prerequisites
Before deploying any applications, you must create the required Kubernetes secrets in your cluster.

### Required Secrets

#### 1. PostgreSQL Credentials (`postgres-credentials`)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-credentials
  namespace: arr  # Also create in: tdarr, web, downloader, default, kube-system
type: Opaque
data:
  password: <base64-encoded-postgres-password>
```

#### 2. Application API Keys (`app-api-keys`)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-api-keys
  namespace: arr  # Also create in: tdarr, web, downloader, default, kube-system
type: Opaque
data:
  bazarr-api-key: <base64-encoded-key>
  sonarr-1080-api-key: <base64-encoded-key>
  sonarr-4k-api-key: <base64-encoded-key>
  radarr-1080-api-key: <base64-encoded-key>
  radarr-4k-api-key: <base64-encoded-key>
  readarr-audio-api-key: <base64-encoded-key>
  readarr-ebook-api-key: <base64-encoded-key>
  lidarr-api-key: <base64-encoded-key>
  prowlarr-api-key: <base64-encoded-key>
```

#### 3. Cloudflare Credentials (`cloudflare-api-token`)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token
  namespace: kube-system
type: Opaque
data:
  api-token: <base64-encoded-cloudflare-api-token>
```

#### 4. qBittorrent Secret (`qbittorrent-secret`)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: qbittorrent-secret
  namespace: downloader
type: Opaque
data:
  qBittorrent.conf: <base64-encoded-config-file>
```

#### 5. Gluetun VPN Secrets (`gluetun-secrets`)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gluetun-secrets
  namespace: vpn
type: Opaque
data:
  protonvpn-username: <base64-encoded-username>
  protonvpn-password: <base64-encoded-password>
  wireguard-private-key: <base64-encoded-private-key>
```

### Secret Deployment Script

Create all secrets across namespaces:

```bash
#!/bin/bash

# Create namespaces if they don't exist
kubectl create namespace arr --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace tdarr --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace web --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace downloader --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace vpn --dry-run=client -o yaml | kubectl apply -f -

# Apply your secrets to all relevant namespaces
kubectl apply -f your-secrets.yaml
```

## 🌐 Domain Configuration

Each application supports domain configuration via Fleet values override:

### Fleet Values Override Example
```yaml
# fleet-values.yaml
global:
  domain: "yourdomain.com"
```

This will make applications available at:
- `sonarr.yourdomain.com`
- `radarr.yourdomain.com`
- `bazarr.yourdomain.com`
- etc.

## 📋 Application Details

### Media Management (Arr Stack)
- **Sonarr**: TV series management with dual instances (1080p/4K)
- **Radarr**: Movie management with dual instances (1080p/4K)
- **Readarr**: Book management with dual instances (Audio/eBook)
- **Lidarr**: Music management
- **Bazarr**: Subtitle management
- **Prowlarr**: Indexer management

### Download Clients
- **qBittorrent**: Torrent client with VueTorrent mod
- **SABnzbd**: Usenet downloader

### Supporting Apps
- **Tautulli**: Plex analytics
- **Organizr**: Dashboard and organization
- **Channels**: TV streaming
- **Tdarr**: Media transcoding
- **Huntarr**: Arr-family management
- **Cleanuparr**: Cleanup utility
- **Configarr**: Configuration management for arr stack

### Infrastructure
- **Cloudflare DDNS**: Dynamic DNS updates
- **Gluetun**: VPN daemon for download clients
- **OpenVSCode Server**: Development environment

## 🛠️ Development

### Adding New Applications

1. Create new directory in `apps/`
2. Add standard Helm chart structure
3. Ensure secrets use placeholder pattern: `PLACEHOLDER_NAME`
4. Add secret substitution via init containers
5. Configure ingress with `{{ .Values.global.domain }}` pattern
6. Add fleet-values.yaml for domain override

### Security Guidelines

- **Never commit real secrets** - use placeholders only
- **Use init containers** for secret substitution
- **Externalize all sensitive data** to Kubernetes secrets
- **Use proper RBAC** for secret access
- **Rotate secrets regularly**

## 📖 Fleet Configuration

### Repository Setup in Fleet

1. Add this repository as a Git repository in Fleet
2. Configure target namespaces for each application
3. Set up Fleet values override for domain configuration
4. Deploy applications via Fleet GitOps

### Fleet.yaml Structure

```yaml
defaultNamespace: arr
helm:
  values:
    global:
      domain: "yourdomain.com"
```

## 🔧 Troubleshooting

### Common Issues

1. **Secret not found**: Ensure secrets are created in the correct namespace
2. **Template syntax errors**: Check for proper placeholder usage
3. **Ingress not working**: Verify domain configuration and ingress controller
4. **Pod startup failures**: Check secret references and volume mounts

### Debug Commands

```bash
# Check secrets
kubectl get secrets -n <namespace>

# Check pod logs
kubectl logs -n <namespace> <pod-name> -c init-config

# Check configmap content
kubectl get configmap -n <namespace> <configmap-name> -o yaml
```

## 🚨 Security Notice

This repository is designed for public sharing with proper secret management:

- ✅ All sensitive data externalized to Kubernetes secrets
- ✅ Placeholder pattern for safe template usage
- ✅ Comprehensive .gitignore for secret files
- ✅ Init container pattern for runtime secret injection
- ✅ Domain configuration via Fleet values override

**Never commit files containing actual secrets, API keys, or passwords!**

## 📄 License

This repository contains configuration for open-source applications. Please respect the licenses of individual applications.

## 🤝 Contributing

1. Follow the security guidelines above
2. Test applications thoroughly before submitting
3. Ensure proper secret management implementation
4. Update documentation for new applications

---

**Happy GitOps with Fleet! 🚀**