# vastai-bootstrap

Scripts de démarrage pour instances GPU Vast.ai.

## Prérequis

- Clé SSH `runpod_nouvelle` présente dans `C:\Users\TON_USER\.ssh\`
- VM Hetzner démarrée avec les données à transférer
- Crédits suffisants sur le compte Vast.ai
- VNCViewer : `E:\Documents\3D\Runpod\vncviewer64-1.15.0.exe`

## Procédure complète

### 1. Louer une instance

- Aller sur https://cloud.vast.ai/search
- Filtres : RAM minimum 128 Go, template **NVIDIA CUDA**
- Cliquer sur **RENT**
- Attendre que l'instance soit active
- **Noter l'IP et le port SSH** affichés dans l'interface

### 2. Bootstrap dans le terminal web

```bash
apt-get update -y
apt-get install -y curl
curl -fsSL https://raw.githubusercontent.com/Wils-on-fire/vastai-bootstrap/refs/heads/main/bootstrap_vastai.sh | bash
```

### 3. Connexion SSH (PowerShell fenêtre 1)

```powershell
ssh -i $env:USERPROFILE\.ssh\runpod_nouvelle root@IP_VAST -p PORT_VAST
```

### 4. Tunnel VNC (PowerShell fenêtre 2)

```powershell
ssh -i $env:USERPROFILE\.ssh\runpod_nouvelle -L 5901:localhost:5901 root@IP_VAST -p PORT_VAST
```

### 5. Connexion VNC

- Ouvrir `E:\Documents\3D\Runpod\vncviewer64-1.15.0.exe`
- Adresse : `localhost:5901`
- Mot de passe : `vastvnc`

### 6. Réinjection des données depuis Hetzner

Dans le terminal de l'instance :

```bash
rsync -avz --no-owner --no-group \
  -e "ssh -i /root/.ssh/runpod_nouvelle" \
  wil@IP_HETZNER:/home/wil/backup-runpod-workspace/ \
  /workspace/
```

### 7. Fin de session — sauvegarde vers Hetzner

```bash
rsync -avz --no-owner --no-group \
  -e "ssh -i /root/.ssh/runpod_nouvelle" \
  /workspace/ \
  wil@IP_HETZNER:/home/wil/backup-runpod-workspace/
```

### 8. Détruire l'instance

- Dans l'interface Vast.ai → **Instances**
- Cliquer sur **Destroy** pour stopper toute facturation

## Scripts

| Fichier | Rôle |
|---|---|
| `bootstrap_vastai.sh` | Configure VNC et installe la clé SSH |
| `manage_packages.sh` | Sauvegarde et restaure les paquets apt installés manuellement |
