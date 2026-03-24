section .data
    good_msg db "Good Job!", 10, 0
    good_len equ $ - good_msg
    
    bad_msg db "Bad Password!", 10, 0
    bad_len equ $ - bad_msg
    
    expected db 0x80, 0xc1, 0xb8, 0x98, 0xcc, 0x3c, 0xec, 0xf1
    expected2 db 0xe4, 0xf8, 0xfc, 0x28, 0xb4, 0xb0, 0x64, 0x88

section .bss
    input resb 32

section .text
    global _start

_start:
    ; Lire l'entrée
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 32
    syscall
    
    ; Vérifier la longueur
    cmp rax, 17
    jne wrong_password
    
    dec rax
    mov byte [input + rax], 0
    
    ; Initialiser le compteur
    xor rcx, rcx            ; i = 0
    
check_loop:
    cmp rcx, 16
    jge correct_password
    
    ; Charger le caractère
    movzx rax, byte [input + rcx]
    
    mov rbx, 0x42
    add rbx, rcx
    and rbx, 0xFF
    
    xor rax, rbx
    
    rol al, 2
    
    cmp rcx, 8
    jl check_first_half
    
check_second_half:
    mov rbx, rcx
    sub rbx, 8
    movzx rdx, byte [expected2 + rbx]
    jmp compare_value
    
check_first_half:
    movzx rdx, byte [expected + rcx]
    
compare_value:
    ; Comparer
    cmp al, dl
    jne wrong_password
    
    ; Caractère suivant
    inc rcx
    jmp check_loop

correct_password:
    ; Afficher "Good Job!"
    mov rax, 1
    mov rdi, 1
    mov rsi, good_msg
    mov rdx, good_len
    syscall
    
    ; Exit avec code 0
    mov rax, 60
    xor rdi, rdi
    syscall

wrong_password:
    ; Afficher "Bad Password!"
    mov rax, 1
    mov rdi, 1
    mov rsi, bad_msg
    mov rdx, bad_len
    syscall
    
    ; Exit avec code 1
    mov rax, 60
    mov rdi, 1
    syscall