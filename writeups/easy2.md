# Writeup - easy2

## Analyse initiale

### Vérification du fichier
```bash
file easy2
# easy2: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped
```

---

Le binaire est un exécutable 64 bits Linux, non strippé.

### Test de strings
```bash
strings easycrackmecrazy
```

Cette commande ne révèle pas directement le mot de passe, ce qui indique qu'il n'est pas stocké en clair dans la section `.data`.

---

### Vérifications préliminaires
```asm
40101b:    cmp    $0x11,%rax              # Longueur doit être 17 (16 + \n)
40101f:    jne    401077 <bad_password>
401021:    cmpb   $0xa,0x402028           # Dernier octet doit être \n
401029:    jne    401077 <bad_password>
```

---

## Désassemblage et analyse statique

### Recherche de la logique de vérification
```bash
objdump -d easy2 | grep -A 20 "cmp"
```

Cette commande révèle un algorithme de **sommation** suivi d'une **vérification de checksum**.

### Structure de l'algorithme

Le code calcule la somme de tous les caractères de l'input puis vérifie cette somme :
```asm
40102b:    xor    %rcx,%rcx               # rcx = 0 (compteur)
40102e:    xor    %rbx,%rbx               # rbx = 0 (accumulateur)

<sum_loop>:
  401031:    cmp    $0x10,%rcx            # Boucle sur 16 caractères
  401035:    je     401047 <verify_sum>
  401037:    movzbq 0x402018(%rcx),%rax  # Charger input[i]
  40103f:    add    %rax,%rbx             # rbx += input[i]
  401042:    inc    %rcx                  # i++
  401045:    jmp    401031 <sum_loop>

<verify_sum>:
  401047:    cmp    $0x451,%rbx           # Vérifier somme = 0x451
  40104e:    jne    401077 <bad_password>
```

**Pattern identifié :**
1. Initialiser un accumulateur à 0
2. Pour chaque caractère de l'input (16 caractères)
3. Ajouter sa valeur ASCII à l'accumulateur
4. Vérifier que la somme totale = `0x451` (1105 en décimal)

**Formule :** `sum(input[0] + input[1] + ... + input[15]) = 0x451 = 1105`

---

## Particularité : Multiple solutions

Contrairement aux crackmes précédents qui ont **un seul mot de passe correct**, ce crackme accepte **une infinité de solutions** !

N'importe quelle combinaison de 16 caractères ASCII dont la somme vaut 1105 est valide.

---

## Résolution

### Calcul simple

La manière la plus simple est d'utiliser des caractères identiques ou presque :
```python
target_sum = 0x451  # 1105
num_chars = 16

# Moyenne par caractère
avg = target_sum / num_chars  # 1105 / 16 = 69.0625

# Le caractère 'E' a la valeur ASCII 69
# 16 * 69 = 1104 (il manque 1)

# Solution : 15 caractères 'E' + 1 caractère 'F' (70)
password = 'E' * 15 + 'F'

# Vérification
print(sum(ord(c) for c in password))  # 1105 ✓
```

---

## Solution

### Mot de passe (le plus simple)
```
EEEEEEEEEEEEEEEF
```

### Vérification mathématique
```python
password = "EEEEEEEEEEEEEEEF"

# Calcul de la somme
# 'E' = 69, 'F' = 70
# 15 × 69 + 1 × 70 = 1035 + 70 = 1105 ✓

total = sum(ord(c) for c in password)
print(f"Somme: {total}")        # 1105
print(f"Hex: {hex(total)}")     # 0x451
```

### Validation
```bash
./easy2
EEEEEEEEEEEEEEEF
Good Job!
```