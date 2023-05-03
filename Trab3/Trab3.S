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

main:
    push lr
    mov r0, in_port
    ldrb r1, [r0, #0]
    mov r2, #1
    and r2, r1, r2
    beq change_output_port
    b main
    pop pc

change_output_port:
    
.data

in_port:
    .word 0xF000

out_port:
    .word 0xE000

.section .bss
    
.section .stack
.space STACK_SIZE
tos:
    .word 0x8000 ; o stack começa no fim da RAM

