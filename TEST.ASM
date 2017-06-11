
 ; Printing "Platy$pus$"
 .model tiny
 .code 
 .286

 org 100h

 start: 
 	mov ah, 02h
	mov dl, 15h										
	int 21h	
	
	mov ax, 4c00h 
	int 21h

 .data
 msg:	db 9, 'Platy$pus$'

 end start																		