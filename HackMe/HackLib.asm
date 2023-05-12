;-----------------------------------------------------------
; Draws a frame on the screen
;-----------------------------------------------------------
; Entry:            AH = color of frame symbol
;                   AL = color of space symbol
;                   BX = video segment coordinates
;                   DH = height of frame
;                   DL = width  of frame
;                   SI = offset of array of drawing symbols
; Expects:          ES -> video segment
; Destroys:         SI
; Exit:             None
;-----------------------------------------------------------
DrawFrame           proc
                    cld
                    push bx dx

                    push ax
                    mov al, ah                                  ; sets color for space symbol for the first line
                    call DrawLine

                    sub dh, 2
                    add bx, new_line
                    add si, next_3_symbols                      ; sets next 3 symbols for drawing
                    pop ax

@@Next_Line:        cmp dh, 0
                    je @@Normal_Exit
                    call DrawLine

                    add bx, new_line
                    dec dh
                    jmp @@Next_Line


@@Normal_Exit:      push ax
                    add si, next_3_symbols
                    mov al, ah                                  ; sets color for space symbol for the last line
                    call DrawLine
                    pop ax

@@Exit:             pop dx bx
                    ret
                    endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Draws a line on the screen
;-----------------------------------------------------------
; Entry:            AH = color of the 1st and the 3rd symbol
;                   AL = color of the 2nd symbol
;                   BX = video segment coordinates
;                   DL = width
;                   SI = offset of array of three symbols
; Expects:          ES -> video segment
; Destroys:         None
; Exit:             None
;-----------------------------------------------------------
size_of_pixel       EQU 2d

DrawLine            proc
                    push ax bx cx di

                    xor cx, cx
                    mov cl, dl
                    mov di, bx
                    mov bx, ax

                    mov al, [si]                                ; sets the 1st symbol of line
                    mov ah, bh
                    stosw

                    sub cx, 2
                    mov al, [si+1]                              ; sets the 2nd symbol of line
                    mov ah, bl
                    rep stosw

                    mov al, [si+2]                              ; sets the 3rd symbol of line
                    mov ah, bh
                    stosw

                    pop di cx bx ax
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




put_symbol          macro  offs
                    mov es:[bx+2*offs],  ax
                    endm



Print_HACK_ME		proc

                    mov bx, top_left_corner + new_line * 2
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

                    add bx, new_line
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

                    add bx, new_line
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

                    add bx, new_line
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

                    add bx, new_line
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

                    mov bx, top_left_corner
                    mov ah, color_of_frame
                    mov al, color_of_space_granted
                    mov dh, height_of_frame
                    mov dl, width_of_frame
                    mov si, offset frame_symbols
                    call DrawFrame

                    mov si, offset AccessGranted
                    mov bx, 160*4d + 2*13d
                    mov ch, 3Ah
                    call PrintString

					pop ax
                    mov bx, new_line * 6d

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

                    add bx, new_line
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

                    add bx, new_line
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

                    add bx, new_line
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

                    add bx, new_line
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

                    mov bx, top_left_corner
                    mov ah, color_of_frame
                    mov al, color_of_space_denied
                    mov dh, height_of_frame
                    mov dl, width_of_frame
                    mov si, offset frame_symbols
                    call DrawFrame

                    mov si, offset AccessDenied
                    mov bx, 160*4d + 2*13d
                    mov ch, 3Ch
                    call PrintString

                    pop ax
                    mov bx, new_line * 6d

                    put_symbol 8d
                    put_symbol 13d
                    put_symbol 14d
                    put_symbol 15d
                    put_symbol 16d
                    put_symbol 18d
                    put_symbol 19d
                    put_symbol 20d
                    put_symbol 21d
                    put_symbol 23d
                    put_symbol 24d
                    put_symbol 25d
                    put_symbol 26d
                    put_symbol 28d
                    put_symbol 29d
                    put_symbol 30d
                    put_symbol 31d

                    add bx, new_line
                    put_symbol 8d
                    put_symbol 13d
                    put_symbol 16d
                    put_symbol 18d
                    put_symbol 23d
                    put_symbol 28d
                    put_symbol 31d

                    add bx, new_line
                    put_symbol 8d
                    put_symbol 13d
                    put_symbol 16d
                    put_symbol 18d
                    put_symbol 19d
                    put_symbol 20d
                    put_symbol 21d
                    put_symbol 23d
                    put_symbol 24d
                    put_symbol 25d
                    put_symbol 26d
                    put_symbol 28d
                    put_symbol 29d
                    put_symbol 30d
                    put_symbol 31d

                    add bx, new_line
                    put_symbol 8d
                    put_symbol 13d
                    put_symbol 16d
                    put_symbol 21d
                    put_symbol 23d
                    put_symbol 28d
                    put_symbol 30d

                    add bx, new_line
                    put_symbol 8d
                    put_symbol 9d
                    put_symbol 10d
                    put_symbol 11d
                    put_symbol 13d
                    put_symbol 14d
                    put_symbol 15d
                    put_symbol 16d
                    put_symbol 18d
                    put_symbol 19d
                    put_symbol 20d
                    put_symbol 21d
                    put_symbol 23d
                    put_symbol 24d
                    put_symbol 25d
                    put_symbol 26d
                    put_symbol 28d
                    put_symbol 31d

					ret
					endp
;-----------------------------------------------------------

AccessGranted       db 'ACCESS GRANTED', 0
AccessDenied        db 'ACCESS  DENIED', 0

;-----------------------------------------------------------