;-----------------------------------------------------------
; Draws a frame on the screen
;-----------------------------------------------------------
; Entry:            AH = color of frame symbol
;                   AL = color of space symbol
;                   BX = video segment coordinates
;                   DH = height of frame
;                   DL = width  of frame
;                   SI = offset of array of 9 drawing symbols
; Expects:          ES -> video segment
; Destroys:         SI
; Exit:             None
;-----------------------------------------------------------
Draw_Frame          proc
                    cld
                    push bx dx

                    push ax
                    mov al, ah                                  ; sets color for space symbol for the first line
                    call Draw_Line

                    sub dh, 2d
                    add bx, new_line
                    add si, next_3_symbols                      ; sets next 3 symbols for drawing
                    pop ax

@@Next_Line:        cmp dh, 0
                    je @@Exit

                    call Draw_Line

                    add bx, new_line
                    dec dh
                    jmp @@Next_Line

@@Exit:             push ax
                    add si, next_3_symbols
                    mov al, ah                                  ; sets color for space symbol for the last line
                    call Draw_Line
                    pop ax

                    pop dx bx
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
;                   SI = offset of array of 3 drawing symbols
; Expects:          ES -> video segment
; Destroys:         None
; Exit:             None
;-----------------------------------------------------------
Draw_Line           proc
                    push ax bx cx di

                    xor cx, cx
                    mov cl, dl
                    mov di, bx                                  ; puts coordinates in DI because of STOSW
                    mov bx, ax

                    mov al, [si]                                ; sets the 1st symbol of line
                    mov ah, bh
                    stosw

                    sub cx, 2d
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
;					AH = color of symbols
;					SI = address of string
; Expects:			ES -> video segment
; Destroys:			AL, SI
; Exit:				None
;-----------------------------------------------------------
Print_String	    proc
                    cld
					push di

                    mov di, bx

@@Next_Symbol:		mov al, [si]
					cmp al, 0
					je @@Exit

                    stosw
                    inc si
					jmp @@Next_Symbol

@@Exit:	 			pop di
					ret
					endp				
;-----------------------------------------------------------




;-----------------------------------------------------------
; Draws the main picture in the frame
;-----------------------------------------------------------
; Entry:            None
; Expects:          ES -> video segment
; Destroys:         BX, CX, DL, SI, DI
; Exit:             None
;-----------------------------------------------------------
Draw_Main_Picture   proc

                    mov bx, coordinates_of_main_picture
                    mov ah, color_of_main_picture
                    mov al, symbol_of_main_picture
                    lea si, main_picture_coords
                    call Draw_Picture

                    ret
                    endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Draws a picture in case of right password
;-----------------------------------------------------------
; Entry:            None
; Expects:          ES -> video segment
; Destroys:         AX, BX, CX, DX, SI, DI
; Exit:             None
;-----------------------------------------------------------
Draw_ACCESS_GRANTED proc

                    mov bx, top_left_corner
                    mov ah, color_of_frame
                    mov al, color_of_space_Granted
                    mov dh, height_of_frame
                    mov dl, width_of_frame
                    lea si, frame_symbols
                    call Draw_Frame                             ; draws a frame with a different color of space

                    lea si, Access_Granted_phrase
                    mov bx, coordinates_of_result_phrase
                    mov ah, color_of_result_phrase_Granted
                    call Print_String                           ; prints "ACCESS GRANTED" phrase in the frame

                    mov bx, coordinates_of_result_picture
                    mov ah, color_of_result_picture
                    mov al, symbol_of_result_picture
                    lea si, Granted_coords
                    call Draw_Picture                           ; draws "ХОРОШ" in the frame

                    ret
                    endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Draws a picture in case of wrong password
;-----------------------------------------------------------
; Entry:            None
; Expects:          ES -> video segment
; Destroys:         AX, BX, CX, DX, SI, DI
; Exit:             None
;-----------------------------------------------------------
Draw_ACCESS_DENIED  proc

                    mov bx, top_left_corner
                    mov ah, color_of_frame
                    mov al, color_of_space_Denied
                    mov dh, height_of_frame
                    mov dl, width_of_frame
                    lea si, frame_symbols
                    call Draw_Frame                             ; draws a frame with a different color of space

                    lea si, Access_Denied_phrase
                    mov bx, coordinates_of_result_phrase
                    mov ah, color_of_result_phrase_Denied
                    call Print_String                           ; prints "ACCESS DENIED" phrase in the frame

                    mov bx, coordinates_of_result_picture
                    mov ah, color_of_result_picture
                    mov al, symbol_of_result_picture
                    lea si, Denied_coords
                    call Draw_Picture                           ; draws "LOSER" in the frame

                    ret
                    endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Draws a picture on the screen
;-----------------------------------------------------------
; Entry:            BX = coordinates of the top left
;                        corner of a picture
;                   AH = color of symbol for drawing
;                   AL = symbol for drawing
;                   SI = offset of coordinates for drawing
; Expects:          ES -> video segment
; Destroys:         BX, CX, DL, SI, DI
; Exit:             None
;-----------------------------------------------------------
Draw_Picture        proc
                    cld

                    mov cx, height_of_pictures

@@Next_Line:        mov di, bx
                    xor dl, dl                                  ; a cooridnate of a symbol in the line will be in DL

@@Next_Symbol:      cmp dl, [si]                                ; skips if coordinates are not equal
                    jne @@Skip

                    stosw
                    sub di, size_of_pixel
                    inc si

@@Skip:             add di, size_of_pixel
                    inc dl
                    cmp dl, width_of_frame - 2d                 ; compares with an internal width of the frame
                    je @@Go_To_Next_Line

                    jmp @@Next_Symbol

@@Go_To_Next_Line:  add bx, new_line
                    loop @@Next_Line

                    ret
                    endp
;-----------------------------------------------------------




;-----------------------------------------------------------

main_picture_coords db 2d,  5d,  8d,  9d, 12d, 13d, 14d, 15d, 17d, 20d, 24d, 28d, 30d, 31d, 32d, 33d
                    db 2d,  5d,  7d, 10d, 12d, 17d, 19d, 24d, 25d, 27d, 28d, 30d
                    db 2d,  3d,  4d,  5d,  7d,  8d,  9d, 10d, 12d, 17d, 18d, 24d, 26d, 28d, 30d, 31d, 32d, 33d
                    db 2d,  5d,  7d, 10d, 12d, 17d, 19d, 24d, 28d, 30d
                    db 2d,  5d,  7d, 10d, 12d, 13d, 14d, 15d, 17d, 20d, 24d, 28d, 30d, 31d, 32d, 33d

Granted_coords      db 5d,  9d, 11d, 12d, 13d, 14d, 16d, 17d, 18d, 19d, 21d, 22d, 23d, 24d, 26d, 28d, 30d
                    db 6d,  7d,  8d, 11d, 14d, 16d, 19d, 21d, 24d, 26d, 28d, 30d
                    db 7d, 11d, 14d, 16d, 17d, 18d, 19d, 21d, 24d, 26d, 28d, 30d
                    db 6d,  7d,  8d, 11d, 14d, 16d, 21d, 24d, 26d, 28d, 30d
                    db 5d,  9d, 11d, 12d, 13d, 14d, 16d, 21d, 22d, 23d, 24d, 26d, 27d, 28d, 29d, 30d

Denied_coords       db 6d, 11d, 12d, 13d, 14d, 16d, 17d, 18d, 19d, 21d, 22d, 23d, 24d, 26d, 27d, 28d, 29d
                    db 6d, 11d, 14d, 16d, 21d, 26d, 29d
                    db 6d, 11d, 14d, 16d, 17d, 18d, 19d, 21d, 22d, 23d, 24d, 26d, 27d, 28d, 29d
                    db 6d, 11d, 14d, 19d, 21d, 26d, 28d
                    db 6d,  7d,  8d,  9d, 11d, 12d, 13d, 14d, 16d, 17d, 18d, 19d, 21d, 22d, 23d, 24d, 26d, 29d


Access_Granted_phrase   db 'ACCESS GRANTED', 0
Access_Denied_phrase    db 'ACCESS  DENIED', 0

;-----------------------------------------------------------