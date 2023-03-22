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
    b . ; suposto dar 457

tos_addr:
    .word tos

main_addr:
    .word main

.text

main:
    push lr
    ldr r0, numeral_addr
    ldr r1, radix_addr
    ldr r1, [r1, #0]
    bl str2nat
    pop pc

numeral_addr:
    .word numeral

radix_addr:
    .word radix

;r0 = &numeral[] , r1 = radix , r2 = number, r3 = error
;r4 = idx , r5 = tmp , r6 = numeral[idx] r7 = temporario

str2nat:
    push r4 ; guardar os valores de r4, r5, r6 e r7 para nao serem perdidos
    push r5
    push r6
    push r7
    mov r2, #0; number = 0
    ldr r3, error_addr; error = 0 
    mov r4, #0 ; idx = 0
    str r4, [r3, #0]
    ldr r3, [r3, #0]

for_loop:
    lsl r7, r4, #1 
    ldr r6, [r0, r7]
    mov r7, #0
    cmp r3, r7 ; if (error != 0) -> str2nat_end
    bne str2nat_end
    mov r7, #'\0'
    cmp r0, r7  ; if (numeral[idx])
    beq str2nat_end
    mov r0, r6
    bl char2nat
    mov r5, r0
    mov r0, r6
    mov r7, #NAN & 0xFF
    movt r7, #NAN & 0xFF
    cmp r5, r7
    bne for_else
    mov r2, #NAN & 0xFF
    movt r2, #NAN & 0xFF
    mov r7, #1
    str 
    b for_increment

for_else:
    mov r7, r0
    bl multiply
    mov r2, r0
    add r2, r2, r5
    mov r0, r7
    b for_increment:

for_increment:
    add r4, r4, #1
    b for_loop

str2nat_end:
    pop r7
    pop r6
    pop r5
    pop r4
    mov r0, r2
    mov pc, lr

multiply: 
    mov r2, #0

while:
    mov r3, #0
    cmp r3, r1
    bhs while_end
    add r2, r2, r0
    sub r1, r1, #1
    b while

while_end:
    mov r0, r2
    mov pc, lr

error_addr:
    .word error

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

numeral:
    .asciz "709"

radix:
    .word 8

.section .bss

error:
    .space 1

.section .stack
.space STACK_SIZE

tos:

