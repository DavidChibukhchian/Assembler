;-----------------------------------------------------------
; Draws a frame on the screen
;-----------------------------------------------------------
; Entry:			BX = video segment coordinates
;					CH = color attributes of frame symbol
;					CL = color attributes of space symbol		
;					DH = height
;					DL = width
; Expects:			ES -> video segment
; Destroys:			AX
; Exit:				None
;-----------------------------------------------------------
new_line 			EQU 160d

DrawFrame			proc
					push dx bx cx

					mov ah, 0C9h
					mov al, 0CDh
					mov cl, ch
					call DrawLine
					pop cx

					push bx dx
					xor dh, dh
					add bx, dx
					add bx, dx
					sub bx, 2
					mov byte ptr es:[bx], 0BBh
					pop dx bx

					add bx, new_line
					dec dh 		

					mov ah, 0BAh
					mov al, ' '
		
@@Next_Line:		cmp dh, 1
					je @@Exit

					call DrawLine
					add bx, new_line
					dec dh
					jmp @@Next_Line

@@Exit:				push cx
					mov cl, ch
					mov ah, 0C8h
					mov al, 0CDh
					call DrawLine
					pop cx
					
					xor dh, dh
					add bx, dx
					add bx, dx
					sub bx, 2
					mov byte ptr es:[bx], 0BCh

					pop bx dx
					ret
					endp
;-----------------------------------------------------------



;-----------------------------------------------------------
; Draws a line on the screen
;-----------------------------------------------------------
; Entry:			AH = frame symbol
;					AL = space symbol
;					BX = video segment coordinates
;					CH = color of the frame symbol
;					CL = color of the space symbol
;					DL = width
; Expects:			ES -> video segment
; Destroys:			None
; Exit:				None	
;-----------------------------------------------------------
size_of_pixel 		EQU 2

DrawLine			proc
					push bx dx

					sub dl, size_of_pixel

					mov byte ptr es:[bx],   ah
					mov byte ptr es:[bx+1], ch

@@Next_Symbol:		cmp dl, 0
					je @@Exit

					add bx, size_of_pixel
					mov byte ptr es:[bx],   al
					mov byte ptr es:[bx+1], cl
					dec dl
					jmp @@Next_Symbol
		
@@Exit:				add bx, size_of_pixel
					mov byte ptr es:[bx],   ah
					mov byte ptr es:[bx+1], ch

					pop dx bx
					ret
					endp
;-----------------------------------------------------------



;-----------------------------------------------------------
; Prints a string on the screen
;-----------------------------------------------------------
; Entry: 			BX = video segment coordinates
;					CH = color
;					SI = address of string
; Expects:			ES -> video segment
; Destroys:			CL, SI
; Exit:				None
;-----------------------------------------------------------
PrintString			proc

					push bx

@@Next:				mov cl, [si]
					cmp cl, 0
					je @@Exit

					mov byte ptr es:[bx],   cl
					mov byte ptr es:[bx+1], ch

					add bx, 2
					inc si
					jmp @@Next

@@Exit:	 			pop bx
					ret
					endp				
;-----------------------------------------------------------



;-----------------------------------------------------------
; Draws "HACK ME" in the frame
;-----------------------------------------------------------
; Entry:			AH = color 
;					AL = symbol
; Expects:			ES -> video segment
; Destroys:			BX
; Exit:				None
;-----------------------------------------------------------
Print_HACK_ME		proc

                    mov bx, 160* 3d + 2d
                    mov es:[bx+2*3],  ax
                    mov es:[bx+2*6],  ax
                    mov es:[bx+2*9],  ax
                    mov es:[bx+2*10], ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*14], ax
                    mov es:[bx+2*15], ax
                    mov es:[bx+2*16], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*21], ax
                    mov es:[bx+2*25], ax
                    mov es:[bx+2*29], ax
                    mov es:[bx+2*31], ax
                    mov es:[bx+2*32], ax
                    mov es:[bx+2*33], ax
                    mov es:[bx+2*34], ax

                    add bx, 160d
                    mov es:[bx+2*3],  ax
                    mov es:[bx+2*6],  ax
                    mov es:[bx+2*8],  ax
                    mov es:[bx+2*11], ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*20], ax
                    mov es:[bx+2*25], ax
                    mov es:[bx+2*26], ax
                    mov es:[bx+2*28], ax
                    mov es:[bx+2*29], ax
                    mov es:[bx+2*31], ax

                    add bx, 160d
                    mov es:[bx+2*3],  ax
                    mov es:[bx+2*4],  ax
                    mov es:[bx+2*5],  ax
                    mov es:[bx+2*6],  ax
                    mov es:[bx+2*8],  ax
                    mov es:[bx+2*9],  ax
                    mov es:[bx+2*10], ax
                    mov es:[bx+2*11], ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*19], ax
                    mov es:[bx+2*25], ax
                    mov es:[bx+2*27], ax
                    mov es:[bx+2*29], ax
                    mov es:[bx+2*31], ax
                    mov es:[bx+2*32], ax
                    mov es:[bx+2*33], ax
                    mov es:[bx+2*34], ax

                    add bx, 160d
                    mov es:[bx+2*3],  ax
                    mov es:[bx+2*6],  ax
                    mov es:[bx+2*8],  ax
                    mov es:[bx+2*11], ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*20], ax
                    mov es:[bx+2*25], ax
                    mov es:[bx+2*29], ax
                    mov es:[bx+2*31], ax

                    add bx, 160d
                    mov es:[bx+2*3],  ax
                    mov es:[bx+2*6],  ax
                    mov es:[bx+2*8],  ax
                    mov es:[bx+2*11], ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*14], ax
                    mov es:[bx+2*15], ax
                    mov es:[bx+2*16], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*21], ax
                    mov es:[bx+2*25], ax
                    mov es:[bx+2*29], ax
                    mov es:[bx+2*31], ax
                    mov es:[bx+2*32], ax
                    mov es:[bx+2*33], ax
                    mov es:[bx+2*34], ax

					ret
					endp
;-----------------------------------------------------------



;-----------------------------------------------------------
; Draws a picture in case of right password
;-----------------------------------------------------------
; Entry:			AH = color 
;					AL = symbol
; Expects:			ES -> video segment
; Destroys:			BX, CX, SI
; Exit:				None
;-----------------------------------------------------------
Print_ACCESS_GRANTED proc

					push ax

					mov bx, 160d + 2d
                    mov ch, 5Ch
                    mov cl, 27h
                    mov dh, 13
                    mov dl, 38
                    call DrawFrame

                    mov si, offset AccessGranted
                    mov bx, 160*4d + 2*13d
                    mov ch, 3Ah
                    call PrintString

					pop ax
                    mov bx, 160*6d

                    mov es:[bx+2*7],  ax
                    mov es:[bx+2*11], ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*14], ax
                    mov es:[bx+2*15], ax
                    mov es:[bx+2*16], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*19], ax
                    mov es:[bx+2*20], ax
                    mov es:[bx+2*21], ax
                    mov es:[bx+2*23], ax
                    mov es:[bx+2*24], ax
                    mov es:[bx+2*25], ax
                    mov es:[bx+2*26], ax
                    mov es:[bx+2*28], ax
                    mov es:[bx+2*30], ax
                    mov es:[bx+2*32], ax

                    add bx, 160d
                    mov es:[bx+2*8],  ax
                    mov es:[bx+2*9],  ax
                    mov es:[bx+2*10], ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*16], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*21], ax
                    mov es:[bx+2*23], ax
                    mov es:[bx+2*26], ax
                    mov es:[bx+2*28], ax
                    mov es:[bx+2*30], ax
                    mov es:[bx+2*32], ax

                    add bx, 160d
                    mov es:[bx+2*9],  ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*16], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*19], ax
                    mov es:[bx+2*20], ax
                    mov es:[bx+2*21], ax
                    mov es:[bx+2*23], ax
                    mov es:[bx+2*26], ax
                    mov es:[bx+2*28], ax
                    mov es:[bx+2*30], ax
                    mov es:[bx+2*32], ax

                    add bx, 160d
                    mov es:[bx+2*8],  ax
                    mov es:[bx+2*9],  ax
                    mov es:[bx+2*10], ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*16], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*23], ax
                    mov es:[bx+2*26], ax
                    mov es:[bx+2*28], ax
                    mov es:[bx+2*30], ax
                    mov es:[bx+2*32], ax

                    add bx, 160d
                    mov es:[bx+2*7],  ax
                    mov es:[bx+2*11], ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*14], ax
                    mov es:[bx+2*15], ax
                    mov es:[bx+2*16], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*23], ax
                    mov es:[bx+2*24], ax
                    mov es:[bx+2*25], ax
                    mov es:[bx+2*26], ax
                    mov es:[bx+2*28], ax
                    mov es:[bx+2*29], ax
                    mov es:[bx+2*30], ax
                    mov es:[bx+2*31], ax
                    mov es:[bx+2*32], ax

					ret
					endp
;-----------------------------------------------------------



;-----------------------------------------------------------
; Draws a picture in case of wrong password
;-----------------------------------------------------------
; Entry:			AH = color
;					AL = symbol
; Expects:			ES -> video segment
; Destroys:			AX, BX, CX, DX, ES, SI, DI
; Exit:				None
;-----------------------------------------------------------
Print_ACCESS_DENIED	proc

					push ax

					mov bx, 160d + 2d
                    mov ch, 5Ch
                    mov cl, 47h
                    mov dh, 13
                    mov dl, 38
                    call DrawFrame

                    mov si, offset AccessDenied
                    mov bx, 160*4d + 2*13d
                    mov ch, 3Ch
                    call PrintString

                    pop ax
					mov bx, 160*6d

                    mov es:[bx+2*8],  ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*14], ax
                    mov es:[bx+2*15], ax
                    mov es:[bx+2*16], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*19], ax
                    mov es:[bx+2*20], ax
                    mov es:[bx+2*21], ax
                    mov es:[bx+2*23], ax
                    mov es:[bx+2*24], ax
                    mov es:[bx+2*25], ax
                    mov es:[bx+2*26], ax
                    mov es:[bx+2*28], ax
                    mov es:[bx+2*29], ax
                    mov es:[bx+2*30], ax
                    mov es:[bx+2*31], ax

                    add bx, 160d
                    mov es:[bx+2*8],  ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*16], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*23], ax
                    mov es:[bx+2*28], ax
                    mov es:[bx+2*31], ax

                    add bx, 160d
                    mov es:[bx+2*8],  ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*16], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*19], ax
                    mov es:[bx+2*20], ax
                    mov es:[bx+2*21], ax
                    mov es:[bx+2*23], ax
                    mov es:[bx+2*24], ax
                    mov es:[bx+2*25], ax
                    mov es:[bx+2*26], ax
                    mov es:[bx+2*28], ax
                    mov es:[bx+2*29], ax
                    mov es:[bx+2*30], ax
                    mov es:[bx+2*31], ax

                    add bx, 160d
                    mov es:[bx+2*8],  ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*16], ax
                    mov es:[bx+2*21], ax
                    mov es:[bx+2*23], ax
                    mov es:[bx+2*28], ax
                    mov es:[bx+2*30], ax

                    add bx, 160d
                    mov es:[bx+2*8],  ax
                    mov es:[bx+2*9],  ax
                    mov es:[bx+2*10], ax
                    mov es:[bx+2*11], ax
                    mov es:[bx+2*13], ax
                    mov es:[bx+2*14], ax
                    mov es:[bx+2*15], ax
                    mov es:[bx+2*16], ax
                    mov es:[bx+2*18], ax
                    mov es:[bx+2*19], ax
                    mov es:[bx+2*20], ax
                    mov es:[bx+2*21], ax
                    mov es:[bx+2*23], ax
                    mov es:[bx+2*24], ax
                    mov es:[bx+2*25], ax
                    mov es:[bx+2*26], ax
                    mov es:[bx+2*28], ax
                    mov es:[bx+2*31], ax

					ret
					endp
;-----------------------------------------------------------

AccessGranted       db 'ACCESS GRANTED', 0
AccessDenied        db 'ACCESS  DENIED', 0

;-----------------------------------------------------------