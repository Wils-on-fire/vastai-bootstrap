#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "=== [1/5] Mise à jour des paquets ==="
apt-get update -y

echo "=== [2/5] Installation des paquets nécessaires (XFCE, VNC) ==="
apt-get install -y \
  xfce4 xfce4-goodies \
  tigervnc-standalone-server \
  xterm \
  iproute2 net-tools \
  dbus-x11 \
  rsync \
  stacer \
  wget \
  gpg

echo "=== [3/5] Installation de Sublime Text ==="
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/sublimehq-archive.gpg
echo "deb https://download.sublimetext.com/ apt/stable/" > /etc/apt/sources.list.d/sublime-text.list
apt-get update -y
apt-get install -y sublime-text

echo "=== [4/5] Configuration et démarrage du serveur VNC (TigerVNC) ==="

mkdir -p /root/.vnc

echo "vastvnc" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd

cat > /root/.vnc/xstartup << 'XEOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export LIBGL_ALWAYS_SOFTWARE=1
dbus-launch --exit-with-session startxfce4
XEOF
chmod +x /root/.vnc/xstartup

vncserver -kill :1 >/dev/null 2>&1 || true

vncserver :1 -geometry 1280x800 -depth 24 -localhost yes

echo "=== [5/5] Installation de la clé SSH personnelle ==="
mkdir -p /root/.ssh
cat << 'KEYEOF' > /root/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIANd9I1a8OpsPbKtehNDkowjv3xmq25YCHnq2vw0Dn0S msi_wil@MSI_WIL-PC
KEYEOF
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

echo
echo "=== RÉSUMÉ ==="
echo "SSH  : déjà actif sur Vast.ai — utilise le port affiché dans l'interface web."
echo "VNC  : serveur lancé sur :1 (port 5901, localhost uniquement)."
echo "Depuis Windows : créer un tunnel SSH puis se connecter à localhost:5901 avec TigerVNC."
