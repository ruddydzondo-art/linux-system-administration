#!/usr/bin/env bash

SSH_MAIN_CONFIG="/etc/ssh/sshd_config"
SSH_BACKUP="/etc/ssh/sshd_config.bak"
SSH_DROPIN="/etc/ssh/sshd_config.d/00-hardening.conf"

if [[ ! -f "$SSH_BACKUP" ]]; then
    cp "$SSH_MAIN_CONFIG" "$SSH_BACKUP"
    echo "[SSH] Sauvegarde d'origine créée : $SSH_BACKUP"
fi

cat << EOF > "$SSH_DROPIN"
# Configuration générée automatiquement par hardening.sh
Port ${SSH_PORT}
PermitRootLogin no
PermitEmptyPasswords no
MaxAuthTries ${MAX_AUTH_TRIES}
AllowUsers ${ALLOW_USERS}
X11Forwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

chmod 600 "$SSH_DROPIN"
echo "[SSH] Fichier de surcharge généré : $SSH_DROPIN"

if sshd -t; then
    systemctl reload sshd
    echo "[SSH] Syntaxe valide. Service sshd rechargé avec succès."
else
    echo "[ERREUR CRITIQUE] Syntaxe SSH invalide ! Annulation des modifications..." >&2
    rm -f "$SSH_DROPIN"
    exit 1
fi
