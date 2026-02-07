section .data
    ; Données initialisées
    mdp db "Zy9Px5Vn2Lk8Qt4", 10, 0
    good_msg db "Good Job !", 10, "0", 10, 0
    good_len equ $ - good_msg
    bad_msg db "Bad Password !", 10, "1", 10, 0
    bad_len equ $ - bad_msg

section .bss
    ; Données non initialisées
    input resb 64

section .text
    global _start

_start:
    mov rax, 0          ; syscall read
    mov rdi, 0          ; stdin
    mov rsi, input      ; stocker dans input
    mov rdx, 64         ; max 64 octets
    syscall

    ; Comparer input avec mdp
    mov rsi, input
    mov rdi, mdp
    mov rcx, 16
    repe cmpsb
    jne wrong
    
success:
    mov rax, 1
    mov rdi, 1
    mov rsi, good_msg
    mov rdx, good_len
    syscall
    
    ; Exit avec code 0
    mov rax, 60
    mov rdi, 0
    syscall

wrong:
    ; Afficher "Bad Password !\n1\n"
    mov rax, 1
    mov rdi, 1
    mov rsi, bad_msg
    mov rdx, bad_len
    syscall
    
    ; Exit avec code 1
    mov rax, 60
    mov rdi, 1
    syscall