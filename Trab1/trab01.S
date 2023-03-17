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

;c)

.equ NAN, 0xFFFF
.equ ZEROCHAR, '0'
.equ NINECHAR, '9'
.equ ACHAR, 'A'
.equ FCHAR, 'F'
.equ SIXTEEN, 16

;r0 = symbol, r1 = radix, r2 = number
;r3 temporary values

char2nat:
    mov r2, # NAN & 0xFF; number = NAN
    movt r2, # NAN & 0xFF
    mov r3, # ZEROCHAR
    cmp r3, r0 
    bhs symbol_else_if ; if(symbol < '0') -> symbol_else_if
    mov r3, # NINECHAR
    cmp r0, r3
    bhs symbol_else_if ; if(symbol > '9') -> symbol_else_if
    mov r3, # ZEROCHAR
    sub r2, r0, r3 ; number = symbol - '0'
    b radix_if

symbol_else_if:
    mov r3, # ACHAR
    cmp r0, r3
    bhs radix_if    ; if(symbol < 'A') -> radix_if
    mov r3, # FCHAR
    cmp r3, r0
    bhs radix_if    ; if( symbol > 'F') -> radix_if
    mov r3, # ACHAR
    sub r2, r0, r3 ; number = symbol - 'A'
    add r2, r2, #10 ; number = number + 10

radix_if:
    mov r3, # SIXTEEN
    cmp r3, r1
    bhs char2nat_end
    cmp r2, r1
    blo char2nat_end
    mov r2, # NAN & 0xFF
    movt r2, # NAN & 0xFF

char2nat_end:
    mov r0, r2
    mov pc, lr
