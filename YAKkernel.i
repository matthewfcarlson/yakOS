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




extern int YKCtxSwCount;
extern int YKIdleCount;
#line 2 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"


typedef struct taskblock *TCBp;

typedef struct taskblock
{

    void* stackPtr;
    int state;
    int priority;
    int delayTicks;
    TCBp next;

} TCB;



TCBp YKReadyTasks;
TCBp YKSuspendedTasks;
TCBp YKAllTasks;
TCB YKTCBs[ 5 +1];


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



	YKNewTask(YKIdleTask, &IdleStack[ 100 ],255);
	asm("sti");

}


void YKEnterMutex(){
	asm("cli");

}

void YKExitMutex(){
	asm("sti");

}

void YKIdleTask(){

}

void YKNewTask(void* taskFunc, void* taskStack, int priority){

}

void YKRun(){

}

void YKScheduler(){

}

void YKDispatcher(){

}
