.model tiny
.code
org 100h
locals @@

Start:		mov bh, 3d
		mov bl, 15d
		call GetVideoAddress
 
		mov ax, 0B800h
		mov es, ax

		mov bx, dx
		mov si, offset Message
		mov ch, 19h
		call PrintMessage

		mov ah, 4Ch
		int 21h

Message:	db 'Hello, world!', 0

;------------------------------------------------------
; Calculate video segment coordinates
;------------------------------------------------------
; Entry:	BH = number of column
;		BL = number of row
; Expects:	None
; Destroys:	AX
; Exit:		DX
;------------------------------------------------------
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
;------------------------------------------------------


;------------------------------------------------------
; Prints message on the screen
;------------------------------------------------------
; Entry:	SI = Message offset
;		BX = Video Seg coordinates
;		CH = color attributes 
; Expects:	ES -> Video Seg
; Destroys:	AX
;		DH
;		SI
; Exit:		None
;-----------------------------------------------------
PrintMessage	proc

@@Next:		mov dh, [si]
		cmp dh, 0
		je @@End

		mov byte ptr es:[bx],   dh 	; symbol
		mov byte ptr es:[bx+1], ch	; color

		add bx, 2
		inc si
		jmp @@Next

@@End:	 	ret
		endp				
;-----------------------------------------------------
	
end		Start		