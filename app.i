# 1 "lab4d_app.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "lab4d_app.c"






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
# 8 "lab4d_app.c" 2
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
# 9 "lab4d_app.c" 2






int AStk[256];
int BStk[256];
int CStk[256];
int DStk[256];

void ATask(void);
void BTask(void);
void CTask(void);
void DTask(void);

void main(void)
{
    YKInitialize();

    printString("Creating tasks...\n");
    YKNewTask(ATask, (void *) &AStk[256], 3);
    YKNewTask(BTask, (void *) &BStk[256], 5);
    YKNewTask(CTask, (void *) &CStk[256], 7);
    YKNewTask(DTask, (void *) &DStk[256], 8);

    printString("Starting kernel...\n");
    YKRun();
}

void ATask(void)
{
    printString("Task A started.\n");
    while (1)
    {
        printString("Task A, delaying 2.\n");
        YKDelayTask(2);
    }
}

void BTask(void)
{
    printString("Task B started.\n");
    while (1)
    {
        printString("Task B, delaying 3.\n");
        YKDelayTask(3);
    }
}

void CTask(void)
{
    printString("Task C started.\n");
    while (1)
    {
        printString("Task C, delaying 5.\n");
        YKDelayTask(5);
    }
}

void DTask(void)
{
    printString("Task D started.\n");
    while (1)
    {
        printString("Task D, delaying 10.\n");
        YKDelayTask(10);
    }
}
