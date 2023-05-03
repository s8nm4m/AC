.equ STACK_SIZE, 64
.equ INPORT_ADDRESS,  0xF000
.equ OUTPORT_ADDRESS, 0xE000

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
    ldr r0, in_port_addr
    ldrb r1, [r0, #0]
    mov r2, #0x01
    and r0, r1, r2
    bne change_output_port
    b main

change_output_port:
    lsr r1, r1, #1
    mov r0, #0x40
    and r2, r0, r1
    bne zero
    mov r1, #0x80
    add r0, r0, r1
    ldr	r1, out_port_addr
	str r0, [r1, #0]
	b main
zero:
    mov r1, #0
    add r0, r0, r1
    b main

in_port_addr:
    .word INPORT_ADDRESS

out_port_addr:
    .word OUTPORT_ADDRESS
.data

.section .bss
    
.section .stack
.space STACK_SIZE
tos:
    .word 0x8000 ; o stack começa no fim da RAM

