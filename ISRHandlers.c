#include "clib.h"
#include "YAKkernel.h"


extern YKEVENT *charEvent;
extern YKEVENT *numEvent;

extern int KeyBuffer; 
extern void printTaskLists();

extern void YKUpdateSuspendedTasks();
unsigned YKTickNum = 0;

/* ----------------- ISR handlers ----------------- */
void KeyboardHandler(void){
	char c;
    c = KeyBuffer;

    /*if(c == 'a') YKEventSet(charEvent, EVENT_A_KEY);
    else if(c == 'b') YKEventSet(charEvent, EVENT_B_KEY);
    else if(c == 'c') YKEventSet(charEvent, EVENT_C_KEY);
    else if(c == 'd') YKEventSet(charEvent, EVENT_A_KEY | EVENT_B_KEY | EVENT_C_KEY);
    else if(c == '1') YKEventSet(numEvent, EVENT_1_KEY);
	else if(c == 'l') printTaskLists();
	else if(c == 't') YKTickHandler();
    else if(c == '2') YKEventSet(numEvent, EVENT_2_KEY);
    else if(c == '3') YKEventSet(numEvent, EVENT_3_KEY);
    else {
        print("\nKEYPRESS (", 11);
        printChar(c);
        print(") IGNORED\n", 10);
    }*/
}

//Handles the tick ISR
void YKTickHandler(){
	
	++YKTickNum;
	
	#if DISPLAY_TICKS == 1
	printString("\nTick ");
	printInt(YKTickNum);
	printString("\n");
	#endif

	//This decrements the delay counts for all suspended tasks
	YKUpdateSuspendedTasks();
	
	
}
void STGameOverHandler(){
	printString("\n\nGAME OVER\n");
	exit(2);
	
}
void STNewPieceHandler(){
	printString("New Piece\n");
	
} 
void STReceivedHandler(){
	printString("Received\n");
}
void STTouchdownHandler(){
	printString("Touchdown\n");
	
}
