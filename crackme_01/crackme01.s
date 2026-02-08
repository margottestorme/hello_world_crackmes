section .data
    msg_success: db "Good Job !", 0x0a
    success_len: equ $ - msg_success
    
    msg_fail:    db "Bad Password !", 0x0a
    fail_len:    equ $ - msg_fail
    
    secret:     db 0x4b, 0x34, 0x09, 0x11, 0xfa, 0xfd, 0xf5, 0x32
                db 0x3e, 0xfa, 0xef, 0x1c, 0xfe, 0xf2, 0x1a, 0x09

section .bss
    buffer:     resb 64

section .text
    global _start

_start:
    mov rax, 0              ; syscall: read
    mov rdi, 0              ; stdin
    mov rsi, buffer
    mov rdx, 64             ; taille max
    syscall
    
    cmp rax, 17
    jne fail
    
    xor rcx, rcx            ; rcx = 0 (compteur de boucle)

check_loop:
    mov al, byte [buffer + rcx]
        
    mov bl, cl              ; bl = i
    shl bl, 1               ; bl = i * 2
    add al, bl              ; al = input[i] + (i * 2)
    
    xor al, 0x7E
    
    mov bl, 16              ; bl = 16
    sub bl, cl              ; bl = 16 - i
    sub al, bl              ; al = al - (16 - i)
    
    cmp al, byte [secret + rcx]
    jne fail                ; Si différent -> échec
    
    ; Incrémenter le compteur
    inc rcx
    
    cmp rcx, 16
    jne check_loop          ; Si non, continuer
    
    jmp success

success:
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; stdout
    mov rsi, msg_success
    mov rdx, success_len
    syscall
    
    ; Exit avec code 0
    mov rax, 60             ; syscall: exit
    xor rdi, rdi            ; code 0
    syscall

fail:
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; stdout
    mov rsi, msg_fail
    mov rdx, fail_len
    syscall
    
    ; Exit avec code 1
    mov rax, 60             ; syscall: exit
    mov rdi, 1              ; code 1
    syscall