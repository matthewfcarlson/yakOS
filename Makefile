#####################################################################
# ECEn 425 Lab 3 Makefile

ifeq ($(OS),Windows_NT)
	COMPILER = mcpp

else
	COMPILER = cpp

endif

lab4.bin:	lab4final.s
		nasm lab4final.s -o lab4.bin -l lab4.lst

lab4final.s:	clib.s YAKos.s YAKkernel.s app.s
		cat clib.s YAKos.s YAKkernel.s app.s > lab4final.s

#kernel code
YAKkernel.s:	YAKkernel.c
		$(COMPILER) YAKkernel.c YAKkernel.i
		c86 -g YAKkernel.i YAKkernel.s
		

#app code
app.s:	lab4b_app.c
		$(COMPILER) lab4b_app.c app.i
		c86 -g app.i app.s

clean:
		rm lab4.bin lab4.lst lab4final.s YAKkernel.s YAKkernel.i app.i app.s 

