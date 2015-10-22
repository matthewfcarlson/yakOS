#include "clib.h"
extern int KeyBuffer; 

void KeyboardHandler(void){
	int i;
	if(((char) KeyBuffer) == 'd'){
		printNewLine();  
		printString("DELAY KEY PRESSED");
		printNewLine(); 
		for(i = 0; i < 5000; i++){}
		printString("DELAY COMPLETE");
		printNewLine();
	} else{
		printNewLine();  
		printString("KEYPRESS (");
		printChar((char) KeyBuffer); 
		printString(") IGNORED"); 
		printNewLine();
	}
}
