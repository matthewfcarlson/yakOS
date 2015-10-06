#include "YAKkernel.h"


int YKCtxSwCount; // - Global variable that tracks context switches 
int YKIdleCount;  // - Global variable incremented by idle task 

// - Initializes all required kernel data structures 
void YKInitialize(){
	
} 
// - Disables interrupts 
void YKEnterMutex(){
	
}
// - Enables interrupts 
void YKExitMutex(){
	
}
// - Kernel's idle task 
void YKIdleTask(){
	
}   
// - Creates a new task 
void YKNewTask(void* taskFunc, void* taskStack, int priority){
	
}
// - Starts actual execution of user code 	
void YKRun(){
	
}
// - Determines the highest priority ready task 
void YKScheduler(){
	
}
// - Begins or resumes execution of the next task
void YKDispatcher(){
	
}
