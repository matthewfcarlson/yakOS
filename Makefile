#####################################################################
# ECEn 425 Lab 3 Makefile

ifeq ($(OS),Windows_NT)
	COMPILER = mcpp

else
	COMPILER = cpp

endif

l7.bin:		lab7final.s
		nasm lab7final.s -o l7.bin -l l7.lst

lab7final.s:	clib.s YAKos.s ISRHandlers.s YAKkernel.s app.s
		cat clib.s YAKos.s ISRHandlers.s YAKkernel.s app.s > lab7final.s

#kernel code
YAKkernel.s:	YAKkernel.c
		$(COMPILER) YAKkernel.c YAKkernel.i
#ISR code
		c86 -g YAKkernel.i YAKkernel.s
ISRHandlers.s:	ISRHandlers.c
		$(COMPILER) ISRHandlers.c ISRHandlers.i
		c86 -g ISRHandlers.i ISRHandlers.s	

#app code
app.s:	lab7app.c
		$(COMPILER) lab7app.c app.i
		c86 -g app.i app.s

clean:
		rm lab4.bin lab4.lst l6.bin lab7.lst lab6final.s ISRHandlers.s ISRHandlers.i YAKkernel.s YAKkernel.i app.i app.s 

