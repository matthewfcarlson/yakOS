#line 1 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/lab7app.c"
#line 6 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/lab7app.c"
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
#line 7 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/lab7app.c"
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
#line 8 "C:/Users/matthewfcarlson/Documents/GitHub/yakOS/lab7app.c"




YKEVENT *charEvent;
YKEVENT *numEvent;

int CharTaskStk[ 512 ];
int AllCharsTaskStk[ 512 ];
int AllNumsTaskStk[ 512 ];
int STaskStk[ 512 ];



void CharTask(void)
{
    unsigned events;

    printString("Started CharTask     (2)\n");

    while(1) {
        events = YKEventPend(charEvent,
                             0x1  |  0x2  |  0x4 ,
                             0x8 );

        if(events == 0) {
            printString("Oops! At least one event should be set "
                        "in return value!\n");
        }

        if(events &  0x1 ) {
            printString("CharTask     (A)\n");
            YKEventReset(charEvent,  0x1 );
        }

        if(events &  0x2 ) {
            printString("CharTask     (B)\n");
            YKEventReset(charEvent,  0x2 );
        }

        if(events &  0x4 ) {
            printString("CharTask     (C)\n");
            YKEventReset(charEvent,  0x4 );
        }
    }
}


void AllCharsTask(void)
{
    unsigned events;

    printString("Started AllCharsTask (3)\n");

    while(1) {
        events = YKEventPend(charEvent,
                             0x1  |  0x2  |  0x4 ,
                             0x10 );


        if(events != 0) {
            printString("Oops! Char events weren't reset by CharTask!\n");
        }

        printString("AllCharsTask (D)\n");
    }
}


void AllNumsTask(void)
{
    unsigned events;

    printString("Started AllNumsTask  (1)\n");

    while(1) {
        events = YKEventPend(numEvent,
                             0x1  |  0x2  |  0x4 ,
                             0x10 );

        if(events != ( 0x1  |  0x2  |  0x4 )) {
            printString("Oops! All events should be set in return value!\n");
        }

        printString("AllNumsTask  (123)\n");

        YKEventReset(numEvent,  0x1  |  0x2  |  0x4 );
    }
}


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

    YKNewTask(CharTask, (void *) &CharTaskStk[ 512 ], 2);
    YKNewTask(AllNumsTask, (void *) &AllNumsTaskStk[ 512 ], 1);
    YKNewTask(AllCharsTask, (void *) &AllCharsTaskStk[ 512 ], 3);

    while (1)
    {
        YKDelayTask(20);

        YKEnterMutex();
        switchCount = YKCtxSwCount;
        idleCount = YKIdleCount;
        YKExitMutex();

        printString("<<<<< Context switches: ");
        printInt((int)switchCount);
        printString(", CPU usage: ");
        tmp = (int) (idleCount/max);
        printInt(100-tmp);
        printString("% >>>>>\r\n");

        YKEnterMutex();
        YKCtxSwCount = 0;
        YKIdleCount = 0;
        YKExitMutex();
    }
}


void main(void)
{
    YKInitialize();

    charEvent = YKEventCreate(0);
    numEvent = YKEventCreate(0);
    YKNewTask(STask, (void *) &STaskStk[ 512 ], 0);

    YKRun();
}
