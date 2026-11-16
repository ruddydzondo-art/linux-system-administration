# Incident 01 : Connexion SSH refusée vers GitHub (port 22)

## Problème
`ssh: connect to host github.com port 22: Connection refused`

**Explication :** Le réseau local bloque les connexions sortantes sur le port TCP `22`, mais autorise le port HTTPS `443`.

## Solution
Configurer `~/.ssh/config` pour passer par le port `443` de GitHub :

```text
Host github.com
    Hostname ssh.github.com
    Port 443
    User git
