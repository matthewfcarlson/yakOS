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
	test	ax, ax ;Not siure why ax,ax
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
	mov ax, 3h
	push ax
	call exit
	
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
	
	mov	ax, word [YKISRDepth]
	test	ax, ax
	jne KeyboardISRSaved ;save the SP on the TCB since we are call depth zero
	mov si, word [YKCurrentTask]
	mov [si],sp			;move sp (the first variable) to the TCB
	KeyboardISRSaved:

	call YKEnterISR
	sti
	
	call KeyboardHandler

	cli
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
	sti
	
	iret

;ISR for the software generated interrupts
SwitchTaskISR:
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
	
	;Save the current SP on the TCB
	mov si, word [YKCurrentTask]
	mov [si],sp			;move sp to the TCB

	mov	al, 0x20		; Load nonspecific EOI value (0x20) into register al
	out	0x20, al		; Write EOI to PIC (port 0x20)
	
	;Call the scheduler
	call YKScheduler
	pop ds
	pop es
	pop bp
	pop di
	pop si
	pop dx
	pop bx
	pop ax
	sti
	iret;
	
	
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
	
	;This is not neccesary so commented out for performance boost
	;mov bp, sp ;set the basepointer accordingly - we are going to pop it soon
	;add bp, 18 ;for debugging purposes
	
	;next pop all the registers
	pop ds
	pop es
	pop bp
	pop di
	pop si
	pop dx
	pop bx
	pop ax
	
	;This will pop the next three items on the stack: IP, CS, and flags
	iret
STGameOver:
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
	sti
	
	call STGameOverHandler

	cli
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
	sti
	
	iret
	
STNewPiece:
	cli
	push ax
	push bx
	push dx
	push si
	push di
	push bp
	push es
	push ds
	
	mov	ax, word [YKISRDepth]
	test	ax, ax
	jne STNewPieceISRSaved	;save the SP on the TCB since we are call depth zero
	mov si, word [YKCurrentTask]
	mov [si],sp				;move sp (the first variable) to the TCB
	STNewPieceISRSaved:

	call YKEnterISR
	sti
	
	call STNewPieceHandler

	cli
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
	sti
	
	iret
	
STReceived:
	cli
	push ax
	push bx
	push dx
	push si
	push di
	push bp
	push es
	push ds
	
	mov	ax, word [YKISRDepth]
	test	ax, ax
	jne STRecievedISRSaved	;save the SP on the TCB since we are call depth zero
	mov si, word [YKCurrentTask]
	mov [si],sp				;move sp (the first variable) to the TCB
	STRecievedISRSaved:

	call YKEnterISR
	sti
	
	call STReceivedHandler

	cli
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
	sti
	
	iret
	
STTouchdown:
	cli
	push ax
	push bx
	push dx
	push si
	push di
	push bp
	push es
	push ds
	
	mov	ax, word [YKISRDepth]
	test	ax, ax
	jne STTouchdownISRSaved	;save the SP on the TCB since we are call depth zero
	mov si, word [YKCurrentTask]
	mov [si],sp				;move sp (the first variable) to the TCB
	STTouchdownISRSaved:

	call YKEnterISR
	sti
	
	call STTouchdownHandler

	cli
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
	sti
	
	iret
	
STClear:
	push ax
	mov	al, 0x20		; Load nonspecific EOI value (0x20) into register al
	out	0x20, al		; Write EOI to PIC (port 0x20)
	pop ax
	reti
	
	cli
	push ax
	push bx
	push dx
	push si
	push di
	push bp
	push es
	push ds
	
	mov	ax, word [YKISRDepth]
	test	ax, ax
	jne STClearISRSaved	;save the SP on the TCB since we are call depth zero
	mov si, word [YKCurrentTask]
	mov [si],sp				;move sp (the first variable) to the TCB
	
	STClearISRSaved:

	call YKEnterISR
	sti
	
	;call STClearHandler

	cli
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
	sti
	
	iret
