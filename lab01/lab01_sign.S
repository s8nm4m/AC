; -----------------------------------------------------------------------------
; Ficheiro:  lab01.S
; Descricao: Codigo de suporte a realizacao da 1a atividade laboratorial de AC.
; Autor:     Tiago M Dias (tiago.dias@isel.pt)
; Data:      11-03-2022
; -----------------------------------------------------------------------------

	; r0 guarda o valor da variavel M
	; r1 guarda o valor da variavel m
	; r2 guarda o valor da variavel p
	; r3 e utilizado para guardar valores temporariamente

mov r3, #0
push r3
push r3
signalcheck:; caso algum numero seja negativo vai trocar o sinal
    mov r3, #0
    cmp r0, r3
    blt minusmone;  mone = M
    cmp r1, r3
    blt minusmtwo;  mtwo = m
    b trade

minusmone:
    mov r3, #1
    mvn r0, r0
    add r0, r0, #1
    push r3 ; quando e negativo da push do valor 1
    b signalcheck

minusmtwo:
    mov r3, #1
    mvn r1, r1
    add r1, r1, #1
    push r3 ; quando é negativo dá push do valor 1

trade:
    cmp r0, r1
    bcc regular
    eor r0, r0, r1
    eor r1, r0, r1
    eor r0, r0, r1

regular:
    mov r3, #0
    mov r2, r3
    cmp r0, r3
    beq while_end

while:
    cmp r3, r1
    bhs while_end
    add r2, r2, r0
    sub r1, r1, #1
    b while

while_end:
    pop r0
    cmp r0, r3
    bne simetric
    b  .

simetric:
    mvn r2, r2
    add r2, r2, #1
    b while_end
