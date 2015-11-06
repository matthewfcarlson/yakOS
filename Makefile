#####################################################################
# ECEn 425 Lab 3 Makefile

ifeq ($(OS),Windows_NT)
	COMPILER = mcpp

else
	COMPILER = cpp

endif

l6.bin:		lab6final.s
		nasm lab6final.s -o l6.bin -l l6.lst

lab6final.s:	clib.s YAKos.s ISRHandlers.s YAKkernel.s app.s
		cat clib.s YAKos.s ISRHandlers.s YAKkernel.s app.s > lab6final.s

#kernel code
YAKkernel.s:	YAKkernel.c
		$(COMPILER) YAKkernel.c YAKkernel.i
#ISR code
		c86 -g YAKkernel.i YAKkernel.s
ISRHandlers.s:	ISRHandlers.c
		$(COMPILER) ISRHandlers.c ISRHandlers.i
		c86 -g ISRHandlers.i ISRHandlers.s	

#app code
app.s:	lab6app.c
		$(COMPILER) lab6app.c app.i
		c86 -g app.i app.s

clean:
		rm lab4.bin lab4.lst l6.bin lab6.lst lab6final.s ISRHandlers.s ISRHandlers.i YAKkernel.s YAKkernel.i app.i app.s 

