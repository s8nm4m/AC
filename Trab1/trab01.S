; r0 = multiplicando
; r1 = multiplicador

;1) a) Esta implementação ocupa 8 bytes de memória, devido ao uso de 4 registos(R0..R3), sendo cada um de 2 bytes tendo em conta as caracteristicas do processor P16.
;b) Enquanto grupo não concordamos com esta afirmação.
;Como sabemos os registos em rotinas encontram-se divididos em 3 classes,
;achamos que não seria preferivel a utilização do R4, pois ao contrário do R2,
 ;este registo tem necessidade de armazenar o seu valor, 
 ;tendo em conta o propósito da rotina multiply não faria sentido 
 ;guardar o valor sendo que o que nos importa é o valor final.

;2) a) O valor da constante NAN é FFFF=65535, porque em hexadecimal cada valor 
;pode ser compreendido entre 0 e 15, onde 15=F. Neste caso o valor é positivo
;por ser do tipo uint16_t, ou seja, um intiero sem sinal de 16 bits.

;b) .equ NAN, FFFF ocupa 16 bits, ou seja, 1 registo.

;2 c)

;.equ NAN, 0xFFFF
.equ ZEROCHAR, '0'
.equ NINECHAR, '9'
.equ ACHAR, 'A'
.equ FCHAR, 'F'
.equ SIXTEEN, 16
.equ STACK_SIZE, 64
.equ ZERO, 0
.equ ONE, 1
.equ TWO, 2
.equ FOUR, 4
.equ EIGHT, 8

.section .startup
    b _start
    b .

_start:
    ldr sp, tos_addr
    mov r1, # ONE
    mov r2, shift_addr
    strb r1, r2
    mov r1, # ZERO
    mov r2, error_addr
    strb r1, r2
    mov r0, pc
    add lr, r0, #4
    ldr pc, main_addr
    b .

tos_addr:
    .word tos

main_addr:
    .word main

tst_results_addr:
    .word tst_results

tst_str0_addr:
    .word tst_str0

tst_str1_addr:
    .word tst_str1

tst_str2_addr:
    .word tst_str2

error_addr:
    .word error

shift_addr:
    .word shift

.text

main:
    push lr
    ldr r0, tst_str0_addr
    ldr r4, [r0, # ZERO]
    mov r1, # TWO
    bl str2nat
    cmp r0, r4
    mov r6, pc
    add r5, r6, # EIGHT
    push r5
    beq error_shift
    ldr r0, tst_str1_addr
    ldr r4, [r0, # TWO]
    mov r1, # EIGHT
    bl str2nat
    cmp r0, r4
    mov r6, pc
    add r5, r6, # EIGHT
    push r5
    beq error_shift
    ldr r0, tst_str2_addr
    ldr r4, [r0, # FOUR]
    mov r1, # SIXTEEN
    bl str2nat
    cmp r0, r4
    mov r6, pc
    add r5, r6, # EIGHT
    push r5
    beq error_shift
    strb r0, error
    pop pc

error_shift:
    ldrb r0, error
    ldrb r1, shift
    orr r1, r0, r1
    mov r2, error_addr
    strb r1, r2
    ldrb r1, shift
    lsl r1, r1, # ONE
    mov r2, shift_addr
    strb r1, r2
    pop pc

;r0 = symbol, r1 = radix, r2 = number
;r3 temporary values

char2nat:
    mov r2, # NAN; & 0xFF; number = NAN
    movt r2, # NAN; & 0xFF
    mov r3, # ZEROCHAR
    cmp r0, r3 
    blo symbol_else_if ; if(symbol < '0') -> symbol_else_if
    mov r3, # NINECHAR
    cmp r3, r0
    blo symbol_else_if ; if(symbol > '9') -> symbol_else_if
    mov r3, # ZEROCHAR
    sub r2, r0, r3 ; number = symbol - '0'
    b radix_if1

symbol_else_if:
    mov r3, # ACHAR
    cmp r0, r3
    blo radix_if1    ; if(symbol < 'A') -> radix_if
    mov r3, # FCHAR
    cmp r3, r0
    blo radix_if1    ; if( symbol > 'F') -> radix_if
    mov r3, # ACHAR
    sub r2, r0, r3 ; number = symbol - 'A'
    add r2, r2, #10 ; number = number + 10

radix_if1:
    mov r3, # SIXTEEN
    cmp r3, r1
    bhs radix_if2 ; if(radix <= 16) -> char2nat_end    

number_nan:
    mov r2, # NAN ;& 0xFF
    movt r2, # NAN; & 0xFF
    b char2nat_end

radix_if2:
    cmp r2, r1
    blo char2nat_end ; if(number < radix) -> char2nat_end
    b number_nan

char2nat_end:
    mov r0, r2
    mov pc, lr
    

;3)

;r0 = &numeral[] , r1 = radix , r2 = number, r3 = error
;r4 = idx , r5 = tmp , r6/r7 temporario

str2nat:
    push r4 ; guardar os valores de r4, r5, r6 e r7 para nao serem perdidos
    push r5
    push r6
    push r7
    mov r2, # ZERO & 0xFF; number = 0
    movt r2, # ZERO & 0xFF
    mov r3, # ZERO ; error = 0
    mov r4, # ZERO ; idx = 0

for_loop:
    mov r6, # ZERO
    cmp r3, r6
    bne str2nat_end ; if( error != 0 ) -> str2nat_end
    mov r6, # '\0'
    ldr r7, [r0,r4]
    cmp r7, r6
    beq str2nat_end ; if( numeral[idx] == '\0' ) -> str2nat_end
    mov r7, r0
    bl char2nat
    mov r5, r0 ; tmp = char2nat(numeral[idx], radix)
    mov r0, r7
    mov r6, # NAN; & 0xFF ; r6 = NAN
    movt r6, # NAN; & 0xFF
    cmp r5, r6 
    bne for_else
    mov r2, # NAN ;& 0xFF
    movt r2, # NAN ;& 0xFF
    mov r3, # ONE
    b for_loop

for_else:
    mov r6, r0
    push r2
    push r3
    bl multiply
    pop r3
    pop r2
    mov r7, r0
    mov r0, r6
    add r2, r7, r5
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

; 4)

.data

NAN:
    .word 0xFFFF

tst_results:
    .word 11, 457, 39439

tst_str0:
    .asciz "01011"

tst_str1:
    .asciz "709"

tst_str2:
    .asciz "9A0F"

.section .bss

error:
    .space 1

shift:
    .space 1

.section .stack
    .space STACK_SIZE
tos:
; 5)
