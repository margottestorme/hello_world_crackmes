# Writeup - MonkeydXOR Crackme

## Analyse initiale

### 1. Reconnaissance du binaire

Première étape : identifier le type de fichier et obtenir des informations de base.

```bash
file MonkeydXOR
strings MonkeydXOR
```

### 2. Désassemblage avec objdump

On commence par désassembler le binaire pour comprendre sa logique :

```bash
objdump -d MonkeydXOR | grep -A 20 "xor"
```

Résultat obtenu :
```asm
  40102f:       48 31 c9                xor    %rcx,%rcx
0000000000401032 <_loop>:
  401032:       8a 81 28 20 40 00       mov    0x402028(%rcx),%al
  401038:       34 23                   xor    $0x23,%al
  40103a:       3a 81 18 20 40 00       cmp    0x402018(%rcx),%al
  401040:       75 30                   jne    401072 <_fail>
  401042:       48 ff c1                inc    %rcx
  401045:       48 83 f9 10             cmp    $0x10,%rcx
  401049:       75 e7                   jne    401032 <_loop>
```

---

## Compréhension de l'algorithme

### Analyse ligne par ligne

1. **Initialisation**
   ```asm
   xor %rcx,%rcx    # rcx = 0 (compteur de boucle)
   ```

2. **Boucle principale** (`_loop`)
   ```asm
   mov 0x402028(%rcx),%al     # Charge user_input[rcx] dans AL
   xor $0x23,%al               # XOR AL avec 0x23 (35 en décimal)
   cmp 0x402018(%rcx),%al     # Compare avec secret[rcx]
   jne 401072 <_fail>          # Si différent → FAIL
   inc %rcx                    # rcx++
   cmp $0x10,%rcx              # Compare rcx avec 16 (0x10)
   jne 401032 <_loop>          # Si rcx != 16, continuer la boucle
   ```

### Algorithme en pseudo-code

```python
for i in range(16):  # 0x10 = 16 itérations
    byte = user_input[i]
    byte = byte XOR 0x23
    if byte != secret[i]:
        goto FAIL
    
goto SUCCESS
```

### Points clés identifiés

- Chaque caractère est XOR avec **0x23** (35 en décimal)
- Le résultat est comparé avec des données stockées en mémoire
- Deux adresses importantes :
  - `0x402028` : input utilisateur
  - `0x402018` : secret de référence

---

## Extraction des données avec Ghidra

### 1. Lancement de Ghidra

```bash
ghidra
```

### 2. Import et analyse
- File → New Project → Non-Shared Project
- File → Import File → Sélectionner `MonkeydXOR`
- Double-clic sur le fichier → Analyze (accepter les options par défaut)

### 3. Navigation vers les données

**Navigation directe**
- Appuyer sur `G` (Go To)
- Taper `0x402018`
- Enter

### 4. Extraction des bytes à 0x402018

```
Adresse   | Bytes en hexadécimal
----------|---------------------
00402018  | 6e 13 77 7c 11 7c 73 17
00402020  | 50 50 10 40 51 17 40 48
```

Les 16 bytes du secret :
```
6e 13 77 7c 11 7c 73 17 50 50 10 40 51 17 40 48
```

---

## Résolution mathématique

### Propriété du XOR

Le XOR a une propriété importante :
```
A ⊕ B = C  ⟹  C ⊕ B = A
```

### Application au crackme

Le programme fait :
```
user_input[i] ⊕ 0x23 = secret[i]
```

Pour trouver `user_input[i]`, on applique l'opération inverse :
```
user_input[i] = secret[i] ⊕ 0x23
```

### Script Python de résolution

```python
# Bytes extraits de l'adresse 0x402018
secret = [0x6e, 0x13, 0x77, 0x7c, 0x11, 0x7c, 0x73, 0x17, 
          0x50, 0x50, 0x10, 0x40, 0x51, 0x17, 0x40, 0x48]

# Clé XOR utilisée par le programme
xor_key = 0x23

# Déchiffrement : secret XOR clé = password
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
M0T_2_P4ss3cr4ck
```

---

## Vérification

Test du mot de passe trouvé :

```bash
rakulan@labesgi:~$ ./MonkeydXOR
M0T_2_P4ss3cr4ck
Good Job!
```

---

## Outils utilisés

- **objdump** : désassemblage initial
- **Ghidra** : analyse statique et extraction de données
- **Python** : calcul du XOR inverse

---