#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[ERREUR] Ce script doit être exécuté avec sudo ou en tant que root." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/lvm.conf"

LV_PATH="/dev/${VG_NAME}/${LV_NAME}"

# 1. Initialisation du nouveau Physical Volume (idempotent)
if ! pvs "$PV_EXTENSION" >/dev/null 2>&1; then
    pvcreate "$PV_EXTENSION"
    echo "[LVM] Nouveau Physical Volume créé sur $PV_EXTENSION."
else
    echo "[LVM] Physical Volume déjà initialisé sur $PV_EXTENSION."
fi

# 2. Ajout du PV au Volume Group existant s'il n'y appartient pas encore
CURRENT_VG=$(pvs --noheadings -o vg_name "$PV_EXTENSION" | tr -d ' ')
if [[ "$CURRENT_VG" != "$VG_NAME" ]]; then
    vgextend "$VG_NAME" "$PV_EXTENSION"
    echo "[LVM] '$PV_EXTENSION' ajouté au Volume Group '$VG_NAME'."
else
    echo "[LVM] '$PV_EXTENSION' fait déjà partie de '$VG_NAME'."
fi

# 3. Extension à chaud du Logical Volume ET du système de fichiers (-r)
lvextend -r -L "$LV_EXTEND_SIZE" "$LV_PATH"
echo "[LVM] Volume '$LV_PATH' et système de fichiers $FS_TYPE étendus de $LV_EXTEND_SIZE à chaud."
