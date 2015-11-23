/* 
File: lab8app.c
Revision date: 10 November 2005
Description: Application code for EE 425 lab 8 (tetris)
*/
#include "clib.h"
#include "simptris.h"
#include "YAKkernel.h"

#define TASK_STACK_SIZE   512         /* stack size in words */



int STaskStk[TASK_STACK_SIZE];     /* a stack for each task */




void STask(void)           /* tracks statistics */
{
    unsigned max, switchCount, idleCount;
    int tmp;

    YKDelayTask(1);
    printString("Welcome to the YAK kernel\r\n");
    printString("Determining CPU capacity\r\n");
    YKDelayTask(1);
    YKIdleCount = 0;
    YKDelayTask(5);
    max = YKIdleCount / 25;
    YKIdleCount = 0;
	printString("Starting Simptris\n");
	StartSimptris();
    while (1)
    {
        YKDelayTask(20);
        
        YKEnterMutex();
        switchCount = YKCtxSwCount;
        idleCount = YKIdleCount;
        YKExitMutex();
        
        printString("<CS: ");
        printInt((int)switchCount);
        printString(", CPU: ");
        tmp = (int) (idleCount/max);
        printInt(100-tmp);
        printString("% >\r\n");
        
        YKEnterMutex();
        YKCtxSwCount = 0;
        YKIdleCount = 0;
        YKExitMutex();
    }
}   


void main(void)
{
    YKInitialize();

    //charEvent = YKEventCreate(0);
    //numEvent = YKEventCreate(0);
    YKNewTask(STask, (void *) &STaskStk[TASK_STACK_SIZE], 0);
	
    SeedSimptris(1234);
	
    YKRun();
}
