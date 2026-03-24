# Writeup - Birth of the URSSAF Crackme

## Analyse initiale

Le binaire est non-stripped, ce qui nous permet de voir les noms des fonctions et des variables directement.

### 1. Reconnaissance du binaire

```bash
nm FIRSTCRACKME | grep -E "encoded_flag|xor_key|flag_len"
```
Resultat :
```bash
0000000000402018 d encoded_flag
0000000000000010 a flag_len
0000000000402028 d xor_key
```

### 2. Analyse avec gdb
```bash
gdb ./FIRSTCRACKME
break _start
run
```

Examiner la clé (pour voir la valeur en hexa)
```bash
(gdb) x/xb &xor_key
0x402028:       0x42
```

Examine le flag encodé (pour voir les 16 premiers octets)
```bash
(gdb) x/16xb &encoded_flag
0x402018:       0x76    0x11    0x0b    0x77    0x1d    0x01    0x30    0x76
0x402020:       0x21    0x29    0x0f    0x71    0x1d    0x12    0x76    0x11
```

## Le décodage final
```bash
python3 -c "encoded = [0x76, 0x11, 0x0b, 0x77, 0x1d, 0x01, 0x30, 0x76, 0x21, 0x29, 0x0f, 0x71, 0x1d, 0x12, 0x76, 0x11]; key = 0x42; print(''.join([chr(b ^ key) for b in encoded]))"

4SI5_Cr4ckM3_P4S
```

