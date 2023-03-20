;3)

;r0 = &numeral[] , r1 = radix , r2 = number, r3 = error
;r4 = idx , r5 = tmp , r6/r7 temporario
.equ ZERO, 0
.equ ONE, 1

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
    mov r6, # NAN & 0xFF ; r6 = NAN
    movt r6, # NAN & 0xFF
    cmp r5, r6 
    bne for_else
    mov r2, # NAN & 0xFF
    movt r2, # NAN & 0xFF
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
    mov r2, # NAN & 0xFF
    movt r2, # NAN & 0xFF
    b char2nat_end

radix_if2:
    cmp r2, r1
    blo char2nat_end ; if(number < radix) -> char2nat_end
    b number_nan

char2nat_end:
    mov r0, r2
    mov pc, lr
    