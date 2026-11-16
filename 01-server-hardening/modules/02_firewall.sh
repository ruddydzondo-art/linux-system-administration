#!/usr/bin/env bash

# 1. Démarrer et activer firewalld au boot si nécessaire
if ! systemctl is-active --quiet firewalld; then
    systemctl enable --now firewalld
    echo "[FIREWALL] Service firewalld démarré et activé."
fi

DEFAULT_ZONE=$(firewall-cmd --get-default-zone)
echo "[FIREWALL] Zone active détectée : $DEFAULT_ZONE"

# 2. Retirer tout service qui ne figure pas dans ALLOWED_SERVICES
CURRENT_SERVICES=$(firewall-cmd --zone="$DEFAULT_ZONE" --list-services)
for service in $CURRENT_SERVICES; do
    if [[ ! " ${ALLOWED_SERVICES} " =~ " ${service} " ]]; then
        firewall-cmd --permanent --zone="$DEFAULT_ZONE" --remove-service="$service" >/dev/null
        echo "[FIREWALL] Service superflu retiré : $service"
    fi
done

# 3. S'assurer que les services autorisés sont bien actifs
for allowed in $ALLOWED_SERVICES; do
    if ! firewall-cmd --permanent --zone="$DEFAULT_ZONE" --query-service="$allowed" >/dev/null; then
        firewall-cmd --permanent --zone="$DEFAULT_ZONE" --add-service="$allowed" >/dev/null
        echo "[FIREWALL] Service autorisé ajouté : $allowed"
    fi
done

# 4. Appliquer les règles à chaud
firewall-cmd --reload >/dev/null
echo "[FIREWALL] Règles rechargées avec succès."
