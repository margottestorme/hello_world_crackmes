# Writeup - Birth of the URSSAF Crackme

## Analyse initiale

### 1. Reconnaissance du binaire

```bash
file "Birth of the URSSAF"
strings "Birth of the URSSAF"
```

Cette commande ne révèle pas directement le mot de passe, ce qui indique qu'il n'est pas stocké en clair dans la section `.data`.

### 2. Analyse préliminaire avec objdump

```bash
objdump -d "Birth of the URSSAF" | grep -i "xor"
objdump -d "Birth of the URSSAF" | grep -i "cmp"
```

**Instructions XOR détectées :**
```asm
  401005:       48 31 ff                xor    %rdi,%rdi
  401008:       48 31 f6                xor    %rsi,%rsi
  40100b:       48 31 d2                xor    %rdx,%rdx
  40100e:       4d 31 d2                xor    %r10,%r10
  401052:       48 31 c9                xor    %rcx,%rcx
  401061:       34 42                   xor    $0x42,%al      # ← CLÉ XOR !
  401090:       48 31 ff                xor    %rdi,%rdi
```

**Comparaisons détectées :**
```asm
  401013:       48 83 f8 00             cmp    $0x0,%rax
  401034:       48 83 f8 00             cmp    $0x0,%rax
  401040:       80 bb 28 20 40 00 0a    cmpb   $0xa,0x402028(%rbx)
  40104c:       48 83 f8 10             cmp    $0x10,%rax
  401055:       48 83 f9 10             cmp    $0x10,%rcx      # ← 16 caractères
  401063:       3a 81 18 20 40 00       cmp    0x402018(%rcx),%al  # ← Comparaison avec secret
```

---

## Compréhension de l'algorithme

### Points clés identifiés

D'après l'analyse des instructions :

1. **Clé XOR** : `0x42` (66 en décimal, caractère 'B')
   ```asm
   xor $0x42,%al
   ```

2. **Longueur du mot de passe** : 16 caractères (`0x10`)
   ```asm
   cmp $0x10,%rcx
   ```

3. **Secret de référence** : stocké à l'adresse `0x402018`
   ```asm
   cmp 0x402018(%rcx),%al
   ```

4. **Buffer d'input** : situé autour de `0x402028`
   ```asm
   cmpb $0xa,0x402028(%rbx)    # Vérification du newline
   ```

### Algorithme en pseudo-code

```python
for i in range(16):
    byte = user_input[i]
    byte = byte XOR 0x42
    if byte != secret[i]:
        print("Bad Password!")
        exit(1)
        
print("Good Job!")
```

---

## Extraction des données

### Méthode avec Ghidra

1. **Lancer Ghidra**
   ```bash
   ghidra
   ```

2. **Importer le binaire**
   - File → Import File
   - Sélectionner `Birth of the URSSAF`
   - Analyser avec les options par défaut

3. **Naviguer vers le secret**
   - Appuyer sur `G` (Go To)
   - Taper `0x402018`
   - Extraire les 16 bytes

### Données extraites

**Adresse `0x402018` - Secret chiffré (16 bytes) :**
```
12 2c 0b 2b 1a 36 07 06 15 36 04 01 0a 35 2a 25
```

---

## Résolution mathématique

### Propriété du XOR

```
A ⊕ B = C  ⟹  C ⊕ B = A
```

### Application au crackme

Le programme vérifie :
```
user_input[i] ⊕ 0x42 = secret[i]
```

Pour trouver `user_input[i]`, on applique l'opération inverse :
```
user_input[i] = secret[i] ⊕ 0x42
```

### Script Python de résolution

```python
#!/usr/bin/env python3

# Clé XOR hardcodée dans le code
xor_key = 0x42

# Secret chiffré extrait de l'adresse 0x402018 (16 bytes)
secret = [0x12, 0x2c, 0x0b, 0x2b, 0x1a, 0x36, 0x07, 0x06, 
          0x15, 0x36, 0x04, 0x01, 0x0a, 0x35, 0x2a, 0x25]

# Déchiffrement : secret XOR key = password
password = ''.join(chr(byte ^ xor_key) for byte in secret)

print(password)
```

---

## Résultat

Exécution du script Python :

```bash
python3 decodeXOR.py
```

**Output:**
```
PnIiXtEDWtFCHwhg
```

---

## Vérification

Test du mot de passe trouvé :

```bash
./Birth\ of\ the\ URSSAF
PnIiXtEDWtFCHwhg
Good Job!
```