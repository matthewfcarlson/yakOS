#line 1 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/lab8app.c"
#line 6 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/lab8app.c"
#line 1 "clib.h"



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
#line 7 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/lab8app.c"
#line 1 "simptris.h"


void SlidePiece(int ID, int direction);
void RotatePiece(int ID, int direction);
void SeedSimptris(int seed);
void StartSimptris(void);
#line 8 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/lab8app.c"
#line 1 "YAKkernel.h"
#line 31 "YAKkernel.h"
typedef struct semaphore
{
    int count;
    void* tasks;

} YKSEM;

struct msg
{
    int tick;
    int data;
};

typedef void* YKQ;

typedef void* YKEVENT;

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


extern unsigned YKCtxSwCount;
extern unsigned YKIdleCount;
#line 9 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/lab8app.c"




extern void printTaskLists();



int STaskStk[ 512 ];
int PlayerTaskStk[ 512 ];
int BrainTaskStk[ 512 ];



YKSEM *SimptrisReadySemPtr;
YKSEM * SimptrisPieceSemPtr;

void *CommandQueue[ 8 ];
YKQ *CommandQPtr;

extern int NewPieceID;

void STask(void)
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


void PlayerTask(){
	char command =  4 ;

	while(1){

		printTaskLists();
		YKSemPend(SimptrisReadySemPtr);
		printString("Waiting for command\n");

		command = (int) YKQPend(CommandQPtr);

		printString("Sending command ");
		printInt(command);
		printString("\n");

		switch(command){
			case  4 :
				RotatePiece(NewPieceID,1);
				break;
			case  3 :
				RotatePiece(NewPieceID,0);
				break;
			case  2 :
				SlidePiece(NewPieceID,0);
				break;
			case  1 :
				SlidePiece(NewPieceID,1);
				break;
		}
		printString("Command sent\n");
	}
}


void BrainTask(){
	while(1){

		YKSemPend(SimptrisPieceSemPtr);
		printString("Brain is thinking\n");
		YKQPost(CommandQPtr,(void*) 2 );
		YKQPost(CommandQPtr,(void*) 2 );
		YKQPost(CommandQPtr,(void*) 2 );
	}
}


void main(void)
{
    YKInitialize();



    YKNewTask(STask, (void *) &STaskStk[ 512 ], 0);
	YKNewTask(PlayerTask, (void *) &PlayerTaskStk[ 512 ], 1);
	YKNewTask(BrainTask, (void *) &BrainTaskStk[ 512 ], 2);

    SeedSimptris(100);

	SimptrisReadySemPtr = YKSemCreate(0);
	SimptrisPieceSemPtr = YKSemCreate(0);
	CommandQPtr = YKQCreate(CommandQueue,  8 );

    YKRun();
}
