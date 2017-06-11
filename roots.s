; roots.asm
segment .text
global  _roots

_roots:
        enter   0,0
        xor     EAX,EAX
        fld     qword[EBP+8]            ; a
        fadd    ST0                     ; 2a
        fld     qword[EBP+8]            ; a,2a
        fld     qword[EBP+24]           ; c,a,2a
        fmulp   ST1                     ; ac,2a
        fadd    ST0                     ; 2ac,2a
        fadd    st0                     ; 4ac,2a
        fchs                            ; -4ac,2a
        fld     qword[EBP+16]           ; b,-4ac,2a
        fld     qword[EBP+16]           ; b,b,-4ac,2a
        fmulp   ST1                     ; b*b,-4ac,2a
        faddp   ST1                     ; b*b-4ac,2a
        ftst                            ; cmp (b*b-4ac),0
        fstsw   AX                      ; result of test in AX
        sahf                            ; store AH in flag reg
        jb      no_real_roots           ; jb tests the carry flag
        fsqrt                           ; sqrt(b*b-4ac),2a
        fld     qword[EBP+16]           ; b,sqrt(b*b-4ac),2a
        fchs                            ; -b,sqrt(b*b-4ac),2a
        fadd    ST1                     ; -b+sqrt(b*b-4ac),sqrt(b*b-4ac),2a
        fdiv    ST2                     ; -b+sqrt(b*b-4ac)/2a,sqrt(b*b-4ac),2a
        mov     EAX,dword[EBP+32]       ; EAX = -b+sqrt(b*b-4ac)/2a
        fstp    qword[EAX]              ; Store and pop
        fchs                            ; -sqrt(b*b-4ac),2a
        fld     qword[EBP+16]           ; b,-sqrt(b*b-4ac),2a
        fchs                            ; -b,-sqrt(b*b-4ac),2a
        faddp   ST1                     ; -b-sqrt(b*b-4ac),2a
        fdivrp  ST1                     ; -b-sqrt(b*b-4ac)/2a
        mov     EAX,dword[EBP+36]       ; EAX = -b-sqrt(b*b-4ac)/2a
        fstp    qword[EAX]              ; Store and pop
        mov     EAX,1                   ; 1 means real roots
        jmp     short done
no_real_roots:
        fchs                            ; Make b*b-4ac positive
        fsqrt                           ; sqrt(b*b-4ac),2a
        fld     qword[EBP+16]           ; b,sqrt(b*b-4ac),2a
        fchs                            ; -b,sqrt(b*b-4ac),2a
        fadd    ST1                     ; -b+sqrt(b*b-4ac),sqrt(b*b-4ac),2a
        fdiv    ST2                     ; -b+sqrt(b*b-4ac)/2a,sqrt(b*b-4ac),2a
        mov     EAX,dword[EBP+32]       ; EAX = -b+sqrt(b*b-4ac)/2a
        fstp    qword[EAX]              ; Store and pop
        fchs                            ; -sqrt(b*b-4ac),2a
        fld     qword[EBP+16]           ; b,-sqrt(b*b-4ac),2a
        fchs                            ; -b,-sqrt(b*b-4ac),2a
        faddp   ST1                     ; -b-sqrt(b*b-4ac),2a
        fdivrp  ST1                     ; -b-sqrt(b*b-4ac)/2a
        mov     EAX,dword[EBP+36]       ; EAX = -b-sqrt(b*b-4ac)/2a
        fstp    qword[EAX]              ; Store and pop
        sub     EAX,EAX                 ; 0 means no real roots
done:
        leave
        ret
