;----------------------------------------------------------
; Calculate Video Seg coordinates
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
; Prints message on the screen
;----------------------------------------------------------
; Entry:	SI = Message offset
;		BX = video segment coordinates
;		CH = color attributes 
; Expects:	ES -> Video Seg
; Destroys:	AX
;		DH
;		SI
; Exit:		None
;----------------------------------------------------------
PrintMessage	proc

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