;----------------------------------------------------------
; Calculats video segments coordinates
;----------------------------------------------------------
; Entry:	BH = number of row
;		BL = number of column
; Expects:	None
; Destroys:	AX
; Exit:		DX
;----------------------------------------------------------
GetVideoAddress	proc
		mov al, bh
		mov dh, 160d
		mul dh
		
		mov dx, ax
		mov al, bl
		add al, bl
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
;		DI
;		SI
; Exit:		None
;----------------------------------------------------------
PrintString	proc

		mov di, bx

@@Next:		mov cl, [si]
		cmp cl, 0
		je @@Exit

		mov byte ptr es:[di],   cl 	; symbol
		mov byte ptr es:[di+1], ch	; color

		add di, 2
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
;		SI = string address
; Expects:	None	
; Destroys:	AX
;		CL
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


;----------------------------------------------------------
; Scans a 16 bit number from keyboard to AX
;----------------------------------------------------------
; Entry:	None
; Destroys:	BX
;		CX
;		DX
;		DI
;		SI
; Exit:		AX
;----------------------------------------------------------
MAX  EQU 5
BASE EQU 10

scanf		proc

		mov ax, 0C0Ah	
		mov dx, offset buffer
		int 21h

		mov si, offset buffer + 1
		mov cl, [si]		; cx == number of digits
		mov ch, 0

		mov ax, 1
		mov bx, BASE

		mov di, 0

@@GetPow10:	mul bx
		loop @@GetPow10
		div bx			; 
		mov bx, ax		; bx = 10^(cx-1)

		mov cl, [si]		; cx == number of digits
		mov ch, 0
		inc si			; [si] = first digit
		mov dx, 0

@@Next:		mov al, [si]
		sub al, '0'
		mov ah, 0
		mul bx

		cmp dx, 0
		jne @@Error	

		add di, ax
		jb @@Error
		
		mov dx, 0
		mov ax, bx
		mov bx, BASE
		div bx
		mov bx, ax
		inc si
		loop @@Next
		
		mov ah, 02h
		mov dl, 0Ah 	; '\n'
		int 21h

		mov ax, di
		jmp @@Exit

@@Error:	mov ah, 09h
		mov dx, offset ErrMessage
		int 21h

@@Exit:		ret
		endp	
;----------------------------------------------------------
buffer db MAX+1, MAX+2 DUP (0Dh)

ErrMessage db "You've entered too big value$"
;----------------------------------------------------------
