#line 1 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
#line 1 "YAKkernel.h"
#line 14 "YAKkernel.h"
typedef struct semaphore
{
    int count;
    void* tasks;

} YKSEM;


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
    int state;
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


unsigned YKCtxSwCount;
unsigned YKIdleCount;
unsigned YKISRDepth;
int YKIsRunning;


void YKAddToSuspendedList(TCBp task);
void YKAddToReadyList(TCBp task);
void YKRemoveFromList(TCBp task);
void printCurrentTask();
void printTCB(void* ptcb);
void SwitchContext();
void printTaskLists();




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
	int i = 0;

	YKExitMutex();
	while(1){

			++YKIdleCount;
#line 108 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	}

}

void YKNewTask(void* taskFunc, void* taskStack, int priority){
	TCBp newTask = &YKTCBs[YKTCBMallocIndex];
	int* newStackSP = (int*)taskStack;
	YKEnterMutex();
	++YKTCBMallocIndex;
#line 127 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
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
#line 146 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	newTask->stackPtr = (int*)newStackSP;



	newTask->priority = priority;
	newTask->next =  0 ;
	newTask->prev =  0 ;
	newTask->delayTicks = 0;
	newTask->state = 1;

	YKAddToReadyList(newTask);
	if (YKIsRunning && YKCurrentTask ==  0 )
		YKScheduler();
	else if (YKIsRunning)
		asm("int 11h");

	YKExitMutex();
}

void YKRun(){
#line 169 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	YKIsRunning = 1;
	YKScheduler();


}

void YKScheduler(){
	YKEnterMutex();
	if (!YKIsRunning) return;

	if (YKReadyTasks != YKCurrentTask){
#line 184 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
		YKCurrentTask = YKReadyTasks;
		++YKCtxSwCount;
#line 191 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
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



void YKTickHandler(){
	static int tickCount = 0;
	TCBp currTCB = YKSuspendedTasks;
	TCBp movingTCB =  0 ;

	++tickCount;
#line 300 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	while (currTCB !=  0 ){
		currTCB->delayTicks = currTCB->delayTicks -1 ;

		if (currTCB->delayTicks <= 0){
#line 312 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
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
#line 338 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
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
	printString("Creating new semaphore: 0x");
	printWord((int)newSem);
	printString("\n");
	YKExitMutex();
	return newSem;
}
void YKSemPend(YKSEM *semaphore){
	YKEnterMutex();
#line 371 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
	if (semaphore->count > 0){
		--(semaphore->count);
		return;
	}
#line 379 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
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
#line 401 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
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
#line 421 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
}


void printCurrentTask(){
	printTCB(YKCurrentTask);
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
