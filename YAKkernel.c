#include "YAKkernel.h"
#include "clib.h"
#define DEBUG 0

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

/* ----------------- Semaphore Array ----------------- */
YKSEM YKSemaphores[MAX_SEMAPHORES];
int YKSemaphoreIndex = 0;

//IDLE TASK stuff
int IdleStack[DEFAULTSTACKSIZE];

/* ----------------- Global Variables ----------------- */
unsigned YKCtxSwCount; // - Global variable that tracks context switches 
unsigned YKIdleCount;  // - Global variable incremented by idle task 
unsigned YKISRDepth;
int YKIsRunning;

/* ----------------- Private Kernel function declerations -----------------  */
void YKAddToSuspendedList(TCBp task);
void YKAddToReadyList(TCBp task);
void YKRemoveFromList(TCBp task);
void printCurrentTask();
void printTCB(void* ptcb);
void SwitchContext();
void printTaskLists();

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
	//If we have a call depth of zero we need to save the SP+4 to the TCB
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
		//for (i = 0; i< 2; i++);
			++YKIdleCount;
		#if DEBUG == 1
		//printString("Idling...\n");
		#endif
	}
	
}   
// - Creates a new task 
void YKNewTask(void* taskFunc, void* taskStack, int priority){
	TCBp newTask = &YKTCBs[YKTCBMallocIndex];
	int* newStackSP = (int*)taskStack;
	YKEnterMutex(); //modifiying a global variable
	++YKTCBMallocIndex;
	
	
	#if DEBUG == 1
	printString("Creating task#");
	printInt(priority);
	printString("\nBP at 0x");
	printWord((int)taskStack);
	#endif
	
	//Create the default stack
	--newStackSP;
	--newStackSP;
	//flags, CS, IP (the address of the function passed in)
	*(newStackSP) = DEFAULTFLAGS; //put the default flags into memory address newStackSp
	--newStackSP; //we minus 1 since C will automatically turn this to 2 because it's a pointer
	*(newStackSP) = 0; //put the default CS into memory adress newStackSP - 2
	--newStackSP;
	*(newStackSP) = (int)taskFunc; //function pointer to put in the IP slot
	newStackSP = newStackSP - 5;   //There are 8 registers on the stack that are default 0
	*(newStackSP) = (int)taskStack; //set the BP correctly
	--newStackSP;
	newStackSP = newStackSP - 2;
	
	#if DEBUG == 1
	printString("\tSP at 0x");
	printWord((int)newStackSP);
	printString("\n");
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
	if (YKIsRunning && YKCurrentTask == NULL)
		YKScheduler();
	else if (YKIsRunning)
		asm("int 11h"); //this will save context and call the scheduler
		//
	YKExitMutex();
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
	if (!YKIsRunning) return;
	//if the new task to run is different
	if (YKReadyTasks != YKCurrentTask){
		#if DEBUG == 1
		printTaskLists();
		#endif
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
	
	
}

// - Begins or resumes execution of the next task
void YKDispatcher(){
	//Put the stack pointer of the current task on the stack
	void* newSP = YKCurrentTask->stackPtr;
	//call the assembly to dispatch the function
	SwitchContext(); //TODO: change name
}


/* ----------------- TCB list functions ----------------- */
//Adds a task to the ready list
void YKAddToReadyList(TCBp newTask){
	int newPriority = newTask->priority;
	TCBp taskListPtr = YKReadyTasks;
	//create the list if it's empty
	if (YKReadyTasks == NULL){
		YKReadyTasks = newTask;
	}
	//prepend to the list
	else if (YKReadyTasks->priority > newPriority){
		newTask->next = YKReadyTasks;
		YKReadyTasks->prev = newTask;
		YKReadyTasks = newTask;
	}
	//stick it somewhere in there
	else{
		while (taskListPtr->next != NULL && taskListPtr->priority < newPriority){
			taskListPtr = taskListPtr->next;
		}
		//Add it after taskListPtr
		if (taskListPtr->priority < newPriority){
			newTask->next = taskListPtr->next;
			taskListPtr->next = newTask;
			newTask->prev = taskListPtr;		
			if (newTask->next != NULL){
				newTask->next->prev = newTask;
			}
		}
		//add before taskList
		else{
			newTask->prev = taskListPtr->prev;
			if (taskListPtr->prev != NULL)
				taskListPtr->prev->next = newTask;
			taskListPtr->prev = newTask;
			newTask->next = taskListPtr;
		}
	}
}
//Adds a task to the suspeneded list
void YKAddToSuspendedList(TCBp task){
	
	if (YKSuspendedTasks == NULL){
		YKSuspendedTasks = task;
		task->next = NULL;
		task->next = NULL;
	}
	else{
		task->prev = NULL;
		task->next = YKSuspendedTasks;
		YKSuspendedTasks->prev = task;
		YKSuspendedTasks = task;
	}
	
	
}

//Removes it from whatever list it's in
void YKRemoveFromList(TCBp task){
	
	if (YKReadyTasks == task){
		YKReadyTasks = task->next;
	}
	else if (YKSuspendedTasks == task){
		YKSuspendedTasks = task->next;
	}
	
	if (task->next != NULL){
		task->next->prev = task->prev;
	}
	if (task->prev != NULL){
		task->prev->next = task->next;
	}
	
	task->prev = NULL;
	task->next = NULL;
	
}

/* ----------------- ISR handlers ----------------- */
//Handles the tick ISR
void YKTickHandler(){
	static int tickCount = 0;
	TCBp currTCB = YKSuspendedTasks;
	TCBp movingTCB = NULL;
	
	++tickCount;
	#if DISPLAY_TICKS == 1
	printString("\nTick ");
	printInt(tickCount);
	printString("\n");
	#endif

	//Decrement the wait list
	while (currTCB != NULL){
		currTCB->delayTicks = currTCB->delayTicks -1 ;
		//check if it needs to go to the readyList
		if (currTCB->delayTicks <= 0){
			//remove it from the list
			#if DEBUG == 1
			printString("Adding task #");
			printInt(currTCB->priority);
			printString(" back to the ready list\n");
			#endif
			
			//Store the TCB before we move on to the next one
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

/* ----------------- Delaying/semaphore functions ------------------- */
void YKDelayTask(int ticks){
	YKEnterMutex();
	if (ticks > 0){
		#if DEBUG == 1
		printString("Delaying Task#");
		printInt(YKCurrentTask->priority);
		printString(" ");
		printInt(ticks);
		printString(" ticks.\n");
		#endif
		YKCurrentTask->delayTicks += ticks;
	}
	
	YKRemoveFromList(YKCurrentTask);
	YKAddToSuspendedList(YKCurrentTask);
	
	//Call the software interrupt that causes a task switch
	asm("int 11h");
	//we will resume from here when we finished the delay ticks
	YKExitMutex(); 
	
}

YKSEM* YKSemCreate(int initialValue){
	YKSEM* newSem = &YKSemaphores[YKSemaphoreIndex];
	YKEnterMutex();
	newSem->count = initialValue;
	newSem->tasks = NULL;
	++YKSemaphoreIndex;
	
	#if DEBUG == 1
	printString("Creating new semaphore: 0x");
	printWord((int)newSem);
	printString("\n");
	#endif
	
	YKExitMutex();
	return newSem;
}
void YKSemPend(YKSEM *semaphore){
	YKEnterMutex();
	#if DEUBG == 1
	printString("Waiting on Semaphore 0x");
	printWord((int) semaphore);
	#endif
	
	
	if (semaphore->count > 0){
		--(semaphore->count);
		return;
	}
	#if DEUBG == 1
	printNewLine();
	#endif
	
	YKRemoveFromList(YKCurrentTask);
	YKCurrentTask->next = semaphore->tasks;
	semaphore->tasks = YKCurrentTask;
	
	//Call the software interrupt that causes a task switch
	if (YKISRDepth == 0)
		asm("int 11h");
	
	YKExitMutex();
	
}
void YKSemPost(YKSEM *semaphore){
	TCBp currTask;
	TCBp addTask;
	YKEnterMutex();
	#if DEUBG == 1
	printString("Posting on Semaphore 0x");
	printWord((int) semaphore);
	printString(" Current Tasks waiting:");	
	printTCB(semaphore->tasks);
	#endif
	
	++(semaphore->count);
	
	currTask = semaphore->tasks;
	if (currTask != NULL)
		--(semaphore->count);
	
	while (currTask != NULL && currTask != currTask->next){
		addTask = currTask;
		currTask = currTask->next;
		YKAddToReadyList(addTask);
	}
	semaphore->tasks = NULL;
	if (YKISRDepth == 0){
		asm("int 11h");
	}
	YKExitMutex();	
	#if DEUBG == 1
	printString(" Current Tasks waiting:");	
	printTCB(semaphore->tasks);
	#endif
}

/* ----------------- Helper functions TCB structure ----------------- */
void printCurrentTask(){
	printTCB(YKCurrentTask);
}
void printTCB(void* ptcb){
	TCBp tcb = (TCBp) ptcb;
	
	if (ptcb == NULL){
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
	if (tcb->next != NULL){
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
