section .code use 32
global _summ
_summ:
		enter 0,0
		mov eax, dword [ebp + 8]
		add eax, dword [ebp + 12]
		leave
		ret
