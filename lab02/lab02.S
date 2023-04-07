; -----------------------------------------------------------------------------
; Ficheiro:  lab02.S
; Descricao: Codigo de suporte a realizacao da 2a atividade laboratorial de AC.
; Autor:     Tiago M Dias (tiago.dias@isel.pt)
; Data:      15-04-2022
; -----------------------------------------------------------------------------

	.text
	ldr	r0, var2_addr
loop:
	ldrb	r1, [r0, #0] ;5
	add	r1, r1, #1		 ;4
	strb	r1, [r0, #0] ;5
	b	loop 			 ;3

var2_addr:
	.word var2

	.data
var1:
	.byte 0xAC
var2:
	.byte 126
var3:
	.word 0x2022
