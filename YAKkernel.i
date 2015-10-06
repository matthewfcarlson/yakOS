#line 1 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/YAKkernel.c"
#line 1 "YAKkernel.h"
#line 6 "YAKkernel.h"
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


int YKCtxSwCount;
int YKIdleCount;


void YKInitialize(){

}

void YKEnterMutex(){

}

void YKExitMutex(){

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
