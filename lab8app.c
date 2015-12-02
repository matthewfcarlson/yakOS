/* 
File: lab8app.c
Revision date: 10 November 2005
Description: Application code for EE 425 lab 8 (tetris)
*/
#include "clib.h"
#include "simptris.h"
#include "YAKkernel.h"

#define TASK_STACK_SIZE   512         /* stack size in words */
#define COMMANDQUEUESIZE 8

extern void printTaskLists();



int STaskStk[TASK_STACK_SIZE];     /* a stack for each task */
int PlayerTaskStk[TASK_STACK_SIZE];
int BrainTaskStk[TASK_STACK_SIZE];


//Tetris Ready Semaphore
YKSEM *SimptrisReadySemPtr;
YKSEM * SimptrisPieceSemPtr;

void *CommandQueue[COMMANDQUEUESIZE];    /* space for message queue */
YKQ *CommandQPtr;                  			 /* actual name of queue */

extern int NewPieceID;

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
	YKSemPost(SimptrisReadySemPtr);
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

//The thumbs which play the game, taking commands from the brain and sending it to tetris
void PlayerTask(){
	char command = ROTATE_RIGHT;
	
	while(1){
		//wait for received
		printTaskLists();
		YKSemPend(SimptrisReadySemPtr);
		printString("Waiting for command\n");
		//wait for command queue
		command = (int) YKQPend(CommandQPtr); /* get next msg */
		//update block ID
		printString("Sending command ");
		printInt(command);
		printString("\n");
		//execute command
		switch(command){
			case ROTATE_RIGHT:
				RotatePiece(NewPieceID,1);
				break;
			case ROTATE_LEFT:
				RotatePiece(NewPieceID,0);
				break;
			case SLIDE_LEFT:
				SlidePiece(NewPieceID,0);
				break;
			case SLIDE_RIGHT:
				SlidePiece(NewPieceID,1);
				break;
		}
		printString("Command sent\n");
	}
} 

//Makes all movement decisions and puts them in the queue
void BrainTask(){
	while(1){
		//wait for a new piece
		YKSemPend(SimptrisPieceSemPtr);
		printString("Brain is thinking\n");
		YKQPost(CommandQPtr,(void*)SLIDE_LEFT);
		YKQPost(CommandQPtr,(void*)SLIDE_LEFT);
		YKQPost(CommandQPtr,(void*)SLIDE_LEFT);
	}
}


void main(void)
{
    YKInitialize();

    //charEvent = YKEventCreate(0);
    //numEvent = YKEventCreate(0);
    YKNewTask(STask, (void *) &STaskStk[TASK_STACK_SIZE], 0);
	YKNewTask(PlayerTask, (void *) &PlayerTaskStk[TASK_STACK_SIZE], 1);
	YKNewTask(BrainTask, (void *) &BrainTaskStk[TASK_STACK_SIZE], 2);
	
    SeedSimptris(100);
	
	SimptrisReadySemPtr = YKSemCreate(0);
	SimptrisPieceSemPtr = YKSemCreate(0);
	CommandQPtr = YKQCreate(CommandQueue, COMMANDQUEUESIZE);
	
    YKRun();
}
