.model tiny
.code
org 100h
locals @@

Start:				cli
					xor bx, bx
					mov es, bx
					mov bx, 8*4d
					
					mov ax, es:[bx]
					mov old_08_OFS, ax						; saves std 8 int vector
					mov ax, es:[bx+2]
					mov old_08_SEG, ax

					mov es:[bx], offset New_08_Int			; puts new 8 int vector
					mov ax, cs
					mov es:[bx+2], ax 
				
					mov bx, 9*4d
					mov ax, es:[bx]							; saves std 9 int vector
					mov old_09_OFS, ax
					mov ax, es:[bx+2]
					mov old_09_SEG, ax
					
					mov es:[bx], offset New_09_Int		
					mov ax, cs								; puts new 9 int vector
					mov es:[bx+2], ax
					sti

					
					call PrepareFrame

					mov ax, 3100h
					mov dx, offset Program_End				; terminates and stay resident
					shr dx, 4
					inc dx
					int 21h

				


;-----------------------------------------------------------
;
;-----------------------------------------------------------
New_08_Int			proc

					cmp mode, 3d
					jna @@Skip
					mov mode, 0
					jmp @@Exit

@@Skip:				cmp mode, MODE_1
					je @@Mode_1

					cmp mode, MODE_2
					je @@Mode_2

					cmp mode, MODE_3
					je @@Mode_3

					jmp @@Exit


@@Mode_1:			call Save
					call Show
					mov mode, MODE_2
					jmp @@Exit


@@Mode_2:			call Check
					call Show
					jmp @@Exit


@@Mode_3:			call Drop
					mov mode, MODE_0


@@Exit:				db 0EAh									; jmp to std 08 interrupter
					old_08_OFS dw 0
					old_08_SEG dw 0

					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
;
;-----------------------------------------------------------
New_09_Int			proc
					push ax
					
					in al, 60h								; save key in AH
					cmp al, Hot_Key
					jne @@Skip

					inc mode
					jmp @@Exit
				
@@Skip:				pop ax
					db 0EAh									; jmp to std 09 interrupter
					old_09_OFS dw 0
					old_09_SEG dw 0

@@Exit:				in al, 61h
					mov ah, al
					or al, 80h
					out 61h, al
					xchg ah, al
					out 61h, al

					mov al, 20h
					out 20h, al

					pop ax
					iret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Saves an interface image to the buffer
;-----------------------------------------------------------
; Entry:			None
; Expects:			None
; Destroys:			None
; Exit:				DI -> saved image
;-----------------------------------------------------------
Save				proc
					cld
					push bx cx si di ds es

					mov bx, 0B800h
					mov ds, bx

					mov si, cs
					mov es, si

					mov si, top_left_corner
					mov di, offset saved_buffer


					mov cx, height_of_frame

@@Next:				push cx
					mov cx, length_of_frame

					push si
					rep movsw
					pop si

					add si, new_line
					pop cx
					loop @@Next


					pop es ds di si cx bx
					ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Drops the saved image on the screen
;-----------------------------------------------------------
; Entry:			None
; Expects:			None
; Destroys:			None
; Exit:				None
;-----------------------------------------------------------
Drop				proc
					cld
					push bx cx si di ds es

					mov bx, cs
					mov ds, bx

					mov si, 0B800h
					mov es, si

					mov si, offset saved_buffer
					mov di, top_left_corner


					mov cx, height_of_frame

@@Next:				push cx
					mov cx, length_of_frame

					push di
					rep movsw
					pop di

					add di, new_line
					pop cx
					loop @@Next


					pop es ds di si cx bx
					ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Checks
;-----------------------------------------------------------
; Entry:			None
; Expects:			None
; Destroys:			None
; Exit:				None
;-----------------------------------------------------------
Check				proc
					push ax bx cx si di bp es

					lea si, image_buffer
					mov di, top_left_corner
					lea bp, saved_buffer

					mov bx, 0B800h
					mov es, bx


					mov cx, height_of_frame

@@Next_Line:		push cx
					mov cx, length_of_frame
					push di

@@Next:				mov ax, cs:[si]			; from image
					mov bx, es:[di]			; from display
					cmp ax, bx
					je @@Skip
					mov cs:[bp], bx

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
; Shows
;-----------------------------------------------------------
; Entry:
; Expects:
; Destroys:
; Exit:
;-----------------------------------------------------------
Show				proc

					call PrintRegisters

					call DropFrame

					ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
DropFrame			proc
					cld
					push bx cx si di ds es

					mov bx, cs
					mov ds, bx

					mov si, 0B800h
					mov es, si

					mov si, offset image_buffer
					mov di, top_left_corner


					mov cx, height_of_frame

@@Next:				push cx
					mov cx, length_of_frame

					push di
					rep movsw
					pop di

					add di, new_line
					pop cx
					loop @@Next


					pop es ds di si cx bx
					ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
PrintRegisters		proc
					push ax bx es

					mov bx, cs
					mov es, bx

					mov bx, offset image_buffer
					mov coordinates, bx
					add coordinates, length_of_frame*2d
					add coordinates, size_of_pixel*8d

					call PrintRegister

					mov ax, bx
					call PrintRegister

					mov ax, cx
					call PrintRegister

					mov ax, dx
					call PrintRegister

					mov ax, si
					call PrintRegister

					mov ax, di
					call PrintRegister

					mov ax, bp
					call PrintRegister

					mov ax, sp
					call PrintRegister

					mov ax, ds
					call PrintRegister

					mov ax, es
					call PrintRegister
					
					mov ax, ss
					call PrintRegister

					mov ax, cs
					call PrintRegister

					pop es bx ax
					ret
					endp
coordinates 		dw 0
;-----------------------------------------------------------




;-----------------------------------------------------------
PrintRegister		proc
					push bx cx di
					std

					mov bx, ax
					mov di, coordinates
					mov cx, 4d

@@Next:				and ax, 15d
					cmp ax, 9d
					jna @@Digit			; если ax не больше чем 9
					jmp @@Letter

@@Digit:			add al, '0'
					jmp @@Continue

@@Letter:			sub al, 10d
					add al, 'A'
					jmp @@Continue

@@Continue:			mov ah, 3Ch
					stosw
					shr bx, 4d
					mov ax, bx

					loop @@Next


@@Exit:				add di, length_of_frame*2d
					add di, size_of_pixel*4d
					mov coordinates, di

					pop di cx bx
					ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Prepares frame
;-----------------------------------------------------------
; Entry:
; Expects:
; Destroys:
; Exit:
;-----------------------------------------------------------
PrepareFrame		proc
					push ax bx dx si bp es

					mov ah, 3Ch
					mov al, 3Ch
					mov bx, offset image_buffer
					mov dh, height_of_frame
					mov dl, length_of_frame

					mov si, offset frame_symbols
					mov byte ptr [si],   0C9h
					mov byte ptr [si+1], 0CDh
					mov byte ptr [si+2], 0BBh
					mov byte ptr [si+3], 0BAh
					mov byte ptr [si+4], ' '
					mov byte ptr [si+5], 0BAh
					mov byte ptr [si+6], 0C8h
					mov byte ptr [si+7], 0CDh
					mov byte ptr [si+8], 0BCh
	
					mov bp, cs
					mov es, bp
					call DrawFrame

					call PrintRegisterNames

					pop es bp si dx bx ax
					ret
					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; Prints register names
;-----------------------------------------------------------
; Entry:
; Expects:
; Destroys:
; Exit:
;-----------------------------------------------------------
PrintRegisterNames	proc
					push ax cx si di es

					mov cx, cs
					mov es, cx

					mov di, offset image_buffer
					add di, length_of_frame
					add di, length_of_frame
					add di, size_of_pixel
					add di, size_of_pixel

					mov cx, number_of_registers
					mov ah, 3Ch ; color
					mov si, offset register_names

@@Next:				push di
					mov al, [si]
					stosw
					mov al, [si+1]
					stosw
					pop di

					add di, length_of_frame
					add di, length_of_frame
					add si, 2

					loop @@Next

					pop es di si cx ax
					ret
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

Hot_Key 			EQU 215d								; F11 87 - 215
length_of_frame		EQU 11d
height_of_frame		EQU 14d
top_left_corner		EQU 0d
;top_left_corner		EQU (width_of_display - length_of_frame) * 2d + new_line
frame_symbols 		db 0C9h, 0CDh, 0BBh, 0BAh, ' ', 0BAh, 0C8h, 0CDh, 0BCh

number_of_registers	EQU 12d
register_names		db "axbxcxdxsidibpspdsessscs"

mode				db 0
saved_buffer		db height_of_frame * length_of_frame * 2d DUP(0)
image_buffer		db height_of_frame * length_of_frame * 2d DUP(0)

include FrameLib.asm

;-----------------------------------------------------------




;-----------------------------------------------------------
Program_End:
end					Start