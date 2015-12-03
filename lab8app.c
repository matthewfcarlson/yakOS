/* 
File: lab8app.c
Revision date: 10 November 2005
Description: Application code for EE 425 lab 8 (tetris)
*/
#include "clib.h"
#include "simptris.h"
#include "YAKkernel.h"

#define TASK_STACK_SIZE   512         /* stack size in words */
#define COMMANDQUEUESIZE 25
#define DEBUG_SIMPTRIS 0

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
extern int ScreenBitMap0;
extern int ScreenBitMap1;
extern int ScreenBitMap2;
extern int ScreenBitMap3;
extern int ScreenBitMap4;
extern int ScreenBitMap5;
extern int NewPieceType;
extern int NewPieceOrientation;
extern int NewPieceColumn;
extern int TouchdownID;

int BrainMoveTo();
int BrainRotateTo();


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
	unsigned rawCommand;
	unsigned pieceID;
	
	while(1){
		//wait for received
		//printTaskLists();
		YKSemPend(SimptrisReadySemPtr);
		#if DEBUG_SIMPTRIS == 1
		printString("Waiting for command\n");
		#endif
		
		rawCommand = (unsigned) YKQPend(CommandQPtr); /* get next msg */\
		pieceID = rawCommand & (0x0FFF);
		command = rawCommand >> 12;

		#if DEBUG_SIMPTRIS == 1
		
		printString("Sending command ");
		printWord(rawCommand);
		printString(" Command:");
		printInt(command);
		printString(" for block ");
		printInt(pieceID);
		printString("\n");
		#endif
		//execute command
		switch(command){
			case ROTATE_RIGHT:
				RotatePiece(pieceID,1);
				break;
			case ROTATE_LEFT:
				RotatePiece(pieceID,0);
				break;
			case SLIDE_LEFT:
				SlidePiece(pieceID,0);
				break;
			case SLIDE_RIGHT:
				SlidePiece(pieceID,1);
				break;
			default:
				printString("-----UNKNWON COMMAND----\n");
		}
		#if DEBUG_SIMPTRIS == 1
		printString("Command sent\n");
		#endif
	}
} 
//Column type is 0 if flat, 1 if a corner, 2 if not
char side1Height = 0;
char side2Height = 0;
char side1Type = 0;
char side2Type = 0;
int desiredColumn = 0;
int desiredRotation = 0;
int currentColumn = 0;
int currentRotation = 0;
int currentPieceID = 0;
void BrainCommand(int commd);


//Makes all movement decisions and puts them in the queue
void BrainTask(){
	
	while(1){
		//wait for a new piece
		YKSemPend(SimptrisPieceSemPtr);
		#if DEBUG_SIMPTRIS == 1
		printString("Brain is thinking about new ");
		printInt(NewPieceType);
		printString(" piece.  Side1:");
		printInt(side1Type);
		printString("@");
		printInt(side1Height);
		printString(" Side2:");
		printInt(side2Type);
		printString("@");
		printInt(side2Height);
		printNewLine();
		
		#endif
		
		currentColumn   = NewPieceColumn + 1;
		currentRotation = NewPieceOrientation;
		currentPieceID  = NewPieceID;
		
		switch(NewPieceType){
			case 0: //corner piece						
				desiredColumn = 1;
				desiredRotation = NewPieceOrientation;
				if (side1Type == 1 && (NewPieceOrientation != 0 || side2Type == 0)){
					//side 1 is now flat
					side1Type = 0;
					desiredColumn = 3;
					desiredRotation = 2;
					++side1Height;
				}				
				else if(side1Type == 2 && (NewPieceOrientation != 2 || side2Type == 0)){
					//side 1 is now flat
					side1Type = 0;
					desiredColumn = 1;
					desiredRotation = 3;
					++side1Height;
				}
				else if (side2Type == 1 && (NewPieceOrientation != 0 || side1Type == 0)){
					//side 2 is now flat
					side2Type = 0;
					desiredRotation = 2;
					desiredColumn = 6;
					++side2Height;
				}				
				else if(side2Type == 2 && (NewPieceOrientation != 2 || side1Type == 0)){
					//side 2 is now flat
					side2Type = 0;
					desiredColumn = 4;
					desiredRotation = 3;
					++side2Height;
				}
 			 	else if (side1Type == 0 && (side2Type != 0 || side1Height <= side2Height)){
				 	//maybe also check where the piece is appearing and put it on the closest side
				 	++side1Height;
				 	if (desiredRotation == 2){
				 		desiredRotation = 1;
				 	}
				 	else if (desiredRotation == 3){
				 		desiredRotation = 0;
				 	}
				 	side1Type = desiredRotation + 1;
				 	if (desiredRotation == 0){
				 		desiredColumn = 1;				 		
				 	}
				 	else if (desiredRotation == 1){
				 		desiredColumn = 3;
				 	}
				}

 			 	else if (side2Type == 0 && (side1Type != 0 || side1Height >= side2Height)){
				 	//maybe also check where the piece is appearing and put it on the closest side
				 	++side2Height;
					if (desiredRotation == 2){
				 		desiredRotation = 1;
				 	}
				 	else if (desiredRotation == 3){
				 		desiredRotation = 0;
				 	}
				 	side2Type = desiredRotation + 1;
				 	if (desiredRotation == 0){
				 		desiredColumn = 4;
				 	}
				 	else if (desiredRotation == 1){
				 		desiredColumn = 6;
				 	}
				}

				else{
					printString("-----------UNABLE TO PLACE PIECE!!!!!---------------\n");
				}
				break;
			case 1: //straight piece
				desiredColumn 	= 2; //left side
				desiredRotation = 0;
				 if (side2Type == 0 && (side1Type != 0 || side1Height >= side2Height)){
				 	//maybe also check where the piece is appearing and put it on the closest side
				 	++side2Height;
					desiredColumn = 5; //right side		
				}
				else if (side1Type != 0 && side2Type != 0)
					printString("-----------UNABLE TO PLACE PIECE!!!!!---------------\n");
				else{
					++side1Height;
				}
				break;
		}
		#if DEBUG_SIMPTRIS == 1
		printString("Moving to:");
		printInt(desiredColumn);
		printString(" from:");
		printInt(currentColumn);
		printString(" and Rotated to:");
		printInt(desiredRotation);
		printString(" from:");
		printInt(currentRotation);
		#endif

		while (BrainRotateTo());
		while (BrainMoveTo());
		
		#if DEBUG_SIMPTRIS == 1
		printNewLine();
		#endif

		
		
	}
}

//attempts a move returning 0 if there is no more moves to be made
int BrainMoveTo(){
	if (desiredColumn > currentColumn){
		//printString("Slide Right\n");
		BrainCommand(SLIDE_RIGHT);
		++currentColumn;
	} 
	else if (desiredColumn < currentColumn){
		//printString("Slide Left\n");
		BrainCommand(SLIDE_LEFT);
		--currentColumn;
	} 

	return currentColumn != desiredColumn;
}
//attemps a move returning 0 if there are more moves to be made
int BrainRotateTo(){
	if (currentColumn == 1 && currentRotation != desiredRotation){
		if (currentColumn != desiredColumn){
			BrainMoveTo();
		}
		else{
			//move right once
			printString("Moving right for proper rotation\n");
			BrainCommand(SLIDE_RIGHT);
			currentColumn = 2;
		}
	}
	else if (currentColumn == 6 && currentRotation != desiredRotation){
		if (currentColumn != desiredColumn){
			BrainMoveTo();
		}
		else{
			//move left once
			printString("Moving left for proper rotation\n");
			BrainCommand(SLIDE_LEFT);
			currentColumn = 5;
		}
	}

	if (desiredRotation == 3 && currentRotation == 0){
		//printString("Rotate Right\n");
		BrainCommand(ROTATE_RIGHT);		
		currentRotation = 3;
	}
	else if (desiredRotation == 0 && currentRotation == 3){
		//printString("Rotate Left\n");
		BrainCommand(ROTATE_LEFT);
		currentRotation = 0;
	}
	else if (desiredRotation < currentRotation){
		//printString("Rotate RIGHT\n");
		BrainCommand(ROTATE_RIGHT);
		++desiredRotation;
	}
	else if (desiredRotation > currentRotation){
		//printString("Rotate LEFT\n");
		BrainCommand(ROTATE_LEFT);
		--desiredRotation;
	}
	
	return currentRotation != desiredRotation;
}
void BrainCommand(int command){
	unsigned messageQCommand = (command << 12) | (currentPieceID);
	#if DEBUG_SIMPTRIS == 1
	printString("Queueing command: 0x");
	printWord(messageQCommand);
	printNewLine();
	#endif
	YKQPost(CommandQPtr,(void*)messageQCommand);

}



void main(void)
{
    YKInitialize();

    //charEvent = YKEventCreate(0);
    //numEvent = YKEventCreate(0);
    YKNewTask(STask, (void *) &STaskStk[TASK_STACK_SIZE], 0);
	YKNewTask(PlayerTask, (void *) &PlayerTaskStk[TASK_STACK_SIZE], 1);
	YKNewTask(BrainTask, (void *) &BrainTaskStk[TASK_STACK_SIZE], 2);
	
    SeedSimptris(10947);
	
	SimptrisReadySemPtr = YKSemCreate(0);
	SimptrisPieceSemPtr = YKSemCreate(0);
	CommandQPtr = YKQCreate(CommandQueue, COMMANDQUEUESIZE);
	
    YKRun();
}
