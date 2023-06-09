.equ RESULT, 0xFE
.equ AVG_TIME, 200
.equ OUTPORT_ADDRESS, 0xFFC0


get_result:
    push lr
    bl ptc_stop
    bl sysclk_get_ticks
    mov r2, #AVG_TIME
    cmp r2, r0
    blt higher_than_avg
    bl lower_than_avg
    bl show_result
    pop pc

higher_than_avg:
    sub r0, r2, r0
    bl show_result
    pop pc

lower_than_avg:
    sub r0, r2, r0
    mvn r0, r0
    add r0, r0, #1
    mov r1, #63
    cmp r0, r1
    
    mov pc, lr
    
show_result:
    push lr
    lsl r0, r0, #1
    bl outport_write
    bl reset_sysclk
    mov r0, #5
    bl delay
    pop pc

outport_write:
	ldr	r1, outport_addr
	strb	r0, [r1, #0]
	mov	pc, lr

outport_addr:
	.word	OUTPORT_ADDRESS
