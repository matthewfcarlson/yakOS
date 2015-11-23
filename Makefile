#####################################################################
# ECEn 425 Lab 3 Makefile

ifeq ($(OS),Windows_NT)
	COMPILER = mcpp

else
	COMPILER = cpp

endif

l8.bin:		lab8final.s
		nasm lab8final.s -o l8.bin -l l8.lst

lab8final.s:	clib.s YAKos.s ISRHandlers.s YAKkernel.s app.s
		cat clib.s YAKos.s ISRHandlers.s simptris.s YAKkernel.s app.s > lab8final.s

#kernel code
YAKkernel.s:	YAKkernel.c
		$(COMPILER) YAKkernel.c YAKkernel.i
#ISR code
		c86 -g YAKkernel.i YAKkernel.s
ISRHandlers.s:	ISRHandlers.c
		$(COMPILER) ISRHandlers.c ISRHandlers.i
		c86 -g ISRHandlers.i ISRHandlers.s	

#app code
app.s:	lab8app.c
		$(COMPILER) lab8app.c app.i
		c86 -g app.i app.s

clean:
		rm l8.lst l8.bin ISRHandlers.s ISRHandlers.i YAKkernel.s YAKkernel.i app.i app.s 

