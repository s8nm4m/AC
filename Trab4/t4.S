.equ STACK_SIZE, 64
;endereços dos port em uso
.equ INPORT_ADDRESS, 0xFF80
.equ OUTPORT_ADDRESS, 0xFFC0
.equ PTC_ADDRESS, 0xFF78
;offsets dos registos do ptc
.equ PTC_TCR, 0
.equ PTC_TMR, 2
.equ PTC_TC, 4
.equ PTC_TIR, 6 
;mascaras
.equ USER, 0x01
.equ STIMULUS, 0x01
.equ TIME, 0xF0
.equ RESULT, 0xFE
; Definicao dos valores dos simbolos utilizados no programa
.equ AVG_TIME, 200
.equ PTC_CMD_START, 0             
.equ PTC_CMD_STOP, 1
.equ LIMIT, 63
.equ OUT_OF_RANGE, -64
.equ MIN_TIME, 1
.equ MAX_TIME, 10
.equ MULT_BY_4, 2
.equ ON, 1
.equ OFF, 0
.equ CHANGE_PART, 4; de high para low ou de low para high
.equ TO_RESULT, 1
.equ SHOW_RES_TIME, 5
.equ SYSCLK_FREQ, 249
.equ REACT_TIME_FREQ, 1

; Seccao:    startup
; Descricao: Guarda o código de arranque do sistema
.section .startup
    b _start
    ldr pc, isr_addr

_start:
    ldr sp, tos_addr
    ldr pc, main_addr

tos_addr:
    .word tos

main_addr:
    .word main

isr_addr:
    .word isr

; Seccao:    text
; Descricao: Guarda o código do programa
.text

main:
    b init
;estado inicial onde liga todos os leds 
init: 
    mov r0, #STIMULUS
    mov r1, #RESULT
    orr r0, r0, r1
    bl outport_write
    b wait_user_1to0
;espera que o SW USER seja colocado a 0
wait_user_1to0:
    bl inport_read
    mov r1, #USER
    and r0, r0, r1
    mov r1, #OFF
    cmp r0, r1
    bne wait_user_1to0
;espera que o SW USER seja colocado a 1
wait_user_0to1:
    bl inport_read
    mov r1, #USER
    and r0, r0, r1
    mov r1, #ON
    cmp r0, r1
    bne wait_user_0to1
    b setup_test
;espera do tempo colocado pelo utilizador em segundos
;Entradas: R0 - numero de segundos a esperar
delay:
    push lr
    bl mult_by_4
delay_loop:
    bl check_user
    bl sysclk_get_ticks
    cmp r0, r1
    bne delay_loop
delay_end:
	pop pc

;espera durante 'SHOW_RES_TIME' segundos
delay_result:
    push lr
    mov r0, SHOW_RES_TIME
    bl mult_by_4
delay_result_loop:
    bl sysclk_get_ticks
    cmp r0, r1
    bne delay_result_loop
delay_result_end:
	pop pc
;multiplica o valor recebido em r0 por 4 e devolve o resultado em r1
mult_by_4:
    lsl r1, r0, #MULT_BY_4
    mov pc, lr
;verifica se o SW USER foi colocado a 0 e dá abort em caso positivo
check_user:
    push lr
    push r0
    push r1
    bl inport_read
    mov r1, #USER
    and r0, r0, r1
    mov r1, #OFF
    cmp r0, r1
    beq init
    pop r1
    pop r0
    pop pc
;faz as preparações do teste , isto é, desliga todos os leds excepto o do STIMULUS
setup_test:
    bl reset_sysclk
    bl get_time
    mov r3, r0
    mov r0, #STIMULUS
    bl outport_write
    b test
;estado de controlo do teste
test:
    bl wait_time
    mov r0, #OFF
    bl outport_write
    bl measure_time
    bl get_result
    b init
;dá enable das interrupções e chama a função 'delay' para esperar o tempo 
;indicado parando depois o contador do ptc e dando reset ao sysclk para 
;preparar a proxima contagem
wait_time:
    push lr
    mov r0, #SYSCLK_FREQ
    bl ptc_init
    mrs r0, cpsr ; lê valor actual do cpsr
    mov r1, #0x10 ; mask do bit a activar IE
    orr r0, r0, r1 ; junta aos outros bits de estado
    msr cpsr, r0 ; carrega novo cpsr
    mov r0, r3
    bl delay
    bl ptc_stop
    bl reset_sysclk
    pop pc 
;lê o tempo do inport, dando-lhe shift da parte alta para a parte baixa
;colocando-o dentro do range no caso em que esteja fora deste
get_time:
    push lr
    bl inport_read
    mov r1, #TIME
    and r0, r0, r1
    lsr r0, r0, #CHANGE_PART
    and r0, r0, r0 
    beq less_than_1
    mov r1, #MAX_TIME
    cmp r0, r1
    bge over_10
    pop pc 
;caso seja menor coloca o valor a 1
less_than_1:
    mov r0, #MIN_TIME
    pop pc
;caso seja maior coloca o valor a 10
over_10:
    mov r0, #MAX_TIME
    pop pc
;reformata o ptc para medir em ms e depois chama a função 'wait_user'
measure_time:
    push lr
    mov r0, #REACT_TIME_FREQ
    bl ptc_init
    bl wait_user
    pop pc
;espera que o utilizador coloque o SW de USER a 0
wait_user:
    push lr
wait_user_loop:
    bl inport_read
    mov r1, #USER
    and r0, r0, r1
    mov r1, #OFF
    cmp r0, r1
    bne wait_user_loop
    pop pc     
;verifica a diferença entre o valor medido e a média de 200 ms
;devolvendo o resultado em r0
get_result:
    push lr
    bl ptc_stop
    bl sysclk_get_ticks
    mov r2, #AVG_TIME
    sub r0, r0, r2
    bl show_result
    pop pc
;demonstra o resultado recebido em r0 e chama a função 'delay_result'
show_result:
    push lr
    bl in_scale
    lsl r0, r0, #TO_RESULT
    bl outport_write
    bl reset_sysclk
    mov r0, #SYSCLK_FREQ
    bl ptc_init
    bl delay_result
    pop pc
;verifica se o resultado está dentro da escala -63 a 63
in_scale:
    mov r1, #LIMIT
    cmp r0, r1
    bge out_of_scale
    mvn r1, r1
    add r1, r1, #1
    cmp r1, r0 
    bge out_of_scale
    mov pc, lr 
;caso não esteja na escala, devolve o valor de -64 em r0
out_of_scale:
    mov r0, #OUT_OF_RANGE
    mov pc, lr
;coloca o sysclk a 0
reset_sysclk:
    ldr r0, sysclk_addr
    mov r1, #OFF
    str r1, [r0]
    mov pc, lr
;dá load ao valor da variável sysclk e devolve-0 em r0
sysclk_get_ticks:
	ldr r0 , sysclk_addr
	ldr r0, [r0]
	mov pc, lr
;função de interrupção que incrementa o valor da variável 'sysclk'
isr:
    push r0
    push r1
    ldr r0, PTC_ADDR
	strb r0, [r0, #PTC_TIR]
	ldr r0, sysclk_addr
	ldr r1, [r0]
	add r1, r1, #1
	str r1, [r0]
    pop r1
    pop r0
    movs pc, lr
;inicia o ptc, colocando o valor recebido em r0 como TMR
ptc_init:
	push lr
	push r0
	bl ptc_stop
	pop r0
	mov r1, #PTC_ADDRESS & 0xFF
    movt r1, #(PTC_ADDRESS >> 8) & 0xFF
    strb r0, [r1, #PTC_TMR]
	strb r0, [r1, #PTC_TIR]
	bl ptc_start
	pop pc
;começa a contagem do ptc
ptc_start:
	ldr	r0, PTC_ADDR
	mov	r1, #PTC_CMD_START
	strb r1, [r0, #PTC_TCR]
	mov	pc, lr
;para a contagem do ptc
ptc_stop:
	ldr	r0, PTC_ADDR
	mov	r1, #PTC_CMD_STOP
	strb r1, [r0, #PTC_TCR]
	mov	pc, lr
;vai ler o valor de contagem do ptc e devolve-o em r0
ptc_get_value:
	ldr	r1, PTC_ADDR
	ldrb r0, [r1, #PTC_TC]
	mov	pc, lr

PTC_ADDR:
	.word PTC_ADDRESS
;lê o valor do inport, devolvendo-o em r0
inport_read:
	ldr	r1, inport_addr
	ldrb r0, [r1]
	mov	pc, lr

inport_addr:
	.word INPORT_ADDRESS
;escreve o valor de r0 no outport
outport_write:
	ldr	r1, outport_addr
	strb r0, [r1]
	mov	pc, lr

outport_addr:
	.word OUTPORT_ADDRESS

sysclk_addr:
    .word sysclk

.data
sysclk:
	.word 0

.bss

    .stack
    .space STACK_SIZE
tos:
