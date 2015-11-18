#line 1 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
#line 1 "YAKkernel.h"
#line 31 "YAKkernel.h"
typedef struct semaphore
{
    int count;
    void* tasks;

} YKSEM;

struct msg
{
    int tick;
    int data;
};

typedef void* YKQ;

typedef void* YKEVENT;

void YKInitialize();
void YKEnterMutex();
void YKExitMutex();
void YKIdleTask();
void YKNewTask(void* taskFunc, void* taskStack, int priority);
void YKRun();
void YKScheduler();
void YKDispatcher();
void YKEnterISR();
void YKExitISR();
void YKTickHandler();
void YKDelayTask(int ticks);

YKSEM* YKSemCreate(int initialValue);
void YKSemPend(YKSEM *semaphore);
void YKSemPost(YKSEM *semaphore);

YKQ* YKQCreate(void **start, unsigned size);
void* YKQPend(YKQ *queue);
int YKQPost(YKQ *queue, void *msg);

YKEVENT* YKEventCreate(unsigned initialValue);
unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode);
void YKEventSet(YKEVENT *event, unsigned eventMask);
void YKEventReset(YKEVENT *event, unsigned eventMask);


extern unsigned YKCtxSwCount;
extern unsigned YKIdleCount;
#line 2 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
#line 1 "clib.h"



void print(char *string, int length);
void printNewLine(void);
void printChar(char c);
void printString(char *string);


void printInt(int val);
void printLong(long val);
void printUInt(unsigned val);
void printULong(unsigned long val);


void printByte(char val);
void printWord(int val);
void printDWord(long val);


void exit(unsigned char code);


void signalEOI(void);
#line 3 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"





typedef struct taskblock *TCBp;

typedef struct taskblock
{
    void* stackPtr;
    unsigned blockReason;
    int priority;
    int delayTicks;
    TCBp next;
    TCBp prev;
} TCB;


TCBp YKCurrentTask;
TCBp YKReadyTasks;
TCBp YKSuspendedTasks;

TCB YKTCBs[ 5 +1];
int YKTCBMallocIndex;


YKSEM YKSemaphores[ 5 ];
int YKSemaphoreIndex = 0;


int IdleStack[ 100 ];


typedef struct YKMessQueue{
	unsigned head;
	unsigned tail;
	unsigned size;
	unsigned length;
	void** queue;
	void* tasks;
} YKMQ;
YKMQ YKQueues[ 5 ];
int YKQueueIndex = 0;


typedef struct YKEventGroups{
	unsigned events;
	void* blockedTasks;
} YKEventGroup;

unsigned YKEventGroupIndex = 0;
YKEventGroup YKEventGroupList[ 5 ];


unsigned YKCtxSwCount;
unsigned YKIdleCount;
unsigned YKISRDepth;
int YKIsRunning;


void YKAddToSuspendedList(TCBp task);
void YKAddToReadyList(TCBp task);
void YKRemoveFromList(TCBp task);
int YKEventReadyToUnblock(YKEventGroup* event, unsigned waitCondition);
void printCurrentTask();
void printTCB(void* ptcb);
void SwitchContext();
void printTaskLists();
void YKUpdateSuspendedTasks();
void printQueue(YKMQ* queue);





void YKInitialize(){
	YKEnterMutex();


	YKCtxSwCount = 0;
	YKISRDepth = 0;
	YKIdleCount = 0;
	YKReadyTasks =  0 ;
	YKSuspendedTasks =  0 ;

	YKCurrentTask =  0 ;
	YKTCBMallocIndex = 0;
	YKIsRunning = 0;


	YKNewTask(YKIdleTask, &IdleStack[ 100 ],255);
	YKExitMutex();
}


void YKEnterMutex(){
	asm("cli");

}

void YKExitMutex(){
	asm("sti");
}


void YKEnterISR(){

	++YKISRDepth;
}


void YKExitISR(){
	--YKISRDepth;


	if (YKISRDepth == 0){

		YKScheduler();
	}

}

void YKIdleTask(){

	while(1){
		YKEnterMutex();

		++YKIdleCount;
		YKExitMutex();
	}

}

void YKNewTask(void* taskFunc, void* taskStack, int priority){
	TCBp newTask = &YKTCBs[YKTCBMallocIndex];
	int* newStackSP = (int*)taskStack;
	YKEnterMutex();
	++YKTCBMallocIndex;
#line 151 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	--newStackSP;
	--newStackSP;

	*(newStackSP) =  64 ;
	--newStackSP;
	*(newStackSP) = 0;
	--newStackSP;
	*(newStackSP) = (int)taskFunc;
	newStackSP = newStackSP - 5;
	*(newStackSP) = (int)taskStack;
	--newStackSP;
	newStackSP = newStackSP - 2;
#line 170 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	newTask->stackPtr = (int*)newStackSP;



	newTask->priority = priority;
	newTask->next =  0 ;
	newTask->prev =  0 ;
	newTask->delayTicks = 0;
	newTask->blockReason =  0 ;

	YKAddToReadyList(newTask);
	if (YKIsRunning && YKCurrentTask ==  0 )
		YKScheduler();
	else if (YKIsRunning)
		asm("int 11h");

	YKExitMutex();
}

void YKRun(){
#line 193 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	YKIsRunning = 1;
	YKScheduler();


}

void YKScheduler(){
	YKEnterMutex();
	if (!YKIsRunning) return;

	if (YKReadyTasks != YKCurrentTask){
#line 208 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
		YKCurrentTask = YKReadyTasks;
		++YKCtxSwCount;
#line 215 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
		YKDispatcher();
	}


}


void YKDispatcher(){

	void* newSP = YKCurrentTask->stackPtr;

	SwitchContext();
}




void YKAddToReadyList(TCBp newTask){
	int newPriority = newTask->priority;
	TCBp taskListPtr = YKReadyTasks;

	if (YKReadyTasks ==  0 ){
		YKReadyTasks = newTask;
	}

	else if (YKReadyTasks->priority > newPriority){
		newTask->next = YKReadyTasks;
		YKReadyTasks->prev = newTask;
		YKReadyTasks = newTask;
	}

	else{
		while (taskListPtr->next !=  0  && taskListPtr->priority < newPriority){
			taskListPtr = taskListPtr->next;
		}

		if (taskListPtr->priority < newPriority){
			newTask->next = taskListPtr->next;
			taskListPtr->next = newTask;
			newTask->prev = taskListPtr;
			if (newTask->next !=  0 ){
				newTask->next->prev = newTask;
			}
		}

		else{
			newTask->prev = taskListPtr->prev;
			if (taskListPtr->prev !=  0 )
				taskListPtr->prev->next = newTask;
			taskListPtr->prev = newTask;
			newTask->next = taskListPtr;
		}
	}
}

void YKAddToSuspendedList(TCBp task){

	if (YKSuspendedTasks ==  0 ){
		YKSuspendedTasks = task;
		task->next =  0 ;
		task->next =  0 ;
	}
	else{
		task->prev =  0 ;
		task->next = YKSuspendedTasks;
		YKSuspendedTasks->prev = task;
		YKSuspendedTasks = task;
	}


}


void YKRemoveFromList(TCBp task){

	if (YKReadyTasks == task){
		YKReadyTasks = task->next;
	}
	else if (YKSuspendedTasks == task){
		YKSuspendedTasks = task->next;
	}

	if (task->next !=  0 ){
		task->next->prev = task->prev;
	}
	if (task->prev !=  0 ){
		task->prev->next = task->next;
	}

	task->prev =  0 ;
	task->next =  0 ;

}


void YKUpdateSuspendedTasks(){
	TCBp currTCB = YKSuspendedTasks;
	TCBp movingTCB =  0 ;


	while (currTCB !=  0 ){
		currTCB->delayTicks = currTCB->delayTicks -1 ;

		if (currTCB->delayTicks <= 0){
#line 327 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
			movingTCB = currTCB;
			currTCB = currTCB->next;
			YKEnterMutex();
			YKRemoveFromList(movingTCB);
			YKAddToReadyList(movingTCB);
			YKExitMutex();
		}
		else{
			currTCB = currTCB->next;
		}

	}

}


void YKDelayTask(int ticks){
	YKEnterMutex();
	if (ticks > 0){
#line 353 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
		YKCurrentTask->delayTicks += ticks;
	}

	YKRemoveFromList(YKCurrentTask);
	YKAddToSuspendedList(YKCurrentTask);


	asm("int 11h");

	YKExitMutex();

}

YKSEM* YKSemCreate(int initialValue){
	YKSEM* newSem = &YKSemaphores[YKSemaphoreIndex];
	YKEnterMutex();
	newSem->count = initialValue;
	newSem->tasks =  0 ;
	++YKSemaphoreIndex;
#line 379 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	YKExitMutex();
	return newSem;
}
void YKSemPend(YKSEM *semaphore){
	YKEnterMutex();
#line 390 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	if (semaphore->count > 0){
		--(semaphore->count);
		return;
	}
#line 398 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	YKRemoveFromList(YKCurrentTask);
	YKCurrentTask->next = semaphore->tasks;
	semaphore->tasks = YKCurrentTask;


	if (YKISRDepth == 0)
		asm("int 11h");

	YKExitMutex();

}
void YKSemPost(YKSEM *semaphore){
	TCBp currTask;
	TCBp addTask;
	YKEnterMutex();
#line 420 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	++(semaphore->count);

	currTask = semaphore->tasks;
	if (currTask !=  0 )
		--(semaphore->count);

	while (currTask !=  0  && currTask != currTask->next){
		addTask = currTask;
		currTask = currTask->next;
		YKAddToReadyList(addTask);
	}
	semaphore->tasks =  0 ;
	if (YKISRDepth == 0){
		asm("int 11h");
	}
	YKExitMutex();
#line 440 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
}


YKQ* YKQCreate(void **start, unsigned size){
	YKMQ* queue = &YKQueues[YKQueueIndex];
	YKEnterMutex();
	queue->head = 0;
	queue->tail = 0;
	queue->size = size;
	queue->length = 0;
	queue->queue = start;
	++YKQueueIndex;
	YKExitMutex();
	return (void*)queue;
}
#line 459 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
void* YKQPend(YKQ *queue){
	void* message;
	YKMQ* messQ = (YKMQ*)queue;
#line 468 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	YKEnterMutex();

	if (messQ->length == 0){
#line 476 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
		if (messQ->tasks !=  0 ){
			printString("\n\nERROR: TWO TASKS ARE WAITING ON THE SAME QUEUE.----------------------\n\n");
			YKDelayTask(2);
		}


		YKRemoveFromList(YKCurrentTask);

		YKCurrentTask->next = messQ->tasks;
		messQ->tasks = YKCurrentTask;
		if (YKISRDepth == 0){

			asm("int 11h");
		}
		else{

			printString("\n\nERROR: CANNOT SWITCH TASK SINCE IN ISR------------------------\n\n");
			exit(6);
		}
	}
	YKExitMutex();

	YKEnterMutex();


	messQ->length = messQ->length - 1;


	message = messQ->queue[messQ->head];


	++(messQ->head);
	if (messQ->head == messQ->size )
		messQ->head = 0;
#line 518 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	return message;

}



int YKQPost(YKQ *queue, void *msg){
	YKMQ* messQ = (YKMQ*)queue;
	TCBp currTask;
	TCBp addTask;


	YKEnterMutex();
#line 540 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	if (messQ->length >= messQ->size){
#line 545 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
		return 0;
	}


	++(messQ->length);
	messQ->queue[messQ->tail] = msg;


	++(messQ->tail);
	if (messQ->tail == messQ->size )
		messQ->tail = 0;


	currTask = messQ->tasks;
	while (currTask !=  0  && currTask != currTask->next){
		addTask = currTask;
		currTask = currTask->next;
		YKAddToReadyList(addTask);
	}

	messQ->tasks =  0 ;

	YKExitMutex();
	return messQ->length;
}


YKEVENT* YKEventCreate(unsigned initialValue){
	YKEventGroup* event;
	YKEnterMutex();
	event = &YKEventGroupList[YKEventGroupIndex];
	event->events = initialValue;
	event->blockedTasks =  0 ;
	++YKEventGroupIndex;
	YKExitMutex();
	return (YKEVENT*)event;
}
unsigned YKEventPend(YKEVENT *eventpointer, unsigned eventMask, int waitMode){
	YKEventGroup* event = (YKEventGroup*) eventpointer;
	YKEnterMutex();
	YKCurrentTask->blockReason = eventMask | waitMode;


	if (!YKEventReadyToUnblock(event,eventMask)){
#line 593 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
		YKRemoveFromList(YKCurrentTask);
		if (event->blockedTasks !=  0 )
			((TCBp)event->blockedTasks)->prev = YKCurrentTask;

		YKCurrentTask->next = event->blockedTasks;
		event->blockedTasks = YKCurrentTask;

		if (YKISRDepth == 0){
			asm("int 11h");
		}
		YKExitMutex();
	}
	return event->events;
}
int YKEventReadyToUnblock(YKEventGroup* event, unsigned waitCondition){

	unsigned mask = (waitCondition & ~ (unsigned) 0x18 );
	unsigned condition = event->events & mask;
	if (waitCondition &  0x8 ){
		if (condition){
			return 1;
		}
	}
	else {
		if (condition == mask){
			return 1;
		}
	}
	return 0;
}
void YKEventSet(YKEVENT *eventpointer, unsigned eventMask){

	TCBp task;
	TCBp nexttask =  0 ;
	int switchNeeded = 0;
	YKEventGroup* event = (YKEventGroup*) eventpointer;


	if (eventpointer ==  0  || !YKIsRunning){
		printString("Not ready for event input\n");
		return;
	}

	YKEnterMutex();

	event->events |= eventMask;

	task = event->blockedTasks;
	while (task !=  0 ){
		nexttask = task->next;
		if (YKEventReadyToUnblock(event,task->blockReason)){

			switchNeeded = 1;

			if (event->blockedTasks == task)
				event->blockedTasks = task->next;

			YKRemoveFromList(task);
			YKAddToReadyList(task);
		}
		task = nexttask;
	}
	if (YKISRDepth == 0 && switchNeeded){
		asm("int 11h");
	}
	YKExitMutex();

}
void YKEventReset(YKEVENT *eventpointer, unsigned eventMask){
	YKEventGroup* event = (YKEventGroup*) eventpointer;
	YKEnterMutex();
	event->events &= ~eventMask;
	YKExitMutex();
}


void printCurrentTask(){
	printTCB(YKCurrentTask);
}


void printQueue(YKMQ* queue){
	int i =0;
	printString("Queue size:");
	printInt(queue->size);
	printString(" count:");
	printInt(queue->length);
	printString(" h:");
	printInt(queue->head);
	printString(" t:");
	printInt(queue->tail);
	printString(" tasks:");
	printTCB(queue->tasks);
	printString("Contents: [");
	for (i=0;i<queue->size;i++){
		printWord((int)queue->queue[i]);
		printString(", ");
	}
	printString("]\n");
}


void printTCB(void* ptcb){
	TCBp tcb = (TCBp) ptcb;

	if (ptcb ==  0 ){
		printString("None\n");
		return;
	}

	printString("TCB(");
	printInt(tcb->priority);
	printString("/");
	printInt(tcb->delayTicks);
	printString(":0x");
	printWord((int)tcb->stackPtr);
	printString(")");
	if (tcb->next !=  0 ){
		printString("->");
		printTCB(tcb->next);
	}
	else
		printString(" \n");
}


void printTaskLists(){
	int i = 0;
	printString("Ready Tasks:  ");
	printTCB(YKReadyTasks);
	printString("Suspended Tasks:  ");
	printTCB(YKSuspendedTasks);
	for (i=0; i< YKSemaphoreIndex;i++){
		printString("Semaphore #");
		printInt(i);
		printString(" tasks:");
		printTCB(YKSemaphores[i].tasks);
	}
}
