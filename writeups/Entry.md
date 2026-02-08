# Writeup - Entry Crackme

## Analyse initiale

### 1. Désassemblage complet

```bash
objdump -d Entry
```

### Code assembleur complet

```asm
Entry:     file format elf64-x86-64
Disassembly of section .text:

0000000000401000 <.text>:
  401000:       eb 02                   jmp    0x401004
  401002:       31 c0                   xor    %eax,%eax
  401004:       b8 01 00 00 00          mov    $0x1,%eax
  401009:       bf 01 00 00 00          mov    $0x1,%edi
  40100e:       48 be 00 20 40 00 00    movabs $0x402000,%rsi
  401015:       00 00 00
  401018:       ba 0b 00 00 00          mov    $0xb,%edx
  40101d:       0f 05                   syscall
  40101f:       b8 00 00 00 00          mov    $0x0,%eax
  401024:       bf 00 00 00 00          mov    $0x0,%edi
  401029:       48 be 3c 20 40 00 00    movabs $0x40203c,%rsi
  401030:       00 00 00
  401033:       ba 40 00 00 00          mov    $0x40,%edx
  401038:       0f 05                   syscall
  40103a:       48 83 f8 11             cmp    $0x11,%rax
  40103e:       75 51                   jne    0x401091
  401040:       48 31 c9                xor    %rcx,%rcx
  401043:       8a 81 3c 20 40 00       mov    0x40203c(%rcx),%al
  401049:       34 2a                   xor    $0x2a,%al
  40104b:       00 c8                   add    %cl,%al
  40104d:       04 05                   add    $0x5,%al
  40104f:       3a 81 2c 20 40 00       cmp    0x40202c(%rcx),%al
  401055:       75 3a                   jne    0x401091
  401057:       48 ff c1                inc    %rcx
  40105a:       48 83 f9 10             cmp    $0x10,%rcx
  40105e:       75 e3                   jne    0x401043
  401060:       48 bb 6c 10 40 00 00    movabs $0x40106c,%rbx
  401067:       00 00 00 00
  40106a:       ff e3                   jmp    *%rbx
  40106c:       b8 01 00 00 00          mov    $0x1,%eax
  401071:       bf 01 00 00 00          mov    $0x1,%edi
  401076:       48 be 0b 20 40 00 00    movabs $0x40200b,%rsi
  40107d:       00 00 00
  401080:       ba 11 00 00 00          mov    $0x11,%edx
  401085:       0f 05                   syscall
  401087:       b8 3c 00 00 00          mov    $0x3c,%eax
  40108c:       48 31 ff                xor    %rdi,%rdi
  40108f:       0f 05                   syscall
  401091:       48 31 c0                xor    %rax,%rax
  401094:       48 31 db                xor    %rbx,%rbx
  401097:       b8 01 00 00 00          mov    $0x1,%eax
  40109c:       bf 01 00 00 00          mov    $0x1,%edi
  4010a1:       48 be 1c 20 40 00 00    movabs $0x40201c,%rsi
  4010a8:       00 00 00
  4010ab:       ba 10 00 00 00          mov    $0x10,%edx
  4010b0:       0f 05                   syscall
  4010b2:       b8 3c 00 00 00          mov    $0x3c,%eax
  4010b7:       bf 01 00 00 00          mov    $0x1,%edi
  4010bc:       0f 05                   syscall
```

---

## Compréhension de l'algorithme

### Analyse du code de vérification

#### Étape 1 : Lecture de l'input

```asm
mov    $0x0,%eax              # syscall read
mov    $0x0,%edi              # stdin
movabs $0x40203c,%rsi         # buffer à 0x40203c
mov    $0x40,%edx             # taille max: 64 bytes
syscall
cmp    $0x11,%rax             # Vérifie que 17 bytes (0x11) ont été lus
jne    0x401091               # Si différent → FAIL
```

**Point clé :** Le programme attend **17 bytes** (16 caractères + newline `\n`)

#### Étape 2 : Boucle de vérification

```asm
xor    %rcx,%rcx              # rcx = 0 (compteur)

<loop>:
mov    0x40203c(%rcx),%al     # al = input[rcx]
xor    $0x2a,%al              # al = al XOR 0x2a
add    %cl,%al                # al = al + rcx (compteur !)
add    $0x5,%al               # al = al + 5
cmp    0x40202c(%rcx),%al     # Compare avec secret[rcx]
jne    0x401091               # Si différent → FAIL
inc    %rcx                   # rcx++
cmp    $0x10,%rcx             # rcx == 16 ?
jne    <loop>                 # Si non, continuer
```

### Algorithme décodé

```python
for i in range(16):  # Boucle de 0 à 15
    byte = input[i]
    byte = byte XOR 0x2a      # XOR avec 42 ('*')
    byte = byte + i           # Ajoute l'index de boucle !
    byte = byte + 5           # Ajoute 5
    if byte != secret[i]:
        goto FAIL
        
goto SUCCESS
```

### Points clés identifiés

- **Input utilisateur** : stocké à `0x40203c` (16 bytes + newline)
- **Secret de référence** : stocké à `0x40202c` (16 bytes)
- **Clé XOR** : `0x2a` (42 en décimal, caractère '*')
- **Addition variable** : le compteur `i` est ajouté (0, 1, 2, ..., 15)
- **Addition constante** : `+ 5` à chaque itération
- **Longueur stricte** : exactement 17 bytes avec le newline

---

## Extraction des données

### Avec Ghidra

1. Lancer Ghidra et analyser le binaire `Entry`
2. Appuyer sur `G` et naviguer vers `0x40202c`
3. Extraire les 16 bytes du secret


### Données extraites

**Adresse `0x40202c` - Secret chiffré (16 bytes) :**

```
74 7f 74 6b 27 83 6e 27 71 59 6d 53 56 56 6d 5f
```

En format Python :
```python
secret = [0x74, 0x7f, 0x74, 0x6b, 0x27, 0x83, 0x6e, 0x27, 
          0x71, 0x59, 0x6d, 0x53, 0x56, 0x56, 0x6d, 0x5f]
```

---

## Résolution mathématique

### Équation du programme

Le programme calcule :
```
secret[i] = ((input[i] XOR 0x2a) + i + 5) mod 256
```

### Inversion de l'algorithme

Pour trouver `input[i]` à partir de `secret[i]`, on inverse les opérations **dans l'ordre inverse** :

#### Étape 1 : Annuler les additions

```
(input[i] XOR 0x2a) + i + 5 = secret[i]
(input[i] XOR 0x2a) = secret[i] - i - 5
```

#### Étape 2 : Annuler le XOR

Rappel de la propriété du XOR :
```
A ⊕ B = C  ⟹  C ⊕ B = A
```

Donc :
```
input[i] XOR 0x2a = secret[i] - i - 5
input[i] = (secret[i] - i - 5) XOR 0x2a
```

### Formule finale

```python
input[i] = (secret[i] - 5 - i) XOR 0x2a
```

**Important :** Toutes les opérations sont modulo 256 (arithmétique sur 8 bits).

---

## Script Python de résolution

```python
#!/usr/bin/env python3

# Secret extrait de l'adresse 0x40202c (16 bytes)
secret = [0x74, 0x7f, 0x74, 0x6b, 0x27, 0x83, 0x6e, 0x27, 
          0x71, 0x59, 0x6d, 0x53, 0x56, 0x56, 0x6d, 0x5f]

# Clé XOR utilisée
xor_key = 0x2a

# Déchiffrement
password = ''
for i in range(16):
    # Formule inverse : (secret[i] - 5 - i) XOR 0x2a
    byte = (secret[i] - 5 - i) ^ xor_key
    password += chr(byte)
    
print(f"Password: {password}")
```

**Fichier : `decodeXOR.py`**

---

## Décodage étape par étape

Exemple pour les premiers bytes :

| i | secret[i] | -5 | -i | Résultat | XOR 0x2a | char |
|---|-----------|----|----|----------|----------|------|
| 0 | 0x74 (116) | -5 | -0 | 111 | 111 ^ 42 = 69 | 'E' |
| 1 | 0x7f (127) | -5 | -1 | 121 | 121 ^ 42 = 79 | 'O' |
| 2 | 0x74 (116) | -5 | -2 | 109 | 109 ^ 42 = 67 | 'C' |
| 3 | 0x6b (107) | -5 | -3 | 99  | 99 ^ 42 = 121 | 'y' |
| ... | ... | ... | ... | ... | ... | ... |

---

## Résultat

Exécution du script Python :

```bash
python3 decodeXOR.py
```

**Output:**
```
Password: ESGI4SI1Nationpa
```

---

## Vérification

Test du mot de passe trouvé :

```bash
./Entry
Password: ESGI4SI1Nationpa
Access Granted!
```

---


## Outils utilisés

- **objdump** : désassemblage et identification de l'algorithme
- **Ghidra** : analyse statique et extraction de données
- **Python** : calcul de l'opération inverse

---