;pTC = FF40 - FF7F 10Hz
;pisca com freq 1Hz -> 1 sec -> 0.5 on 0.5 off
.equ STACK_SIZE, 64
.equ PTC_ADDRESS, 0xFF40
.equ PTC_TCR, 0x00
.equ PTC_TMR, 0x02
.equ PTC_TC, 0x04
.equ PTC_TIR, 0x06
.equ OUTPORT_ADDRESS, 0xFFC0

.section .startup
    b _start
    b .

_start:
    ldr sp, tos_addr
    ldr pc, main_addr

tos_addr:
    .word tos
main_addr:
    .word main

.text
main:
    mov r0, #0
    bl outport_init
    bl ptc_stop
    mov r0, #5
    mov r4, r0
    bl ptc_init
    bl ptc_start
    mov r0, #1
    bl outport_write

loop_on:
    bl ptc_get_value
    cmp r0, r4
    bne loop_on
    mov r0, #0
    bl outport_write

loop_off:
    bl ptc_get_value
    cmp r0, r4
    bne loop_off
    mov r0, #1
    bl outport_write
    b loop_on

ptc_start:
    mov r0, #0
    mov r1, #PTC_ADDRESS & 0xFF
    movt r1, #(PTC_ADDRESS >> 8) & 0xFF
    strb r0, [r1, #PTC_TCR]
    mov pc, lr

ptc_stop:;TCR = 1
    mov r0, #1
    mov r1, #PTC_ADDRESS & 0xFF
    movt r1, #(PTC_ADDRESS >> 8) & 0xFF
    strb r0, [r1, #PTC_TCR]
    mov pc, lr

ptc_init:;TMR
    mov r1, #PTC_ADDRESS & 0xFF
    movt r1, #(PTC_ADDRESS >> 8) & 0xFF
    strb r0, [r1, #PTC_TMR]
    mov pc, lr

ptc_get_value:;TC
    mov r1, #PTC_ADDRESS & 0xFF
    movt r1, #(PTC_ADDRESS >> 8) & 0xFF
    ldrb r0, [r1, #PTC_TC]
    mov pc, lr

ptc_elapsed:

outport_write:
    ldr r1, outport_addr
    strb r0, [r1, #0]
    mov pc, lr

outport_init:
    ldr r3, outport_status_addr
    str r0, [r3, #0]
    ldr r1, outport_addr
    strb r0, [r1, #0]
    mov pc, lr

outport_addr:
    .word OUTPORT_ADDRESS

outport_status_addr:
    .word outport_status

.data

outport_status:
    .byte 0x00

.section .bbs
.section .stack
.space STACK_SIZE
tos:
