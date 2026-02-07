# Writeup - Fait_Toi_Confiance Crackme

## Solution

### Analyse basique
La première étape consiste à examiner les chaînes de caractères présentes dans le binaire avec la commande `strings` :

```bash
strings Fait_Toi_Confiance
```

### Résultat
En parcourant la sortie de la commande, le mot de passe apparaît en clair dans les chaînes du binaire.

**Flag trouvé :** `[U2FubmR5Y29vbA=]`

### Validation
Il suffit d'exécuter le binaire et d'entrer le mot de passe trouvé :

```bash
./Fait_Toi_Confiance
U2FubmR5Y29vbA=
Good Job!
```

## Outils utilisés
- `strings` - affichage des chaînes de caractères imprimables