;-----------------------------------------------------------
; Saves an interface image in the buffer
;-----------------------------------------------------------
; Entry:			None
; Expects:			None
; Destroys:			None
; Exit:				DI -> saved image
;-----------------------------------------------------------
Save_Image			proc
					mov correct_sp, sp
					;---------------------------------------
					cld
					push bx cx si di ds es

					mov bx, 0B800h
					mov ds, bx

					mov si, cs
					mov es, si

					mov si, top_left_corner
					lea di, saved_image


					mov cx, height_of_frame

@@Next:				push cx
					mov cx, length_of_frame

					push si
					rep movsw									; sends data from the video memory to the buffer
					pop si

					add si, new_line
					pop cx
					loop @@Next


					pop es ds di si cx bx
					;---------------------------------------
					cmp correct_sp, sp
					jne @@Error
					jmp @@Exit0

@@Error:			push ax dx ds

					mov dx, cs
					mov ds, dx
					lea dx, message
					mov ah, 09h
					int 21h
					mov ah, 02h
					mov dl, '1'
					int 21h
					
					pop ds dx ax

@@Exit0:			ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Checks the working area and updates the saved image
;-----------------------------------------------------------
; Entry:			None
; Expects:			None
; Destroys:			None
; Exit:				None
;-----------------------------------------------------------
Update_Saved_Image	proc
					mov correct_sp, sp
					;---------------------------------------
					push ax bx cx si di bp es

					lea si, image_to_show
					mov di, top_left_corner
					lea bp, saved_image

					mov bx, 0B800h
					mov es, bx


					mov cx, height_of_frame

@@Next_Line:		push cx
					mov cx, length_of_frame
					push di

@@Next:				mov ax, cs:[si]								; symbol from image to show is in AX
					mov bx, es:[di]								; symbol from video memory  is in BX
					cmp ax, bx
					je @@Skip
					mov cs:[bp], bx								; updates saved image

@@Skip:				add si, size_of_pixel
					add di, size_of_pixel
					add bp, size_of_pixel
					loop @@Next

					pop di
					add di, new_line
					pop cx
					loop @@Next_Line

					pop es bp di si cx bx ax
					;---------------------------------------
					cmp correct_sp, sp
					jne @@Error
					jmp @@Exit0

@@Error:			push ax dx ds

					mov dx, cs
					mov ds, dx
					lea dx, message
					mov ah, 09h
					int 21h
					mov ah, 02h
					mov dl, '2'
					int 21h

					pop ds dx ax

@@Exit0:			ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Drops the saved image on the working area
;-----------------------------------------------------------
; Entry:			None
; Expects:			None
; Destroys:			None
; Exit:				None
;-----------------------------------------------------------
Drop_Saved_Image	proc
					mov correct_sp, sp
					;---------------------------------------
					cld
					push bx cx si di ds es

					mov bx, cs
					mov ds, bx

					mov si, 0B800h
					mov es, si

					lea si, saved_image
					mov di, top_left_corner


					mov cx, height_of_frame

@@Next:				push cx
					mov cx, length_of_frame

					push di
					rep movsw									; sends data from the saved buffer to the video memory
					pop di

					add di, new_line
					pop cx
					loop @@Next


					pop es ds di si cx bx
					;---------------------------------------
					cmp correct_sp, sp
					jne @@Error
					jmp @@Exit0

@@Error:			push ax dx ds

					mov dx, cs
					mov ds, dx
					lea dx, message
					mov ah, 09h
					int 21h
					mov ah, 02h
					mov dl, '3'
					int 21h

					pop ds dx ax

@@Exit0:			ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Shows a frame with registers' values on the screen
;-----------------------------------------------------------
; Entry:			None
; Expects:			None
; Destroys:			None
; Exit:				None
;-----------------------------------------------------------
Show_Frame			proc
					mov correct_sp, sp
					;---------------------------------------

					call Print_Registers

					call Draw_Image

					;---------------------------------------
					cmp correct_sp, sp
					jne @@Error
					jmp @@Exit0

@@Error:			push ax dx ds

					mov dx, cs
					mov ds, dx
					lea dx, message
					mov ah, 09h
					int 21h
					mov ah, 02h
					mov dl, '4'
					int 21h

					pop ds dx ax

@@Exit0:			ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Prints registers' values in the frame in the memory
;-----------------------------------------------------------
; Entry:			None
; Expects:			None
; Destroys:			None
; Exit:				None
;-----------------------------------------------------------
Print_Registers		proc
					mov correct_sp_1, sp
					;---------------------------------------
					push ax es

					mov address, offset image_to_show
					
					add address, length_of_frame*2d
					add address, size_of_pixel*8d

					call Print_Register

					mov ax, bx
					call Print_Register

					mov ax, cx
					call Print_Register

					mov ax, dx
					call Print_Register

					mov ax, si
					call Print_Register

					mov ax, di
					call Print_Register

					mov ax, bp
					call Print_Register

					mov ax, sp
					call Print_Register

					mov ax, ds
					call Print_Register

					mov ax, cs
					call Print_Register
					
					mov ax, ss
					call Print_Register

					mov ax, es
					call Print_Register

					pop es ax
					;---------------------------------------
					cmp correct_sp_1, sp
					jne @@Error
					jmp @@Exit0

@@Error:			push ax dx ds

					mov dx, cs
					mov ds, dx
					lea dx, message
					mov ah, 09h
					int 21h
					mov ah, 02h
					mov dl, '5'
					int 21h

					pop ds dx ax

@@Exit0:			ret
					endp

address 			dw 0
;-----------------------------------------------------------




;-----------------------------------------------------------
; Prints register value in hexadecimal format to 
; ES:[address - 3] - ES:[address]
;-----------------------------------------------------------
; Entry:			AX = register
;					address = address of the end of four
;						 	  digit number in memory
; Expects:			None
; Destroys:			AX, address++
; Exit:				None
;-----------------------------------------------------------
Print_Register		proc
					mov correct_sp_2, sp
					;---------------------------------------
					push bx cx di
					;std											; to print reversly

					mov bx, ax
					mov di, address
					mov cx, 4d									; number of digits of the register's value

@@Next:				and ax, 15d									; gets remainder of division by 16d
					cmp ax, 9d
					jna @@Digit

@@Letter:			sub al, 10d
					add al, 'A'
					jmp @@Continue

@@Digit:			add al, '0'

@@Continue:			mov ah, color_of_registers_values
					mov word ptr cs:[di], ax
					sub di, 2
					;stosw
					shr bx, 4d									; divides a value by 16d
					mov ax, bx

					loop @@Next


@@Exit:				add di, length_of_frame*2d
					add di, size_of_pixel*4d
					mov address, di

					pop di cx bx
					;---------------------------------------
					cmp correct_sp_2, sp
					jne @@Error
					jmp @@Exit0

@@Error:			push ax dx ds

					mov dx, cs
					mov ds, dx
					lea dx, message
					mov ah, 09h
					int 21h
					mov ah, 02h
					mov dl, '6'
					int 21h

					pop ds dx ax

@@Exit0:			ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Draws a frame with registers' values on the screen
;-----------------------------------------------------------
; Entry:			None
; Expects:			None
; Destroys:			None
; Exit:				None
;-----------------------------------------------------------
Draw_Image			proc
					mov correct_sp_1, sp
					;---------------------------------------
					cld
					push bx cx si di ds es

					mov bx, cs
					mov ds, bx

					mov si, 0B800h
					mov es, si

					lea si, image_to_show
					mov di, top_left_corner


					mov cx, height_of_frame

@@Next:				push cx
					mov cx, length_of_frame

					push di
					rep movsw									; sends data from the buffer to the video memory
					pop di

					add di, new_line
					pop cx
					loop @@Next


					pop es ds di si cx bx
					;---------------------------------------
					cmp correct_sp_1, sp
					jne @@Error
					jmp @@Exit

@@Error:			push ax dx ds

					mov dx, cs
					mov ds, dx
					lea dx, message
					mov ah, 09h
					int 21h
					mov ah, 02h
					mov dl, '7'
					int 21h

					pop ds dx ax

@@Exit:				ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Prepares frame to work by drawing frame and registers'
; names in the memory
;-----------------------------------------------------------
; Entry:			None
; Expects:			None
; Destroys:			None
; Exit:				None
;-----------------------------------------------------------
Prepare_Frame		proc
					mov correct_sp, sp
					;---------------------------------------
					push ax bx dx si bp es

					mov ah, color_of_frame
					mov al, color_of_space
					lea bx, image_to_show
					mov dh, height_of_frame
					mov dl, length_of_frame

					lea si, frame_symbols
	
					mov bp, cs
					mov es, bp
					call DrawFrame

					call Print_Registers_Names

					pop es bp si dx bx ax
					;---------------------------------------
					cmp correct_sp, sp
					jne @@Error
					jmp @@Exit0

@@Error:			push ax dx ds

					mov dx, cs
					mov ds, dx
					lea dx, message
					mov ah, 09h
					int 21h
					mov ah, 02h
					mov dl, '8'
					int 21h

					pop ds dx ax

@@Exit0:			ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Prints registers' names in the frame in the memory
;-----------------------------------------------------------
; Entry:			None
; Expects:			None
; Destroys:			None
; Exit:				None
;-----------------------------------------------------------
Print_Registers_Names proc
					mov correct_sp_1, sp
					;---------------------------------------
					push ax cx si di es

					mov cx, cs
					mov es, cx

					lea di, image_to_show
					add di, length_of_frame
					add di, length_of_frame
					add di, size_of_pixel
					add di, size_of_pixel

					mov cx, number_of_registers
					mov ah, color_of_registers_names
					lea si, register_names

@@Next:				push di
					mov al, [si]
					stosw
					mov al, [si+1]
					stosw
					pop di

					add di, length_of_frame*size_of_pixel
					inc si
					inc si

					loop @@Next

					pop es di si cx ax
					;---------------------------------------
					cmp correct_sp_1, sp
					jne @@Error
					jmp @@Exit0

@@Error:			push ax dx ds

					mov dx, cs
					mov ds, dx
					lea dx, message
					mov ah, 09h
					int 21h
					mov ah, 02h
					mov dl, '9'
					int 21h

					pop ds dx ax

@@Exit0:			ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------

width_of_display	EQU 80d
new_line			EQU 160d
size_of_pixel		EQU 2

MODE_0				EQU 0
MODE_1				EQU 1
MODE_2				EQU 2
MODE_3				EQU 3

Hot_Key 			EQU 215d		; F11 (87d-215d)
length_of_frame		EQU 11d
height_of_frame		EQU 14d
number_of_registers	EQU 12d

color_of_frame		       EQU 3Ch
color_of_space			   EQU 3Ch
color_of_registers_names   EQU 3Ch
color_of_registers_values  EQU 3Ch

top_left_corner		EQU 0
;top_left_corner		EQU (width_of_display - length_of_frame) * 2d + new_line

frame_symbols 		db 0C9h, 0CDh, 0BBh, 0BAh, ' ', 0BAh, 0C8h, 0CDh, 0BCh

register_names		db "axbxcxdxsidibpspdscssses"

mode				db 0
saved_image			db height_of_frame * length_of_frame * 2d DUP(0)
image_to_show		db height_of_frame * length_of_frame * 2d DUP(0)

correct_sp			dw 0
correct_sp_1 		dw 0
correct_sp_2		dw 0
message				db "Different stack pointers in function $"

include FrameLib.asm



;-----------------------------------------------------------