#include "YAKkernel.h"
#include "clib.h"
#define DEBUG 1
/* ----------------- TCB stuff ----------------- */
typedef struct taskblock *TCBp;
/* the TCB struct definition */
typedef struct taskblock
{
    void* stackPtr;		/* pointer to current top of stack */
    int state;			/* current state */
    int priority;		/* current priority */
    int delayTicks;		/* #ticks yet to wait */
    TCBp next;			/* forward ptr for dbl linked list */
    TCBp prev;			/* backward ptr for dbl linked list */
}  TCB;

/* ----------------- TCB lisks ----------------- */
TCBp YKCurrentTask;		/* the currently running task */
TCBp YKReadyTasks;		/* a list of TCBs of all ready tasks in order of decreasing priority */ 
TCBp YKSuspendedTasks;	/* tasks delayed or suspended */
//TCBp YKAllTasks;		/* a list of available TCBs */
TCB  YKTCBs[MAX_TASKS+1];/* array to allocate all needed TCBs*/
int  YKTCBMallocIndex;	/* the index of the current empty TCB in the array */

//IDLE TASK stuff
int IdleStack[DEFAULTSTACKSIZE];

/* ----------------- Global Variables ----------------- */
int YKCtxSwCount; // - Global variable that tracks context switches 
int YKIdleCount;  // - Global variable incremented by idle task 
int YKISRDepth;
int YKIsRunning;
/* ----------------- Private Kernel function declerations -----------------  */
void YKAddToSuspendedList(TCBp task);
void YKAddToReadyList(TCBp task);
void YKRemoveFromList(TCBp task);

void printTCB(void* ptcb);
void SwitchContext();
void SaveSPtoTCB();

/* ----------------- Public kernel functions -----------------  */
// - Initializes all required kernel data structures 
void YKInitialize(){
	YKEnterMutex();
	
	//Set things to zero or null
	YKCtxSwCount = 0;
	YKISRDepth = 0;
	YKIdleCount = 0;
	YKReadyTasks = NULL;
	YKSuspendedTasks = NULL;
	//YKAllTasks = NULL;
	YKCurrentTask = NULL;
	YKTCBMallocIndex = 0;
	YKIsRunning = 0;	
	
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
	//If we have a call depth of zero we need to save the SP-2 to the TCB
	if (YKISRDepth == 0){
		SaveSPtoTCB();
	}
	++YKISRDepth;
}

// - Exits an ISR
void YKExitISR(){
	--YKISRDepth;
	
	//check if we need to run the scheduler
	if (YKISRDepth == 0){
		//run scheduler since we are call depth 0
		YKScheduler();
	}
	
}
// - Kernel's idle task 
void YKIdleTask(){
	int i = 0;
	//make sure we have interrupts on
	YKExitMutex();
	while(1){ //Just spin in idle and count to 1000
		for (i = 0; i< 1000; i++);
			++YKIdleCount;
		printString("Idling...\n");
	}
	
}   
// - Creates a new task 
void YKNewTask(void* taskFunc, void* taskStack, int priority){
	TCBp newTask = &YKTCBs[YKTCBMallocIndex];
	int* newStackSP = (int*)taskStack;
	YKEnterMutex(); //modifiying a global variable
	++YKTCBMallocIndex;
	YKExitMutex();
	
	#if DEBUG == 1
	printString("\nBP at 0x");
	printWord((int)taskStack);
	#endif
	
	//Create the default stack	
	//flags, CS, IP (the address of the function passed in)
	*(newStackSP) = DEFAULTFLAGS; //put the default flags into memory address newStackSp
	--newStackSP; //we minus 1 since C will automatically turn this to 2 because it's a pointer
	*(newStackSP) = 0; //put the default CS into memory adress newStackSP - 2
	--newStackSP;
	*(newStackSP) = (int)taskFunc; //function pointer to put in the IP slot
	newStackSP = newStackSP - 8;   //There are 8 registers on the stack that are default 0
	
	#if DEBUG == 1
	printString("\nSP at 0x");
	printWord((int)newStackSP);
	#endif
	
	newTask->stackPtr = (int*)newStackSP; //we just add the space for the rest of the functions
	

	//Initalize the TCB
	newTask->priority = priority;
	newTask->next = NULL;	//links to the next task
	newTask->prev = NULL; 
	newTask->delayTicks = 0;
	newTask->state = 1;
	//Add to the ready list
	YKAddToReadyList(newTask);
	if (YKIsRunning)
		YKScheduler();
}
// - Starts actual execution of user code 	
void YKRun(){
	#if DEBUG == 1
	printString("Starting Yak OS (c) 2015\n");
	#endif
	YKIsRunning = 1;
	YKScheduler();
	
	
}
// - Determines the highest priority ready task 
void YKScheduler(){
	YKEnterMutex();
	#if DEBUG == 1
	printString("Scheduler\n");
	printTCB(YKReadyTasks);
	#endif
	//if the new task to run is different
	if (YKReadyTasks != YKCurrentTask){
		//Load the new task
		YKCurrentTask = YKReadyTasks;
		++YKCtxSwCount;
		#if DEBUG == 1
		printString("Switching context to task#");
		printInt(YKCurrentTask->priority);
		printString("\n");
		#endif
		YKDispatcher();
	}
	YKExitMutex();
}

// - Begins or resumes execution of the next task
void YKDispatcher(){
	//Put the stack pointer of the current task on the stack
	void* newSP = YKCurrentTask->stackPtr;
	//call the assembly to dispatch the function
	SwitchContext(); //TODO: change name
}

/* ----------------- ISR handlers ----------------- */
//Handles the tick ISR
void YKTickHandler(){
	static int tickCount = 0;
	TCBp currTCB = YKSuspendedTasks;
	TCBp movingTCB = NULL;
	
	++tickCount;
	printString("\nTick ");
	printInt(tickCount);
	printString("\n");

	//Decrement the wait list
	while (currTCB != NULL){
		currTCB->delayTicks = currTCB->delayTicks -1 ;
		//check if it needs to go to the readyList
		if (currTCB->delayTicks <= 0){
			//remove it from the list
			printString("Adding task #");
			printInt(currTCB->priority);
			printString(" back to the ready list\n");
			
			//Store the TCB before we move on to the next one
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

/* ----------------- TCB list functions ----------------- */
//Adds a task to the ready list
void YKAddToReadyList(TCBp newTask){
	int priority = newTask->priority;
	TCBp taskListPtr = YKReadyTasks;
	//create the list if it's empty
	if (YKReadyTasks == NULL)
		YKReadyTasks = newTask;
	//append to the list
	else if (YKReadyTasks->priority > priority){
		newTask->next = YKReadyTasks;
		YKReadyTasks->prev = newTask;
		YKReadyTasks = newTask;
	}
	//stick it somewhere in there
	else{
		//TODO: optimize this somehow and make easier to understand
		while (taskListPtr->next != NULL && taskListPtr->next->priority > priority){
			taskListPtr = taskListPtr -> next;
		}
		//TODO: use prev as well as next to make double linked list
		newTask-> next = taskListPtr -> next;
		taskListPtr->next = newTask;
	}
}
//Adds a task to the suspeneded list
void YKAddToSuspendedList(TCBp task){
	task->next = YKSuspendedTasks;
	YKSuspendedTasks->prev = task;
	YKSuspendedTasks = task;
}

//Removes it from whatever list it's in
void YKRemoveFromList(TCBp task){
	if (YKReadyTasks == task){
		YKReadyTasks = task->next;
	}
	else if (YKSuspendedTasks = task){
		YKSuspendedTasks = task->next;
	}
	
	if (task->next != NULL){
		task->next->prev = task->prev;
	}
	if (task->prev != NULL){
		task->prev->next = task->next;
	}
}

/* ----------------- Delaying/semaphore functions ------------------- */
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
	//Call the software interrupt that causes a task switch
	asm("int 11h");
	//we will resume from here when we finished the delay ticks
	YKExitMutex(); 
	
}

/* ----------------- Helper functions TCB structure ----------------- */
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
	if (tcb->next != NULL){
		printString("->");
		printTCB(tcb->next);
	}
	else
		printString(" \n");
}
