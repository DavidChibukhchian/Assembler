.model tiny
.code
org 100h
locals @@

Start:				mov ax, 0B800h
					mov es, ax

					mov bx, 2*3d + 160*(5d - 1d)			; x = 3, y = 5
					mov ah, 03h								; frame symbol
					mov al, 5Ch								; color attributes
					mov ch, ' '								; space symbol
					mov cl, 4Ch 							; color attributes
					mov dh, 5d								; height of frame
					mov dl, 7d								; width  of frame
					call DrawFrame
											
					mov ax, 4C00h
					int 21h



;-----------------------------------------------------------
; Draws a frame on the screen
;-----------------------------------------------------------		
; Entry:			AH = frame symbol
;					AL = color attributes
;					BX = video segment coordinates
;					CH = space symbol
;					CL = color attributes
;					DH = height
;					DL = width
; Expects:			ES -> video segment
; Destroys:			None
; Exit:				None
;-----------------------------------------------------------
new_line 			EQU 160d

DrawFrame			proc
					push dx bx cx
					mov cx, ax
					call DrawLine

					add bx, new_line
					pop cx
					dec dh 		
		
@@Next_Line:		cmp dh, 1
					je @@Exit

					call DrawLine
					add bx, new_line
					dec dh
					jmp @@Next_Line

@@Exit:				push cx
					mov cx, ax
					call DrawLine

					pop cx bx dx
					ret
					endp
;-----------------------------------------------------------



;-----------------------------------------------------------
; Draws a line on the screen
;-----------------------------------------------------------
; Entry:			AH = frame symbol
;					AL = color attributes
;					BX = video segment coordinates
;					CH = space symbol
;					CL = color attributes
;					DL = width
; Expects:			ES -> video segment
; Destroys:			None
; Exit:				None	
;-----------------------------------------------------------
size_of_pixel 		EQU 2

DrawLine			proc
					push bx dx

					sub dl, size_of_pixel

					mov byte ptr es:[bx],   ah
					mov byte ptr es:[bx+1], al

@@Next_Symbol:		cmp dl, 0
					je @@Exit

					add bx, size_of_pixel
					mov byte ptr es:[bx],   ch
					mov byte ptr es:[bx+1], cl
					dec dl
					jmp @@Next_Symbol
		
@@Exit:				add bx, size_of_pixel
					mov byte ptr es:[bx],   ah
					mov byte ptr es:[bx+1], al

					pop dx bx
					ret
					endp
;-----------------------------------------------------------

end					Start
