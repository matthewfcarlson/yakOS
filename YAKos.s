TickISR:
	cli		;this is atomic so no more interrupts for a bit
	push ax
	push bx
	push dx
	push si
	push di
	push bp
	push es
	push ds
	sti;
	
	call YKTickHandler ;call the tick handler
	
	cli
	pop ds
	pop es
	pop bp
	pop di
	pop si
	pop dx
	pop bx	
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	pop ax;
	
	sti 	;return interrupts back on
	iret 	;return from interrupt
ResetISR:
	jmp main;

SwitchContext:
	;we put the address we need in a local variable
	mov sp, [bp-2]
	mov bp, sp
	sub bp, 18
	;next pop all the registers
	pop ds
	pop es
	pop bp
	pop di
	pop si
	pop dx
	pop bx
	pop ax
	iret;
	