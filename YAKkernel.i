#line 1 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
#line 1 "YAKkernel.h"
#line 12 "YAKkernel.h"
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




extern int YKCtxSwCount;
extern int YKIdleCount;
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


int IdleStack[ 100 ];


int YKCtxSwCount;
int YKIdleCount;
int YKISRDepth;
int YKIsRunning;

void YKAddToSuspendedList(TCBp task);
void YKAddToReadyList(TCBp task);
void YKRemoveFromList(TCBp task);

void printTCB(void* ptcb);
void SwitchContext();
void SaveSPtoTCB();



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
		for (i = 0; i< 1000; i++);
			++YKIdleCount;

		printString("Idling...\n");

	}

}

void YKNewTask(void* taskFunc, void* taskStack, int priority){
	TCBp newTask = &YKTCBs[YKTCBMallocIndex];
	int* newStackSP = (int*)taskStack;
	YKEnterMutex();
	++YKTCBMallocIndex;
	YKExitMutex();


	printString("\nBP at 0x");
	printWord((int)taskStack);




	*(newStackSP) =  64 ;
	--newStackSP;
	*(newStackSP) = 0;
	--newStackSP;
	*(newStackSP) = (int)taskFunc;
	newStackSP = newStackSP - 8;


	printString("\nSP at 0x");
	printWord((int)newStackSP);


	newTask->stackPtr = (int*)newStackSP;



	newTask->priority = priority;
	newTask->next =  0 ;
	newTask->prev =  0 ;
	newTask->delayTicks = 0;
	newTask->state = 1;

	YKAddToReadyList(newTask);
	if (YKIsRunning)
		YKScheduler();
}

void YKRun(){

	printString("Starting Yak OS (c) 2015\n");

	YKIsRunning = 1;
	YKScheduler();


}

void YKScheduler(){
	YKEnterMutex();

	printString("Scheduler\n");
	printTCB(YKReadyTasks);


	if (YKReadyTasks != YKCurrentTask){

		YKCurrentTask = YKReadyTasks;
		++YKCtxSwCount;

		printString("Switching context to task#");
		printInt(YKCurrentTask->priority);
		printString("\n");

		YKDispatcher();
	}
	YKExitMutex();
}


void YKDispatcher(){

	void* newSP = YKCurrentTask->stackPtr;

	SwitchContext();
}



void YKTickHandler(){
	static int tickCount = 0;
	TCBp currTCB = YKSuspendedTasks;
	TCBp movingTCB =  0 ;

	++tickCount;
	printString("\nTick ");
	printInt(tickCount);
	printString("\n");


	while (currTCB !=  0 ){
		currTCB->delayTicks = currTCB->delayTicks -1 ;

		if (currTCB->delayTicks <= 0){

			printString("Adding task #");
			printInt(currTCB->priority);
			printString(" back to the ready list\n");


			movingTCB = currTCB;
			currTCB = currTCB->next;

			YKRemoveFromList(movingTCB);
			YKAddToReadyList(movingTCB);
		}
		else{
			currTCB = currTCB->next;
		}

	}

}



void YKAddToReadyList(TCBp newTask){
	int priority = newTask->priority;
	TCBp taskListPtr = YKReadyTasks;

	if (YKReadyTasks ==  0 )
		YKReadyTasks = newTask;

	else if (YKReadyTasks->priority > priority){
		newTask->next = YKReadyTasks;
		YKReadyTasks->prev = newTask;
		YKReadyTasks = newTask;
	}

	else{

		while (taskListPtr->next !=  0  && taskListPtr->next->priority > priority){
			taskListPtr = taskListPtr -> next;
		}

		newTask-> next = taskListPtr -> next;
		taskListPtr->next = newTask;
	}
}

void YKAddToSuspendedList(TCBp task){
	task->next = YKSuspendedTasks;
	YKSuspendedTasks->prev = task;
	YKSuspendedTasks = task;
}


void YKRemoveFromList(TCBp task){
	if (YKReadyTasks == task){
		YKReadyTasks = task->next;
	}
	else if (YKSuspendedTasks = task){
		YKSuspendedTasks = task->next;
	}

	if (task->next !=  0 ){
		task->next->prev = task->prev;
	}
	if (task->prev !=  0 ){
		task->prev->next = task->next;
	}
}


void YKDelayTask(int ticks){
	YKEnterMutex();
	if (ticks > 0){

		printString("Delaying\n\n");

		YKCurrentTask->delayTicks += ticks;
	}
	YKRemoveFromList(YKCurrentTask);
	YKAddToSuspendedList(YKCurrentTask);

	printString("Current Ready Tasks:\n");
	printTCB(YKReadyTasks);
	printString("Calling Software delay interrupt\n");


	asm("int 11h");

	YKExitMutex();

}


void printCurrentTask(){
	printTCB(YKCurrentTask);
}
void printTCB(void* ptcb){
	TCBp tcb = (TCBp) ptcb;

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
