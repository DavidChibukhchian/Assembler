.model tiny
.code
org 100h
locals @@

Hot_Key 			EQU 215d								; F11 87 - 215

Start:				cli
					xor bx, bx
					mov es, bx
					mov bx, 8*4d
					
					mov ax, es:[bx]
					mov old_08_OFS, ax						; saves std 8 int vector
					mov ax, es:[bx+2]
					mov old_08_SEG, ax

					mov es:[bx], offset New_08_int			; puts new 8 int vector
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

					
					mov ax, 3100h
					mov dx, offset Program_End				; terminates and stay resident
					shr dx, 4
					inc dx
					int 21h

				

;-----------------------------------------------------------
New_08_Int			proc

					cmp mode, 4d
					jna @@Skip
					mov mode, 0
					jmp @@Exit

@@Skip:				cmp mode, 1
					je @@Mode_1

					cmp mode, 2
					je @@Mode_2

					cmp mode, 3
					je @@Mode_3

					jmp @@Exit


@@Mode_1:			call Save
					call Show
					mov mode, 2
					jmp @@Exit


@@Mode_2:			call Check
					call Show
					jmp @@Exit


@@Mode_3:			call Drop
					mov mode, 0
					jmp @@Exit


@@Exit:				db 0EAh									; jmp to std 08 interrupter
					old_08_OFS dw 0
					old_08_SEG dw 0

					endp
;-----------------------------------------------------------



;-----------------------------------------------------------
New_09_Int			proc
			
					push ax									; save registers
					
					in al, 60h								; save key in AH
					
					cmp al, Hot_Key
					jne @@Skip

					inc mode
					jmp @@End
				
@@Skip:				pop ax
					db 0EAh									; jmp to std 09 interrupter
					old_09_OFS dw 0
					old_09_SEG dw 0

@@End:				in al, 61H
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
; Saves interface data to the buffer
;-----------------------------------------------------------
; Entry:
; Expects:			ES -> video segment
; Destroys:
; Exit:
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
; Entry:
; Expects:
; Destroys:
; Exit:
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
; Entry:
; Expects:
; Destroys:
; Exit:
;-----------------------------------------------------------
Check				proc
					push ax bx cx si di bp es

					mov si, offset image_buffer
					mov di, top_left_corner
					mov bp, offset saved_buffer

					mov bx, 0B800h
					mov es, bx


					mov cx, height_of_frame

@@Next:				push cx
					mov cx, length_of_frame
					push di

@@Next_2:			mov ax, es:[di]			; from display
					mov bx, [si]			; from image
					cmp ax, bx
					jne @@ChangeSymbol
@@Return:
					inc si
					inc di
					inc bp
					loop @@Next_2

					pop di
					add di, new_line
					pop cx
					loop @@Next

					jmp @@End



@@ChangeSymbol:		mov [bp], ax

					jmp @@Return


@@End:				pop es bp di si cx bx ax
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
					push ax bx dx si bp es

					mov ah, 3Ch
					mov al, 3Ch
					mov bx, offset image_buffer
					mov dh, height_of_frame
					mov dl, length_of_frame


					mov si, offset Symbols
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


					call DropImage


					pop es bp si dx bx ax
					ret
					endp

Symbols 			db 0C9h, 0CDh, 0BBh, 0BAh, ' ', 0BAh, 0C8h, 0CDh, 0BCh
;-----------------------------------------------------------


DropImage			proc
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

width_of_display	EQU 80d
new_line			EQU 160d

length_of_frame		EQU 11d
height_of_frame		EQU 16d

top_left_corner		EQU (width_of_display - length_of_frame) * 2d

mode				db 0
saved_buffer		db height_of_frame*length_of_frame*2d DUP(0)
image_buffer		db height_of_frame*length_of_frame*2d DUP(0)

include FrameLib.asm

;-----------------------------------------------------------



;-----------------------------------------------------------
Program_End:
end					Start