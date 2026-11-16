#!/usr/bin/env bash
set -euo pipefail

# 1. Contrôle des privilèges root
if [[ $EUID -ne 0 ]]; then
    echo "[ERREUR] Ce script doit être exécuté avec sudo ou en tant que root." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/lvm.conf"

LV_PATH="/dev/${VG_NAME}/${LV_NAME}"

# 2. Création idempotente du Volume Physique (PV)
if ! pvs "$PV_INITIAL" >/dev/null 2>&1; then
    pvcreate "$PV_INITIAL"
    echo "[LVM] Physical Volume créé sur $PV_INITIAL."
else
    echo "[LVM] Physical Volume déjà présent sur $PV_INITIAL."
fi

# 3. Création idempotente du Volume Group (VG)
if ! vgs "$VG_NAME" >/dev/null 2>&1; then
    vgcreate "$VG_NAME" "$PV_INITIAL"
    echo "[LVM] Volume Group '$VG_NAME' créé."
else
    echo "[LVM] Volume Group '$VG_NAME' déjà existant."
fi

# 4. Création idempotente du Logical Volume (LV)
if ! lvs "$LV_PATH" >/dev/null 2>&1; then
    lvcreate -L "$LV_INITIAL_SIZE" -n "$LV_NAME" "$VG_NAME"
    echo "[LVM] Logical Volume '$LV_NAME' ($LV_INITIAL_SIZE) créé."
else
    echo "[LVM] Logical Volume '$LV_NAME' déjà existant."
fi

# 5. Formatage en XFS uniquement si aucun système de fichiers n'est détecté
if ! blkid -o value -s TYPE "$LV_PATH" >/dev/null 2>&1; then
    mkfs."$FS_TYPE" "$LV_PATH"
    echo "[FS] Système de fichiers $FS_TYPE formaté sur $LV_PATH."
else
    echo "[FS] Système de fichiers déjà présent sur $LV_PATH."
fi

# 6. Création du point de montage et sauvegarde /etc/fstab
mkdir -p "$MOUNT_POINT"

if [[ ! -f /etc/fstab.bak ]]; then
    cp /etc/fstab /etc/fstab.bak
    echo "[FSTAB] Sauvegarde créée : /etc/fstab.bak"
fi

# 7. Montage persistant via UUID dans /etc/fstab
UUID=$(blkid -s UUID -o value "$LV_PATH")
if ! grep -q "$UUID" /etc/fstab; then
    echo "UUID=${UUID}  ${MOUNT_POINT}  ${FS_TYPE}  defaults  0 0" >> /etc/fstab
    echo "[FSTAB] Entrée ajoutée avec UUID=$UUID."
fi

systemctl daemon-reload
mount -a
echo "[MOUNT] Volume monté avec succès sur $MOUNT_POINT."
