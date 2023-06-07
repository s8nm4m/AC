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
.equ AVG_TIME, 200
.equ	PTC_CMD_START, 0             
.equ	PTC_CMD_STOP, 1

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
    b init

init:
    ldr r0, stimulus_init_val3
    ldr r1,  result_init_val2
    orr r0, r0, r1
    bl outport_write
    b wait1to0

stimulus_init_val3:
    .word STIMULUS

wait1to0:
    ldr r0, user_mask
    ldr r1, inport_addr2
    ldr r2, [r1, #0]
    and r0, r0, r2
    mov r2, #0
    cmp r0, r2
    bne wait1to0

wait0to1:
    ldr r0, user_mask
    ldr r1, inport_addr2
    ldr r2, [r1, #0]
    and r0, r0, r2
    mov r2, #1
    cmp r0, r2
    bne wait0to1
    b setup_test

result_init_val2:
    .word RESULT

user_mask:
    .word USER
;tá mal help
delay:
    push lr
	and	r0, r0, r0
	beq	delay_end
delay_outer_loop:
	mov	r1, #0x50
	movt r1, #0xC3
delay_inner_loop:
	sub	r1, r1, #1
    bl check_user
	bne	delay_inner_loop
	sub	r0, r0, #1
	bne	delay_outer_loop
delay_end:
	pop pc

check_user:
    push lr
    push r0
    push r1
    bl inport_read
    mov r1, #USER
    and r0, r0, r1
    mov r1, #0
    cmp r0, r1
    beq init
    pop r1
    pop r0
    pop pc

isr:
    push r0
    push r1
    ldr r0, ptc_addr2
	strb r0, [r0, #PTC_TIR]
	ldr r0, sysclk_addr2
	ldr r1, [r0,#0]
	add r1, r1, #1
	str r1, [r0, #0]
    pop r1
    pop r0
    movs pc, lr

setup_test:
    ldr r1, outport_addr2
    ldr r0, [r1, #0]
    mvn r0, r0
    ldr r2, stimulus_init_val2
    add r0, r0, r2
    bl outport_write
    b test

stimulus_init_val2:
    .word STIMULUS

inport_addr2:
    .word INPORT_ADDRESS

test:
    bl test_1
    mov r0, #0
    bl outport_write
    bl test_2
    bl show_result
    b init

ptc_addr2:
    .word PTC_ADDRESS

outport_addr2:
    .word OUTPORT_ADDRESS

sysclk_addr2:
    .word sysclk

test_1:
    push lr
   ; bl inport_read
    ;bl check_user
    bl get_time
    mov r4, r0
    bl delay
    pop pc 

get_time:
    push lr
    bl inport_read
    mov r1, #TIME
    and r0, r0, r1
    lsr r0, r0, #4
    pop pc

test_2:
    push lr 
    push lr
    mrs r0, cpsr ; lê valor actual do cpsr
    mov r1, #0x10 ; mask do bit a activar IE
    orr r0, r0, r1 ; junta aos outros bits de estado
    msr cpsr, r0 ; carrega novo cpsr
    mov r0, #2
    bl ptc_init
    bl wait_user
    pop pc

wait_user:
    bl inport_read
    mov r1, #USER
    and r0, r0, r1
    mov r1, #0
    cmp r0, r1
    bne wait_user
    pop pc 

show_result:
    push lr
    bl sysclk_get_ticks
    mov r2, r0
    bl ptc_stop
    mov r0, #AVG_TIME
    sub r0, r2, r0
    lsl r0, r0, #1
    mov r1, #RESULT
    and r0, r0, r1
    bl outport_write
    mov r0, #5
    bl delay
    pop pc

reset_sysclk:
    ldr r0, sysclk_addr
    mov r1, #0
    str r1, [r0]
    mov pc, lr

sysclk_get_ticks:
	ldr r0 , sysclk_addr
	ldr r0, [r0, #0]
	mov pc, lr

ptc_init:
	push lr
	push r0
	bl ptc_stop
	pop r0
	mov r1, #PTC_ADDRESS & 0xFF
    movt r1, #(PTC_ADDRESS >> 8) & 0xFF
    strb r0, [r1, #PTC_TMR]
	strb r0, [r1, #PTC_TIR]
	bl ptc_start
	pop lr
    mov pc, lr

ptc_start:
	ldr	r0, PTC_ADDR
	mov	r1, #PTC_CMD_START
	strb	r1, [r0, #PTC_TCR]
	mov	pc, lr

ptc_stop:
	ldr	r0, PTC_ADDR
	mov	r1, #PTC_CMD_STOP
	strb	r1, [r0, #PTC_TCR]
	mov	pc, lr

ptc_get_value:
	ldr	r1, PTC_ADDR
	ldrb	r0, [r1, #PTC_TC]
	mov	pc, lr

PTC_ADDR:
	.word	PTC_ADDRESS

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
