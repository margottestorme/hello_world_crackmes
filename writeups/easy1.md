# Writeup - Easy1 Crackme

## Solution

### Analyse basique
La première étape consiste à examiner les chaînes de caractères présentes dans le binaire avec la commande `strings` :

```bash
strings easy1
```

### Résultat
En parcourant la sortie de la commande, le mot de passe apparaît en clair dans les chaînes du binaire.

**Flag trouvé :** `[EASY_FLAG_123456]`

### Validation
Il suffit d'exécuter le binaire et d'entrer le mot de passe trouvé :

```bash
./easy1
EASY_FLAG_123456
Good Job!
```

## Outils utilisés
- `strings` - affichage des chaînes de caractères imprimables