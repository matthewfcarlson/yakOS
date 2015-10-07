#include "YAKkernel.h"
#include "clib.h"
/* TCB stuff */
typedef struct taskblock *TCBp;
/* the TCB struct definition */
typedef struct taskblock
{
    void* stackPtr;		/* pointer to current top of stack */
    int state;			/* current state */
    int priority;		/* current priority */
    int delayTicks;			/* #ticks yet to wait */
    TCBp next;		/* forward ptr for dbl linked list */
    //TCBptr prev;		/* backward ptr for dbl linked list */
}  TCB;


TCBp YKCurrentTask;		/* the currently running task */
TCBp YKReadyTasks;		/* a list of TCBs of all ready tasks in order of decreasing priority */ 
TCBp YKSuspendedTasks;	/* tasks delayed or suspended */
TCBp YKAllTasks;		/* a list of available TCBs */
TCB  YKTCBs[MAX_TASKS+1];/* array to allocate all needed TCBs*/
int  YKTCBMallocIndex;	/* the index of the current empty TCB in the array */

//IDLE TASK stuff
int IdleStack[DEFAULTSTACKSIZE];

/* Global Variables */
int YKCtxSwCount; // - Global variable that tracks context switches 
int YKIdleCount;  // - Global variable incremented by idle task 
int YKISRDepth;

/*Kernel functions */

// - Initializes all required kernel data structures 
void YKInitialize(){
	YKEnterMutex();
	YKCtxSwCount = 0;
	YKISRDepth = 0;
	YKIdleCount = 0;
	YKReadyTasks = NULL;
	YKSuspendedTasks = NULL;
	YKAllTasks = NULL;
	YKCurrentTask = NULL;
	YKTCBMallocIndex = 0;
	
	
	//create idle task
	YKNewTask(YKIdleTask, &IdleStack[DEFAULTSTACKSIZE],255); //prority is negative -1 or rolled over to max
	YKExitMutex();
}

// - Disables interrupts 
void YKEnterMutex(){
	asm("cli");
	
}
// - Enables interrupts 
void YKExitMutex(){
	asm("sti");	
}

// - Enters an ISR
void YKEnterISR(){
	//since we are accessing a global variable, we need to disable interrupts
	YKEnterMutex();
	++YKISRDepth;
	YKExitMutex();
}

// - Exits an ISR
void YKExitISR(){
	YKEnterMutex();
	--YKISRDepth;
	
	//check if we need to run the scheduler
	if (YKISRDepth == 0){
		//run scheduler
		YKScheduler();
	}
	
	YKExitMutex();
	
}
// - Kernel's idle task 
void YKIdleTask(){
	int i = 0;
	while(1){ //Just spin in idle and count to 5000
		for (i = 0; i< 5000; i++);
		++YKIdleCount;
	}
	
}   
// - Creates a new task 
void YKNewTask(void* taskFunc, void* taskStack, int priority){
	TCBp taskListPtr = YKReadyTasks;
	TCBp newTask = &YKTCBs[YKTCBMallocIndex];
	int* newStackSP = taskStack;
	++YKTCBMallocIndex;
	
	//Create the stack
	
	newTask->stackPtr = taskStack;
	*(newStackSP) = DEFAULTFLAGS;
	newStackSP -= 2;
	*(newStackSP) = 0; //CS
	newStackSP -= 2;
	*(newStackSP) = taskFunc; //function
	newTask->stackPtr-=18;
	//flags, CS, IP (the address of the function passed in)

	
	//Initalize the TCB
	newTask->priority = priority;
	newTask->next = NULL;
	
	//create the list
	if (YKReadyTasks == NULL)
		YKReadyTasks = newTask;
	//append to the list
	else if (YKReadyTasks->priority > priority){
		newTask->next = YKReadyTasks;
		YKReadyTasks = newTask;
	}
	//stick it somewhere in there
	else{
		while (taskListPtr->next != NULL && taskListPtr->next->priority > priority){
			taskListPtr = taskListPtr -> next;
		}
		newTask-> next = taskListPtr -> next;
		taskListPtr->next = newTask;
	}
	
}
// - Starts actual execution of user code 	
void YKRun(){
	printString("Starting Yak OS (c) 2015\n");
	YKScheduler();
	
}
// - Determines the highest priority ready task 
void YKScheduler(){
	printString("Scheduler\n");
	printTCB(YKReadyTasks);
	//if the new task to run is different
	if (YKReadyTasks != YKCurrentTask){
		//Load the new task
		YKCurrentTask = YKReadyTasks;
		YKDispatcher();
	}
}

// - Begins or resumes execution of the next task
void YKDispatcher(){
	void* newSP = YKCurrentTask->stackPtr;
	//we are dispatching!
	SwitchContext();
}

/* ISR handlers */
void YKTickHandler(){
	static int tickCount = 0;
	TCBp currTCB = YKSuspendedTasks;
	
	++tickCount;
	printString("\nTick ");
	printInt(tickCount);
	printString("\n");
	//Decrement the wait list
	while (currTCB != NULL){
		--currTCB->delayTicks;
		currTCB = currTCB->next;
	}
	
}

/* Helper functions TCB structure */
void printTCB(void* ptcb){
	TCBp tcb = (TCBp) ptcb;
	
	printString("TCB(");
	printInt(tcb->priority);
	printString("/");
	printInt(tcb->delayTicks);
	printString(":");
	printInt(tcb->stackPtr);
	printString(")");
	if (tcb->next != NULL){
		printString("->");
		printTCB(tcb->next);
	}
	else
		printString(" \n");
}
