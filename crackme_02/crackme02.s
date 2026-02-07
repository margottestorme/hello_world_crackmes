BITS 64
default rel

section .data
good_msg: db "Good Job!", 10
good_len: equ $ - good_msg

bad_msg:  db "Bad Password!", 10
bad_len:  equ $ - bad_msg

flag: db "TEAMHELLOWORLD01"   ; 16 bytes pile

section .bss
buf: resb 64

section .text
global _start

_start:
    xor eax, eax          ; sys_read = 0
    xor edi, edi          ; fd = 0 (stdin)
    lea rsi, [buf]
    mov edx, 64
    syscall
    ; rax = number of bytes read
    cmp rax, 0
    jle bad

    lea rbx, [buf]
    mov rcx, rax          ; rcx = len
    dec rcx               ; last index = len-1
    js bad
    mov al, [rbx + rcx]
    cmp al, 10            ; '\n'
    jne .no_newline
    ; remove newline
    mov byte [rbx + rcx], 0
    mov rax, rcx          ; new len = len-1
.no_newline:

    cmp rax, 16
    jne bad

    lea rsi, [buf]
    lea rdi, [flag]
    mov ecx, 16
.compare_loop:
    mov al, [rsi]
    mov dl, [rdi]
    cmp al, dl
    jne bad
    inc rsi
    inc rdi
    loop .compare_loop

good:
    mov eax, 1            ; sys_write
    mov edi, 1            ; stdout
    lea rsi, [good_msg]
    mov edx, good_len
    syscall

    ; exit(0)
    mov eax, 60           ; sys_exit
    xor edi, edi
    syscall

bad:
    mov eax, 1
    mov edi, 1
    lea rsi, [bad_msg]
    mov edx, bad_len
    syscall

    ; exit(1)
    mov eax, 60
    mov edi, 1
    syscall
