# Projet 02 : Gestion et Extension Dynamique du Stockage LVM (Rocky Linux 9)

![OS](https://img.shields.io/badge/OS-Rocky_Linux_9-10B981?style=flat-square&logo=rockylinux&logoColor=white)
![Storage](https://img.shields.io/badge/Stockage-LVM2_%2F_XFS-0078D4?style=flat-square)
![Status](https://img.shields.io/badge/Statut-Opérationnel-10B981?style=flat-square)

> **Automatisation du provisionnement initial et de l'extension à chaud (sans interruption de service) d'un volume logique LVM formaté en XFS.**

---

## 1. Problème résolu
En production, la saturation d'une partition applicative exige d'augmenter la capacité disque **sans démonter le système de fichiers ni arrêter le service**. Ce projet automatise de manière idempotente la création de la pile LVM (PV, VG, LV), le montage persistant par UUID dans `/etc/fstab` et l'extension en ligne du volume et du système de fichiers XFS.

## 2. Architecture du projet

```text
02-lvm-storage-management/
├── README.md                     # Documentation technique et preuves d'audit
├── config/
│   └── lvm.conf                  # Paramètres cibles (partitions, noms VG/LV, tailles, point de montage)
└── scripts/
    ├── 01_provision_lvm.sh       # Création PV/VG/LV, formatage XFS, montage persistant UUID (/etc/fstab)
    └── 02_extend_lvm.sh          # Ajout d'un 2e PV au VG et extension à chaud LV + XFS (lvextend -r)
