# 1 "YAKkernel.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "YAKkernel.c"
# 1 "YAKkernel.h" 1
# 12 "YAKkernel.h"
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
void YKDelayTask(int ticks);




extern unsigned YKCtxSwCount;
extern unsigned YKIdleCount;
# 2 "YAKkernel.c" 2
# 1 "clib.h" 1



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
# 3 "YAKkernel.c" 2


typedef struct taskblock *TCBp;

typedef struct taskblock
{
    void* stackPtr;
    int state;
    int priority;
    int delayTicks;
    TCBp next;
    TCBp prev;
} TCB;


TCBp YKCurrentTask;
TCBp YKReadyTasks;
TCBp YKSuspendedTasks;

TCB YKTCBs[5 +1];
int YKTCBMallocIndex;


int IdleStack[100];


unsigned YKCtxSwCount;
unsigned YKIdleCount;
unsigned YKISRDepth;
int YKIsRunning;


void YKAddToSuspendedList(TCBp task);
void YKAddToReadyList(TCBp task);
void YKRemoveFromList(TCBp task);
void printCurrentTask();
void printTCB(void* ptcb);
void SwitchContext();




void YKInitialize(){
 YKEnterMutex();


 YKCtxSwCount = 0;
 YKISRDepth = 0;
 YKIdleCount = 0;
 YKReadyTasks = 0;
 YKSuspendedTasks = 0;

 YKCurrentTask = 0;
 YKTCBMallocIndex = 0;
 YKIsRunning = 0;


 YKNewTask(YKIdleTask, &IdleStack[100],255);
 YKExitMutex();
}


void YKEnterMutex(){
 asm("cli");

}

void YKExitMutex(){
 asm("sti");
}


void YKEnterISR(){

 ++YKISRDepth;
}


void YKExitISR(){
 --YKISRDepth;


 if (YKISRDepth == 0){

  YKScheduler();
 }

}

void YKIdleTask(){
 int i = 0;

 YKExitMutex();
 while(1){

   ++YKIdleCount;



 }

}

void YKNewTask(void* taskFunc, void* taskStack, int priority){
 TCBp newTask = &YKTCBs[YKTCBMallocIndex];
 int* newStackSP = (int*)taskStack;
 YKEnterMutex();
 ++YKTCBMallocIndex;
 YKExitMutex();


 printString("\nBP at 0x");
 printWord((int)taskStack);




 *(newStackSP) = 64;
 --newStackSP;
 *(newStackSP) = 0;
 --newStackSP;
 *(newStackSP) = (int)taskFunc;
 newStackSP = newStackSP - 8;


 printString("\nSP at 0x");
 printWord((int)newStackSP);


 newTask->stackPtr = (int*)newStackSP;



 newTask->priority = priority;
 newTask->next = 0;
 newTask->prev = 0;
 newTask->delayTicks = 0;
 newTask->state = 1;

 YKAddToReadyList(newTask);
 if (YKIsRunning)
  YKScheduler();
}

void YKRun(){

 printString("Starting Yak OS (c) 2015\n");

 YKIsRunning = 1;
 YKScheduler();


}

void YKScheduler(){
 TCBp tst = YKReadyTasks;
 TCBp tst2 = YKSuspendedTasks;
 YKEnterMutex();

 printString("Scheduler ");



 if (YKReadyTasks != YKCurrentTask){

  YKCurrentTask = YKReadyTasks;
  ++YKCtxSwCount;

  printString("Switching context to task#");
  printInt(YKCurrentTask->priority);
  printString("\n");
  printString("\ntask ready list: \n");
  while(tst->next != 0){
    printInt(tst->priority);
    printString("\n");
    tst = tst->next;
   }
  printString("\n");
  printString("\ntask suspeneded list: \n");
  printInt(tst2->priority);
  printString("\n");
  while(tst2->next != 0){
   tst2 = tst2->next;
    printInt(tst2->priority);
    printString("\n");
   }


 }
 YKDispatcher();
}


void YKDispatcher(){

 void* newSP = YKCurrentTask->stackPtr;

 SwitchContext();
}



void YKTickHandler(){
 static int tickCount = 0;
 TCBp currTCB = YKSuspendedTasks;
 TCBp tst2 = YKSuspendedTasks;
 TCBp movingTCB = 0;

 ++tickCount;
 printString("\nTick ");
 printInt(tickCount);
 printString("\n");
# 224 "YAKkernel.c"
 while (currTCB != 0){
  currTCB->delayTicks = currTCB->delayTicks -1 ;

  if (currTCB->delayTicks <= 0){


   printString("Adding task #");
   printInt(currTCB->priority);
   printString(" back to the ready list\n");



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



void YKAddToReadyList(TCBp newTask){
 int priority = newTask->priority;
 TCBp taskListPtr = YKReadyTasks;

 if (YKReadyTasks == 0){
  YKReadyTasks = newTask;
  YKReadyTasks-> prev = 0;

 } else if(YKReadyTasks->priority > priority){
  newTask->next = YKReadyTasks;
  YKReadyTasks->prev = newTask;
  YKReadyTasks = newTask;
 }

 else{

  while (taskListPtr->next != 0 && taskListPtr->next->priority < priority){
   taskListPtr = taskListPtr -> next;
  }

  newTask-> next = taskListPtr -> next;
  taskListPtr->next = newTask;

 }
}

void YKAddToSuspendedList(TCBp task){

 printString("adding task to suspeneded list: ");
 printInt(task->priority);
 printString("\n");

 if(YKSuspendedTasks == 0){
  YKSuspendedTasks = task;
  task->next = 0;
  task->prev = 0;
 }
 else{
  task->next = YKSuspendedTasks;
  YKSuspendedTasks->prev = task;
  YKSuspendedTasks = task;
 }
}


void YKRemoveFromList(TCBp task){
 if (YKReadyTasks == task){
  YKReadyTasks = task->next;
 }
 else if (YKSuspendedTasks == task){
  YKSuspendedTasks = task->next;
 }

 if (task->next != 0){
  task->next->prev = task->prev;
 }
 if (task->prev != 0){
  task->prev->next = task->next;
 }
}


void YKDelayTask(int ticks){
 YKEnterMutex();
 if (ticks > 0){

  printString("Delaying\n\n");

  YKCurrentTask->delayTicks += ticks;
 }

 YKRemoveFromList(YKCurrentTask);
 YKAddToSuspendedList(YKCurrentTask);


 asm("int 11h");

 YKExitMutex();

}


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
 if (tcb->next != 0){
  printString("->");
  printTCB(tcb->next);
 }
 else
  printString(" \n");
}
