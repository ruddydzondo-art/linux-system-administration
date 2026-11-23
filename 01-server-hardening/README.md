# Module 01 : Automatisation du Durcissement Serveur (RHEL / Rocky Linux)

![OS](https://img.shields.io/badge/OS-Rocky_Linux_9-10B981?style=flat-square&logo=rockylinux&logoColor=white)
![Bash](https://img.shields.io/badge/Langage-Bash_Modulaire-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![Status](https://img.shields.io/badge/Statut-En_développement-F59E0B?style=flat-square)

> **Un outil d'administration en Bash permettant d'appliquer automatiquement, de manière répétable et sécurisée, les bonnes pratiques de sécurité sur un serveur Rocky Linux 9 fraîchement installé.**

---

## 1. Problème résolu
Lorsqu'un serveur Linux est déployé avec sa configuration par défaut, il expose inutilement sa surface d'attaque (accès `root` autorisé en SSH, tentatives de connexion illimitées, paramètres réseau permissifs). Appliquer ces correctifs manuellement serveur par serveur est lent, source d'oubli et risqué (une simple faute de frappe dans la configuration SSH peut verrouiller l'administrateur hors de la machine).

## 2. Objectif du projet
Construire un script d'automatisation **modulaire** et **idempotent** (exécutable plusieurs fois sans altérer le système) capable de :
* Sécuriser l'accès distant (SSH) avec validation syntaxique et retour arrière (*rollback*) automatique en cas d'erreur.
* Verrouiller le pare-feu réseau (`firewalld`) sur le strict minimum nécessaire.
* Renforcer les politiques de mots de passe et les permissions sur les fichiers système critiques.
* Vérifier et imposer le mode `Enforcing` de **SELinux** ainsi que le durcissement réseau du noyau (`sysctl`).

---

## 3. Architecture de l'outil

```text
01-server-hardening/
├── README.md                 # Documentation technique du module
├── hardening.sh              # Script maître (vérification root, chargement config, journalisation)
├── config/
│   └── hardening.conf        # Variables d'environnement (port SSH, utilisateurs autorisés)
├── modules/
│   ├── 01_ssh.sh             # Durcissement OpenSSH via /etc/ssh/sshd_config.d/
│   ├── 02_firewall.sh        # Configuration restrictive de firewalld
│   ├── 03_users_perms.sh     # Politiques de mots de passe et permissions critiques
│   └── 04_selinux_kernel.sh  # Vérification SELinux et paramètres noyau (sysctl)
└── logs/                     # Journaux d'exécution horodatés (ignorés par Git)
