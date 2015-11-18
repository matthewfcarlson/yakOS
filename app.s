; Generated by c86 (BYU-NASM) 5.1 (beta) from app.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
L_app_5:
	DB	"CharTask     (C)",0xA,0
L_app_4:
	DB	"CharTask     (B)",0xA,0
L_app_3:
	DB	"CharTask     (A)",0xA,0
L_app_2:
	DB	"Oops! At least one event should be set in return value!",0xA,0
L_app_1:
	DB	"Started CharTask     (2)",0xA,0
	ALIGN	2
CharTask:
	; >>>>> Line:	23
	; >>>>> { 
	jmp	L_app_6
L_app_7:
	; >>>>> Line:	26
	; >>>>> printString("Started CharTask     (2)\n"); 
	mov	ax, L_app_1
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	28
	; >>>>> while(1) { 
	jmp	L_app_9
L_app_8:
	; >>>>> Line:	29
	; >>>>> events = YKEventPend(charEvent, 
	mov	ax, 8
	push	ax
	mov	ax, 7
	push	ax
	push	word [charEvent]
	call	YKEventPend
	add	sp, 6
	mov	word [bp-2], ax
	; >>>>> Line:	33
	; >>>>> cha 
	mov	ax, word [bp-2]
	test	ax, ax
	jne	L_app_11
	; >>>>> Line:	34
	; >>>>> printString("Oops! At least one event should be set " 
	mov	ax, L_app_2
	push	ax
	call	printString
	add	sp, 2
L_app_11:
	; >>>>> Line:	38
	; >>>>> if(events &  0x1 ) { 
	mov	ax, word [bp-2]
	and	ax, 1
	je	L_app_12
	; >>>>> Line:	39
	; >>>>> printString("CharTask     (A)\n"); 
	mov	ax, L_app_3
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	40
	; >>>>> YKEventReset(charEvent,  0x1 ); 
	mov	ax, 1
	push	ax
	push	word [charEvent]
	call	YKEventReset
	add	sp, 4
L_app_12:
	; >>>>> Line:	43
	; >>>>> if(events &  0x2 ) { 
	mov	ax, word [bp-2]
	and	ax, 2
	je	L_app_13
	; >>>>> Line:	44
	; >>>>> printString("CharTask     (B)\n"); 
	mov	ax, L_app_4
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	45
	; >>>>> YKEventReset(charEvent,  0x2 ); 
	mov	ax, 2
	push	ax
	push	word [charEvent]
	call	YKEventReset
	add	sp, 4
L_app_13:
	; >>>>> Line:	48
	; >>>>> if(events &  0x4 ) { 
	mov	ax, word [bp-2]
	and	ax, 4
	je	L_app_14
	; >>>>> Line:	49
	; >>>>> printString("CharTask     (C)\n"); 
	mov	ax, L_app_5
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	50
	; >>>>> YKEventReset(cha 
	mov	ax, 4
	push	ax
	push	word [charEvent]
	call	YKEventReset
	add	sp, 4
L_app_14:
L_app_9:
	jmp	L_app_8
L_app_10:
	mov	sp, bp
	pop	bp
	ret
L_app_6:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_app_7
L_app_18:
	DB	"AllCharsTask (D)",0xA,0
L_app_17:
	DB	"Oops! Char events weren't reset by CharTask!",0xA,0
L_app_16:
	DB	"Started AllCharsTask (3)",0xA,0
	ALIGN	2
AllCharsTask:
	; >>>>> Line:	57
	; >>>>> { 
	jmp	L_app_19
L_app_20:
	; >>>>> Line:	60
	; >>>>> printString("Started AllCharsTask (3)\n"); 
	mov	ax, L_app_16
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	62
	; >>>>> while(1) { 
	jmp	L_app_22
L_app_21:
	; >>>>> Line:	63
	; >>>>> events = YKEventPend(charEvent, 
	mov	ax, 16
	push	ax
	mov	ax, 7
	push	ax
	push	word [charEvent]
	call	YKEventPend
	add	sp, 6
	mov	word [bp-2], ax
	; >>>>> Line:	68
	; >>>>> if(events != 0) { 
	mov	ax, word [bp-2]
	test	ax, ax
	je	L_app_24
	; >>>>> Line:	69
	; >>>>> printString("Oops! Char events weren't reset by CharTask!\n"); 
	mov	ax, L_app_17
	push	ax
	call	printString
	add	sp, 2
L_app_24:
	; >>>>> Line:	72
	; >>>>> printString("AllCharsTask (D)\n"); 
	mov	ax, L_app_18
	push	ax
	call	printString
	add	sp, 2
L_app_22:
	jmp	L_app_21
L_app_23:
	mov	sp, bp
	pop	bp
	ret
L_app_19:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_app_20
L_app_28:
	DB	"AllNumsTask  (123)",0xA,0
L_app_27:
	DB	"Oops! All events should be set in return value!",0xA,0
L_app_26:
	DB	"Started AllNumsTask  (1)",0xA,0
	ALIGN	2
AllNumsTask:
	; >>>>> Line:	78
	; >>>>> { 
	jmp	L_app_29
L_app_30:
	; >>>>> Line:	81
	; >>>>> printString("Starte 
	mov	ax, L_app_26
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	83
	; >>>>> while(1) { 
	jmp	L_app_32
L_app_31:
	; >>>>> Line:	84
	; >>>>> events = YKEventPend(numEvent, 
	mov	ax, 16
	push	ax
	mov	ax, 7
	push	ax
	push	word [numEvent]
	call	YKEventPend
	add	sp, 6
	mov	word [bp-2], ax
	; >>>>> Line:	88
	; >>>>> if(events != ( 0x1  |  0x2  |  0x4 )) { 
	cmp	word [bp-2], 7
	je	L_app_34
	; >>>>> Line:	89
	; >>>>> printString("Oops! All events should be set in return value!\n"); 
	mov	ax, L_app_27
	push	ax
	call	printString
	add	sp, 2
L_app_34:
	; >>>>> Line:	92
	; >>>>> printString("AllNumsTask  (123)\n"); 
	mov	ax, L_app_28
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	94
	; >>>>> YKEventReset(numEvent,  0x1  |  0x2  |  0x4 ); 
	mov	ax, 7
	push	ax
	push	word [numEvent]
	call	YKEventReset
	add	sp, 4
L_app_32:
	jmp	L_app_31
L_app_33:
	mov	sp, bp
	pop	bp
	ret
L_app_29:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_app_30
L_app_40:
	DB	"% >>>>>",0xD,0xA,0
L_app_39:
	DB	", CPU usage: ",0
L_app_38:
	DB	"<<<<< Context switches: ",0
L_app_37:
	DB	"Determining CPU capacity",0xD,0xA,0
L_app_36:
	DB	"Welcome to the YAK kernel",0xD,0xA,0
	ALIGN	2
STask:
	; >>>>> Line:	100
	; >>>>> { 
	jmp	L_app_41
L_app_42:
	; >>>>> Line:	104
	; >>>>> YKDelayTask(1); 
	mov	ax, 1
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	105
	; >>>>>  
	mov	ax, L_app_36
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	106
	; >>>>> printString("Determining CPU capacity\r\n"); 
	mov	ax, L_app_37
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	107
	; >>>>> YKDelayTask(1); 
	mov	ax, 1
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	108
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	109
	; >>>>> YKDelayTask(5); 
	mov	ax, 5
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	110
	; >>>>> max = YKIdleCount / 25; 
	mov	ax, word [YKIdleCount]
	xor	dx, dx
	mov	cx, 25
	div	cx
	mov	word [bp-2], ax
	; >>>>> Line:	111
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	113
	; >>>>> YKNewTask(CharTask, (void *) &CharTaskStk[ 512 ], 2); 
	mov	ax, 2
	push	ax
	mov	ax, (CharTaskStk+1024)
	push	ax
	mov	ax, CharTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	114
	; >>>>> YKNewTask(AllNumsTask, (void *) &AllNumsTaskStk[ 512 ], 1); 
	mov	ax, 1
	push	ax
	mov	ax, (AllNumsTaskStk+1024)
	push	ax
	mov	ax, AllNumsTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	115
	; >>>>> YKNewTask(AllCharsTask, (void *) &AllCharsTaskStk[ 512 ], 3); 
	mov	ax, 3
	push	ax
	mov	ax, (AllCharsTaskStk+1024)
	push	ax
	mov	ax, AllCharsTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	117
	; >>>>> while (1) 
	jmp	L_app_44
L_app_43:
	; >>>>> Line:	119
	; >>>>> YKDelayTask(20); 
	mov	ax, 20
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	121
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	122
	; >>>>> switchCount = YKCtxSwCount; 
	mov	ax, word [YKCtxSwCount]
	mov	word [bp-4], ax
	; >>>>> Line:	123
	; >>>>> sk, (voi 
	mov	ax, word [YKIdleCount]
	mov	word [bp-6], ax
	; >>>>> Line:	124
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	126
	; >>>>> printString("<<<<< Context switches: "); 
	mov	ax, L_app_38
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	127
	; >>>>> printInt((int)switchCount); 
	push	word [bp-4]
	call	printInt
	add	sp, 2
	; >>>>> Line:	128
	; >>>>> printString(", CPU usage: "); 
	mov	ax, L_app_39
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	129
	; >>>>> tmp = (int) (idleCount/max); 
	mov	ax, word [bp-6]
	xor	dx, dx
	div	word [bp-2]
	mov	word [bp-8], ax
	; >>>>> Line:	130
	; >>>>> printInt(100-tmp); 
	mov	ax, 100
	sub	ax, word [bp-8]
	push	ax
	call	printInt
	add	sp, 2
	; >>>>> Line:	131
	; >>>>> printString("% >>>>>\r\n"); 
	mov	ax, L_app_40
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	133
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	134
	; >>>>> YKCtxSwCount = 0; 
	mov	word [YKCtxSwCount], 0
	; >>>>> Line:	135
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	136
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
L_app_44:
	jmp	L_app_43
L_app_45:
	mov	sp, bp
	pop	bp
	ret
L_app_41:
	push	bp
	mov	bp, sp
	sub	sp, 8
	jmp	L_app_42
	ALIGN	2
main:
	; >>>>> Line:	142
	; >>>>> { 
	jmp	L_app_47
L_app_48:
	; >>>>> Line:	143
	; >>>>> YKInitialize(); 
	call	YKInitialize
	; >>>>> Line:	145
	; >>>>> charEvent = YKEventCreate(0); 
	xor	ax, ax
	push	ax
	call	YKEventCreate
	add	sp, 2
	mov	word [charEvent], ax
	; >>>>> Line:	146
	; >>>>> numEvent = YKEventCreate(0); 
	xor	ax, ax
	push	ax
	call	YKEventCreate
	add	sp, 2
	mov	word [numEvent], ax
	; >>>>> Line:	147
	; >>>>> YKNewTask(STask, (voi 
	xor	ax, ax
	push	ax
	mov	ax, (STaskStk+1024)
	push	ax
	mov	ax, STask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	149
	; >>>>> YKRun(); 
	call	YKRun
	mov	sp, bp
	pop	bp
	ret
L_app_47:
	push	bp
	mov	bp, sp
	jmp	L_app_48
	ALIGN	2
charEvent:
	TIMES	2 db 0
numEvent:
	TIMES	2 db 0
CharTaskStk:
	TIMES	1024 db 0
AllCharsTaskStk:
	TIMES	1024 db 0
AllNumsTaskStk:
	TIMES	1024 db 0
STaskStk:
	TIMES	1024 db 0
