;-----------------------------------------------------------
; Draws a frame in the array
;-----------------------------------------------------------
; Entry:            AH = color of frame symbol
;                   AL = color of space symbol
;                   BX = offset of the array for drawing
;                   DH = height of a frame
;                   DL = width  of a frame
;                   SI = offset of an array of drawing symbols
; Expects:          ES -> segment with the array for drawing
; Destroys:         SI
; Exit:             None
;-----------------------------------------------------------
new_line            EQU 160d
next_3_symbols      EQU 3d
min_length_of_side  EQU 2d

DrawFrame           proc
                    cld
                    push bx dx

                    push ax
                    mov al, ah                                  ; sets color for a space symbol for the first line
                    call DrawLine

                    sub dh, 2
                    call Increase_BX
                    add si, next_3_symbols                      ; sets next 3 symbols for drawing
                    pop ax

@@Next_Line:        cmp dh, 0
                    je @@Exit
                    call DrawLine

                    call Increase_BX
                    dec dh
                    jmp @@Next_Line

@@Exit:             push ax
                    add si, next_3_symbols
                    mov al, ah                                  ; sets color for a space symbol for the last line
                    call DrawLine
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
;                   DL = width of the line
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
; Increases BX by the width of the frame
;-----------------------------------------------------------
; Entry:            DL = width of the frame
; Expects:          None
; Destroys:         None
; Exit:             BX
;-----------------------------------------------------------
Increase_BX         proc

                    push dx
                    xor dh, dh
                    add bx, dx
                    add bx, dx
                    pop dx

                    ret
                    endp
;-----------------------------------------------------------