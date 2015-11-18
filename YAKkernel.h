/*
The YAK kernel functions
*/
#define NULL 0
#define MAX_TASKS 5
#define MAX_QUEUES 5
#define DEFAULTSTACKSIZE 100
#define DEFAULTFLAGS 64
#define STATE_RUNNING   1
#define STATE_DELAYED   2
#define STATE_SUSPENDED 3
#define MAX_SEMAPHORES  5
#define DISPLAY_TICKS 	0 	//if you want TICK n to show
#define MSGARRAYSIZE      20

typedef struct semaphore
{
    int count;			/* the current current state */
    void* tasks;		/* current delayed tasks */
    
}  YKSEM;



struct msg 
{
    int tick;
    int data;
};

typedef void* YKQ;

typedef void* YKEVENT; 

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

//Global Variables extern since they are defined in the c code
extern unsigned YKCtxSwCount; // - Global variable that tracks context switches 
extern unsigned YKIdleCount;  // - Global variable incremented by idle task

