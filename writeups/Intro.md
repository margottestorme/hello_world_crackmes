# Writeup - Intro Crackme

## Analyse initiale

### 1. Reconnaissance du binaire

```bash
file Intro
strings Intro
objdump -d Intro | grep -i "xor"
objdump -d Intro | grep -i "cmp"
```

### 2. Observations préliminaires

Les résultats montrent :
- Présence d'instructions XOR
- Comparaisons avec `0x10` (16 en décimal)
- Comparaison avec des données en mémoire à `0x402019`
- Structure de boucle évidente

---

## Désassemblage complet

```bash
objdump -d Intro
```

### Code assembleur annoté

```asm
0000000000401000 <_start>:
  401000:       31 c0                   xor    %eax,%eax
  401002:       31 ff                   xor    %edi,%edi
  401004:       48 8d 35 21 10 00 00    lea    0x1021(%rip),%rsi    # Buffer d'input
  40100b:       ba 40 00 00 00          mov    $0x40,%edx           # Taille max: 64 bytes
  401010:       0f 05                   syscall                     # read(stdin)
  401012:       48 85 c0                test   %rax,%rax
  401015:       7e 60                   jle    401077 <fail>        # Si erreur lecture → fail
  401017:       48 89 c1                mov    %rax,%rcx            # rcx = nombre de bytes lus
  40101a:       48 8d 1d 0b 10 00 00    lea    0x100b(%rip),%rbx    # rbx = adresse buffer

  # Vérification et suppression du newline
  401021:       48 ff c9                dec    %rcx
  401024:       80 3c 0b 0a             cmpb   $0xa,(%rbx,%rcx,1)   # Dernier char = '\n' ?
  401028:       75 02                   jne    40102c
  40102a:       eb 03                   jmp    40102f

000000000040102c <_start.no_newline>:
  40102c:       48 ff c1                inc    %rcx

000000000040102f <_start.len_done>:
  40102f:       48 83 f9 10             cmp    $0x10,%rcx           # Longueur = 16 ?
  401033:       75 42                   jne    401077 <fail>        # Si != 16 → fail
  401035:       45 31 c0                xor    %r8d,%r8d            # r8 = 0 (compteur)
  401038:       8a 15 da 0f 00 00       mov    0xfda(%rip),%dl      # Charge CLÉ XOR (0x402018)

000000000040103e <_start.compare_loop>:
  40103e:       42 8a 04 03             mov    (%rbx,%r8,1),%al     # al = user_input[r8]
  401042:       30 d0                   xor    %dl,%al              # al = al XOR clé
  401044:       41 3a 80 19 20 40 00    cmp    0x402019(%r8),%al    # Compare avec secret[r8]
  40104b:       75 2a                   jne    401077 <fail>        # Si différent → fail
  40104d:       49 ff c0                inc    %r8                  # r8++
  401050:       49 83 f8 10             cmp    $0x10,%r8            # r8 == 16 ?
  401054:       75 e8                   jne    40103e               # Si non, continuer boucle

0000000000401056 <success>:
  401056:       b8 01 00 00 00          mov    $0x1,%eax
  40105b:       bf 01 00 00 00          mov    $0x1,%edi
  401060:       48 8d 35 99 0f 00 00    lea    0xf99(%rip),%rsi     # Message success
  401067:       ba 0a 00 00 00          mov    $0xa,%edx
  40106c:       0f 05                   syscall                     # write(stdout)
  40106e:       b8 3c 00 00 00          mov    $0x3c,%eax
  401073:       31 ff                   xor    %edi,%edi
  401075:       0f 05                   syscall                     # exit(0)

0000000000401077 <fail>:
  401077:       b8 01 00 00 00          mov    $0x1,%eax
  40107c:       bf 01 00 00 00          mov    $0x1,%edi
  401081:       48 8d 35 82 0f 00 00    lea    0xf82(%rip),%rsi     # Message fail
  401088:       ba 0e 00 00 00          mov    $0xe,%edx
  40108d:       0f 05                   syscall                     # write(stdout)
  40108f:       b8 3c 00 00 00          mov    $0x3c,%eax
  401094:       bf 01 00 00 00          mov    $0x1,%edi
  401099:       0f 05                   syscall                     # exit(1)
```

---

## Compréhension de l'algorithme

### Logique de vérification

```python
# Pseudo-code
key = memory[0x402018]          # Clé XOR unique
secret = memory[0x402019:16]    # 16 bytes de référence

for i in range(16):
    if (user_input[i] XOR key) != secret[i]:
        goto FAIL
        
goto SUCCESS
```

### Points clés identifiés

- **Clé XOR** : stockée à l'adresse `0x402018` (1 byte)
- **Secret chiffré** : stocké à l'adresse `0x402019` (16 bytes)
- **Algorithme** : XOR symétrique avec clé fixe

---

## Extraction des données

### Avec Ghidra

1. Lancer Ghidra et importer `Intro`
2. Analyser le binaire
3. Appuyer sur `G` et naviguer vers `0x402018`
4. Lire la clé XOR (1 byte)
5. Naviguer vers `0x402019`
6. Extraire les 16 bytes du secret

### Données extraites

**Adresse `0x402018` - Clé XOR :**
```
0x5a
```

**Adresse `0x402019` - Secret chiffré (16 bytes) :**
```
6b 68 69 6e 6f 6c 6d 62 63 12 1b 19 11 12 1b 19
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
user_input[i] ⊕ key = secret[i]
```

Pour trouver `user_input[i]`, on applique l'opération inverse :
```
user_input[i] = secret[i] ⊕ key
```

### Script Python de résolution

```python
# Clé XOR extraite de 0x402018
key = 0x5a

# Secret chiffré extrait de 0x402019 (16 bytes)
secret = [0x6b, 0x68, 0x69, 0x6e, 0x6f, 0x6c, 0x6d, 0x62, 
          0x63, 0x12, 0x1b, 0x19, 0x11, 0x12, 0x1b, 0x19]

# Déchiffrement : secret XOR key = password
password = ''.join(chr(byte ^ key) for byte in secret)

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
123456789HACKHAC
```
---

## Vérification

Test du mot de passe trouvé :

```bash
./Intro
123456789HACKHAC
Good Job!
```

---

## Outils utilisés

- **objdump** : désassemblage initial et extraction de données
- **Ghidra** : analyse statique et visualisation des données en mémoire
- **Python** : calcul du XOR inverse
