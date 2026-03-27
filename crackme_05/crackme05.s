section .data
    msg_success: db "Good Job !", 0x0a
    success_len: equ $ - msg_success
    msg_fail:    db "Bad Password !", 0x0a
    fail_len:    equ $ - msg_fail

    sbox: db 0x63, 0xAA, 0xFB, 0x17, 0x44, 0x9E, 0x2C, 0x58
          db 0xD3, 0x0F, 0x76, 0xE1, 0x39, 0xB5, 0x82, 0xCC
          db 0x11, 0xA7, 0x5D, 0x3A, 0xF0, 0x6B, 0xC9, 0x84
          db 0x2E, 0x70, 0x1D, 0x98, 0x4F, 0xB3, 0xE6, 0x05

    secret: db 0xf0, 0x2e, 0x6b, 0xb3, 0x11, 0xd3, 0x5d, 0x0f
            db 0x17, 0x44, 0xfb, 0x70, 0xb3, 0xb5, 0x1d, 0x39

    expected_checksum: db 0x10

section .bss
    buffer:      resb 64
    transformed: resb 16

section .text
    global _start

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 64
    syscall

    cmp rax, 16
    jl fail
    cmp rax, 18
    jg fail

    xor rcx, rcx

transform_loop:
    movzx eax, byte [buffer + rcx]

    movzx edx, cl
    imul edx, edx, 3
    add al, dl

    test cl, 1
    jnz rotate_odd
rotate_even:
    ror al, 3
    jmp pass3
rotate_odd:
    rol al, 4

pass3:
    mov dl, cl
    xor dl, 0x5A
    xor al, dl

    and al, 0x1F
    movzx eax, al
    movzx eax, byte [sbox + rax]

    mov byte [transformed + rcx], al

    inc rcx
    cmp rcx, 16
    jne transform_loop

    xor rcx, rcx
    xor r8d, r8d

compare_loop:
    movzx eax, byte [transformed + rcx]
    add r8b, al
    cmp al, byte [secret + rcx]
    jne fail
    inc rcx
    cmp rcx, 16
    jne compare_loop

    movzx eax, byte [expected_checksum]
    cmp r8b, al
    jne fail

success:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_success
    mov rdx, success_len
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall

fail:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_fail
    mov rdx, fail_len
    syscall
    mov rax, 60
    mov rdi, 1
    syscall