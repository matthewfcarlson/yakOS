#line 1 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
#line 1 "YAKkernel.h"
#line 8 "YAKkernel.h"
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
void printTCB(void* ptcb);




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

} TCB;


TCBp YKCurrentTask;
TCBp YKReadyTasks;
TCBp YKSuspendedTasks;
TCBp YKAllTasks;
TCB YKTCBs[ 5 +1];
int YKTCBMallocIndex;


int IdleStack[ 100 ];


int YKCtxSwCount;
int YKIdleCount;
int YKISRDepth;




void YKInitialize(){
	YKEnterMutex();
	YKCtxSwCount = 0;
	YKISRDepth = 0;
	YKIdleCount = 0;
	YKReadyTasks =  0 ;
	YKSuspendedTasks =  0 ;
	YKAllTasks =  0 ;
	YKCurrentTask =  0 ;
	YKTCBMallocIndex = 0;



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

	YKEnterMutex();
	++YKISRDepth;
	YKExitMutex();
}


void YKExitISR(){
	YKEnterMutex();
	--YKISRDepth;


	if (YKISRDepth == 0){

		YKScheduler();
	}

	YKExitMutex();

}

void YKIdleTask(){
	int i = 0;
	while(1){
		for (i = 0; i< 5000; i++);
		++YKIdleCount;
	}

}

void YKNewTask(void* taskFunc, void* taskStack, int priority){
	TCBp taskListPtr = YKReadyTasks;
	TCBp newTask = &YKTCBs[YKTCBMallocIndex];
	++YKTCBMallocIndex;


	newTask->stackPtr = taskStack;


	newTask->priority = priority;
	newTask->next =  0 ;

	printTCB(newTask);


	if (YKReadyTasks ==  0 )
		YKReadyTasks = newTask;

	else if (YKReadyTasks->priority > priority){
		newTask->next = YKReadyTasks;
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

void YKRun(){
	printString("Starting Yak OS (c) 2015\n");
	YKScheduler();

}

void YKScheduler(){
	printString("Scheduler\n");
	printTCB(YKReadyTasks);

	if (YKReadyTasks != YKCurrentTask){

		YKCurrentTask = YKReadyTasks;
		YKDispatcher();
	}
}


void YKDispatcher(){

	printString("DISPATCHED \n");
}


void YKTickHandler(){
	static int tickCount = 0;
	TCBp currTCB = YKSuspendedTasks;

	++tickCount;
	printString("\nTick ");
	printInt(tickCount);
	printString("\n");

	while (currTCB !=  0 ){
		--currTCB->delayTicks;
		currTCB = currTCB->next;
	}

}


void printTCB(void* ptcb){
	TCBp tcb = (TCBp) ptcb;
	printString("TCB(");
	printInt(tcb->priority);
	printString("/");
	printInt(tcb->delayTicks);
	printString(")");
	if (tcb->next !=  0 ){
		printString("->");
		printTCB(tcb->next);
	}
	else
		printString(" \n");
}
