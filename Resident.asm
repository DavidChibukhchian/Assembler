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
					
					
					;mov ah, 4Ch
					;mov al, 4Ch
					;mov bx, 69d*2
					;mov dh, 16d
					;mov dl, 11d
					;mov si, offset Symbols
					;mov bp, 0B800h
					;mov es, bp
					;call DrawFrame
					
					
					mov ax, 3100h
					mov dx, offset Program_End				; terminates and stay resident
					shr dx, 4
					inc dx
					mov flag, 0
					int 21h

				

;-----------------------------------------------------------
New_08_Int			proc

					cmp mode, 4d
					jna @@Skip_new
					mov mode, 0
					jmp @@Exit_new

@@Skip_new:			cmp mode, 1
					je @@Mode_1

					cmp mode, 2
					je @@Mode_2

					cmp mode, 3
					je @@Mode_3

					jmp @@Exit_new


@@Mode_1:			call Save
					call Show
					mov mode, 2
					jmp @@Exit_new


@@Mode_2:			call Check
					call Show
					jmp @@Exit_new


@@Mode_3:			call Drop
					mov mode, 0
					jmp @@Exit_new


@@Exit_new:			db 0EAh									; jmp to std 08 interrupter
					old_08_OFS dw 0
					old_08_SEG dw 0

					endp
;-----------------------------------------------------------






					push bx es
					mov bx, 0B800h
					mov es, bx
					mov bx, 160*5d + 80d

					cmp flag, 0
					je @@Skip

					mov byte ptr es:[bx],   '1'
					mov byte ptr es:[bx+1], 4Eh
					jmp @@Exit

@@Skip:				mov byte ptr es:[bx],   '2'
					mov byte ptr es:[bx+1], 4Eh
			
@@Exit:				pop es bx

					db 0EAh									; jmp to std 08 interrupter
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

					
					;------------------------
					inc mode
					;------------------------

					cmp flag, 1
					je @@Change_flag

					mov flag, 1
					push ax dx
					;mov dl, flag
					;mov ah, 02h
					;int 21h
					pop dx ax
					jmp @@End

@@Change_flag:		mov flag, 0
					push ax dx
					;mov dl, flag
					;mov ah, 02h
					;int 21h
					pop dx ax
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



flag 			db 	0
model			db 0

include FrameLib.asm



;-----------------------------------------------------------
Program_End:
end					Start