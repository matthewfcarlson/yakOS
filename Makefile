#####################################################################
# ECEn 425 Lab 3 Makefile

ifeq ($(OS),Windows_NT)
	COMPILER = mcpp

else
	COMPILER = cpp

endif

l5.bin:		lab5final.s
		nasm lab5final.s -o l5.bin -l l5.lst

lab5final.s:	clib.s YAKos.s ISRHandlers.s YAKkernel.s app.s
		cat clib.s YAKos.s ISRHandlers.s YAKkernel.s app.s > lab5final.s

#kernel code
YAKkernel.s:	YAKkernel.c
		$(COMPILER) YAKkernel.c YAKkernel.i
#ISR code
		c86 -g YAKkernel.i YAKkernel.s
ISRHandlers.s:	ISRHandlers.c
		$(COMPILER) ISRHandlers.c ISRHandlers.i
		c86 -g ISRHandlers.i ISRHandlers.s	

#app code
app.s:	lab5app.c
		$(COMPILER) lab5app.c app.i
		c86 -g app.i app.s

clean:
		rm lab4.bin lab4.lst l5 lab5.lst lab4final.s lab5final.s ISRHandlers.s ISRHandlers.i YAKkernel.s YAKkernel.i app.i app.s 

