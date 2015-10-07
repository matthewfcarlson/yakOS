TickISR:
	cli				;this is atomic so no more interrupts for a bit
	
	;TODO save the SP to the current task TCB
	;TODO: create a function that pushes and pops context in the same way
	push ax
	push bx
	push dx
	push si
	push di
	push bp
	push es
	push ds
	sti;
	
	
	
	;call the tick handler to handle the interrupt
	call YKTickHandler 
	
	cli
					; Reset the PIC before we pop registers
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	
	pop ds
	pop es
	pop bp
	pop di
	pop si
	pop dx
	pop bx
	pop ax	
	
	sti 	;return interrupts back on
	iret 	;return from interrupt
	
ResetISR:
	jmp main;
	
KeyboardISR:
	iret;
	
SwitchTask:
	cli				;this is atomic so no more interrupts for a bit
	
	;TODO save the SP to the current task TCB
	;TODO: create a function that pushes and pops context in the same way
	push ax
	push bx
	push dx
	push si
	push di
	push bp
	push es
	push ds
	;Save the current SP on the TCB
	
	;Call the scheduler
	call YKScheduler;
	

SwitchContext:
	;we put the address we need in a local variable in YKDispatch
	mov sp, [bp-2] ;this is the stack pointer
	mov bp, sp ;set the basepointer accordingly - we are going to pop it soon
	add bp, 18 ;for debugging purposes
	
	;next pop all the registers
	pop ds
	pop es
	pop bp
	pop di
	pop si
	pop dx
	pop bx
	pop ax
RestoreContext:
	;This will pop the next three registers: IP, CS, and flags
	iret;
	