# Writeup - easycrackmecrazy

## Analyse initiale

### Test de strings
```bash
strings easycrackmecrazy
```

Cette commande ne révèle pas directement le mot de passe, ce qui indique qu'il n'est pas stocké en clair dans la section `.data`.

---

## Désassemblage et analyse statique

### Recherche de la logique de comparaison
```bash
objdump -d easycrackmecrazy | grep -A 20 "cmp"
```

Cette commande révèle la logique principale du programme : une série de comparaisons `cmpb` (compare byte) successives.

### Structure de la vérification

Le code compare chaque caractère de l'input (stocké à l'adresse `0x402078 + offset`) avec une valeur hexadécimale :
```asm
401020:    cmpb   $0x32,0x402078(%rcx)    # Compare avec 0x32
401027:    jne    401161 <_error>         # Si différent → erreur
40102d:    inc    %rcx                    # Passe au caractère suivant
401030:    cmpb   $0x66,0x402078(%rcx)    # Compare avec 0x66
401037:    jne    401161 <_error>
...
```

**Pattern identifié :**
1. Comparaison d'un octet avec une valeur hex
2. Saut vers `_error` si différent (`jne`)
3. Incrémentation du compteur (`inc %rcx`)
4. Répétition pour chaque caractère

---

## Extraction du mot de passe

### Liste complète des comparaisons

En parcourant le désassemblage, on extrait toutes les valeurs hexadécimales comparées :

| Position | Hex  | ASCII | Position | Hex  | ASCII |
|----------|------|-------|----------|------|-------|
| 0        | 0x32 | 2     | 8        | 0x37 | 7     |
| 1        | 0x66 | f     | 9        | 0x74 | t     |
| 2        | 0x5A | Z     | 10       | 0x48 | H     |
| 3        | 0x54 | T     | 11       | 0x46 | F     |
| 4        | 0x33 | 3     | 12       | 0x43 | C     |
| 5        | 0x36 | 6     | 13       | 0x66 | f     |
| 6        | 0x76 | v     | 14       | 0x7A | z     |
| 7        | 0x7A | z     | 15       | 0x58 | X     |

Dernière comparaison : `0x0a` = `\n` (caractère newline)

### Conversion hex → ASCII
```python
# Script Python pour convertir
hex_values = [0x32, 0x66, 0x5A, 0x54, 0x33, 0x36, 0x76, 0x7A, 
              0x37, 0x74, 0x48, 0x46, 0x43, 0x66, 0x7A, 0x58]

password = ''.join(chr(x) for x in hex_values)
print(password)
# Output: 2fZT36vz7tHFCfzX
```

---

## Solution

### Mot de passe
```
2fZT36vz7tHFCfzX
```

### Validation
```bash
./easycrackmecrazy
2fZT36vz7tHFCfzX
AU SECOUUUURS
ARRETERRRR
LAISSEZ MOIIIIII
BLBLLBLMBLBM..je me noie
```
