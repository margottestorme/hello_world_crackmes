# Writeup - Krasý_sa_2 Crackme

## Solution

### Analyse basique
La première étape consiste à examiner les chaînes de caractères présentes dans le binaire avec la commande `strings` :

```bash
strings Krasý_sa_2
```

### Résultat
En parcourant la sortie de la commande, le mot de passe apparaît en clair dans les chaînes du binaire.

**Flag trouvé :** `[Kounyamanmanwzot]`

### Validation
Il suffit d'exécuter le binaire et d'entrer le mot de passe trouvé :

```bash
./Krasý_sa_2
Kounyamanmanwzot
Good Job!
```

## Outils utilisés
- `strings` - affichage des chaînes de caractères imprimables