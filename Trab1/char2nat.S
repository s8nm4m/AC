;2 c)

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
    