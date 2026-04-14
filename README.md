# vastai-bootstrap

Scripts de démarrage pour instances GPU Vast.ai.

## Workflow

1. Louer une instance sur Vast.ai (noter l'IP et le port SSH affiché)
2. Ouvrir le terminal web de l'instance
3. Lancer le bootstrap :

```bash
curl -fsSL https://raw.githubusercontent.com/Wils-on-fire/vastai-bootstrap/refs/heads/main/bootstrap_vastai.sh | bash
```

4. Réinjecter les données depuis Hetzner via `rsync`
5. Travailler
6. Sauvegarder vers Hetzner puis détruire l'instance

## Connexion VNC depuis Windows

1. Créer un tunnel SSH :
```bash
ssh -L 5901:localhost:5901 root@IP_INSTANCE -p PORT_VAST
```
2. Se connecter avec TigerVNC sur `localhost:5901`
3. Mot de passe : `vastvnc`

## Scripts

| Fichier | Rôle |
|---|---|
| `bootstrap_vastai.sh` | Configure VNC et installe la clé SSH |
| `manage_packages.sh` | Sauvegarde et restaure les paquets apt installés manuellement |
