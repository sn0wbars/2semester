#include <stdio.h>
#define BREAK\
	__asm nop; 		  \
	__asm nop; 		  \
	__asm nop; 		  \
	__asm nop; 		  \
	__asm nop; 		  \
	__asm int 3; 	  \
	__asm nop; 		  \
	__asm nop; 		  \
	__asm nop; 		  \
	__asm nop; 		  \
	__asm nop;		  \

extern "C" int printfr(char*, ...);

int main()
{	
	printf("Start\n");
	BREAK
	printfr("1111111%d111%c111", 40, 223);
	return 0;
}
