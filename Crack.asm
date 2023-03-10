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
; Destroys:         AX, BX, CX, DX, SI
; Exit:             None
;-----------------------------------------------------------
Display_Menu        proc

                    mov bx, 160d + 2d
                    mov ch, 5Ch                                 ; color of a frame symbol
                    mov cl, 5Ch                                 ; color of a space symbol
                    mov dh, 13d					; height of the frame
		    mov dl, 38d					; width  of the frame
                    call DrawFrame

                    mov ah, 3Ch                                 ; color of a symbol for the picture
                    mov al, ' '                                 ; symbol for the picture
                    call Print_HACK_ME

                    mov bx, 160*9d + 2*10d
                    mov si, offset Enter_The_Password
                    mov ch, 4Ah                                 ; color for "ENTER THE PASSWORD"
                    call PrintString
                
                    mov field_coordinates, 160*11d + 2*14d      ; saves password field coordinates
                    mov bx, field_coordinates

                    mov si, offset Password_Field
                    mov ch, 3Ch                                 ; color for a field to entering the password
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
max_len_of_password EQU 12

Enter_Password      proc

                    mov bx, field_coordinates
                    mov ch, 0BAh                                ; prints the first blinking underscore
                    mov cl, '_'
                    mov es:[bx], cx
                    
                    mov si, offset Entered_Password
                    xor dx, dx

@@Next_Symbol:      mov ah, 08h                                 ; reads a symbol without echo
                    int 21h
                    inc dx

                    cmp al, 0Dh                                 ; compares with enter
                    je @@Enter_Exit

                    mov [si], al                                ; puts entered char to a password buffer
                    inc si

                    mov ch, 3Ah
                    mov cl, '*'
                    mov es:[bx], cx                             ; prints a star
                    add bx, 2
                    mov ch, 0BAh

                    cmp dx, max_len_of_password
                    je @@Max_Len_Exit

                    mov cl, '_'                                 ; prints a blinking underscore
                    mov es:[bx], cx

                    jmp @@Next_Symbol

@@Max_Len_Exit:     mov ah, 08h                         
                    int 21h
                    mov [si], al

                    cmp al, 0Dh                                 ; continues only by enter
                    jne @@Max_Len_Exit
                    jmp @@Exit

@@Enter_Exit:       mov cl, ' '                                 ; does not print a blinking star 
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

                    mov si, offset Entered_Password
                    mov di, offset Right_Password

                    mov cx, max_len_of_password
                    mov dh, [si]                                ; entered symbols will be in DH

@@Next:             cmp dh, [di]                                ; comparison
                    jne @@Change_Flag

                    inc si
                    mov dh, [si]
                    inc di
                    loop @@Next
                    
                    jmp @@Result

@@Change_Flag:      add flag, 1
                    
@@Result:           mov ah, 93h                                 ; color 
                    mov al, 0B1h                                ; a symbol for the picture

                    cmp flag, 1                                 ; flag = 0 - right password
                    je @@AccessDenied                           ; flag = 1 - wrong password

@@AccessGranted:    call Print_ACCESS_GRANTED
                    jmp @@Exit

@@AccessDenied:     call Print_ACCESS_DENIED

@@Exit:             ret
                    endp
;-----------------------------------------------------------

include CrackLib.asm

;-----------------------------------------------------------

Enter_The_Password  db ' ENTER THE PASSWORD ', 0
Password_Field      db max_len_of_password DUP(' '), 0
field_coordinates   dw 0

Right_Password      db 'password', 4 DUP(0)
Entered_Password    db max_len_of_password DUP(0)
flag                db 0

;-----------------------------------------------------------

end                 Start
