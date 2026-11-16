#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[ERREUR] Ce script doit être exécuté avec sudo ou en tant que root." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/logs/hardening_$(date +%F_%H-%M-%S).log"

source "${SCRIPT_DIR}/config/hardening.conf"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=================================================="
echo " Démarrage du durcissement : $(date)"
echo "=================================================="

for module in "${SCRIPT_DIR}"/modules/*.sh; do
    if [[ -f "$module" ]]; then
        echo "[INFO] Exécution du module : $(basename "$module")"
        source "$module"
    fi
done

echo "=================================================="
echo " Durcissement terminé avec succès."
echo "=================================================="
