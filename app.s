; Generated by c86 (BYU-NASM) 5.1 (beta) from app.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
L_app_6:
	DB	"% >",0xD,0xA,0
L_app_5:
	DB	", CPU: ",0
L_app_4:
	DB	"<CS: ",0
L_app_3:
	DB	"Starting Simptris",0xA,0
L_app_2:
	DB	"Determining CPU capacity",0xD,0xA,0
L_app_1:
	DB	"Welcome to the YAK kernel",0xD,0xA,0
	ALIGN	2
STask:
	; >>>>> Line:	32
	; >>>>> { 
	jmp	L_app_7
L_app_8:
	; >>>>> Line:	36
	; >>>>> YKDelayTask(1); 
	mov	ax, 1
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	37
	; >>>>> printString("Welcome to the YAK kernel\r\n"); 
	mov	ax, L_app_1
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	38
	; >>>>> printString("Determining CPU capacity\r\n"); 
	mov	ax, L_app_2
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	39
	; >>>>> YKDelayTask(1); 
	mov	ax, 1
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	40
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	41
	; >>>>> YKDelayTask(5); 
	mov	ax, 5
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	42
	; >>>>> max = YKIdleCount / 25; 
	mov	ax, word [YKIdleCount]
	xor	dx, dx
	mov	cx, 25
	div	cx
	mov	word [bp-2], ax
	; >>>>> Line:	43
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	44
	; >>>>> printString("Starting Simptris\n"); 
	mov	ax, L_app_3
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	45
	; >>>>> StartSimptris(); 
	call	StartSimptris
	; >>>>> Line:	46
	; >>>>> YKSemPost(SimptrisReadySemPtr); 
	push	word [SimptrisReadySemPtr]
	call	YKSemPost
	add	sp, 2
	; >>>>> Line:	47
	; >>>>> while (1) 
	jmp	L_app_10
L_app_9:
	; >>>>> Line:	49
	; >>>>> YKDelayTask(20); 
	mov	ax, 20
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	51
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	52
	; >>>>> switchCount = YKCtxSwCount; 
	mov	ax, word [YKCtxSwCount]
	mov	word [bp-4], ax
	; >>>>> Line:	53
	; >>>>> idleCount = YKIdleCount; 
	mov	ax, word [YKIdleCount]
	mov	word [bp-6], ax
	; >>>>> Line:	54
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	56
	; >>>>> printString("<CS: "); 
	mov	ax, L_app_4
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	57
	; >>>>> printInt((int)switchCount); 
	push	word [bp-4]
	call	printInt
	add	sp, 2
	; >>>>> Line:	58
	; >>>>> printString(", CPU: "); 
	mov	ax, L_app_5
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	59
	; >>>>> tmp = (int) (idleCount/max); 
	mov	ax, word [bp-6]
	xor	dx, dx
	div	word [bp-2]
	mov	word [bp-8], ax
	; >>>>> Line:	60
	; >>>>> printInt(100-tmp); 
	mov	ax, 100
	sub	ax, word [bp-8]
	push	ax
	call	printInt
	add	sp, 2
	; >>>>> Line:	61
	; >>>>> printString("% >\r\n"); 
	mov	ax, L_app_6
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	63
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	64
	; >>>>> YKCtxSwCount = 0; 
	mov	word [YKCtxSwCount], 0
	; >>>>> Line:	65
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	66
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
L_app_10:
	jmp	L_app_9
L_app_11:
	mov	sp, bp
	pop	bp
	ret
L_app_7:
	push	bp
	mov	bp, sp
	sub	sp, 8
	jmp	L_app_8
L_app_15:
	DB	"Command sent",0xA,0
L_app_14:
	DB	"Sending command ",0
L_app_13:
	DB	"Waiting for command",0xA,0
	ALIGN	2
PlayerTask:
	; >>>>> Line:	71
	; >>>>> void PlayerTask(){ 
	jmp	L_app_16
L_app_17:
	; >>>>> Line:	74
	; >>>>> while(1){ 
	mov	byte [bp-1], 4
	; >>>>> Line:	74
	; >>>>> while(1){ 
	jmp	L_app_19
L_app_18:
	; >>>>> Line:	76
	; >>>>> k(){ 
	call	printTaskLists
	; >>>>> Line:	77
	; >>>>> YKSemPend(SimptrisReadySemPtr); 
	push	word [SimptrisReadySemPtr]
	call	YKSemPend
	add	sp, 2
	; >>>>> Line:	78
	; >>>>> printString("Waiting for command\n"); 
	mov	ax, L_app_13
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	80
	; >>>>> command = (int) YKQPend(CommandQPtr); 
	push	word [CommandQPtr]
	call	YKQPend
	add	sp, 2
	mov	byte [bp-1], al
	; >>>>> Line:	82
	; >>>>> printString("Sending command "); 
	mov	ax, L_app_14
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	83
	; >>>>> printInt(command); 
	mov	al, byte [bp-1]
	cbw
	push	ax
	call	printInt
	add	sp, 2
	; >>>>> Line:	84
	; >>>>> printString("\n"); 
	mov	ax, (L_app_1+26)
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	86
	; >>>>> switch(command){ 
	mov	al, byte [bp-1]
	sub	al, 4
	je	L_app_22
	inc	al
	je	L_app_23
	inc	al
	je	L_app_24
	inc	al
	je	L_app_25
	jmp	L_app_21
L_app_22:
	; >>>>> Line:	88
	; >>>>> RotatePiece(NewPieceID,1); 
	mov	ax, 1
	push	ax
	push	word [NewPieceID]
	call	RotatePiece
	add	sp, 4
	; >>>>> Line:	89
	; >>>>> break; 
	jmp	L_app_21
L_app_23:
	; >>>>> Line:	91
	; >>>>> RotatePiece(NewPieceID,0); 
	xor	ax, ax
	push	ax
	push	word [NewPieceID]
	call	RotatePiece
	add	sp, 4
	; >>>>> Line:	92
	; >>>>> break; 
	jmp	L_app_21
L_app_24:
	; >>>>> Line:	94
	; >>>>> SlidePiece(NewPieceID,0); 
	xor	ax, ax
	push	ax
	push	word [NewPieceID]
	call	SlidePiece
	add	sp, 4
	; >>>>> Line:	95
	; >>>>> break; 
	jmp	L_app_21
L_app_25:
	; >>>>> Line:	97
	; >>>>> SlidePiece(NewPieceID,1); 
	mov	ax, 1
	push	ax
	push	word [NewPieceID]
	call	SlidePiece
	add	sp, 4
L_app_21:
	; >>>>> Line:	100
	; >>>>> printString("Command sent\n"); 
	mov	ax, L_app_15
	push	ax
	call	printString
	add	sp, 2
L_app_19:
	jmp	L_app_18
L_app_20:
	mov	sp, bp
	pop	bp
	ret
L_app_16:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_app_17
L_app_27:
	DB	"Brain is thinking",0xA,0
	ALIGN	2
BrainTask:
	; >>>>> Line:	105
	; >>>>> void BrainTask(){ 
	jmp	L_app_28
L_app_29:
	; >>>>> Line:	106
	; >>>>> mandQP 
	jmp	L_app_31
L_app_30:
	; >>>>> Line:	108
	; >>>>> YKSemPend(SimptrisPieceSemPtr); 
	push	word [SimptrisPieceSemPtr]
	call	YKSemPend
	add	sp, 2
	; >>>>> Line:	109
	; >>>>> printString("Brain is thinking\n"); 
	mov	ax, L_app_27
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	110
	; >>>>> YKQPost(CommandQPtr,(void*) 2 ); 
	mov	ax, 2
	push	ax
	push	word [CommandQPtr]
	call	YKQPost
	add	sp, 4
	; >>>>> Line:	111
	; >>>>> YKQPost(CommandQPtr,(void*) 2 ); 
	mov	ax, 2
	push	ax
	push	word [CommandQPtr]
	call	YKQPost
	add	sp, 4
	; >>>>> Line:	112
	; >>>>> YKQPost(CommandQPtr,(void*) 2 ); 
	mov	ax, 2
	push	ax
	push	word [CommandQPtr]
	call	YKQPost
	add	sp, 4
L_app_31:
	jmp	L_app_30
L_app_32:
	mov	sp, bp
	pop	bp
	ret
L_app_28:
	push	bp
	mov	bp, sp
	jmp	L_app_29
	ALIGN	2
main:
	; >>>>> Line:	118
	; >>>>> { 
	jmp	L_app_34
L_app_35:
	; >>>>> Line:	119
	; >>>>> YKInitialize(); 
	call	YKInitialize
	; >>>>> Line:	123
	; >>>>> YKNewTask(STask, (void *) &STaskStk[ 512 ], 0); 
	xor	ax, ax
	push	ax
	mov	ax, (STaskStk+1024)
	push	ax
	mov	ax, STask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	124
	; >>>>> YKNewTask(PlayerTask, (void *) &PlayerTaskStk[ 512 ], 1); 
	mov	ax, 1
	push	ax
	mov	ax, (PlayerTaskStk+1024)
	push	ax
	mov	ax, PlayerTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	125
	; >>>>> YKNewTask(BrainTask, (void *) &BrainTaskStk[ 512 ], 2); 
	mov	ax, 2
	push	ax
	mov	ax, (BrainTaskStk+1024)
	push	ax
	mov	ax, BrainTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	127
	; >>>>> SeedSimptris(100); 
	mov	ax, 100
	push	ax
	call	SeedSimptris
	add	sp, 2
	; >>>>> Line:	129
	; >>>>> SimptrisReadySemPtr = YKSemCreate(0); 
	xor	ax, ax
	push	ax
	call	YKSemCreate
	add	sp, 2
	mov	word [SimptrisReadySemPtr], ax
	; >>>>> Line:	130
	; >>>>> SimptrisPieceSemPtr = YKSemCreate(0); 
	xor	ax, ax
	push	ax
	call	YKSemCreate
	add	sp, 2
	mov	word [SimptrisPieceSemPtr], ax
	; >>>>> Line:	131
	; >>>>> CommandQP 
	mov	ax, 8
	push	ax
	mov	ax, CommandQueue
	push	ax
	call	YKQCreate
	add	sp, 4
	mov	word [CommandQPtr], ax
	; >>>>> Line:	133
	; >>>>> YKRun(); 
	call	YKRun
	mov	sp, bp
	pop	bp
	ret
L_app_34:
	push	bp
	mov	bp, sp
	jmp	L_app_35
	ALIGN	2
STaskStk:
	TIMES	1024 db 0
PlayerTaskStk:
	TIMES	1024 db 0
BrainTaskStk:
	TIMES	1024 db 0
SimptrisReadySemPtr:
	TIMES	2 db 0
SimptrisPieceSemPtr:
	TIMES	2 db 0
CommandQueue:
	TIMES	16 db 0
CommandQPtr:
	TIMES	2 db 0
