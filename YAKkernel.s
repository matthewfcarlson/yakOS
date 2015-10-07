; Generated by c86 (BYU-NASM) 5.1 (beta) from YAKkernel.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
	ALIGN	2
YKInitialize:
	; >>>>> Line:	38
	; >>>>> void YKInitialize(){ 
	jmp	L_YAKkernel_1
L_YAKkernel_2:
	; >>>>> Line:	39
	; >>>>> er(); 
	call	YKEnterMutex
	; >>>>> Line:	40
	; >>>>> YKCtxSwCount = 0; 
	mov	word [YKCtxSwCount], 0
	; >>>>> Line:	41
	; >>>>> YKISRDepth = 0; 
	mov	word [YKISRDepth], 0
	; >>>>> Line:	42
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	43
	; >>>>> YKReadyTasks =  0 ; 
	mov	word [YKReadyTasks], 0
	; >>>>> Line:	44
	; >>>>> YKSuspendedTasks =  0 ; 
	mov	word [YKSuspendedTasks], 0
	; >>>>> Line:	45
	; >>>>> YKAllTasks =  0 ; 
	mov	word [YKAllTasks], 0
	; >>>>> Line:	46
	; >>>>> YKCurrentTask =  0 ; 
	mov	word [YKCurrentTask], 0
	; >>>>> Line:	47
	; >>>>> YKTCBMallocIndex = 0; 
	mov	word [YKTCBMallocIndex], 0
	; >>>>> Line:	48
	; >>>>> YKIsRunning = 0; 
	mov	word [YKIsRunning], 0
	; >>>>> Line:	51
	; >>>>> YKNewTask(YKIdleTask, &IdleStack[ 100 ],255); 
	mov	ax, 255
	push	ax
	mov	ax, (IdleStack+200)
	push	ax
	mov	ax, YKIdleTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	52
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_1:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_2
	ALIGN	2
YKEnterMutex:
	; >>>>> Line:	56
	; >>>>> void YKEnterMutex(){ 
	jmp	L_YAKkernel_4
L_YAKkernel_5:
	; >>>>> Line:	57
	; >>>>> asm("cli"); 
	cli
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_4:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_5
	ALIGN	2
YKExitMutex:
	; >>>>> Line:	61
	; >>>>> void YKExitMutex(){ 
	jmp	L_YAKkernel_7
L_YAKkernel_8:
	; >>>>> Line:	62
	; >>>>> asm("sti"); 
	sti
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_7:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_8
	ALIGN	2
YKEnterISR:
	; >>>>> Line:	66
	; >>>>> void YKEnterISR(){ 
	jmp	L_YAKkernel_10
L_YAKkernel_11:
	; >>>>> Line:	68
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	69
	; >>>>> ++YKISRDepth; 
	inc	word [YKISRDepth]
	; >>>>> Line:	70
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_10:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_11
	ALIGN	2
YKExitISR:
	; >>>>> Line:	74
	; >>>>> void YKExitISR(){ 
	jmp	L_YAKkernel_13
L_YAKkernel_14:
	; >>>>> Line:	75
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	76
	; >>>>> --YKISRDepth; 
	dec	word [YKISRDepth]
	; >>>>> Line:	79
	; >>>>> if (YKISRDepth == 0){ 
	mov	ax, word [YKISRDepth]
	test	ax, ax
	jne	L_YAKkernel_15
	; >>>>> Line:	81
	; >>>>> YKScheduler(); 
	call	YKScheduler
L_YAKkernel_15:
	; >>>>> Line:	84
	; >>>>> kSP); 
	call	YKExitMutex
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_13:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_14
	ALIGN	2
YKIdleTask:
	; >>>>> Line:	88
	; >>>>> void YKIdleTask(){ 
	jmp	L_YAKkernel_17
L_YAKkernel_18:
	; >>>>> Line:	90
	; >>>>> while(1){ 
	mov	word [bp-2], 0
	; >>>>> Line:	90
	; >>>>> while(1){ 
	jmp	L_YAKkernel_20
L_YAKkernel_19:
	; >>>>> Line:	91
	; >>>>> for (i = 0; i< 5000; i++); 
	mov	word [bp-2], 0
	jmp	L_YAKkernel_23
L_YAKkernel_22:
L_YAKkernel_25:
	inc	word [bp-2]
L_YAKkernel_23:
	cmp	word [bp-2], 5000
	jl	L_YAKkernel_22
L_YAKkernel_24:
	; >>>>> Line:	92
	; >>>>> ++YKIdleCount; 
	inc	word [YKIdleCount]
L_YAKkernel_20:
	jmp	L_YAKkernel_19
L_YAKkernel_21:
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_17:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_YAKkernel_18
L_YAKkernel_28:
	DB	0xA,"SP at 0x",0
L_YAKkernel_27:
	DB	0xA,"BP at 0x",0
	ALIGN	2
YKNewTask:
	; >>>>> Line:	97
	; >>>>> void YKNewTask(void* taskFunc, void* taskStack, int priority){ 
	jmp	L_YAKkernel_29
L_YAKkernel_30:
	; >>>>> Line:	100
	; >>>>> ++YKTCBMallocIndex; 
	mov	ax, word [YKTCBMallocIndex]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBs
	mov	word [bp-2], ax
	mov	ax, word [bp+6]
	mov	word [bp-4], ax
	; >>>>> Line:	100
	; >>>>> ++YKTCBMallocIndex; 
	inc	word [YKTCBMallocIndex]
	; >>>>> Line:	103
	; >>>>> printString("\nBP at 0x"); 
	mov	ax, L_YAKkernel_27
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	104
	; >>>>> printWord((int)taskStack); 
	push	word [bp+6]
	call	printWord
	add	sp, 2
	; >>>>> Line:	107
	; >>>>> *(newStackSP) =  64 ; 
	mov	si, word [bp-4]
	mov	word [si], 64
	; >>>>> Line:	108
	; >>>>> newStackSP -= 1; 
	sub	word [bp-4], 2
	; >>>>> Line:	109
	; >>>>> *(newStackSP) = 0; 
	mov	si, word [bp-4]
	mov	word [si], 0
	; >>>>> Line:	110
	; >>>>> newStackSP -= 1; 
	sub	word [bp-4], 2
	; >>>>> Line:	111
	; >>>>> *(newStackSP) = (int)taskFunc; 
	mov	si, word [bp-4]
	mov	ax, word [bp+4]
	mov	word [si], ax
	; >>>>> Line:	112
	; >>>>> newStackSP -= 8; 
	sub	word [bp-4], 16
	; >>>>> Line:	113
	; >>>>> printString("\nSP at 0x"); 
	mov	ax, L_YAKkernel_28
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	114
	; >>>>> printWord((int)newStackSP); 
	push	word [bp-4]
	call	printWord
	add	sp, 2
	; >>>>> Line:	115
	; >>>>> newT 
	mov	si, word [bp-2]
	mov	ax, word [bp-4]
	mov	word [si], ax
	; >>>>> Line:	119
	; >>>>> newTask->priority = priority; 
	mov	si, word [bp-2]
	add	si, 4
	mov	ax, word [bp+8]
	mov	word [si], ax
	; >>>>> Line:	120
	; >>>>> newTask->next =  0 ; 
	mov	si, word [bp-2]
	add	si, 8
	mov	word [si], 0
	; >>>>> Line:	121
	; >>>>> newTask->prev =  0 ; 
	mov	si, word [bp-2]
	add	si, 10
	mov	word [si], 0
	; >>>>> Line:	124
	; >>>>> YKAddToReadyList(newTask); 
	push	word [bp-2]
	call	YKAddToReadyList
	add	sp, 2
	; >>>>> Line:	125
	; >>>>> if (YKIsRunning) 
	mov	ax, word [YKIsRunning]
	test	ax, ax
	je	L_YAKkernel_31
	; >>>>> Line:	126
	; >>>>> YKScheduler(); 
	call	YKScheduler
L_YAKkernel_31:
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_29:
	push	bp
	mov	bp, sp
	sub	sp, 4
	jmp	L_YAKkernel_30
L_YAKkernel_33:
	DB	"Starting Yak OS (c) 2015",0xA,0
	ALIGN	2
YKRun:
	; >>>>> Line:	129
	; >>>>> void YKRun(){ 
	jmp	L_YAKkernel_34
L_YAKkernel_35:
	; >>>>> Line:	130
	; >>>>> printString("Starting Yak OS (c) 2015\n"); 
	mov	ax, L_YAKkernel_33
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	131
	; >>>>> YKIsRunning = 1; 
	mov	word [YKIsRunning], 1
	; >>>>> Line:	132
	; >>>>> YKScheduler(); 
	call	YKScheduler
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_34:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_35
L_YAKkernel_37:
	DB	"Scheduler",0xA,0
	ALIGN	2
YKScheduler:
	; >>>>> Line:	137
	; >>>>> void YKScheduler(){ 
	jmp	L_YAKkernel_38
L_YAKkernel_39:
	; >>>>> Line:	138
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	139
	; >>>>> printString("Scheduler\n"); 
	mov	ax, L_YAKkernel_37
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	140
	; >>>>> printTCB(YKReadyTasks); 
	push	word [YKReadyTasks]
	call	printTCB
	add	sp, 2
	; >>>>> Line:	142
	; >>>>> if (YKReadyTasks != YKCurrentTask){ 
	mov	ax, word [YKCurrentTask]
	cmp	ax, word [YKReadyTasks]
	je	L_YAKkernel_40
	; >>>>> Line:	144
	; >>>>> YKCurrentTask = YKReadyTasks; 
	mov	ax, word [YKReadyTasks]
	mov	word [YKCurrentTask], ax
	; >>>>> Line:	145
	; >>>>> ++YKCtxSwCount; 
	inc	word [YKCtxSwCount]
	; >>>>> Line:	146
	; >>>>> YKDispatcher(); 
	call	YKDispatcher
L_YAKkernel_40:
	; >>>>> Line:	148
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_38:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_39
	ALIGN	2
YKDispatcher:
	; >>>>> Line:	152
	; >>>>>  
	jmp	L_YAKkernel_42
L_YAKkernel_43:
	; >>>>> Line:	155
	; >>>>> SwitchContext(); 
	mov	si, word [YKCurrentTask]
	mov	ax, word [si]
	mov	word [bp-2], ax
	; >>>>> Line:	155
	; >>>>> SwitchContext(); 
	call	SwitchContext
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_42:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_YAKkernel_43
	ALIGN	2
L_YAKkernel_45:
	DW	0
L_YAKkernel_47:
	DB	0xA,0
L_YAKkernel_46:
	DB	0xA,"Tick ",0
	ALIGN	2
YKTickHandler:
	; >>>>> Line:	160
	; >>>>> void YKTickHandler(){ 
	jmp	L_YAKkernel_48
L_YAKkernel_49:
	; >>>>> Line:	164
	; >>>>> ++tickCount; 
	mov	ax, word [YKSuspendedTasks]
	mov	word [bp-2], ax
	; >>>>> Line:	164
	; >>>>> ++tickCount; 
	inc	word [L_YAKkernel_45]
	; >>>>> Line:	165
	; >>>>> printString("\nTick "); 
	mov	ax, L_YAKkernel_46
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	166
	; >>>>> printInt(tickCount); 
	push	word [L_YAKkernel_45]
	call	printInt
	add	sp, 2
	; >>>>> Line:	167
	; >>>>> printString("\n"); 
	mov	ax, L_YAKkernel_47
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	169
	; >>>>> while (currTCB !=  0 ){ 
	jmp	L_YAKkernel_51
L_YAKkernel_50:
	; >>>>> Line:	170
	; >>>>> --currTCB->delayTicks; 
	mov	si, word [bp-2]
	add	si, 6
	dec	word [si]
	; >>>>> Line:	172
	; >>>>> if (currTCB->delayTicks == 0){ 
	mov	si, word [bp-2]
	add	si, 6
	mov	ax, word [si]
	test	ax, ax
	jne	L_YAKkernel_53
	; >>>>> Line:	174
	; >>>>> YKRemoveFromList(currTCB); 
	push	word [bp-2]
	call	YKRemoveFromList
	add	sp, 2
	; >>>>> Line:	175
	; >>>>> YKAddToReadyList(currTCB); 
	push	word [bp-2]
	call	YKAddToReadyList
	add	sp, 2
L_YAKkernel_53:
	; >>>>> Line:	177
	; >>>>> currTCB = currTCB->next; 
	mov	si, word [bp-2]
	add	si, 8
	mov	ax, word [si]
	mov	word [bp-2], ax
L_YAKkernel_51:
	mov	ax, word [bp-2]
	test	ax, ax
	jne	L_YAKkernel_50
L_YAKkernel_52:
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_48:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_YAKkernel_49
	ALIGN	2
YKAddToReadyList:
	; >>>>> Line:	183
	; >>>>> void YKAddToReadyList(TCBp newTask){ 
	jmp	L_YAKkernel_55
L_YAKkernel_56:
	; >>>>> Line:	187
	; >>>>> if (YKReadyTasks ==  0 ) 
	mov	si, word [bp+4]
	add	si, 4
	mov	ax, word [si]
	mov	word [bp-2], ax
	mov	ax, word [YKReadyTasks]
	mov	word [bp-4], ax
	; >>>>> Line:	187
	; >>>>> if (YKReadyTasks ==  0 ) 
	mov	ax, word [YKReadyTasks]
	test	ax, ax
	jne	L_YAKkernel_57
	; >>>>> Line:	188
	; >>>>> YKReadyTasks = newTask; 
	mov	ax, word [bp+4]
	mov	word [YKReadyTasks], ax
	jmp	L_YAKkernel_58
L_YAKkernel_57:
	; >>>>> Line:	190
	; >>>>> else if (YKReadyTasks->priority > priority){ 
	mov	si, word [YKReadyTasks]
	add	si, 4
	mov	ax, word [bp-2]
	cmp	ax, word [si]
	jge	L_YAKkernel_59
	; >>>>> Line:	191
	; >>>>> newTask->next = YKReadyTasks; 
	mov	si, word [bp+4]
	add	si, 8
	mov	ax, word [YKReadyTasks]
	mov	word [si], ax
	; >>>>> Line:	192
	; >>>>> YKReadyTasks = newTask; 
	mov	ax, word [bp+4]
	mov	word [YKReadyTasks], ax
	jmp	L_YAKkernel_60
L_YAKkernel_59:
	; >>>>> Line:	197
	; >>>>> while (taskListPtr->next !=  0  && taskListPtr->next->priority > priority){ 
	jmp	L_YAKkernel_62
L_YAKkernel_61:
	; >>>>> Line:	198
	; >>>>> taskListPtr = taskListPtr -> next; 
	mov	si, word [bp-4]
	add	si, 8
	mov	ax, word [si]
	mov	word [bp-4], ax
L_YAKkernel_62:
	mov	si, word [bp-4]
	add	si, 8
	mov	ax, word [si]
	test	ax, ax
	je	L_YAKkernel_64
	mov	si, word [bp-4]
	add	si, 8
	mov	si, word [si]
	add	si, 4
	mov	ax, word [bp-2]
	cmp	ax, word [si]
	jl	L_YAKkernel_61
L_YAKkernel_64:
L_YAKkernel_63:
	; >>>>> Line:	201
	; >>>>> newTask-> next = taskListPtr -> next; 
	mov	si, word [bp-4]
	add	si, 8
	mov	di, word [bp+4]
	add	di, 8
	mov	ax, word [si]
	mov	word [di], ax
	; >>>>> Line:	202
	; >>>>> taskListPtr->next = newTask; 
	mov	si, word [bp-4]
	add	si, 8
	mov	ax, word [bp+4]
	mov	word [si], ax
L_YAKkernel_60:
L_YAKkernel_58:
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_55:
	push	bp
	mov	bp, sp
	sub	sp, 4
	jmp	L_YAKkernel_56
	ALIGN	2
YKAddToSuspendedList:
	; >>>>> Line:	206
	; >>>>> void YKAddToSuspendedList(TCBp task){ 
	jmp	L_YAKkernel_66
L_YAKkernel_67:
	; >>>>> Line:	208
	; >>>>> } 
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_66:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_67
	ALIGN	2
YKRemoveFromList:
	; >>>>> Line:	211
	; >>>>> void YKRemoveFromList(TCBp task){ 
	jmp	L_YAKkernel_69
L_YAKkernel_70:
	; >>>>> Line:	212
	; >>>>> if (task->next !=  0 ){ 
	mov	si, word [bp+4]
	add	si, 8
	mov	ax, word [si]
	test	ax, ax
	je	L_YAKkernel_71
	; >>>>> Line:	213
	; >>>>> task->next->prev = task->p 
	mov	si, word [bp+4]
	add	si, 10
	mov	di, word [bp+4]
	add	di, 8
	mov	di, word [di]
	add	di, 10
	mov	ax, word [si]
	mov	word [di], ax
L_YAKkernel_71:
	; >>>>> Line:	215
	; >>>>> if (task->prev !=  0 ){ 
	mov	si, word [bp+4]
	add	si, 10
	mov	ax, word [si]
	test	ax, ax
	je	L_YAKkernel_72
	; >>>>> Line:	216
	; >>>>> task->prev->next = task->next; 
	mov	si, word [bp+4]
	add	si, 8
	mov	di, word [bp+4]
	add	di, 10
	mov	di, word [di]
	add	di, 8
	mov	ax, word [si]
	mov	word [di], ax
L_YAKkernel_72:
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_69:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_70
L_YAKkernel_79:
	DB	" ",0xA,0
L_YAKkernel_78:
	DB	"->",0
L_YAKkernel_77:
	DB	")",0
L_YAKkernel_76:
	DB	":0x",0
L_YAKkernel_75:
	DB	"/",0
L_YAKkernel_74:
	DB	"TCB(",0
	ALIGN	2
printTCB:
	; >>>>> Line:	221
	; >>>>> void printTCB(void* ptcb){ 
	jmp	L_YAKkernel_80
L_YAKkernel_81:
	; >>>>> Line:	224
	; >>>>> printString("TCB("); 
	mov	ax, word [bp+4]
	mov	word [bp-2], ax
	; >>>>> Line:	224
	; >>>>> printString("TCB("); 
	mov	ax, L_YAKkernel_74
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	225
	; >>>>> printInt(tcb->priority); 
	mov	si, word [bp-2]
	add	si, 4
	push	word [si]
	call	printInt
	add	sp, 2
	; >>>>> Line:	226
	; >>>>> printString("/"); 
	mov	ax, L_YAKkernel_75
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	227
	; >>>>> printInt(tcb->delayTicks); 
	mov	si, word [bp-2]
	add	si, 6
	push	word [si]
	call	printInt
	add	sp, 2
	; >>>>> Line:	228
	; >>>>> printString(":0x"); 
	mov	ax, L_YAKkernel_76
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	229
	; >>>>> printWord((int)tcb->stackPtr); 
	mov	si, word [bp-2]
	push	word [si]
	call	printWord
	add	sp, 2
	; >>>>> Line:	230
	; >>>>> printString(")"); 
	mov	ax, L_YAKkernel_77
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	231
	; >>>>> if (tcb->next !=  0 ){ 
	mov	si, word [bp-2]
	add	si, 8
	mov	ax, word [si]
	test	ax, ax
	je	L_YAKkernel_82
	; >>>>> Line:	232
	; >>>>> printString("->"); 
	mov	ax, L_YAKkernel_78
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	233
	; >>>>> printTCB(tcb->next); 
	mov	si, word [bp-2]
	add	si, 8
	push	word [si]
	call	printTCB
	add	sp, 2
	jmp	L_YAKkernel_83
L_YAKkernel_82:
	; >>>>> Line:	236
	; >>>>> printString(" \n"); 
	mov	ax, L_YAKkernel_79
	push	ax
	call	printString
	add	sp, 2
L_YAKkernel_83:
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_80:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_YAKkernel_81
	ALIGN	2
YKCtxSwCount:
	TIMES	2 db 0
YKIdleCount:
	TIMES	2 db 0
YKCurrentTask:
	TIMES	2 db 0
YKReadyTasks:
	TIMES	2 db 0
YKSuspendedTasks:
	TIMES	2 db 0
YKAllTasks:
	TIMES	2 db 0
YKTCBs:
	TIMES	72 db 0
YKTCBMallocIndex:
	TIMES	2 db 0
IdleStack:
	TIMES	200 db 0
YKISRDepth:
	TIMES	2 db 0
YKIsRunning:
	TIMES	2 db 0
