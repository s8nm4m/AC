.equ MAX_PHRASE_SIZE, 100
.equ STACK_SIZE, 64

.section .startup
b _start
b .

_start:
    ldr sp, tos_addr
    mov r0, pc
    add lr, r0, #4
    ldr pc, main_addr
    b .

tos_addr:
    .word tos

main_addr:
    .word main
.text

main:
    push lr
    ldr r0, phrase_copy_addr
    ldr r1, phrase_orig_addr
    bl str_copy
    pop pc

phrase_orig_addr: 
    .word phrase_orig

phrase_copy_addr:
    .word phrase_copy

; r0 = &dst[0], r1 = &src[0]
; r2 = i, r3 = aux char, r4 = 
temp
str_copy:
    push r4 ; save
    mov r2, #0
    mov r4, #0 ; same as ’\0’
str_copy_loop:
    ldrb r3, [r1, r2]
    cmp r3, r4
    beq str_copy_ret
    strb r3, [r0, r2]
    add r2, r2, #1
    b str_copy_loop
str_copy_ret:
    strb r4, [r0, r2]
    pop r4 ; restore
    mov pc, lr

.data
phrase_orig:
    .asciz "the quick brown fox jumps 
    over the lazy dog"

.section .bss

phrase_copy:
    .space MAX_PHRASE_SIZE

.section .stack
.space STACK_SIZE
tos:

