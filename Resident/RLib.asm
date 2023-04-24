;-----------------------------------------------------------
; Saves an interface image in the buffer
;-----------------------------------------------------------
; Entry:			None
; Expects:			None
; Destroys:			None
; Exit:				DI -> saved image
;-----------------------------------------------------------
Save_Image			proc
					cld
					push bx cx si di ds es

					mov bx, 0B800h
					mov ds, bx									; DS -> video segment

					mov si, cs
					mov es, si									; ES -> data(code) segment

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
					ret
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
Update_Image		proc
					push ax bx cx si di bp es

					lea si, image_to_show
					mov di, top_left_corner
					lea bp, saved_image

					mov bx, 0B800h
					mov es, bx									; ES -> video segment


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
					ret
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
Restore_Image		proc
					push bx cx si di ds es
					cld

					mov bx, cs
					mov ds, bx									; DS -> data(code) segment

					mov si, 0B800h
					mov es, si									; ES -> video segment

					mov si, offset saved_image
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
					ret
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

					call Print_Registers

					call Draw_Image

					ret
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
					push ax

					mov address, offset image_to_show	
					add address, length_of_frame * size_of_pixel
					add address, size_of_pixel * 8d

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

					pop ax
					ret
					endp
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
					push bx cx di

					mov bx, ax
					mov di, address
					mov cx, 4d									; number of digits of the register's value


@@Next:				and ax, get_remainder						; gets remainder of division by 16d
					cmp ax, 9d
					jna @@Digit

@@Letter:			sub al, 10d
					add al, 'A'
					jmp @@Continue

@@Digit:			add al, '0'

@@Continue:			mov ah, color_of_registers_values
					mov word ptr cs:[di], ax
					sub di, size_of_pixel
					shr bx, 4d									; divides a value by 16d
					mov ax, bx

					loop @@Next


					add di, length_of_frame * size_of_pixel
					add di, size_of_pixel * 4d
					mov address, di

					pop di cx bx
					ret
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
					push bx cx si di ds es
					cld

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
					ret
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
					ret
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
					push ax cx si di es

					mov cx, cs
					mov es, cx

					lea di, image_to_show
					add di, length_of_frame * size_of_pixel
					add di, size_of_pixel * 2d

					mov cx, number_of_registers
					mov ah, color_of_registers_names
					lea si, register_names

@@Next:				push di
					mov al, [si]
					stosw
					mov al, [si+1]
					stosw
					pop di

					add di, length_of_frame * size_of_pixel
					inc si
					inc si

					loop @@Next

					pop es di si cx ax
					ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------

width_of_display	EQU 80d
new_line			EQU 160d
size_of_pixel		EQU 2
get_remainder		EQU 15d

FRAME_OFF			EQU 0
SAVE_AND_SHOW		EQU 1
UPDATE_AND_SHOW		EQU 2
RESTORE				EQU 3

Hot_Key 			EQU 215d									; F11 (87d - 215d)
length_of_frame		EQU 11d
height_of_frame		EQU 14d
number_of_registers	EQU 12d

top_left_corner		EQU 0
;top_left_corner		EQU (width_of_display - length_of_frame) * 2d + new_line

color_of_frame		       EQU 3Ch
color_of_space			   EQU 3Ch
color_of_registers_names   EQU 3Ch
color_of_registers_values  EQU 3Ch

frame_symbols 		db 0C9h, 0CDh, 0BBh, 0BAh, ' ', 0BAh, 0C8h, 0CDh, 0BCh

register_names		db "axbxcxdxsidibpspdscssses"

mode				db 0
saved_image			db height_of_frame * length_of_frame * 2d DUP(0)
image_to_show		db height_of_frame * length_of_frame * 2d DUP(0)

address 			dw 0

include FrameLib.asm

;-----------------------------------------------------------