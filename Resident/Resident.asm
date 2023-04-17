.model tiny
.code
org 100h
locals @@

Start:				cli											; disables external interrupts
					xor bx, bx
					mov es, bx


					mov bx, 8*4d								; address of the old 8th interrupt handler in the table
					mov ax, es:[bx]
					mov old_08_OFS, ax							; saves std 8th interrupt vector
					mov ax, es:[bx+2]
					mov old_08_SEG, ax

					mov es:[bx], offset New_08_Int				; puts new 8th interrupt vector
					mov ax, cs
					mov es:[bx+2], ax 


					mov bx, 9*4d								; address of the old 9th interrupt handler in the table
					mov ax, es:[bx]
					mov old_09_OFS, ax							; saves std 9th interrupt vector
					mov ax, es:[bx+2]
					mov old_09_SEG, ax
					
					mov es:[bx], offset New_09_Int		
					mov ax, cs									; puts new 9th interrupt vector
					mov es:[bx+2], ax


					sti											; enables external interrupts
					

					call Prepare_Frame							; draws a frame and registers names in the memory


					mov ax, 3100h								; terminates and stays resident
					lea dx, Program_End
					shr dx, 4d
					inc dx
					int 21h

				


;-----------------------------------------------------------
; New interrupt handler of the timer
;-----------------------------------------------------------
; This handler calls different functions from "ResLib"
; depending on the value of "mode" variable that changes
; in some cases.
; It calls the old handler in any case after calling
; further functions.
;-----------------------------------------------------------
New_08_Int			proc

					cmp mode, 3d
					jna @@Skip
					mov mode, 0									; initializes the value of "mode" variable
					jmp @@Exit

@@Skip:				cmp mode, MODE_1
					je @@Mode_1

					cmp mode, MODE_2
					je @@Mode_2

					cmp mode, MODE_3
					je @@Mode_3

					jmp @@Exit


@@Mode_1:			call Save_Image
					call Show_Frame
					mov mode, MODE_2							; changes mode
					jmp @@Exit


@@Mode_2:			call Update_Saved_Image
					call Show_Frame
					jmp @@Exit


@@Mode_3:			call Drop_Saved_Image
					mov mode, MODE_0							; changes mode


@@Exit:				db 0EAh										; jumps to std 8th interrupter
					old_08_OFS dw 0
					old_08_SEG dw 0

					endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; New interrupt handler of the keyboard
;-----------------------------------------------------------
; This handler scans user's keystrokes.
; If user presses the hot key, it changes the value of
; "mode" variable, confirms an interrupt and exits.
; If user presses any other key, calls old handler.
;-----------------------------------------------------------
New_09_Int			proc
					push ax
					
					in al, 60h									; saves scancode
					cmp al, Hot_Key
					jne @@Skip

					inc mode									; changes mode
					jmp @@Exit
				
@@Skip:				pop ax
					db 0EAh										; jumps to std 9th interrupter
					old_09_OFS dw 0
					old_09_SEG dw 0

@@Exit:				in al, 61h									; sends confirmation to the keyboard controller
					mov ah, al
					or al, 80h
					out 61h, al
					xchg ah, al
					out 61h, al

					mov al, 20h									; sends confirmation to the interrupt controller
					out 20h, al

					pop ax
					iret
					endp
;-----------------------------------------------------------



include ResLib.asm



Program_End:
end					Start





------------------------------------------------------------------------------------------------------------> Time

       off             off             on             on             on             off             off             off
		-               -          Save_Image    Update_Saved   Update_Saved     Drop_Saved          -               -
			 					   Show_Frame     Show_Frame	 Show_Frame									   
Mode:	0               0              1              2              2               3               0               0