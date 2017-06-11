extern GetStdHandle
extern WriteConsoleA
extern ExitProcess
extern MessageBoxA
extern ReadConsoleA

section .code write use64 
STD_INPUT_HANDLE equ -10
STD_OUTPUT_HANDLE equ -11 
NUM_OF_DIGITS equ 100
NUM_OF_SYMBOLS equ (NUM_OF_DIGITS + 2) 

start:	
			call checkHash
			mov byte al, [isOK]
			test al, al
			jnz end
			mov r8, GreetMessage.len
			mov rdx, GreetMessage
			call EasyWrite
			
			mov rdx, Loginbuffer
			call EasyRead
			
			jmp login_check

;-----------EasyWrite-----------------------------------------------------;
;  entry: r8 -  num of printing symbols									  ;
;		  rdx - adress of begin								      		  ;
;  destr: 						    									  ;
;  exit: 									 							  ;
;-------------------------------------------------------------------------;
EasyWrite:			push rbp
					mov rbp, rsp

					mov rcx, STD_OUTPUT_HANDLE
					call [GetStdHandle]
									
					mov rcx, rax
					xor r9, r9
					push r9
					call [WriteConsoleA]

					mov rsp, rbp; leave
					pop rbp
					ret

;-----------EasyRead------------------------------------------------------;
;  entry: rdx(2) - adress of buffer										  ;
;  destr: rdi, rax						    					 	      ;
;  exit: 									 							  ;
;-------------------------------------------------------------------------;

EasyRead:			
					push rbp
					mov rbp, rsp
					mov rcx, STD_INPUT_HANDLE 
					call [GetStdHandle]
					
					mov rcx, rax;(1)
					mov r8, NUM_OF_SYMBOLS; (3)
					mov r9, numofread; (4) 
					xor rax, rax
					push rax
					call [ReadConsoleA]
					
					leave
					ret
					
login_check:		
					xor rax, rax
					xor rdx, rdx
					mov rcx, TotallyNotPsword.len
					mov R10, Loginbuffer
					mov R11, Error1
					mov al, ':'
					mov rdi, TotallyNotPsword	
					cld
					repne scasb
NextCheck:			
					mov dl, [rdi]
					inc rdi
					sub dl, al
					test dl, dl
					jz return
					shl dx, 8
					shr dx, 8
					mov dl, [Error1 + rdx]
					cmp dl, [R10]
					jne wrongLogin
					inc R10
					jmp NextCheck

wrongLogin:	
					mov r8, Error1.len
					mov rdx, Error1
					call EasyWrite
			
					mov rdx, Answer
					call EasyRead
			
					mov al, [Answer]
					cmp al, 'Y'
					je start
					cmp al, 'N'
					je end
					jmp wrongLogin
			
wrongPassword:
					mov r8, Error2.len
					mov rdx, Error2
					call EasyWrite
					
					mov rdx, Answer
					call EasyRead
					
					mov al, [Answer]
					cmp al, 'Y'
					je password_check
					cmp al, 'N'
					je end
					jmp wrongPassword
					
checkHash:
					;cld	
					mov rax, start
					mov rcx, rax
					xor rdx, rdx
next:		
					mov dl, [rcx]
					xor rax, rdx 			
					rol rax, 1
					inc rcx
					cmp rcx, end
					jb next
					mov [hash2], rax
					cmp rax, [hash]
					jne error 
					ret
error:				mov byte [isOK], 13
message:
					xor rcx, rcx
					mov rdx, Msg
					xor r8,r8
					xor r9,r9
					call [MessageBoxA]
					ret	

return:	
					call checkHash
					mov byte al, [isOK]
					test al, al
					jnz end
			
password_check:			
					mov r8, Password.len
					mov rdx, Password
					call EasyWrite
					
					mov rdx, Passwordbuffer
					call EasyRead			
					
					mov rax, [hash]
					not rax
					mov r9, [Passwordbuffer]	
					cmp r9, rax
					jne wrongPassword
					mov byte al, [isOK]
					test al, al
					jnz end
					mov r8, AccessReserved.len
					mov rdx, AccessReserved
					call EasyWrite
					
end:				cld
					xor rcx, rcx
					call [ExitProcess]

section .data

GreetMessage db 'Greetings!', 0dh, 0ah, '@Username, enter your login and password plz', 0dh, 0ah, 'Login:',  0
GreetMessage.len equ $ - GreetMessage
Password db 'Password:', 0
Password.len equ $ - Password 

Passwordbuffer resb (NUM_OF_SYMBOLS + 1); +1
Answer resb 3
isOK db 0
numofread resq 1
hash dq 0D9191099B84DA603h
hash2 resq 1
Loginbuffer resb (NUM_OF_SYMBOLS - 2); +1
TotallyNotPsword db 'NFJLdjsdjfhhfqzFJnaYwjgYAUpyX9T15LiVmQIUSZmfIp4A85RJuIomALfrvScvBIygD0JoIlt:;Ocno:8ge4oQvwNjHy3oXz0wU5eKet0ZCbklmhhiwoi1113', 0
TotallyNotPsword.len equ $ - TotallyNotPsword
Error1 db 'Fail! No such login! Do you try to trick me? Try again?(Y/N)', 0dh, 0ah
Error1.len equ $ - Error1
Error2 db 'Game over! Wrong Password. Try again?(Y/N)', 0dh, 0ah
Error2.len equ $ - Error2
Smthing db 'When life gives you lemons, make lemonade', 0
TryAgain db 'Try again?(Y/N)', 0dh, 0ah, '>'
TryAgain.len equ $ - TryAgain
Msg db "Error", 0dh, 0ah, 0
Msg.len equ $ - Msg
AccessReserved db 'Access granted. You won!'
AccessReserved.len equ $ - AccessReserved