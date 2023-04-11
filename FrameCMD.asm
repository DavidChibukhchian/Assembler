.model tiny
.code
org 100h
locals @@

Start:              call GetArguments

                    call SetFrameType

                    mov bp, 0B800h
                    mov es, bp

                    call DrawFrame
                    
                    call WriteText

                    mov ax, 4C00h
                    int 21h



;-----------------------------------------------------------
; Gets command line arguments
;-----------------------------------------------------------
; Entry:            None
; Expects:          ES -> PSP
; Destroys:         None
; Exit:             AH = color of frame symbol
;                   AL = color of space symbol
;                   BX = video segment coordinates
;                   CX = color of text
;                   DH = height of frame
;                   DL = width  of frame
;                   BP = frame type
;                   DI = address of array of custom symbols
;-----------------------------------------------------------
offset_of_arguments EQU 82h

GetArguments        proc

                    call PutSpace                               ; puts a space symbol to the end of CMD arguments

                    mov di, offset_of_arguments
                    mov bp, 10d                                 ; coordinates, height and width are in decimal format

                    call GetFrameCoordinates

                    call ReadNumber                             ; gets height
                    mov ch, dl

                    call ReadNumber                             ; gets width
                    mov cl, dl                                  ; saves height and width in CX

                    mov bp, 16d                                 ; colors are in hexadecimal format
                    call ReadNumber                             ; gets color of a frame symbol
                    mov ah, dl

                    call ReadNumber                             ; gets color of a space symbol
                    mov al, dl                                  ; saves colors in AX

                    call ReadNumber                             ; gets frame type
                    push dx

                    call ReadNumber                             ; gets color of text
                    mov si, dx                                  

                    mov dx, cx
                    mov cx, si
                    pop bp                                      ; saves frame type in BP

                    ret
                    endp
;-----------------------------------------------------------



;-----------------------------------------------------------
; Puts a space symbol to the end of CMD arguments
; in order to read numbers correctly
;-----------------------------------------------------------
; Entry:            None
; Expects:          ES -> PSP
; Destroys:         AX, DI
; Exit:             None
;-----------------------------------------------------------
number_of_arguments EQU 80h

PutSpace            proc

                    xor ax, ax
                    mov di, number_of_arguments
                    mov al, [di]
                    add di, ax

                    inc di
                    mov byte ptr es:[di], ' '

                    ret
                    endp
;-----------------------------------------------------------



;-----------------------------------------------------------
; Gets frame coordinates by reading two decimal numbers
; and calculating video segment coordinates
;-----------------------------------------------------------
; Entry:            BP = base of numbers
;                   DI = offset of array   
; Expects:          None
; Destroys:         CX, DI++
; Exit:             BX
;-----------------------------------------------------------
GetFrameCoordinates proc

                    call ReadNumber                             ; gets X coordinate
                    mov ch, dl

                    call ReadNumber                             ; gets Y coordinate
                    mov cl, dl

                    call GetCoordinates                         ; gets video segment coordinates
                    mov bx, cx                                  ; saves in BX

                    ret
                    endp
;-----------------------------------------------------------



;-----------------------------------------------------------
; Sets a frame type and sets custom symbols in case of
; custom type
;-----------------------------------------------------------
; Entry:            BP = frame type
;                   DI = address of array of custom symbols
; Expects:          ES -> PSP
; Destroys:         BP
; Exit:             SI = offset of array of drawing symbols
;                   DI = address of text
;-----------------------------------------------------------
custom_type_mode    EQU 5d
number_of_frame_symbols EQU 9d

SetFrameType        proc
                    cld
                    push ax cx

                    mov cx, bp
                    cmp cx, custom_type_mode
                    je @@Custom_Type

                    dec cx
                    mov si, offset Type1

@@Next_Type:        cmp cx, 0                                   ; sets offset of array of symbols
                    je @@Exit                                   ; instead of using comparings
                    add si, number_of_frame_symbols
                    dec cx
                    jmp @@Next_Type

@@Custom_Type:      mov bp, offset CustomType
                    mov cx, number_of_frame_symbols
                    mov si, di

@@Next:             lodsb
                    mov [bp], al
                    inc di
                    inc bp
                    loop @@Next

                    inc di
                    mov si, offset CustomType

@@Exit:             pop cx ax
                    ret
                    endp
;-----------------------------------------------------------



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
new_line            EQU 160d
next_3_symbols      EQU 3d
min_length_of_side  EQU 2d

DrawFrame           proc
                    cld
                    push bx dx

                    cmp dh, min_length_of_side
                    jb @@Small_Height

                    cmp dl, min_length_of_side
                    jb @@Small_Width

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


@@Small_Height:     mov ah, 09h
                    mov dx, offset Small_Height
                    int 21h
                    jmp @@Exit

@@Small_Width:      mov ah, 09h
                    mov dx, offset Small_Width
                    int 21h
                    jmp @@Exit


@@Normal_Exit:      push ax
                    add si, next_3_symbols
                    mov al, ah                                  ; sets color for space symbol for the last line
                    call DrawLine
                    pop ax

@@Exit:             pop dx bx
                    ret
                    endp

Small_Height        db "ERROR: height is too small", 10d, '$'
Small_Width         db "ERROR: width is too small",  10d, '$'
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
; Writes text in the frame or skips it
;-----------------------------------------------------------
; Entry:            CX = color of text
;                   DH = height of frame
;                   DL = width  of frame
;                   DI = address of text
; Expects:          ES -> video segment
; Destroys:         AX, BX, CX, DX, DI, SI
; Exit:             None
;-----------------------------------------------------------
side_offset         EQU 4d

WriteText           proc
                    cld

                    mov si, number_of_arguments
                    xor ax, ax
                    mov al, [si]                                ; length of arguments (without text) is in AL

                    sub di, offset_of_arguments
                    cmp di, ax
                    jne @@Write_Text
                    jmp @@Exit


@@Write_Text:       mov color_of_text, cl

                    sub ax, di
                    dec ax                                      ; length of the text is in AL, AH = 0
                    mov length_of_text, ax
                    add di, offset_of_arguments                 ; DI -> text 

                    sub dl, side_offset
                    cmp al, dl                                  ; max length of the text is in DL
                    jna @@One_Line
                    jmp @@Many_Lines

@@One_Line:         push ax                                     ; saves length of the text

                    sub dl, al
                    mov al, dl

                    mov ch, 2
                    div ch                                      ; X offset is in AL
                    xor ah, ah                                  ; clears remainder

@@Correct_X:        add bx, side_offset                               
                    add bx, ax                                  ; corrects video segment coordinates
                    add bx, ax

                    xor ax, ax
                    mov al, dh
                    div ch
                    add al, ah
                    dec al                                      ; Y offset is in AL

@@Correct_Y:        cmp al, 0
                    je @@StartWriting                
                    add bx, new_line                            ; corrects video segment coordinates
                    dec al
                    jmp @@Correct_Y

@@StartWriting:     pop ax
                    mov cx, ax

                    mov si, di
                    mov di, bx
                    mov ah, color_of_text

@@Next_Symbol:      mov al, [si]
                    stosw
                    inc si
                    loop @@Next_Symbol
                    jmp @@Exit


@@Many_Lines:       add bx, side_offset

                    div dl
                    cmp ah, 0                                   ; checks remainder
                    je @@NoRemainder
                    inc al

@@NoRemainder:      xor ah, ah                                  ; in AL number of lines, AH = 0
                    sub dh, al
                    mov al, dh
                    mov ch, 2
                    div ch

@@Correct_BX:       cmp al, 0
                    je @@StartWriting_                
                    add bx, new_line                            ; corrects video segment coordinates
                    dec al
                    jmp @@Correct_BX  

                          
@@StartWriting_:    xor dh, dh
                    mov bp, length_of_text                      ; number of remaining symbols

                    mov si, di                                  ; address of text is in SI
                    mov ah, color_of_text
                    mov di, bx                                  ; video segment coordinates are in DI
                    xor cx, cx

@@Next_Symbol_:     cmp bp, 0
                    je @@Exit

                    cmp cl, dl                                  ; compares with max length of the text
                    jne @@NoCarriageReturn

                    add di, new_line                            ; \n
                    sub di, dx                                  ; \r
                    sub di, dx
                    xor cl, cl                                  ; resets counter

@@NoCarriageReturn: mov al, [si]
                    stosw
                    inc si
                    inc cl                                      ; counts a number of symbols in the current line
                    dec bp
                    jmp @@Next_Symbol_


@@Exit:             ret
                    endp
                    
length_of_text      dw 0
color_of_text       db 0
;-----------------------------------------------------------



;-----------------------------------------------------------
; Reads a number from an array
;-----------------------------------------------------------
; Entry:            BP = base
;                   DI = offset of array
; Expects:          None
; Destroys:         DI++
; Exit:             DX
;-----------------------------------------------------------
ReadNumber          proc
                    push ax bx cx bp

                    mov result, 0
                    mov base, bp
                    mov powered_base, 1                         ; sets start value of powered base

                    xor bx, bx
                    xor bp, bp

                    mov bl, [di]

@@Next_Digit:       cmp bl, ' '
                    je @@Start
                    inc bp                                      ; counts number of digits in BP
                    inc di
                    mov bl, [di]
                    jmp @@Next_Digit

@@Start:            dec di
                    mov bl, [di]
                    mov cx, bp

@@Next:             cmp bl, '9'              
                    ja @@Letter
                    sub bl, '0'
                    jmp @@Digit

@@Letter:           sub bl, 'A'
                    add bl, 10d              
@@Digit:            mov ax, powered_base
                    mul bx
                    add result, ax

                    mov ax, powered_base
                    mul base                                    ; increases powered base
                    mov powered_base, ax
    
                    dec di
                    mov bl, [di]
                    loop @@Next

                    add di, bp
                    add di, size_of_pixel
                    mov dx, result

                    pop bp cx bx ax
                    ret
                    endp

base                dw 0
powered_base        dw 0
result              dw 0
;-----------------------------------------------------------



;-----------------------------------------------------------
; Calculates video segment coordinates
;-----------------------------------------------------------
; Entry:            CH = X coordinate
;                   CL = Y coordinate
; Expects:          None
; Destroys:         None
; Exit:             CX
;-----------------------------------------------------------
GetCoordinates      proc
                    push ax bx dx
                    xor bx, bx

                    mov dh, size_of_pixel
                    mov dl, new_line

                    mov al, ch
                    dec al
                    mul dh
                    add bx, ax

                    mov al, cl
                    dec al
                    mul dl
                    add bx, ax

                    mov cx, bx

                    pop dx bx ax
                    ret 
                    endp
;-----------------------------------------------------------



;-----------------------------------------------------------

Type1               db 0DAh, 0C4h, 0BFh, 0B3h, ' ', 0B3h, 0C0h, 0C4h, 0D9h
Type2               db 0C9h, 0CDh, 0BBh, 0BAh, ' ', 0BAh, 0C8h, 0CDh, 0BCh   
Type3               db 4 DUP(0B0h), ' ', 4 DUP(0B0h)
Type4               db 4 DUP(3h),   ' ', 4 DUP(3h)
CustomType          db 9 DUP(0)

;-----------------------------------------------------------



end                 Start