.model tiny
.code
org 100h

Start:		cli
		xor bx, bx
		mov es, bx
		mov bx, 8*4d
		
		mov ax, es:[bx]
		mov [old_08_OFS], ax			; save std 8 int vector
		mov ax, es:[bx+2]
		mov [old_08_SEG], ax

		mov es:[bx], offset New_08_int		; put new 8 int vector
		mov ax, cs
		mov es:[bx+2], ax 
	
		mov bx, 9*4d
		mov ax, es:[bx]				; save std 9 int vector
 		mov [old_09_OFS], ax
		mov ax, es:[bx+2]
		mov [old_09_SEG], ax
		
		mov es:[bx], offset New_09_Int		
		mov ax, cs				; put new 9 int vector
		mov es:[bx+2], ax
		sti
		
		mov ax, 3100h
		mov dx, offset Program_End		; terminate and
		shr dx, 4				; stay resident
		inc dx
		int 21h


Hot_Key EQU 87	; F11

New_09_Int	proc
		
		push ax					; save registers
		
		in al, 60h				; save key in AH
		mov ah, al
		
		in al, 61h				; put the first bit
		or al, 80h				; to 61h
		out 61h, al
		
		and al, not 80h				; put the old value
		out 61h, al				; to 61h
		
		mov al, 20h				; confirm
		out 20h, al
				
		cmp ah, Hot_Key
		jne Skip
		xor flag, 1				; change flag
			
Skip:		pop ax
		
		pushf
		db 09Ah		; call std 09 interrupter
		old_09_OFS dw 0
		old_09_SEG dw 0

		iret
		endp


New_08_Int	proc
		
		push ax bx es
		mov bx, 0B800h
		mov es, bx
		mov bx, 160*5d + 80d

		cmp flag, 0
		je Skipl

		mov byte ptr es:[bx],   '1'
		mov byte ptr es:[bx+1], 4Eh
		jmp Ext

Skipl:		mov byte ptr es:[bx],   '2'
		mov byte ptr es:[bx+1], 4Eh
		
Ext:		pop es bx ax

		pushf
		db 09Ah		; call std 08 interrupter
		old_08_OFS dw 0
		old_08_SEG dw 0
		
		iret
		endp

flag db 0

Program_End:

end		Start





Change_08_Int 	proc
		
		cmp flag, 0
		jne TurnOff

		mov flag, 1
		mov bx, 0B800h
		mov es, bx
		mov bx, 160*5d + 80d
		mov byte ptr es:[bx], '2'
		mov byte ptr es:[bx+1], 4Eh

		; put new interrupter
		cli
		xor bx, bx
		mov es, bx
		mov bx, 9*4d

		mov es:[bx], offset New_08_Int
		mov ax, cs
		mov es:[bx+2], ax
		sti
		
		jmp Exit

TurnOff:	mov flag, 0

		mov bx, 0B800h
		mov es, bx
		mov bx, 160*5d + 80d		; debug
		mov byte ptr es:[bx], '1'
		mov byte ptr es:[bx+1], 4Eh

		; put old interrupter
		;xor bx, bx
		;mov es, bx
		;mov bx, 9*4d

		;mov ax, [old_08_OFS]
		;mov es:[bx],   ax
		;mov ax, [old_08_SEG]
		;mov es:[bx+2], ax
		
Exit:		ret
		endp

New_08_Int	proc
		
		pushf
		db 09Ah		; call far
		old_08_OFS dw 0
		old_08_SEG dw 0

		iret
		endp





Program_End:

end		Start