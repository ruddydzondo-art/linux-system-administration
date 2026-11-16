#!/usr/bin/env bash

# 1. Verrouillage des permissions sur les fichiers d'identité critiques
chmod 0000 /etc/shadow /etc/gshadow
chown root:root /etc/shadow /etc/gshadow

chmod 0644 /etc/passwd /etc/group
chown root:root /etc/passwd /etc/group
echo "[USERS] Permissions et propriétaires des fichiers d'identité verrouillés."

# 2. Durcissement de la politique de mots de passe dans /etc/login.defs
LOGIN_DEFS="/etc/login.defs"
LOGIN_DEFS_BAK="/etc/login.defs.bak"

if [[ ! -f "$LOGIN_DEFS_BAK" ]]; then
    cp "$LOGIN_DEFS" "$LOGIN_DEFS_BAK"
    echo "[USERS] Sauvegarde d'origine créée : $LOGIN_DEFS_BAK"
fi

sed -i "s/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   ${PASS_MAX_DAYS}/" "$LOGIN_DEFS"
sed -i "s/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   ${PASS_MIN_DAYS}/" "$LOGIN_DEFS"
sed -i "s/^PASS_WARN_AGE.*/PASS_WARN_AGE   ${PASS_WARN_AGE}/" "$LOGIN_DEFS"

# PASS_MIN_LEN est parfois commenté ou absent sur RHEL 9 : on le met à jour ou on l'ajoute
if grep -q "^PASS_MIN_LEN" "$LOGIN_DEFS"; then
    sed -i "s/^PASS_MIN_LEN.*/PASS_MIN_LEN    ${PASS_MIN_LEN}/" "$LOGIN_DEFS"
else
    echo "PASS_MIN_LEN    ${PASS_MIN_LEN}" >> "$LOGIN_DEFS"
fi

echo "[USERS] Politique de mots de passe appliquée dans $LOGIN_DEFS."
