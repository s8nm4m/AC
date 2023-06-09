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
.equ PTC_CMD_START, 0             
.equ PTC_CMD_STOP, 1

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
    mov r0, #STIMULUS
    mov r1, #RESULT
    orr r0, r0, r1
    bl outport_write
    b wait1to0

wait1to0:
    bl inport_read
    mov r1, #USER
    and r0, r0, r1
    mov r1, #0
    cmp r0, r1
    bne wait1to0

wait0to1:
    bl inport_read
    mov r1, #USER
    and r0, r0, r1
    mov r1, #1
    cmp r0, r1
    bne wait0to1
    b setup_test

delay_first:
    push lr
    lsl r1, r0, #2
delay_first_loop:
    bl check_user
    bl sysclk_get_ticks
    cmp r0, r1
    bne delay_first_loop
delay_first_end:
	pop pc

delay:
    push lr
    lsl r1, r0, #2
delay_loop:
    bl sysclk_get_ticks
    cmp r0, r1
    bne delay_loop
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

setup_test:
    bl reset_sysclk
    bl get_time
    mov r3, r0
    mov r0, #1
    bl outport_write
    b test

test:
    bl wait_time
    mov r0, #0
    bl outport_write
    bl measure_time
    bl get_result
    b init

wait_time:
    push lr
    mov r0, #249
    bl ptc_init
    mrs r0, cpsr ; lê valor actual do cpsr
    mov r1, #0x10 ; mask do bit a activar IE
    orr r0, r0, r1 ; junta aos outros bits de estado
    msr cpsr, r0 ; carrega novo cpsr
    mov r0, r3
    bl delay_first
    bl ptc_stop
    bl reset_sysclk
    pop pc 

get_time:
    push lr
    bl inport_read
    mov r1, #TIME
    and r0, r0, r1
    lsr r0, r0, #4
    and r0, r0, r0 
    beq less_than_1
    mov r1, #10
    cmp r0, r1
    bge over_10
    pop pc 

less_than_1:
    mov r0, #1
    pop pc

over_10:
    mov r0, #10
    pop pc

measure_time:
    push lr
    mov r0, #1
    bl ptc_init
    bl wait_user
    pop pc

wait_user:
    push lr
wait_loop:
    bl inport_read
    mov r1, #USER
    and r0, r0, r1
    mov r1, #0
    cmp r0, r1
    bne wait_loop
    pop pc     

get_result:
    push lr
    bl ptc_stop
    bl sysclk_get_ticks
    mov r2, #AVG_TIME
    cmp r2, r0
    blt higher_than_avg
    bl lower_than_avg
    bl show_result
    pop pc

higher_than_avg:
    sub r0, r0, r2
    bl show_result
    pop pc

lower_than_avg:
    sub r0, r0, r2
    mvn r0, r0
    add r0, r0, #1
    mov pc, lr
    
show_result:
    push lr
    bl in_scale
    lsl r0, r0, #1
    bl outport_write
    bl reset_sysclk
    mov r0, #249
    bl ptc_init
    mov r0, #5
    bl delay
    pop pc

in_scale:
    mov r1, #63
    cmp r0, r1
    bge out_of_scale
    mvn r1, r1
    add r1, r1, #1
    cmp r1, r0 
    bge out_of_scale
    mov pc, lr 

out_of_scale:
    mov r0, #-64
    mov pc, lr

reset_sysclk:
    ldr r0, sysclk_addr
    mov r1, #0
    str r1, [r0]
    mov pc, lr

sysclk_get_ticks:
	ldr r0 , sysclk_addr
	ldr r0, [r0, #0]
	mov pc, lr

isr:
    push r0
    push r1
    ldr r0, PTC_ADDR
	strb r0, [r0, #PTC_TIR]
	ldr r0, sysclk_addr
	ldr r1, [r0,#0]
	add r1, r1, #1
	str r1, [r0, #0]
    pop r1
    pop r0
    movs pc, lr

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
	pop pc

ptc_start:
	ldr	r0, PTC_ADDR
	mov	r1, #PTC_CMD_START
	strb r1, [r0, #PTC_TCR]
	mov	pc, lr

ptc_stop:
	ldr	r0, PTC_ADDR
	mov	r1, #PTC_CMD_STOP
	strb r1, [r0, #PTC_TCR]
	mov	pc, lr

ptc_get_value:
	ldr	r1, PTC_ADDR
	ldrb r0, [r1, #PTC_TC]
	mov	pc, lr

PTC_ADDR:
	.word PTC_ADDRESS

inport_read:
	ldr	r1, inport_addr
	ldrb r0, [r1, #0]
	mov	pc, lr

inport_addr:
	.word INPORT_ADDRESS

outport_init:
    push lr
    mov r0, #0xFF
    bl outport_write
    pop pc

outport_write:
	ldr	r1, outport_addr
	strb r0, [r1, #0]
	mov	pc, lr

outport_addr:
	.word OUTPORT_ADDRESS

sysclk_addr:
    .word sysclk

.data
sysclk:
	.word 0

.bss

    .stack
    .space STACK_SIZE
tos:
