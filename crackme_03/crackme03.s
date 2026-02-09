BITS 64
default rel

section .data
good_msg: db "Good Job!", 10
good_len: equ $ - good_msg

bad_msg:  db "Bad Password!", 10
bad_len:  equ $ - bad_msg

; target caché = partA XOR partB
partA: dq 0xA5A5A5A5A5A5A5A5
partB: dq 0x091FE58C604B3675

section .bss
buf: resb 64

section .text
global _start

_start:
    ; read(0, buf, 64)
    xor eax, eax              ; sys_read = 0
    xor edi, edi              ; fd = 0
    lea rsi, [buf]
    mov edx, 64
    syscall                   ; rax = nb octets lus
    cmp rax, 0
    jle bad

    ; retirer '\n' final si présent
    lea rbx, [buf]
    mov rcx, rax
    dec rcx
    js bad
    mov al, [rbx + rcx]
    cmp al, 10                ; '\n'
    jne .no_newline
    mov byte [rbx + rcx], 0
    mov rax, rcx              ; nouvelle longueur
.no_newline:

    ; longueur exacte = 16
    cmp rax, 16
    jne bad

    ; target = partA XOR partB
    mov r8, [rel partA]
    xor r8, [rel partB]

    ; acc = 0
    xor r9, r9
    lea rsi, [buf]
    xor rcx, rcx              ; i = 0

.loop:
    mov al, [rsi]             ; lire caractère
    cmp al, '0'
    jb bad
    cmp al, '9'
    ja bad
    sub al, '0'               ; convertir en chiffre

    ; tmp = d*7 + i*3
    movzx r10, al             ; r10 = d
    imul r10, 7               ; r10 = d*7

    mov r11, rcx
    imul r11, 3               ; r11 = i*3
    add r10, r11              ; tmp = d*7 + i*3

    ; acc = acc*131 + tmp
    mov rax, r9
    imul rax, 131
    add rax, r10
    mov r9, rax

    ; acc ^= (acc >> 13)
    mov rax, r9
    shr rax, 13
    xor r9, rax

    inc rsi
    inc rcx
    cmp rcx, 16
    jne .loop

    ; comparer acc et target
    cmp r9, r8
    jne bad

good:
    ; write(1, good_msg, good_len)
    mov eax, 1
    mov edi, 1
    lea rsi, [good_msg]
    mov edx, good_len
    syscall

    ; exit(0)
    mov eax, 60
    xor edi, edi
    syscall

bad:
    ; write(1, bad_msg, bad_len)
    mov eax, 1
    mov edi, 1
    lea rsi, [bad_msg]
    mov edx, bad_len
    syscall

    ; exit(1)
    mov eax, 60
    mov edi, 1
    syscall
