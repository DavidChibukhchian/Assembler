.model tiny
.code
org 100h
locals @@

Start:				mov bx, offset str_example
					call my_printf
					
					mov ax, 4C00h
					int 21h


str_example db "hello %x hello $"








;---------------------------------------------------
; My printf implementation
;---------------------------------------------------
; Entry:
; Expects:
; Exit :
; Destroys: 
;---------------------------------------------------
my_printf			proc

@@Next:				mov dl, [bx]
					mov temp, dl
					cmp temp, '$'
					je @@Exit_near
					
					cmp temp, '%'
					je @@Specifier
					jmp @@Symbol
				

@@Specifier:		inc bx

					mov dl, [bx]
					mov temp, dl
					cmp temp, '$'
					je @@Exit_near
					
					cmp temp, 's'
					je @@String

					cmp temp, 'u'
					je @@Unsigned
					
					cmp temp, 'x'
					je @@Hex
					
					cmp temp, 'b'
					je @@Binary

					cmp temp, 'c'
					je @@Char

				
@@Exit_near:	 	jmp @@Exit

;---------------------------------------------------

@@String: 			mov ah, 09h
					mov dx, [arg1]
					int 21h
					
					inc bx
					jmp @@Next
				
;---------------------------------------------------

base dw 0

@@Unsigned:			mov base, 10d
					jmp @@Start

@@Hex:				mov base, 16d
					jmp @@Start

@@Binary:			mov base, 2d
					jmp @@Start


@@Start:			push bx
					mov ax, 31
					mov bx, base
					mov si, offset temp_str
					call print_number_in_str

					mov si, offset temp_str
					jmp @@SkipZero
				
@@SkipZero:			mov dl, [si]
					cmp dl, '0'
					je @@Skip
					jmp @@Exit_number
				
@@Skip:				inc si
					jmp @@SkipZero

				
@@Exit_number:		pop bx
					mov ah, 09h
					mov dx, si
					int 21h

					inc bx
					jmp @@Next

;---------------------------------------------------

@@Char:				mov ah, 02h
					mov dx, [arg1]
					int 21h
					
					inc bx
					jmp @@Next

;---------------------------------------------------
		
@@Symbol:			mov ah, 02h
					mov dl, [temp]
					int 21h

					inc bx
					jmp @@Next

;---------------------------------------------------

@@Exit:				ret
					endp




temp db 0
temp_str db 16 DUP(0)


arg1 dw 0
arg2 dw 0
arg3 dw 0
arg4 dw 0
arg5 dw 0

;----------------------------------------------------------
; Converts a number to system with base BX and puts
; result in any string of length 16
;----------------------------------------------------------
; Entry:			AX = number
;					BX = base
;					SI = address of string
; Expects:			None
; Destroys:			CL DX SI
; Exit:				None
;----------------------------------------------------------
print_number_in_str	proc
				
					mov dx, 00h 				; (DX,AX) - dword
					add si, 0Fh					; si -> end of string
					mov byte ptr [si+1], '$' 	; puts \0 to the end
					mov cl, 16d					; counter = 16

@@Next_Digit: 		dec cl
					div bx

					cmp dl, 10d
					jb @@Small_Base
	
@@Big_Base:			sub dl, 10d
					add dl, 'A'
					sub dl, '0'

@@Small_Base:		add dl, '0'

					mov [si], dl
					dec si
					cmp ax, 0
					je @@Fill_Zero
					
					mov dx, 00h
					jmp @@Next_Digit		
		
@@Fill_Zero: 		cmp cl, 0
					je @@Exit
					mov byte ptr [si], '0'
					dec si
					dec cl
					jmp @@Fill_Zero

@@Exit:				mov cl, byte ptr[si]
					cmp cl, '0'
					je @@SkipZero
					jmp @@Exit0

@@SkipZero: 		inc si
					jmp @@Exit



@@Exit0:			ret
					endp
;----------------------------------------------------------



end					Start