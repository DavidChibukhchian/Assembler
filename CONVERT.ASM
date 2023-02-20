.model tiny
.code
locals @@
org 100h

Start:		mov ax, 127d		; number
		mov bx, 2d		; base
		mov si, offset res	; string -> res
		call Converter

		mov bh, 5d
		mov bl, 7d
		call GetVideoAddress

		mov bx, dx
		mov si, offset res
		mov ch, 19h
		mov ax, 0B800h
		mov es, ax
		call PrintMessage		
		
		mov ax, 4C00h
		int 21h

;----------------------------------------------------------
; Converts a number to system with base BX and puts
; result in any string of length 16
;----------------------------------------------------------
; Entry:	AX = number
;		BX = base
;		SI = address of string
; Expects:	None	
; Destroys:	CL
;		DX
; Exit:		None
;----------------------------------------------------------
Converter	proc
		
		mov dx, 00h 		; (DX,AX) - dword
		add si, 0Fh		; si -> end of string
		mov byte ptr [si+1], 0 	; puts \0 to the end
		mov cl, 16d		; counter = 16

@@Next_Digit:	dec cl
		div bx

		cmp dl, 10d
		jb Small_Base  
	
Big_Base:	sub dl, 10d
		add dl, 'A'
		sub dl, '0'

Small_Base:	add dl, '0'

		mov [si], dl
		dec si
		cmp ax, 0
		je @@Fill_Zero
		
		mov dx, 00h
		jmp @@Next_Digit		
		
@@Fill_Zero:	cmp cl, 0
		je @@Exit
		mov byte ptr [si], '0'
		dec si
		dec cl
		jmp @@Fill_Zero

@@Exit:		ret
		endp
;----------------------------------------------------------

res db 17 DUP('$')

include library.asm

end		Start
