.equ NAN, 0xFFFF
.equ STACK_SIZE, 64

.section .startup
    b _start
    b .

_start:
    ldr sp, tos_addr
    mov r0, pc
    add lr, r0, #4
    ldr pc, main_addr
    b . ; e suposto dar 0

tos_addr:
    .word tos

main_addr:
    .word main

.text

main:
    push lr
    ldr r0, symbol_addr
    ldr r0, [r0, #0]
    ldr r1, radix_addr
    ldr r1, [r1, #0]
    bl char2nat
    pop pc

;r0 = symbol, r1 = radix, r2 = number
;r3 temporary values

symbol_addr:
    .word symbol

radix_addr:
    .word radix

char2nat:
    mov r2, #NAN & 0xFF
    movt r2, #NAN & 0xFF
if:
    mov r3, #'0'
    cmp r0, r3          ; symbol >= '0'
    blo else_if
    mov r3, #'9'         
    cmp r3, r0          ; symbol <= '9'
    blo else_if
    mov r3, #'0'
    sub r2, r0, r3      ; number = symbol - '0'
    b if_cond1
else_if: 
    mov r3, #'A'         
    cmp r0, r3          ; symbol >= 'A'
    blo if_cond1
    mov r3, #'F' 
    cmp r3, r0          ; symbol <= 'F'
    blo if_cond1
    mov r3, #'A' 
    sub r2, r0, r3      ; number = symbol - 'A'
    add r2, r2, #10     ; number = r5 + 10
if_cond1:
    mov r3, #16
    cmp r3, r1          ; radix > 16
    bhs if_cond2
    b if_2
if_cond2:
    cmp r2, r1          ; number >= radix
    blo if_end
if_2:
    mov r2, #NAN & 0xFF
    movt r2, #NAN & 0xFF  
if_end:
    mov r0, r2          ; return number
    mov pc, lr
    
.data

symbol:
    .word 0x0037 ; nao esta a funcionar .ascii '0'

radix:
    .word 8

.section .stack
.space STACK_SIZE

tos:
