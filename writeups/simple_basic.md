# Writeup - simple_basic

## Analyse initiale

### Test de strings
```bash
strings simple_basic
```

Cette commande ne révèle pas directement le mot de passe en clair, mais peut montrer les messages "Good password" et "Bad password".

---

## Désassemblage et analyse statique

### Recherche de la logique de comparaison
```bash
objdump -d simple_basic | grep -A 50 "cmp"
```

Cette commande révèle immédiatement toute la logique du crackme : une série de comparaisons `cmpb` (compare byte) extrêmement simple et directe.

### Structure de la vérification

Le code compare chaque caractère de l'input (pointé par `%esi`) avec une valeur hexadécimale fixe :
```asm
804901b:    cmpb   $0x43,(%esi)          # Compare caractère 0 avec 0x43
804901e:    jne    80490b2 <bad_password> # Si différent → échec
8049024:    cmpb   $0x48,0x1(%esi)       # Compare caractère 1 avec 0x48
8049028:    jne    80490b2 <bad_password>
804902e:    cmpb   $0x4f,0x2(%esi)       # Compare caractère 2 avec 0x4F
8049032:    jne    80490b2 <bad_password>
...
```

**Pattern identifié :**
1. Comparaison d'un octet à l'offset N avec une valeur hex
2. Saut vers `bad_password` si différent (`jne`)
3. Passage au caractère suivant (offset N+1)
4. Répétition pour tous les caractères

**Particularité :** Le dernier caractère accepte SOIT `\n` (0x0a) SOIT `\0` (0x00) :
```asm
8049082:    cmpb   $0xa,0x10(%esi)    # \n ?
8049086:    je     8049090 <good_password>
8049088:    cmpb   $0x0,0x10(%esi)    # \0 ?
804908c:    je     8049090 <good_password>
```

---

## Extraction du mot de passe

### Liste complète des comparaisons

En parcourant séquentiellement le code, on extrait toutes les valeurs hexadécimales comparées :

| Position | Hex  | ASCII | Position | Hex  | ASCII |
|----------|------|-------|----------|------|-------|
| 0        | 0x43 | C     | 8        | 0x49 | I     |
| 1        | 0x48 | H     | 9        | 0x4E | N     |
| 2        | 0x4F | O     | 10       | 0x45 | E     |
| 3        | 0x43 | C     | 11       | 0x5F | _     |
| 4        | 0x4F | O     | 12       | 0x43 | C     |
| 5        | 0x4C | L     | 13       | 0x5F | _     |
| 6        | 0x41 | A     | 14       | 0x4F | O     |
| 7        | 0x54 | T     | 15       | 0x4B | K     |

Position 16 : `0x0a` (\n) ou `0x00` (\0)

### Conversion hex → ASCII
```python
# Script Python pour convertir
hex_values = [0x43, 0x48, 0x4F, 0x43, 0x4F, 0x4C, 0x41, 0x54,
              0x49, 0x4E, 0x45, 0x5F, 0x43, 0x5F, 0x4F, 0x4B]

password = ''.join(chr(x) for x in hex_values)
print(password)
# Output: CHOCOLATINE_C_OK
```

---

## Solution

### Mot de passe
```
CHOCOLATINE_C_OK
```

### Validation
```bash
./simple_basic
CHOCOLATINE_C_OK
Good Job!
```
