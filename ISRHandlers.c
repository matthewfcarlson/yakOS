#include "clib.h"
#include "YAKkernel.h"

extern int KeyBuffer; 
extern void printTaskLists();

extern YKQ* MsgQPtr; 
extern struct msg MsgArray[];
extern int GlobalFlag;


extern void YKUpdateSuspendedTasks();
unsigned YKTickNum = 0;

/* ----------------- ISR handlers ----------------- */
void KeyboardHandler(void){
	int i;
	//if any key is pressed set the global flag
	GlobalFlag = 1;
	
	if(((char) KeyBuffer) == 'd'){
		printNewLine();  
		printString("DELAY KEY PRESSED");
		printNewLine(); 
		for(i = 0; i < 5000; i++){}
		printString("DELAY COMPLETE");
		printNewLine();
	}
	else if(((char) KeyBuffer) == 'l'){
		printTaskLists();
	}
	else if(((char) KeyBuffer) == 't'){
		YKTickHandler();
	}
	/*
	//Commented out for lab6
	else{
		printNewLine();  
		printString("KEYPRESS (");
		printChar((char) KeyBuffer); 
		printString(") IGNORED"); 
		printNewLine();
	}
	*/
}

//Handles the tick ISR
void YKTickHandler(){
	
	static int next = 0;
    static int data = 0;
	
	++YKTickNum;
	
	#if DISPLAY_TICKS == 1
	printString("\nTick ");
	printInt(YKTickNum);
	printString("\n");
	#endif

	//This decrements the delay counts for all suspended tasks
	YKUpdateSuspendedTasks();
	
	/* create a message with tick (sequence #) and pseudo-random data */
    MsgArray[next].tick = YKTickNum;
    data = (data + 89) % 100;
    MsgArray[next].data = data;
    if (YKQPost(MsgQPtr, (void *) &(MsgArray[next])) == 0)
	printString("  TickISR: queue overflow! \n");
    else if (++next >= MSGARRAYSIZE)
	next = 0;
	
}

