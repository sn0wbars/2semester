extern GetStdHandle
extern WriteConsoleA
extern ExitProcess
extern MessageBoxA
extern ReadConsoleA

STD_INPUT_HANDLE equ -10
STD_OUTPUT_HANDLE equ -11 
NUM_OF_DIGITS equ 6
NUM_OF_SYMBOLS equ (NUM_OF_DIGITS + 2) 

section .code use32 ;write
	
;-----------AtoI----------------------------------------------------;
;  entry:  esi - adress of string  									;
;  destr: eax, bl, (edx), esi										;
;  exit: eax - number												;
;-------------------------------------------------------------------;
AtoI:		
first_symb:	xor eax, eax
			mov bl, [esi]
			cmp bl, '9'
			jg type_check  ; short optimize?
def:		sub bl, '0'			
			jb end
			jmp ffAtoD
			
type_check:	cmp bl, 'b'
			je AtoB
			cmp bl, 'o'
			je AtoO
			cmp bl, 'h'
			je AtoH
			cmp bl, 'd'
			jne error
			
AtoD:		inc esi
			mov bl, [esi]
		
			cmp bl, '9' ; optimize
			jg end
			sub bl, '0'
			jb end 
									;extra multiply
			lea eax, [eax + eax*4] ; MUL 10   Самоизменяющийся код?
			add eax, eax ;	
		
ffAtoD:		add al, bl
			jmp AtoD
							
AtoB:		inc esi
			mov bl, [esi]

			cmp bl, '1' ; optimize?
			jg end
			sub bl, '0'
			jb end   ; !optim suv -> cmp
			
			add eax, eax ; MUL 2
			
			add al, bl  
			jmp AtoB

AtoO:		inc esi
			mov bl, [esi]

			cmp bl, '7' ; optimize?
			jg end
			sub bl, '0'
			jb end   ; !optim suv -> cmp
			
			shl eax, 3 ; MUL 8
			
			add al, bl  
			jmp AtoO
			
AtoH:		inc esi
			mov bl, [esi]
			
			sub bl, '0'
			jb end
			cmp bl, 09h
			jbe AtoH_next
			sub bl, ('A' - '0') - 10d
			jb end
			cmp bl, 0fh
			jbe AtoH_next
			sub bl, 'a' - 'A'
			jb end
			cmp bl, 0fh
			jbe short AtoH_next
			jmp end
			
AtoH_next: 	shl eax, 4 ; MUL 16
			add al, bl
			jmp AtoH			

end:		ret
			
;-----------ItoA--------------------------------------------------------;
;  entry: eax - number, edi - adress of string destination,				;
;ebx = adress of translation table, cx - base of numeral system( < 36h) ;
;  destr: eax, edi, edx													;
;  exit: [esi] - string of ascii codes, edi - pointer to begin of string;
;-----------------------------------------------------------------------;
ItoA16sbit:		
			std
next16:		
			mov edx, eax
			shr edx, 10h
			div cx ; dword
			
			shl eax, 10h ; xchg
			mov al, dl
			xlat
            stosb
			shr eax, 10h
            
            test al, al; cmp al, 0
            jnz next16
			ret
;------------------------------------------------------------------------;
; -||- ecx - base of numeral system( < 36h)
ItoA32bit:		
			std
next32:		
			xor edx, edx
			div ecx ; word
			xchg edx, eax
			
			xlat
            stosb
			mov eax, edx
            
            test al, al; cmp al, 0
            jnz next32
			ret
;------------------------------------------------------------------------;

;-----------ItoAbinary---------------------------------------------------;
;  entry: eax - number, edi - adress of string destination,				 ;
;ebx = adress of translation table, edx - base of numeral system		 ;
;  destr: eax, edi, (edx)												 ;
;  exit: [esi] - ascii code of number									 ;
;------------------------------------------------------------------------;
;ItoAbinary:
;			std


;-----------Clear_mem@2---------------------------------------------------;
;  entry: 1. adress of end												  ;
;		  2. adress of begin											  ;
;  destr: 						    									  ;
;  exit: 									 							  ;
;-------------------------------------------------------------------------;
Clear_mem@2:  	
			push ebp
			mov ebp, esp
			
			push edi
			push esp
			
			cld
			mov ecx, [ebp + 8d]
			mov edi, [ebp + 12d]
			sub ecx, edi
			inc ecx
			mov al, 00h
			rep stosb
			
			pop edi
			pop esp

			pop ebp
			ret			

;-----------EasyWrite@2---------------------------------------------------;
;  entry: 1. adress of begin												 		  ;
;		  2. adress of end											  ;
;  destr: 						    									  ;
;  exit: 									 							  ;
;-------------------------------------------------------------------------;
EasyWrite:	push ebp
			mov ebp, esp
			
			push ecx
			push eax

write:		push 						;mov dword [buffer_output], eax
			push STD_OUTPUT_HANDLE
			call [GetStdHandle]
			
			xor ecx, ecx
			push ecx
			push ecx
			
			mov ecx, [ebp + 8] ; adress of end
			sub ecx, [ebp + 12] ; num of elements
			inc ecx
			
			push ecx
			push [ebp + 12]
			push eax
			call [WriteConsoleA]
			
			pop ecx
			pop eax
			
			pop ebp
			ret
Printb:
			
			
			
start:						
read: 		push STD_INPUT_HANDLE 
			call [GetStdHandle]
			
			xor edx, edx
			push edx
			push numOfread
			push NUM_OF_SYMBOLS
			push buffer_input
			push eax
			call [ReadConsoleA]
			
			mov esi, buffer_input
			call AtoI
			
			mov edi, buffer_output_end
			mov ebx, HexStr
			mov ecx, 00000010h
			call ItoA32bit
			
			inc edi ; edi - adress of string's begin
			push edi
			push buffer_output_end
			call Clear_mem@2

			
			call Printb
			call Printh
			call Printo
			
exit:		xor eax, eax
			push eax
			call[ExitProcess]
			
error:		
message:
			xor eax, eax
 			push eax
			push eax
			push dword Msg
			push eax
			call [MessageBoxA]
			jmp exit			
			
section .bss use32
			buffer_output resb (4*NUM_OF_SYMBOLS+1)
			buffer_output_end equ $ - 2
			buffer_input resb (NUM_OF_SYMBOLS + 1)
			numOfread resb 1
			
section .data use32
			HexStr db '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', 0
			Msg db "Wrong type", 0dh, 0ah, 0
			Msg.len equ $ - Msg