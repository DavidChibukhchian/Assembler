;----------------------------------------------------------
; Calculates video segment coordinates
;----------------------------------------------------------
; Entry:	BH = number of column
;		BL = number of row
; Expects:	None
; Destroys:	AX
; Exit:		DX
;----------------------------------------------------------
GetVideoAddress	proc
		mov al, bl
		mov dh, 160d
		mul dh
		
		mov dx, ax
		mov al, bh
		add al, bh
		cbw
		
		add dx, ax

		ret
		endp
;----------------------------------------------------------


;----------------------------------------------------------
; Prints a string on the screen
;----------------------------------------------------------
; Entry: 	BX = video segment coordinates
;		CH = color attributes 
;		SI = address of string
; Expects:	ES -> Video Segment
; Destroys:	AX
;		DH
;		SI
; Exit:		None
;----------------------------------------------------------
PrintString	proc

@@Next:		mov dh, [si]
		cmp dh, 0
		je @@Exit

		mov byte ptr es:[bx],   dh 	; symbol
		mov byte ptr es:[bx+1], ch	; color

		add bx, 2
		inc si
		jmp @@Next

@@Exit:	 	ret
		endp				
;----------------------------------------------------------


;----------------------------------------------------------
; Converts a number to system with base BX and puts
; result in any string of length 17
;----------------------------------------------------------
; Entry:	AX = number
;		BX = base
;		SI = address of string
; Expects:	None	
; Destroys:	CL
;		DX
;		SI
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
