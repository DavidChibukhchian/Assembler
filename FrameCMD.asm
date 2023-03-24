.model tiny
.code
org 100h
locals @@

Start:              call GetArguments

                    call SetFrameType

                    mov ax, 0B800h
                    mov es, ax
                    pop bp                                      ; color of text
                    pop ax                                      ; colors of frame and space symbols
                    pop dx                                      ; height and width
                    pop bx                                      ; video segment coordinates
                    call DrawFrame
                    
                    call WriteText

                    mov ax, 4C00h
                    int 21h



;-----------------------------------------------------------
; Puts command line arguments in stack
;-----------------------------------------------------------
; Entry:            None
; Expects:          ES -> PSP
; Destroys:         AX, BX, CX, DX, BP, DI
; Exit:             color of text               <- stack top
;                   colors of frame and space symbols
;                   height and width
;                   video segments coordinates  
;-----------------------------------------------------------
GetArguments        proc
                    pop bp                                      ; saves a return address in BP

                    xor ax, ax
                    mov di, 80h
                    mov al, [di]
                    add di, ax
                    inc di
                    mov byte ptr es:[di], ' '

                    mov di, 82h
                    mov bx, 10d
                    call ReadNumber                             ; gets X coordinate
                    mov ch, dl

                    call ReadNumber
                    mov cl, dl
                    call GetCoordinates                         ; gets Y coordinate
                    push cx

                    call ReadNumber                             ; gets height
                    mov ch, dl

                    call ReadNumber                             ; gets width
                    mov cl, dl
                    push cx

                    mov bx, 16d
                    call ReadNumber                             ; gets color of a frame symbol
                    mov ch, dl

                    call ReadNumber                             ; gets color of a space symbol
                    mov cl, dl
                    push cx

                    call ReadNumber                             ; gets frame type
                    mov cl, dl

                    call ReadNumber                             ; gets color of text
                    push dx
                    mov dl, cl

                    push bp                                     ; pushes a return address

                    ret
                    endp
;-----------------------------------------------------------



;-----------------------------------------------------------
; Sets a frame type and sets custom symbols in case of
; custom type
;-----------------------------------------------------------
; Entry:            DX = frame type
;                   DI = address of symbol of type
; Expects:          ES -> PSP
; Destroys:         AH, CX, DX, BP, DI, SI
; Exit:             None
;-----------------------------------------------------------
SetFrameType        proc

                    cmp dx, 5d                                  ; number of custom type
                    je @@Custom_Type

                    dec dl
                    mov si, offset Type1

@@Next_Type:        cmp dl, 0                                   ; sets offset of array of symbols
                    je @@Exit                                   ; in order to not use comparings
                    add si, 9d
                    dec dl
                    jmp @@Next_Type

@@Custom_Type:      mov bp, offset CustomType
                    mov cx, 9d

@@Next:             mov ah, [di]                                ; puts custom symbols into array          
                    mov [bp], ah
                    inc di
                    inc bp
                    loop @@Next
                    inc di

                    mov si, offset CustomType

@@Exit:             ret
                    endp
;-----------------------------------------------------------



;-----------------------------------------------------------
; Writes text in the frame or skips it
;-----------------------------------------------------------
; Entry:
; Expects:          ES -> PSP
; Destroys:
; Exit:             None
;-----------------------------------------------------------
WriteText           proc

                    push bp
                    mov bp, 80h

                    xor ax, ax
                    mov al, [bp]                                ; length of arguments (without text) is in AL
                    pop bp

                    sub di, 82h
                    cmp di, ax
                    jne @@Write_Text
                    jmp @@Exit


@@Write_Text:       sub ax, di
                    sub ax, 1                                   ; length of text is in AL, AH = 0
                    add di, 82h                                 ; DI -> text 

                    sub dl, 2
                    cmp al, dl
                    jna @@One_Line
                    jmp @@Many_Lines

@@One_Line:         push ax

                    sub dl, al
                    mov al, dl

                    mov ch, 2
                    div ch                                      ; X offset is in AL
                    xor ah, ah                                  ; clears remainder

                    add bx, 2                               
                    add bx, ax                                  ; corrects video segment coordinates
                    add bx, ax

                    xor ax, ax
                    sub dh, 2
                    mov al, dh
                    div ch
                    add ah, al                                  ; Y offset is in AH

@@Add:              cmp ah, 0
                    je @@Correct_BX                 
                    add bx, new_line                            ; corrects video segment coordinates
                    dec ah
                    jmp @@Add

@@Correct_BX:       pop ax
                    mov cx, ax

@@Next_Symbol:      push cx
                    mov cx, bp

                    mov dh, [di]
                    mov byte ptr es:[bx],   dh
                    mov byte ptr es:[bx+1], cl

                    add bx, 2
                    inc di
                    pop cx
                    loop @@Next_Symbol
                    jmp @@Exit


@@Many_Lines:       
                    ;push ax dx
                    ;mov dl, "*"
                    ;mov ah, 02h
                    ;int 21h
                    ;pop dx ax


                    div dl
                    cmp ah, 0
                    je @@Skip
                    inc al

@@Skip:             xor ah, ah              ; in AL number of lines, AH = 0

                    sub dh, 2

                    sub dh, al
                    mov al, dh
                    mov ch, 2
                    div ch
                    inc al

                    add bx, 2

@@Adde:             cmp al, 0
                    je @@Exitrr                
                    add bx, new_line                            ; corrects video segment coordinates
                    dec al
                    jmp @@Adde         

                          
@@Exitrr:           
                    xor ax, ax
                    mov dh, 0

@@Next_Symbolr:     push cx
                    mov cx, bp

                    inc al
                    cmp al, dl
                    jne @@Skippp
                    add bx, new_line
                    sub bx, dx
                    sub bx, dx


@@Skippp:           mov dh, [di]
                    mov byte ptr es:[bx],   dh
                    mov byte ptr es:[bx+1], cl

                    add bx, 2
                    inc di
                    pop cx
                    loop @@Next_Symbolr
                    jmp @@Exit



@@Exit:            

                    ret
                    endp
;-----------------------------------------------------------



;-----------------------------------------------------------
; Draws a frame on the screen
;-----------------------------------------------------------
; Entry:            AH = color of frame symbol
;                   AL = color of space
;                   BX = video segment coordinates
;                   DH = height
;                   DL = width
;                   SI = offset of array of drawing symbols
; Expects:          ES -> video segment
; Destroys:         SI
; Exit:             None
;-----------------------------------------------------------
new_line            EQU 160d
next_3_symbols      EQU 3
min_length_of_side  EQU 2

DrawFrame           proc
                    push bx dx

                    cmp dh, min_length_of_side
                    jb @@Small_Height

                    cmp dl, min_length_of_side
                    jb @@Small_Width

                    push ax
                    mov al, ah                                  ; sets color for space symbol for the 1st line
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
                    mov al, ah                                  ; sets color for space symbol for the 1st line
                    call DrawLine
                    pop ax

@@Exit:             pop dx bx
                    ret
                    endp

Small_Height        db "ERROR: height is too small$"
Small_Width         db "ERROR: width is too small$"

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
; Destroys:         CH
; Exit:             None
;-----------------------------------------------------------
size_of_pixel       EQU 2

DrawLine            proc

                    push bx dx
                    sub dl, 2

                    mov ch, [si]                                ; sets the 1st symbol for drawing

                    mov byte ptr es:[bx],   ch
                    mov byte ptr es:[bx+1], ah
                    add bx, size_of_pixel

                    mov ch, [si+1]                              ; sets the 2nd symbol for drawing

@@Next_Symbol:      cmp dl, 0
                    je @@Exit

                    mov byte ptr es:[bx],   ch
                    mov byte ptr es:[bx+1], al
                    add bx, size_of_pixel
                    dec dl
                    jmp @@Next_Symbol

@@Exit:             mov ch, [si+2]                              ; sets the 3rd symbol for drawing
                    mov byte ptr es:[bx],   ch
                    mov byte ptr es:[bx+1], ah

                    pop dx bx
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



;-----------------------------------------------------------
; Reads a number from an array
;-----------------------------------------------------------
; Entry:            BX = base
;                   DI = offset of array
; Expects:          None
; Destroys:         DI
; Exit:             DX
;-----------------------------------------------------------
base                dw 0
powered_base        dw 0
result              dw 0

ReadNumber          proc

                    mov result, 0
                    push ax bx cx bp
                    
                    mov base, bx

                    xor bx, bx
                    xor bp, bp
                    mov bl, [di]

@@Next_Digit:       cmp bl, ' '
                    je @@Start
                    inc bp
                    inc di
                    mov bl, [di]
                    jmp @@Next_Digit

@@Start:            mov powered_base, 1                         ; sets start value of powered base
                    dec di
                    mov bl, [di]
                    mov cx, bp

@@Next:             cmp bl, 39h                                 ; compares with '9'              
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
                    add di, 2
                    mov dx, result

                    pop bp cx bx ax
                    ret
                    endp
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

                    xor dx, dx
                    mov dh, size_of_pixel
                    mov dl, new_line

                    xor bx, bx

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



end                 Start