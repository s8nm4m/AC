; Trabalho realizado pelos alunos 
;André Monteiro, 43842, e Constança Costa, 50541, 
;da turma 24D

;r0 = multiplicando
;r1 = multiplicador

;1) a) Após consultar a tabela presente no Guia de Codificação das Instruções 
;concluimos que a implementação do código ocupa 18 bytes de memória.
;Tendo em conta os nossos calculos cada uma das 9 linhas com instruções
;ocupam 16 bits(2 bytes), logo 9x2 bytes = 18 bytes.

;b) Enquanto grupo não concordamos com esta afirmação.
;Como sabemos os registos em rotinas encontram-se divididos em 3 classes,
;achamos que não seria preferivel a utilização do R4, pois ao contrário do R2,
 ;este registo tem necessidade de armazenar o seu valor, 
 ;tendo em conta o propósito da rotina multiply não faria sentido 
 ;guardar o valor sendo que o que nos importa é o valor final.

;2) a) O valor da constante NAN é FFFF=65535, porque em hexadecimal cada valor 
;pode ser compreendido entre 0 e 15, onde 15=F. Neste caso o valor é positivo
;por ser do tipo uint16_t, ou seja, um inteiro sem sinal de 16 bits.

;b) A constante NAN apresenta duas opções de definição das quais: 
;.equ NAN, FFFF e
;NAN:
;     .word 0xFFFF
;Como sabemos ambas são distintas, a primeira apenas trabalha com registos,
;no entanto acaba por necessitar de mais instruções do que a segunda definição.
;Esta apresenta uma maior velocidade de processamento por recorrer à memória.

;2 c)

.equ NAN, 0xFFFF
.equ STACK_SIZE, 64

.section .startup
    b _start
    b .

_start:
    ldr sp, tos_addr ; por no sp o address do top of
    mov r0, pc
    add lr, r0, #4
    ldr pc, main_addr
    b .

tos_addr:
    .word tos

main_addr:
    .word main

.text

main:
    push lr
    ldr r5, error_addr
    mov r0, #0
    strb r0, [r5, #0]
    ldr r0, tst_str0_addr
    mov r1, #2
    bl str2nat
    ldr r4, tst_results_addr
    ldr r1, [r4, #0]
    mov r2, #1
    mov r6, pc
    add r3, r6, #6
    cmp r0, r1
    bne error_op
    ldr r0, tst_str1_addr
    mov r1, #8
    bl str2nat
    ldr r1, [r4, #2]
    mov r2, #2
    mov r6, pc
    add r3, r6, #6
    cmp r0, r1
    bne error_op
    ldr r0, tst_str2_addr
    mov r1, #16
    bl str2nat
    ldr r1, [r4, #4]
    mov r2, #4
    mov r6, pc
    add r3, r6, #6
    cmp r0, r1
    bne error_op
    ldrb r0, [r5, #0]
    pop pc

error_op:
    push r3 
    ldr r0, error_addr
    ldrb r1, [r0, #0]
    orr r1, r1, r2
    strb r1, [r0, #0]
    pop lr
    mov pc, lr

tst_str0_addr:
    .word tst_str0

tst_str1_addr:
    .word tst_str1

tst_str2_addr:
    .word tst_str2

tst_results_addr:
    .word tst_results

char2nat_addr:
    .word char2nat

str2nat_addr:
    .word str2nat

error_addr:
    .word error

;r0 = &numeral[] , r1 = radix , r2 = number, r3 = error
;r4 = idx , r5 = tmp , r6 = numeral[idx] r7 = temporario

str2nat:
    push lr
    push r4 ; guardar os valores de r4, r5, r6 e r7 para nao serem perdidos
    push r5
    push r6
    push r7
    push r8
    mov r2, #0 ; number = 0 
    mov r3, #0 ; error = 0
    mov r4, #0 ; idx = 0

for_loop:
    ldrb r6, [r0, r4] ; load numeral[idx]
    mov r7, #0
    cmp r3, r7 ; if (error != 0) -> str2nat_end
    bne str2nat_end
    mov r7, #'\0'
    cmp r6, r7  ; if (numeral[idx] == '\0') -> str2nat_end
    beq str2nat_end
    mov r7, r0 ; guardar o valor &numerical[]
    mov r0, r6 ; por o parametro a passar a char2nat na posicao certa
    mov r6, r3
    mov r8, r2
    bl char2nat
    mov r2, r8
    mov r3, r6
    mov r5, r0 ; tmp = char2nat(numeral[idx], radix)
    mov r0, r7 ; restaurar &numerical[] para o sitio certo
    mov r7, #NAN & 0xFF
    movt r7, #NAN & 0xFF
    cmp r5, r7      ; if (tmp != NAN) -> for_else
    bne for_else
    mov r2, #NAN & 0xFF
    movt r2, #NAN & 0xFF
    mov r3, #1 
    b for_increment

for_else:
    mov r6, r1
    mov r7, r0
    mov r8, r3
    mov r0, r2
    bl multiply
    mov r2, r0
    mov r1, r6
    mov r0, r7
    mov r3, r8
    add r2, r2, r5
    mov r0, r7
    b for_increment

for_increment:
    add r4, r4, #1
    b for_loop

str2nat_end:
    pop r8
    pop r7
    pop r6
    pop r5
    pop r4
    mov r0, r2
    pop lr
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

tst_results:
    .word 11, 457, 39439

tst_str0:
    .asciz "01011"
    .align

tst_str1:
    .asciz "709"
    .align
    
tst_str2:
    .asciz "9A0F"

.section .bss

error:
    .space 1

.section .stack
.space STACK_SIZE
tos:
