#!/bin/bash
#
# manage_packages.sh
# Gestion des paquets installés manuellement dans un Pod RunPod éphémère
# - Mode "backup"  : génère une liste des paquets installés manuellement
# - Mode "restore" : réinstalle les paquets à partir de la liste sauvegardée
#
# Aucune automatisation au démarrage. Usage manuel uniquement.
#

###############################################
# CONFIG PATHS (Volume RunPod)
###############################################

VOLUME="/workspace/persistent-works"
PKG_DIR="$VOLUME/packages"
LOG_DIR="$VOLUME/logs"
MANUAL_LIST="$PKG_DIR/manual-packages.txt"

###############################################
# Ensure directories exist
###############################################

mkdir -p "$PKG_DIR"
mkdir -p "$LOG_DIR"

###############################################
# Logging helper
###############################################

LOGFILE="$LOG_DIR/manage_packages_$(date +%Y%m%d-%H%M%S).log"

log() {
    echo -e "$1" | tee -a "$LOGFILE"
}

###############################################
# Backup installed manual packages
###############################################

backup_packages() {

    log "======== MODE BACKUP DES PAQUETS ========"

    # Vérification d'apt-mark
    if ! command -v apt-mark >/dev/null 2>&1; then
        log "ERREUR : 'apt-mark' est introuvable. Impossible de générer la liste."
        exit 1
    fi

    log "Génération de la liste des paquets installés manuellement..."
    apt-mark showmanual | sort > "$MANUAL_LIST"

    log ""
    log "Liste enregistrée dans : $MANUAL_LIST"
    log "Vous pouvez éditer ce fichier manuellement pour supprimer des paquets inutiles."
    log "Backup terminé."
}

###############################################
# Restore packages from saved list
###############################################

restore_packages() {

    log "======== MODE RESTORE DES PAQUETS ========"

    if [[ ! -f "$MANUAL_LIST" ]]; then
        log "ERREUR : Aucun fichier '$MANUAL_LIST' trouvé."
        log "Lancez d'abord : ./manage_packages.sh backup"
        exit 1
    fi

    log "Lecture des paquets depuis : $MANUAL_LIST"
    log ""
    log "Paquets à réinstaller :"
    log "-----------------------------------------"
    cat "$MANUAL_LIST" | tee -a "$LOGFILE"
    log "-----------------------------------------"

    echo ""
    read -p "Confirmer l'installation de ces paquets ? [y/N] " confirm

    if [[ "$confirm" != "y" ]]; then
        log "Restauration annulée."
        exit 0
    fi

    log ""
    log "Mise à jour de la liste des dépôts..."
    apt-get update >> "$LOGFILE" 2>&1

    log "Installation des paquets..."
    xargs -a "$MANUAL_LIST" apt-get install -y >> "$LOGFILE" 2>&1

    log ""
    log "Restauration des paquets terminée."
}

###############################################
# Interface / Menu
###############################################

show_menu() {
    echo "============================================="
    echo "       manage_packages.sh - Menu"
    echo "============================================="
    echo "1) Sauvegarder la liste des paquets installés"
    echo "2) Restaurer les paquets depuis la liste"
    echo "3) Quitter"
    echo ""
    read -p "Choix [1-3] : " choice

    case "$choice" in
        1) backup_packages ;;
        2) restore_packages ;;
        3) exit 0 ;;
        *) echo "Choix invalide."; exit 1 ;;
    esac
}

###############################################
# Mode CLI direct (backup / restore)
###############################################

case "$1" in
    backup)  backup_packages ;;
    restore) restore_packages ;;
    "")      show_menu ;;
    *)       echo "Usage : $0 [backup|restore]"; exit 1 ;;
esac
