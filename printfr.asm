%define ExitProcess _ExitProcess@4
%define GetStdHandle _GetStdHandle@4
%define WriteConsoleA _WriteConsoleA@20
; %define MessageBoxA _MessageBoxA@16
; %define ReadConsoleA _ReadConsoleA@20

extern _printf
extern GetStdHandle
;import GetStdHandle kernel32.dll 
extern WriteConsoleA
;import WriteConsoleA user32.dll
extern ExitProcess
;import ExitProcess kernel32.dll
; extern MessageBoxA
; ;import MessageBoxA user32.dll
; extern ReadConsoleA
; ;import ReadConsoleA user32.dll

STD_INPUT_HANDLE equ -10
STD_OUTPUT_HANDLE equ -11 

section .code use32
global _printfr

;-----------Strlen---------------------------------------------------------;
;  entry: edi - adress of string										   ;
;  destr: eax, ecx, edi													   ;
;  exit: eсx - num of characters before '0', edi - adress of last symbol   ;
;--------------------------------------------------------------------------;
Strlen:		push ebp
			mov ebp, esp
			pushf
			cld
			
			mov ecx, -1
			xor al,al
			repne scasb
			not ecx
			dec edi
			dec edi
			dec ecx
			
			popf
			leave 
			ret

;-----------ItoA-----------------------------------------------------------;
;  entry: eax - number, edi - adress of string destination,				   ;
;   ebx = adress of translation table, ecx - base of numeral system( < 36h);
;  destr: eax, edi, edx													   ;
;  exit: [esi] - string of ascii codes, edi - pointer to begin of string   ;
;--------------------------------------------------------------------------;
ItoA32:		
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
			
;-----------EasyWrite@2---------------------------------------------------;
;  entry: 1. num of printing symbols									  ;
;		  2. adress of begin											  ;
;  destr: 																  ;
;  exit: 									 							  ;
;-------------------------------------------------------------------------;
EasyWrite:			push ebp
					mov ebp, esp
					
					push ecx
					push eax

write:		
					push STD_OUTPUT_HANDLE
					call GetStdHandle
					
					xor ecx, ecx
					push ecx
					push ecx
					
					push dword [ebp + 8] ; num of symbols		
					push dword [ebp + 12]
					
					push eax
					call WriteConsoleA	
					
					pop ecx
					pop eax
					
					mov esp, ebp
					pop ebp
					ret

;-----------_printfr--------------------------------------------------;
;  entry:  1. adress of string; Any number of parametres in stack     ;
;								  									  ;
;  destr: eax, ebx, ecx, edx, esi, edi								  ;
;  exit: eax - number												  ;
;---------------------------------------------------------------------;
_printfr:			push ebp
					mov ebp, esp
					;STR_LENw0 equ [ebp - 4]
					sub esp, 8;optim
					
					 push string
					 call _printf
					
					 mov edi, [ebp + 8]
					 mov esi, edi; esi - pointer to begin of string
					 mov ecx, -1
					 cld
					 mov al, 0
					 repne scasb
					 ;cmp edi,0  jmp error 
					 not ecx; lenght of string
					 dec ecx; without '0'
					 mov [ebp - 4], ecx; save it for later
					 dec edi; edi - pointer to last "real" symblol
					 
					 std
					 mov al, '%'
					 repne scasb ; check is there any '%' 
					 jne WriteText ; if not use simple print
					 
					 mov ecx, [ebp - 4]
					 
					 cld
					 mov edx, 1;edx - num of blocks
					 mov edi, esi
					 mov ebx, ecx
					 repne scasb 
BuildMAP:			 ;;;;;;;;;;;;;;;;
					 sub ebx, ecx; num of symbols in block
					 dec ebx
					 push ebx
					 ;inc edi; to get letter after '%'
					 
					 ;xor ebx, ebx
					 ;mov bl, [edi]; !!!!!!!!!!!
					 ;push ebx; optim
					 inc edi; to skip format letter
					 dec ecx; to skip format letter
					 
					 mov ebx, ecx
					 repne scasb 
					 
					 inc edx; edx - num of blocks
					 test ecx, ecx
					 jne BuildMAP
					 ;;;;;;;;;;;;;;;;
					 sub ebx, ecx; num of symbols in block
					 push ebx
					 
					 std
					 xor eax, eax; ah - symbol
					 add esi, [ebp - 4]; esi - end of string
					 dec esi; one extra
					 mov edi, esp 
					 sub edi, 24; edi - end of output
					 mov [ebp - 8], edi
					 lea ebx, [ebp + 12];ebx - contains parametres
CreatOutputString:	 pop ecx
					 rep movsb 
					 mov al, [esi]
					 cmp al, 'd'
					 je ItoD
					 
					 cmp al, 'o'
					 je ItoO
					 
					 cmp al, 'x'
					 je ItoX
					 
					 cmp al, 'b'
					 je ItoB
					 
					 cmp al, 'c'
					 je ItoC
					 
					 cmp al, 's'
					 je ItoS
					 
SwitchEnd:			 add ebx, 4; next parameter
					 dec esi
					 dec esi
					 
					 dec edx
					 jnz CreatOutputString
					 
					 inc edi; one extra 
					 mov esi, [ebp - 8]
					 sub esi, edi
					 inc esi
					 mov esp, edi
					 
WriteF:		         push edi
					 push esi
					 call EasyWrite
					 jmp printfrLeave
WriteText: 			 
					 push esi
					 push dword [ebp - 4]
					 call EasyWrite		 
printfrLeave:		 
					 cld
					 leave 
					 ret					 
					 
ItoC:				 mov eax, [ebx]
					 mov [edi], al
					 dec edi
					 jmp SwitchEnd

ItoO:				 mov eax, [ebx]
ItoOnext:			 shl eax, 5
					 shr al, 5
					 add al, '0'
					 mov [edi], al
					 dec edi
					 shr eax, 8
					 test al, al
					 jne ItoOnext
					 mov al, [ebx + 3]
					 test al, al
					 je SwitchEnd
					 shr al, 5
					 add al, '0'
					 mov [edi], al
					 dec edi
					 jmp SwitchEnd
					 
ItoB:				 mov eax, [ebx]
ItoBnext:			 shl eax, 7
					 shr al, 7
					 add al, '0'
					 mov [edi], al
					 dec edi
					 shr eax, 8
					 test al, al
					 jne ItoBnext
					 mov al, [ebx + 3]
					 test al, al
					 je SwitchEnd
					 shr al, 7
					 add al, '0'
					 mov [edi], al
					 dec edi
					 jmp SwitchEnd

ItoX:				 mov eax, [ebx]
ItoXnext:			 shl eax, 4
					 shr al, 4
					 cmp al,  10d
					 sbb al, 69h
					 das
					 mov [edi], al
					 dec edi
					 shr eax, 8
					 test al, al
					 jne ItoXnext
					 mov al, [ebx + 3]
					 test al, al
					 je SwitchEnd
					 shr al, 4
					 cmp al, 10d
					 sbb al, 69h
					 das
					 mov [edi], al
					 dec edi
					 
					 jmp SwitchEnd
					 
ItoD:				 
					 mov eax, [ebx]
					 push edx
					 push ebx
					 
					 mov ecx, 10d
					 mov ebx, HexStr
					 call ItoA32
					 
					 pop ebx
					 pop edx
					 jmp SwitchEnd
					 
					 
ItoS:				 push ecx
					 push esi
					 push edi
					 
					 mov edi, [ebx]
					 call Strlen
					 mov esi, edi
					 pop edi
					 rep movsb
					 
					 pop esi
					 pop ecx 
					 jmp SwitchEnd
					 
; start:
					 
					 
					 ; push 123d
					 ; push 1234d
					 ; push HexStr
					 ; push 65530
					 ; push String2
					 ; push '<'
					 ; push '3'
					 ; push 3802
					 ; push 100d
					 ; push edi, String
					 
				
					 ; call _printfr
					
; exit:				 push 0
					 ; call ExitProcess
					
section .data use32
					;String2 db 'And I',0
					HexStr db '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', 0
					string db '╔═══════════════════════════════════════════════════════════════╗', 0dh, 0ah,
							  '║ printfr - format print                                        ║', 0dh, 0ah,
							  '║ entry: 1.adress of string; Any number of parametres in stack  ║', 0dh, 0ah, 
							  '║ destr: eax, ebx, ecx, edx, esi, edi                           ║', 0dh, 0ah, 
							  '║ exit: eax - number                                            ║', 0dh, 0ah,'╚═══════════════════════════════════════════════════════════════╝', 0dh, 0ah, 0