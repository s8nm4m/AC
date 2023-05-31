.equ STACK_SIZE, 64
.equ INPORT_ADDRESS, 0xFF80
.equ OUTPORT_ADDRESS, 0xFFC0
.equ PTC_ADDRESS, 0xFF78
.equ PTC_TCR, 0
.equ PTC_TMR, 2
.equ PTC_TC, 4
.equ PTC_TIR, 6 
.equ USER, 0x01
.equ STIMULUS, 0x01
.equ TIME, 0xF0
.equ RESULT, 0xFE

.section .startup
    b _start
    ldr pc, isr_addr

_start:
    ldr sp, tos_addr
    ldr pc, main_addr

tos_addr:
    .word tos

main_addr:
    .word main

isr_addr:
    .word isr

.text

main:
    mrs r0, cpsr ; lê valor actual do cpsr
    mov r1, #0x10 ; mask do bit a activar IE
    orr r0, r0, r1 ; junta aos outros bits de estado
    msr cpsr, r0 ; carrega novo cpsr
    bl outport_init
    b main

isr:
    push r0
    push r1
    ldr r0, ptc_addr
	strb r0, [r0, #PTC_TIR]
	ldr r0, sysclk_addr
	ldr r1, [r0,#0]
	add r1, r1, #1
	str r1, [r0, #0]
    pop r1
    pop r0
    movs pc, lr

inport_read:
	ldr	r1, inport_addr
	ldrb	r0, [r1, #0]
	mov	pc, lr

inport_addr:
	.word	INPORT_ADDRESS

outport_init:
    push lr
    mov r0, #0xFF
    bl outport_write
    pop pc

outport_write:
	ldr	r1, outport_addr
	strb	r0, [r1, #0]
	mov	pc, lr

outport_addr:
	.word	OUTPORT_ADDRESS

.data

.bss

    .stack
    .space STACK_SIZE
tos:
