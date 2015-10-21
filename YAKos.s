TickISR:
	cli				;this is atomic so no more interrupts for a bit
	
	
	;TODO: create a function that pushes and pops context in the same way
	push ax
	push bx
	push dx
	push si
	push di
	push bp
	push es
	push ds
	
	mov	ax, word [YKISRDepth]
	test	ax, 0
	jne TickISRSaved
						;save the SP on the TCB since we are call depth zero
	mov si, word [YKCurrentTask]
	mov [si],sp			;move sp (the first variable) to the TCB
	TickISRSaved:
						
	call YKEnterISR		;enter the ISR
	sti 				;turn interupts back on
						;call the tick handler to handle the interrupt
	call YKTickHandler 

	cli 				; Turn off interrupts
						; Reset the PIC before we pop registers
	mov	al, 0x20		; Load nonspecific EOI value (0x20) into register al
	out	0x20, al		; Write EOI to PIC (port 0x20)

	call YKExitISR		; exit the ISR	
	
	;Restore registers
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
	cli
	mov	al, 0x20		; Load nonspecific EOI value (0x20) into register al
	out	0x20, al		; Write EOI to PIC (port 0x20)
	push 3
	jmp exit;
	
KeyboardISR:
	cli
	push ax
	push bx
	push dx
	push si
	push di
	push bp
	push es
	push ds
	
	call YKEnterISR
	mov	al, 0x20		; Load nonspecific EOI value (0x20) into register al
	out	0x20, al		; Write EOI to PIC (port 0x20)
	call YKExitISR
	
	pop ds
	pop es
	pop bp
	pop di
	pop si
	pop dx
	pop bx
	pop ax
	sti;
	
	iret

;ISR for the software generated interrupts
SwitchTaskISR:
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
	mov si, word [YKCurrentTask]
	mov [si],sp			;move sp to the TCB

	mov	al, 0x20		; Load nonspecific EOI value (0x20) into register al
	out	0x20, al		; Write EOI to PIC (port 0x20)
	
	call printCurrentTask;
	;Call the scheduler
	call YKScheduler;
	jmp main			; this should never be called
	
	
SaveSPtoTCB:	
						;Save the current SP on the TCB
	mov si, word [YKCurrentTask]
	mov ax, sp			;move sp to the ax
	add ax, 2h			;add 4. 2 for the call to EnterISR, 2 for the call to save SPtoTCB
	mov [si], ax		;move the SP to the TCB
	
	ret					;return
	

;This function is callewd by the dispatcher to swtich to the current task
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
	