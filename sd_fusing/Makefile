.SUFFIXES : .c .o
.PHONY: all _depend dep clean new 

CC		= gcc
ASM		=
LINK		=
LIBCC		= ar
RM		= rm

#----------------------------------------------------------------------------------------------
INCPATH		=
LIBPATH		= 
OBJPATH		= .
OUTPATH		= .
SOURCEPATH	= .

LDFLAGS		= -L$(LIBPATH) 
#LFLAGS		= -lm
ASFLAGS		=
ARFLAGS		= -ruv
CFLAGS		= -o

LIBS =

#---------------------------------------------------------------------------------------
SOURCES = $(OBJECTS:.o=.c)


all:
	$(CC) $(CFLAGS)	mkbl1 C110-EVT1-mkbl1.c 
	$(CC) $(CFLAGS)	sd_fdisk sd_fdisk.c

#---------------------------------------------------------------------------------------
.c.o:
		$(CC) $(CFLAGS) -c $< -o $@

_depend:  

dep:
		gccmakedep	$(SOURCES)

#---------------------------------------------------------------------------------------
clean:
		$(RM)		-rf sd_fdisk
		$(RM)		-rf mkbl1

new:
		$(MAKE)		clean
		$(MAKE)

