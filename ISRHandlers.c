#include "clib.h"
#include "YAKkernel.h"
extern int KeyBuffer; 
extern void* NSemPtr;
extern void printTaskLists();


void KeyboardHandler(void){
	int i;
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
	else if(((char) KeyBuffer) == 'l'){
		YKTickHandler();
	}
	else if(((char) KeyBuffer) == 'p'){
		YKSemPost(NSemPtr);
	}
	else{
		printNewLine();  
		printString("KEYPRESS (");
		printChar((char) KeyBuffer); 
		printString(") IGNORED"); 
		printNewLine();
	}
}

