.model tiny
.code
org 100h
locals @@

Start:              mov bx, 0B800h
                    mov es, bx

                    call Display_Menu

                    call Enter_Password

                    call Verify_Password

                    mov ax, 4C00h
                    int 21h




;-----------------------------------------------------------
; Displays the start menu of this HackMe program
;-----------------------------------------------------------
; Entry:            None
; Expects:          ES -> video segment
; Destroys:         AX, BX, CH, DX, SI
; Exit:             None
;-----------------------------------------------------------
Display_Menu        proc

                    mov bx, top_left_corner                     ; coordinates of the top left corner of the frame
                    mov ah, color_of_frame
                    mov al, color_of_space
                    mov dh, height_of_frame
                    mov dl, width_of_frame
                    lea si, frame_symbols
                    call DrawFrame

                    mov ah, color_of_HACK_ME
                    mov al, symbol_of_HACK_ME
                    call Print_HACK_ME

                    mov bx, enter_the_password_coordinates
                    lea si, enter_the_password_phrase
                    mov ch, color_of_enter_the_password_phrase
                    call PrintString

                    mov bx, password_field_coordinates
                    lea si, password_field
                    mov ch, color_of_password_field
                    call PrintString

                    ret
                    endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Records entered password to a password buffer
; Shows a blinking underscore and stars when entering
;-----------------------------------------------------------
; Entry:            None
; Expects:          ES -> video segment
; Destroys:         AX, BX, CX, DX, SI
; Exit:             None
;-----------------------------------------------------------
Enter_Password      proc

                    mov bx, password_field_coordinates
                    mov ch, color_of_blinking_underscore        ; prints the first blinking underscore
                    mov cl, '_'
                    mov es:[bx], cx
                    
                    lea si, password_buffer
                    xor dx, dx                                  ; a number of entered symbols will be in DX


@@Next_Symbol:      mov ah, 08h                                 ; reads a symbol without echo
                    int 21h

                    cmp al, ENTER_code                          ; compares with enter
                    je @@Enter_Exit

                    cmp al, BACKSPACE_code                      ; compares with backspace
                    je @@Delete_Symbol


@@Enter_Symbol:     mov [si], al                                ; puts entered symbol to a password buffer
                    inc si
                    inc dx                                      ; increases counter of entered symbols

                    mov ch, color_of_star                         
                    mov cl, '*'                                 ; prints a star
                    mov es:[bx], cx
                    add bx, size_of_pixel

                    cmp dx, max_len_of_password                 ; exits if the max length was reached
                    je @@Max_Len_Exit

                    mov ch, color_of_blinking_underscore
                    mov cl, '_'                                 ; prints a blinking underscore
                    mov es:[bx], cx
                    jmp @@Next_Symbol


@@Delete_Symbol:    cmp dx, 0                                   ; skips deleting a blinking underscore
                    je @@Skip                                   ; if no symbols were entered

                    dec dx

                    mov cl, ' '
                    mov byte ptr es:[bx], cl                    ; deletes a blinking underscore
                    sub bx, size_of_pixel

                    mov ch, color_of_blinking_underscore
                    mov cl, '_'                                 ; prints a blinking underscore over a star
                    mov es:[bx], cx

@@Skip:             dec si
                    mov word ptr [si], 0                        ; deletes entered symbol from the password buffer
                    jmp @@Next_Symbol


@@Max_Len_Exit:     mov ah, 08h                                 ; reads a symbol without echo
                    int 21h
                    mov [si], al

                    cmp byte ptr [si], BACKSPACE_code           ; compares with backspace
                    je @@Delete_Symbol

                    cmp byte ptr [si], ENTER_code               ; compares with enter
                    je @@Exit

                    jmp @@Max_Len_Exit


@@Enter_Exit:       mov ch, color_of_password_field
                    mov cl, ' '                                 ; doesn't print a blinking underscore
                    mov es:[bx], cx

@@Exit:             ret
                    endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Verifies entered password and displays
; an appropriate picture
;-----------------------------------------------------------
; Entry:            None
; Expects:          ES -> video segment
; Destroys:         AX, BX, CX, DX, SI, DI
; Exit:             None
;-----------------------------------------------------------
Verify_Password     proc

                    lea si, password_buffer
                    lea di, right_password

                    mov cx, max_len_of_password
                    mov dh, [si]                                ; entered symbols will be in DH

@@Next_Symbol:      cmp dh, [di]                                ; compares entered symbol with right symbol
                    jne @@Change_Flag

                    inc si
                    inc di
                    mov dh, [si]
                    loop @@Next_Symbol
                    
                    jmp @@Result

@@Change_Flag:      xor flag, 1
                    
@@Result:           mov al, 0B1h                                ; a symbol for the result picture
                    mov ah, 93h                                 ; color

                    cmp flag, 1                                 ; flag == 0 - right password
                    je  @@Denied                                ; flag == 1 - wrong password
                    jmp @@AccessGranted
@@Denied:           jmp @@AccessDenied

;-----------------------------------------------------------
include HackLib.asm
;-----------------------------------------------------------

@@AccessGranted:    call Print_ACCESS_GRANTED
                    jmp @@Exit

@@AccessDenied:     call Print_ACCESS_DENIED

@@Exit:             ret
                    endp
;-----------------------------------------------------------




;-----------------------------------------------------------

new_line                EQU 160d
next_3_symbols          EQU 3d
ENTER_code              EQU 0Dh
BACKSPACE_code          EQU 08h

top_left_corner         EQU 162d
color_of_frame          EQU 5Ch
color_of_space          EQU 5Ch
color_of_space_granted  EQU 27h
color_of_space_denied   EQU 47h
height_of_frame         EQU 13d
width_of_frame          EQU 38d

color_of_HACK_ME        EQU 3Ch
symbol_of_HACK_ME       EQU ' '

enter_the_password_coordinates      EQU 160*9d + 2*10d
color_of_enter_the_password_phrase  EQU 4Ah

password_field_coordinates          EQU 160*11d + 2*14d
color_of_password_field             EQU 3Ch
max_len_of_password                 EQU 12d

color_of_blinking_underscore        EQU 0BAh
color_of_star                       EQU 3Ah

;-----------------------------------------------------------




;-----------------------------------------------------------

enter_the_password_phrase  db ' ENTER THE PASSWORD ', 0
password_buffer     db max_len_of_password DUP(0)
flag                db 0

password_field      db max_len_of_password DUP(' '), 0
field_coordinates   dw 0
frame_symbols       db 0C9h, 0CDh, 0BBh, 0BAh, ' ', 0BAh, 0C8h, 0CDh, 0BCh

right_password      db 'password', 4 DUP(0)

;-----------------------------------------------------------




end                 Start