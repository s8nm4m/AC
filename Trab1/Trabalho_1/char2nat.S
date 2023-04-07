; unit test da rotina char2nat 
;teste default symbol = 0, radix = 2
;para outros testes mudar na seccao .data os valores de symbol e radix

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
    mov r2, #NAN & 0xFF; number = NAN
    movt r2, #NAN & 0xFF
    mov r3, #'0'
    cmp r0, r3 
    blo symbol_else_if ; if(symbol < '0') -> symbol_else_if
    mov r3, #'9'
    cmp r3, r0
    blo symbol_else_if ; if(symbol > '9') -> symbol_else_if
    mov r3, #'0'
    sub r2, r0, r3 ; number = symbol - '0'
    b radix_if1

symbol_else_if:
    mov r3, #'A'
    cmp r0, r3
    blo radix_if1    ; if(symbol < 'A') -> radix_if
    mov r3, #'F'
    cmp r3, r0
    blo radix_if1    ; if( symbol > 'F') -> radix_if
    mov r3, #'A'
    sub r2, r0, r3 ; number = symbol - 'A'
    add r2, r2, #10 ; number = number + 10

radix_if1:
    mov r3, #16
    cmp r3, r1
    bhs radix_if2 ; if(radix <= 16) -> char2nat_end    

number_nan:
    mov r2, #NAN & 0xFF
    movt r2, #NAN & 0xFF
    b char2nat_end

radix_if2:
    cmp r2, r1
    blo char2nat_end ; if(number < radix) -> char2nat_end
    b number_nan

char2nat_end:
    mov r0, r2
    mov pc, lr
    
.data

symbol:
    .word 0x0030 ; nao esta a funcionar .ascii '0'

radix:
    .word 2

.section .stack
.space STACK_SIZE

tos:
