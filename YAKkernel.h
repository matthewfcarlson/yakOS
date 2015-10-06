/*
The YAK kernel functions
*/
#define NULL 0

void YKInitialize(); // - Initializes all required kernel data structures 
void YKEnterMutex(); // - Disables interrupts 
void YKExitMutex();  // - Enables interrupts 
void YKIdleTask();   // - Kernel's idle task 
void YKNewTask(void* taskFunc, void* taskStack, int priority);	 // - Creates a new task 
void YKRun();		 // - Starts actual execution of user code 
void YKScheduler();	 // - Determines the highest priority ready task 
void YKDispatcher(); // - Begins or resumes execution of the next task 

