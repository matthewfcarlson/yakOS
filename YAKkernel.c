#include "YAKkernel.h"
#include "clib.h"
#define DEBUG 0
#define DEBUG_QUEUE 0

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

/* ----------------- Message Queue Array ----------------- */
typedef struct YKMessQueue{
	unsigned head;
	unsigned tail;
	unsigned size;
	unsigned length;
	void**	 queue;
	void* 	 tasks;
} YKMQ;
YKMQ YKQueues[MAX_QUEUES];
int YKQueueIndex = 0;

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
void YKUpdateSuspendedTasks();
void printQueue(YKMQ* queue);


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
	//make sure we have interrupts on
	while(1){ //Just spin in idle and count to 1000
		YKEnterMutex(); 
		//We enter mutex here not for atomic reasons but so that the idle takes 4 instructions as per spec 
		++YKIdleCount;
		YKExitMutex();
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

//Decrements the delays in the suspended list typically run from TickHandler
void YKUpdateSuspendedTasks(){
	TCBp currTCB = YKSuspendedTasks;
	TCBp movingTCB = NULL;
	
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

// Message queue functions
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

/* A function called by a task to delay if there's nothing in the queue 
		return the message at the front of the queue when you return*/

void* YKQPend(YKQ *queue){
	void* message;
	YKMQ* messQ = (YKMQ*)queue;
	
	#if DEBUG==1 || DEBUG_QUEUE == 1
	printString("Pending on Queue\n");
	printQueue(messQ);
	#endif
	
	YKEnterMutex();
	//if there isn't anything in the queue delay the task
	if (messQ->length == 0){
		#if DEBUG==1 || DEBUG_QUEUE == 1
		printString("Delaying current Task for Queue\n");
		#endif
		
		//Check to make sure there isn't already a task waiting
		if (messQ->tasks != NULL){
			printString("\n\nERROR: TWO TASKS ARE WAITING ON THE SAME QUEUE.----------------------\n\n");
			YKDelayTask(2);
		}
		
		//Add the current task to the queue's suspended list
		YKRemoveFromList(YKCurrentTask);
		//Set the queue's task list head as the current task
		YKCurrentTask->next = messQ->tasks;
		messQ->tasks = YKCurrentTask;
		if (YKISRDepth == 0){
			//generate the hardware interrupt that will save context and switch away
			asm("int 11h");
		}
		else{
			//You shouldn't ever pend on a queue in an ISR but if you do, then this will run
			printString("\n\nERROR: CANNOT SWITCH TASK SINCE IN ISR------------------------\n\n");
			exit(6); //if you get an exit code 6 then you did something realy dumb
		}
	}	
	YKExitMutex();
	//We will be delayed here since we exit mutex
	YKEnterMutex();
	
	//If we return to this point then there is something in the queue
	messQ->length = messQ->length - 1;
	
	//Get the message from the queue
	message = messQ->queue[messQ->head];
	
	//Set the Head correctly
	++(messQ->head);
	if (messQ->head == messQ->size )
		messQ->head = 0;
	
	#if DEBUG==1 || DEBUG_QUEUE == 1
	printString("Returning Message: 0x");
	printWord((int)message);
	printString("\n");
	YKExitMutex();
	#endif
	
	return message;
	
}

/* Posts to a message queue */
/*		Returns 0 if full, otherwise the length of the queue */
int YKQPost(YKQ *queue, void *msg){
	YKMQ* messQ = (YKMQ*)queue;
	TCBp currTask;
	TCBp addTask;
	
	//Make sure we aren't interrupted
	YKEnterMutex();
	
	#if DEBUG==1 || DEBUG_QUEUE == 1
	printQueue(messQ);
	printString("Adding to queue with ");
	printInt(messQ->length);
	printString(" messages.\n");
	#endif
	
	//If we are already full don't try to post
	if (messQ->length >= messQ->size){
		#if DEBUG==1 || DEBUG_QUEUE == 1
		printString("Overflow of Queue\n");
		#endif
		//return 0 so they know we are full
		return 0;
	}
	
	//Add to the queue and increase it's count
	++(messQ->length);
	messQ->queue[messQ->tail] = msg;
	
	//Set the tail to the next open location
	++(messQ->tail);
	if (messQ->tail == messQ->size )
		messQ->tail = 0;
	
	//Reactivate all the tasks waiting on this queue
	currTask = messQ->tasks;
	while (currTask != NULL && currTask != currTask->next){
		addTask = currTask;
		currTask = currTask->next;
		YKAddToReadyList(addTask);
	}
	//make sure there aren't any tasks waiting for this queue anymore
	messQ->tasks = NULL;	
	
	YKExitMutex();
	return messQ->length;
}

/* ----------------- Helper functions TCB structure ----------------- */
void printCurrentTask(){
	printTCB(YKCurrentTask);
}

//Prints the queue and it's waiting tasks
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

//print a task control black and if it has a next task then print that until it's not null
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

//prints the ready, suspended, and semaphore blocked task lists
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
