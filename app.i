#line 1 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/lab4b_app.c"
#line 7 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/lab4b_app.c"
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
#line 8 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/lab4b_app.c"
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
void YKEnterISR();
void YKExitISR();
void YKTickHandler();
void printTCB(void* ptcb);




extern int YKCtxSwCount;
extern int YKIdleCount;
#line 9 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/lab4b_app.c"





int AStk[ 256 ];
int BStk[ 256 ];
int CStk[ 256 ];

void ATask(void);
void BTask(void);
void CTask(void);

void main(void)
{
    YKInitialize();

    printString("Creating task A...\n");
    YKNewTask(ATask, (void *)&AStk[ 256 ], 5);

    printString("Starting kernel...\n");
    YKRun();
}

void ATask(void)
{
    printString("Task A started!\n");

    printString("Creating low priority task B...\n");
    YKNewTask(BTask, (void *)&BStk[ 256 ], 7);

    printString("Creating task C...\n");
    YKNewTask(CTask, (void *)&CStk[ 256 ], 2);

    printString("Task A is still running! Oh no! Task A was supposed to stop.\n");
    exit(0);
}

void BTask(void)
{
    printString("Task B started! Oh no! Task B wasn't supposed to run.\n");
    exit(0);
}

void CTask(void)
{
    int count;
    unsigned numCtxSwitches;

    YKEnterMutex();
    numCtxSwitches = YKCtxSwCount;
    YKExitMutex();

    printString("Task C started after ");
    printUInt(numCtxSwitches);
    printString(" context switches!\n");

    while (1)
    {
	printString("Executing in task C.\n");
        for(count = 0; count < 5000; count++);
    }
}
