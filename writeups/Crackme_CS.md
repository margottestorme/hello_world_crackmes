# Writeup - Crackme_CS

## Analyse initiale

### Test de strings
```bash
strings Crackme_CS
```

Cette commande ne révèle pas directement le mot de passe, ce qui indique qu'il n'est pas stocké en clair dans la section `.data`.

---

## Désassemblage et analyse statique

### Recherche de la logique de comparaison
```bash
objdump -d Crackme_CS | grep -A 20 "cmp"
```

Cette commande révèle une structure fragmentée en plusieurs sections (`check_fragment_0` à `check_fragment_7`), chacune vérifiant 2 caractères.

### Structure de la vérification

Contrairement aux crackmes précédents qui comparent directement, celui-ci utilise une **transformation arithmétique** :
```asm
<check_fragment_0>:
  401076:    movzbl (%r9),%eax         # Charger input[0]
  40107a:    add    $0x3,%eax          # Ajouter 3 au caractère
  40107d:    cmp    $0x44,%eax         # Comparer avec 0x44
  401080:    jne    401057 <decoy_2>   # Si différent → échec
```

**Pattern identifié :**
1. Charger un caractère de l'input
2. **Ajouter 3** à sa valeur ASCII
3. Comparer le résultat avec une valeur fixe
4. Sauter vers un "decoy" ou `bad_password` si différent

**Formule inverse :** `caractère_original = valeur_attendue - 3`

---

## Extraction du mot de passe

### Liste complète des comparaisons

En parcourant tous les fragments (`check_fragment_0` à `check_fragment_7`), on extrait les valeurs attendues après l'ajout de 3 :

| Position | Offset | Valeur après +3 | Hex  | Calcul    | Résultat | ASCII |
|----------|--------|----------------|------|-----------|----------|-------|
| 0        | 0x0    | 0x44           | 68   | 68 - 3    | 0x41     | **A** |
| 1        | 0x1    | 0x45           | 69   | 69 - 3    | 0x42     | **B** |
| 2        | 0x2    | 0x49           | 73   | 73 - 3    | 0x46     | **F** |
| 3        | 0x3    | 0x53           | 83   | 83 - 3    | 0x50     | **P** |
| 4        | 0x4    | 0x57           | 87   | 87 - 3    | 0x54     | **T** |
| 5        | 0x5    | 0x39           | 57   | 57 - 3    | 0x36     | **6** |
| 6        | 0x6    | 0x3A           | 58   | 58 - 3    | 0x37     | **7** |
| 7        | 0x7    | 0x47           | 71   | 71 - 3    | 0x44     | **D** |
| 8        | 0x8    | 0x4A           | 74   | 74 - 3    | 0x47     | **G** |
| 9        | 0x9    | 0x39           | 57   | 57 - 3    | 0x36     | **6** |
| 10       | 0xA    | 0x3C           | 60   | 60 - 3    | 0x39     | **9** |
| 11       | 0xB    | 0x48           | 72   | 72 - 3    | 0x45     | **E** |
| 12       | 0xC    | 0x3B           | 59   | 59 - 3    | 0x38     | **8** |
| 13       | 0xD    | 0x35           | 53   | 53 - 3    | 0x32     | **2** |
| 14       | 0xE    | 0x36           | 54   | 54 - 3    | 0x33     | **3** |
| 15       | 0xF    | 0x56           | 86   | 86 - 3    | 0x53     | **S** |

Position 16 : `\n` (0x0A)

### Script Python de résolution
```python
# Valeurs attendues après l'ajout de 3
expected_values = [0x44, 0x45, 0x49, 0x53, 0x57, 0x39, 0x3A, 0x47,
                   0x4A, 0x39, 0x3C, 0x48, 0x3B, 0x35, 0x36, 0x56]

# Soustraire 3 pour obtenir les caractères originaux
password = ''.join(chr(val - 3) for val in expected_values)
print(f"Password: {password}")
# Output: ABFPT67DG69E823S
```

---

## Solution

### Mot de passe
```
ABFPT67DG69E823S
```

### Validation
```bash
./Crackme_CS
Enter flag:
ABFPT67DG69E823S
Good Job!

---
