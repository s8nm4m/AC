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
-equ RESULT, 0xFE

.section .startup
    b _start
    ldr pc, isr_addr

_start:
    ldr sp, tos_addr
    ldr, pc, main_addr

to_addr:
    .word tos

main_addr:
    .word main

isr_addr:
    .word isr

.text

main:

inport_read:
	ldr	r1, inport_addr
	ldrb	r0, [r1, #0]
	mov	pc, lr

inport_addr:
	.word	INPORT_ADDRESS

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
