.model tiny
.code
locals @@
org 100h

Start:			mov ax, 0B800h
			mov es, ax

			mov bx, 2*3d + 160*(5d - 1d)		; x = 3, y = 5

			mov ah, ' '				; space symbol
			mov al, 4Ch 				; color
			mov ch, 03h				; frame symbol
			mov cl, 5Ch				; color
			mov dh, 5d				; height of frame
			mov dl, 7d				; width  of frame
			call DrawFrame

			mov ax, 4C00h
			int 21h



;---------------------------------------------------
; Draws a frame on the screen
;---------------------------------------------------
; Entry:		AH = space symbol
;			AL = color attributes
;			BX = video segment coordinates
;			CH = frame symbol
;			CL = color attributes
;			DH = height
;			DL = width
; Expects:		ES -> video segment
; Destroys:		?
; Exit:			None
;---------------------------------------------------
new_line EQU 160d

DrawFrame		proc

			mov space_symbol, ah
			mov space_color, al
			mov ah, ch
			mov al, cl

			call DrawLine
			add bx, new_line

			mov ah, space_symbol
			mov al, space_color

			dec dh 		
		
@@NextLine:		cmp dh, 1
			je @@Exit
			call DrawLine
			add bx, new_line
			dec dh

			jmp @@NextLine

@@Exit:			mov space_symbol, ah
			mov space_color, al
			mov ah, ch
			mov al, cl

			call DrawLine
			mov ah, space_symbol
			mov al, space_color

			ret
			endp
;---------------------------------------------------



;---------------------------------------------------
; Draws a line on the screen
;---------------------------------------------------
; Entry:		AH = space symbol
;			AL = color attributes
;			BX = video segment coordinates
;			CH = frame symbol
;			CL = color attributes
;			DL = width
; Expects:		ES -> video segment
; Destroys:		None
; Exit:			None	
;---------------------------------------------------
DrawLine		proc
			push bx dx

			sub dl, 2

			mov byte ptr es:[bx],   ch
			mov byte ptr es:[bx+1], cl

@@Next:			cmp dl, 0
			je @@Exit

			add bx, 2
			mov byte ptr es:[bx],   ah
			mov byte ptr es:[bx+1], al
			dec dl
			jmp @@Next
		
@@Exit:			add bx, 2
			mov byte ptr es:[bx],   ch
			mov byte ptr es:[bx+1], cl

			pop dx bx
			ret
			endp
;---------------------------------------------------

space_symbol db 0
space_color  db 0

end			Start
