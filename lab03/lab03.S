; Ficheiro:  lab03.S
; Descricao: Programa para a realização da 3a atividade laboratorial de
;            Arquitetura de Computadores.
; Autor:     Tiago M Dias (tiago.dias@isel.pt)
; Data:      29-03-2023

; Definicao dos valores dos simbolos utilizados no programa
;
	.equ	STACK_SIZE, 64                ; Dimensao do stack - 64 B
; *** Para completar ***
	.equ	INPORT_ADDRESS, 0xFF80        ; ??
	.equ	OUTPORT_ADDRESS, 0xFFC0      ; ??

; Seccao:    startup
; Descricao: Guarda o código de arranque do sistema
;
	.section startup
	b	_start
	b	.
_start:
	ldr	sp, tos_addr
	ldr	pc, main_addr

tos_addr:
	.word	tos
main_addr:
	.word	main

; Seccao:    text
; Descricao: Guarda o código do programa
;
	.text

; Rotina:    main
; Descricao: *** Para completar ***
; Entradas:  *** Para completar ***
; Saidas:    *** Para completar ***
; Efeitos:   *** Para completar ***
main:
	;mov	r0, #0x80
	;bl	outport_write
	mov r5, #0
loop:
	bl	inport_read
	mov r3, r0
	mov r4, #0x80
	and r3, r3, r4
	bne pisca
	mov r0, #0
	bl outport_write
	b	loop

pisca:
	mvn r0, r0
	mov r1, #0x07
	and r0, r0, r1
	add r2, r0, r0
	add r2, r2, r2
	add r0, r2, r0
	bl sleep
	mvn r5, r5
	mov r2, #0x01
	and r0, r5, r2
	mov r3, #0x80 
	add r0, r0, r3
	bl	outport_write
	b loop

; Rotina:    inport_read
; Descricao: *** Para completar ***
; Entradas:  -
; Saidas:    r0 - *** Para completar ***
; Efeitos:   r1 - *** Para completar ***
inport_read:
	ldr	r1, inport_addr
	ldrb	r0, [r1, #0]
	mov	pc, lr

inport_addr:
	.word	INPORT_ADDRESS

; Rotina:    outport_write
; Descricao: *** Para completar ***
; Entradas:  r0 - *** Para completar ***
; Saidas:    -
; Efeitos:   r1 - *** Para completar ***
outport_write:
	ldr	r1, outport_addr
	strb	r0, [r1, #0]
	mov	pc, lr

outport_addr:
	.word	OUTPORT_ADDRESS

; Rotina:    sleep
; Descricao: *** Para completar ***
; Entradas:  *** Para completar ***
; Saidas:    *** Para completar ***
; Efeitos:   *** Para completar ***
sleep:
	and	r0, r0, r0
	beq	sleep_end
sleep_outer_loop:
	mov	r1, #0x3E
	movt	r1, #0x03
sleep_inner_loop:
	sub	r1, r1, #1
	bne	sleep_inner_loop
	sub	r0, r0, #1
	bne	sleep_outer_loop
sleep_end:
	mov	pc, lr

; Seccao:    data
; Descricao: Guarda as variáveis globais com um valor inicial definido
;
	.data

; Seccao:    bss
; Descricao: Guarda as variáveis globais sem valor inicial definido
;
	.bss

; Seccao:    stack
; Descricao: Implementa a pilha com o tamanho definido pelo simbolo STACK_SIZE
;
	.stack
	.space	STACK_SIZE
tos:
