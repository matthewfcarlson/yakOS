/*
The YAK kernel functions
*/
#define NULL 0
#define MAX_TASKS 5
#define DEFAULTSTACKSIZE 100

void YKInitialize(); // - Initializes all required kernel data structures 
void YKEnterMutex(); // - Disables interrupts 
void YKExitMutex();  // - Enables interrupts 
void YKIdleTask();   // - Kernel's idle task 
void YKNewTask(void* taskFunc, void* taskStack, int priority);	 // - Creates a new task 
void YKRun();		 // - Starts actual execution of user code 
void YKScheduler();	 // - Determines the highest priority ready task 
void YKDispatcher(); // - Begins or resumes execution of the next task
void YKEnterISR();
void YKExitISR(); 



//Global Variables extern since they are defined in the c code
extern int YKCtxSwCount; // - Global variable that tracks context switches 
extern int YKIdleCount;  // - Global variable incremented by idle task 
