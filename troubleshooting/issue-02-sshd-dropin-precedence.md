---

### 2. Fichier `troubleshooting/issue-02-sshd-dropin-precedence.md`

```markdown
# Incident 02 : Directive `X11Forwarding no` ignorée dans `sshd_config.d`

## Problème
`sudo sshd -T | grep x11forwarding` affiche toujours `x11forwarding yes` malgré l'ajout de `99-hardening.conf`.

**Explication :** OpenSSH lit `sshd_config.d/` par ordre alphabétique et applique la **première** règle trouvée. Le fichier système `50-redhat.conf` (`X11Forwarding yes`) passait donc avant `99-hardening.conf`.

## Solution
Renommer le fichier en `00-hardening.conf` pour qu'il soit lu en premier, supprimer l'ancien et relancer le script :

```bash
sudo rm -f /etc/ssh/sshd_config.d/99-hardening.conf
sudo ./01-server-hardening/hardening.sh
