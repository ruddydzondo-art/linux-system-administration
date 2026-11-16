#!/usr/bin/env bash

# 1. Vérification et enforcement de SELinux
SELINUX_CONFIG="/etc/selinux/config"

if command -v getenforce >/dev/null 2>&1; then
    CURRENT_SELINUX=$(getenforce)
    if [[ "$CURRENT_SELINUX" == "Permissive" ]]; then
        setenforce 1
        echo "[SELINUX] Mode basculé à chaud de Permissive vers Enforcing."
    elif [[ "$CURRENT_SELINUX" == "Disabled" ]]; then
        echo "[AVERTISSEMENT] SELinux est Disabled : un redémarrage sera nécessaire après modification de $SELINUX_CONFIG."
    else
        echo "[SELINUX] Déjà actif en mode Enforcing."
    fi

    if [[ -f "$SELINUX_CONFIG" ]]; then
        sed -i 's/^SELINUX=.*/SELINUX=enforcing/' "$SELINUX_CONFIG"
        echo "[SELINUX] Persistance vérifiée dans $SELINUX_CONFIG (SELINUX=enforcing)."
    fi
fi

# 2. Durcissement des paramètres réseau du noyau (sysctl)
SYSCTL_DROPIN="/etc/sysctl.d/99-hardening.conf"

cat << 'EOF' > "$SYSCTL_DROPIN"
# Paramètres de durcissement noyau générés par hardening.sh
# Désactiver le routage IP (le serveur n'est pas un routeur)
net.ipv4.ip_forward = 0

# Protection contre les attaques SYN Flood
net.ipv4.tcp_syncookies = 1

# Ignorer les redirections ICMP (protection Man-in-the-Middle)
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Refuser l'envoi de redirections ICMP
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Activer la vérification d'adresse source (anti-spoofing)
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Journaliser les paquets aux adresses impossibles (martians)
net.ipv4.conf.all.log_martians = 1
EOF

chmod 644 "$SYSCTL_DROPIN"
sysctl --system >/dev/null
echo "[KERNEL] Paramètres sysctl appliqués et rechargés depuis $SYSCTL_DROPIN."
