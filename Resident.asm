.model tiny
.code
org 100h
locals @@

Hot_Key 			EQU 87									; F11

Start:				cli
					xor bx, bx
					mov es, bx
					mov bx, 8*4d
					
					mov ax, es:[bx]
					mov [old_08_OFS], ax					; save std 8 int vector
					mov ax, es:[bx+2]
					mov [old_08_SEG], ax

					mov es:[bx], offset New_08_int			; put new 8 int vector
					mov ax, cs
					mov es:[bx+2], ax 
				
					mov bx, 9*4d
					mov ax, es:[bx]							; save std 9 int vector
					mov [old_09_OFS], ax
					mov ax, es:[bx+2]
					mov [old_09_SEG], ax
					
					mov es:[bx], offset New_09_Int		
					mov ax, cs								; put new 9 int vector
					mov es:[bx+2], ax
					sti
					
					mov ax, 3100h
					mov dx, offset Program_End				; terminate and stay resident
					shr dx, 4
					inc dx
					int 21h

				

New_08_Int			proc
			
					push ax bx es
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
			
@@Exit:				pop es bx ax

					db 0EAh									; jmp to std 08 interrupter
					old_08_OFS dw 0
					old_08_SEG dw 0
					
					endp



New_09_Int			proc
			
					push ax									; save registers
					
					in al, 60h								; save key in AH
					
					cmp al, Hot_Key
					jne @@Skip
					not flag

	;				cmp flag, 1
	;				je @@Flag
	;				mov flag, 1
	;				jmp Ext
;@@Flag:				mov flag, 0



					;xor flag, 1
					
					;in al, 61h								; put the first bit
					;or al, 80h								; to 61h
					;out 61h, al
					
					;and al, not 80h						; put the old value
					;out 61h, al							; to 61h
					
					;mov al, 20h							; confirm
					;out 20h, al
		

					;cmp flag, 1
					;je Label1
					;mov flag, 1
					;jmp l1
;Label1:				mov flag, 0

;l1: 			
					;xor flag, 1
				
@@Skip:				pop ax
			
					db 0EAh									; jmp to std 09 interrupter
					old_09_OFS dw 0
					old_09_SEG dw 0

					endp

flag db 0



Program_End:

end					Start