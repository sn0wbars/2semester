;=================================================
; 0-Nasm+Alink.asm                     (c)Ded,2012
;=================================================

; nasm    "0-Nasm+Alink.asm" -f obj -l "0-Nasm+Alink.lst"
; alink   "0-Nasm+Alink.obj" -oPE -c -subsys console
; ndisasm "0-Nasm+Alink.exe" -b 32 -e 512 > "0-Nasm+Alink.disasm"

; Hardcoded addrs are valid for Microsoft Windows [Version 10.0.10240] ONLY!
; Run "0-Nasm+Alink.in.bat" to get .asm file for exactly your version.

section .code use32

start:        push -11                  ; STD_OUTPUT_HANDLE = -11
                mov eax, 07674a060h       ; GetStdHandle
                call eax                  ; eax = stdout = GetStdHandle (STD_OUTPUT_HANDLE = -11)

                xor edx, edx
                push edx                  ; Resvd = 0
                push edx                  ; Ptr to number of chars written = NULL
                push 5                    ; sizeof ("Text\n")
                push dword MsgText
                push eax                  ; stdout = GetStdHandle (STD_OUTPUT_HANDLE) 
                mov eax, 076756910h       ; WriteConsoleA
                call eax                  ; WriteConsoleA (stdout, MsgText, 5, NULL, 0)

                push 0767574f0h           ; ExitProcess
                ret                       ; he-he

MsgText         db "Text", 0ah

 