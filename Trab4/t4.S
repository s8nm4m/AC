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
    b init

init:
    ldr r0, stimulus_init_val
    ldr r1,  result_init_val
    orr r0, r0, r1
    bl outport_write
    b wait1to0

wait1to0:
    ldr r0, user_mask
    ldr r1, inport_addr
    ldr r2, [r1, #0]
    and r0, r0, r2
    mov r2, #0
    cmp r0, r2
    bne wait1to0

wait0to1:
    ldr r0, user_mask
    ldr r1, inport_addr
    ldr r2, [r1, #0]
    and r0, r0, r2
    mov r2, #1
    cmp r0, r2
    bne wait0to1
    b setup_test

user_mask:
    .word USER

delay:
    push lr
    push r4
    push r5
    mov r4, r0
    bl sysclk_get_ticks
    mov r5, r0

delay_loop:
    bl sysclk_get_ticks
    sub r0, r0 ,r5
    cmp r0, r4
    blo delay_loop
    pop r5
    pop r4
    pop pc

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

setup_test:
    ldr r1, outport_addr
    ldr r0, [r1, #0]
    mvn r0, r0
    ldr r2, stimulus_init_val
    add r0, r0, r2
    bl outport_write
    ldr r1, inport_addr
    ldr r0, [r1, #0]
    ldr r1, sysclk_addr
    str r0, [r1, #0]
    b test

test:
    b .

stimulus_init_val:
    .word STIMULUS

result_init_val:
    .word RESULT

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

sysclk_get_ticks:
	ldr r0 , sysclk_addr
	ldr r0, [r0, #0]
	mov pc, lr

outport_addr:
	.word	OUTPORT_ADDRESS

sysclk_addr:
    .word sysclk

ptc_addr:
	.word PTC_ADDRESS

.data

.bss

sysclk:
	.space	2

    .stack
    .space STACK_SIZE
tos:
