## Principe du crackme

Le mot de passe correct n’est pas stocké en clair dans le binaire.

À la place :
- Le programme lit les 16 caractères.
- Chaque chiffre est transformé par une suite d’opérations :
        - multiplications
        - additions
        - décalage de bits
        - XOR
- Ces transformations produisent une valeur finale appelée accumulateur (acc).
- Cette valeur est comparée à une constante cible (target).

Si les deux correspondent, le mot de passe est correct.

## Obfuscation de la constante cible

La valeur cible n’apparaît pas directement dans le code.

Elle est reconstruite à l’exécution :
```bash
target = partA XOR partB
```
Cela évite d’avoir une constante reconnaissable directement dans le binaire.

## Fonctionnement détaillé du programme

### Lecture de l'entrée
Le programme utilise le syscall read :
```bash
read(0, buf, 64)
```
- Lit jusqu’à 64 octets depuis l’entrée standard.
- Le nombre d’octets lus est stocké dans rax.

### Suppression du retour à la ligne
Si l’entrée se termine par \n (cas d’un echo), il est retiré pour obtenir la vraie longueur.

### Vérification de la longueur
```bash
cmp rax, 16 
jne bad
```
Le programme refuse toute entrée qui n’a pas exactement 16 caractères.

### Construction de la constante cible
```bash
target = partA XOR partB
```
Cette valeur sera comparée au résultat du calcul sur le mot de passe.

### Boucle de transformation
Une boucle traite les 16 chiffres un par un.

Pour chaque chiffre d à la position i :
```bash
tmp = d*7 + i*3
acc = acc*131 + tmp
acc = acc XOR (acc >> 13)
```
Cela mélange progressivement les chiffres dans une valeur unique.

### Comparaison finale
Après les 16 itérations :
```bash
if acc == target:
    success
else:
    fail
```

### Affichage du résultat
Le programme utilise uniquement des syscalls :
- write pour afficher le message
- exit pour quitter avec le code approprié

## Compilation
Dans le dossier du crackme :
```bash
nasm -f elf64 crackme.s -o crackme.o
ld crackme.o -o crackme
```

## Exemple d’exécution
Mot de passe correct :
```bash
echo "1234567890111213" | ./crackme ; echo $?
```
Résultat :
```bash
Good Job!
0
```
Mot de passe incorrect :
```bash
echo "1111111111111111" | ./crackme ; echo $?
```
Résultat :
```bash
Bad Password!
1
```

