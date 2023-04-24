.model tiny
.code
org 100h
locals @@

Start:				cli									; disables external interrupts
				xor bx, bx
				mov es, bx


				mov bx, 8*4d								; address of the old 8th interrupt handler in the table
				mov ax, es:[bx]
				mov old_08_OFS, ax							; saves the std 8th interrupt vector
				mov ax, es:[bx+2]
				mov old_08_SEG, ax

				mov es:[bx],   offset New_08_Int					; puts a new 8th interrupt vector
				mov es:[bx+2], cs 


				mov bx, 9*4d								; address of the old 9th interrupt handler in the table
				mov ax, es:[bx]
				mov old_09_OFS, ax							; saves the std 9th interrupt vector
				mov ax, es:[bx+2]
				mov old_09_SEG, ax

				mov es:[bx],   offset New_09_Int					; puts a new 9th interrupt vector
				mov es:[bx+2], cs


				sti									; enables external interrupts


				call Prepare_Frame							; draws a frame and registers names in the memory


				mov ax, 3100h								; terminates and stays resident
				lea dx, Program_End
				shr dx, 4d
				inc dx
				int 21h

				


;-----------------------------------------------------------
; New interrupt handler of the timer
;-----------------------------------------------------------
; This handler calls different functions from "RLib"
; depending on the value of variable "mode".
;
; Variable "mode" takes on the four values which are equal
; to consecutive natural numbers (in order to change "mode"
; quickly):
;
;       FRAME_OFF   - Used when the frame isn't shown.
;	            - Nothing is being done.
;                   - Equals 0.
;
;   SAVE_AND_SHOW   - Used just after user presses hot key if
;                     the previous mode was FRAME_OFF.
;                   - Calls Save_Image to save an interface
;		      image in the buffer.
;                   - Calls Show_Frame to draw a frame with
;		      registers' values on the screen.
;                   - Changes "mode" to UPDATE_AND_SHOW.
;                   - Equals 1.
;
; UPDATE_AND_SHOW   - Used when the frame is shown.
;		    - Calls Update_Image to save changes and
;                     update buffer with an interface image.
;                   - Calls Show_Frame to draw a frame with
;		      registers' values on the screen.
;                   - Equals 2.
;
;         RESTORE   - Used just after user presses hot key if
;		      the previous mode was UPDATE_AND_SHOW.
;                   - Calls Restore_Image to restore an
;		      interface image from the buffer to the
;                     video memory.
;                   - Changes "mode" to FRAME_OFF.
;                   - Equals 3.
;
; It calls the old handler in any case after calling
; further functions.
;-----------------------------------------------------------
New_08_Int			proc
				push bx

				lea bx, mode

@@Skip:				cmp byte ptr cs:[bx], SAVE_AND_SHOW					; cmp mode, SAVE_AND_SHOW
				je @@Save_and_Show

				cmp byte ptr cs:[bx], UPDATE_AND_SHOW					; cmp mode, UPDATE_AND_SHOW
				je @@Update_and_Show

				cmp byte ptr cs:[bx], RESTORE						; cmp mode, RESTORE
				je @@Restore

				jmp @@Exit


@@Save_and_Show:		call Save_Image
				call Show_Frame
				mov byte ptr cs:[bx], UPDATE_AND_SHOW					; mov mode, UPDATE_AND_SHOW
				jmp @@Exit


@@Update_and_Show:		call Update_Image
				call Show_Frame
				jmp @@Exit


@@Restore:			call Restore_Image
				mov byte ptr cs:[bx], FRAME_OFF						; mov mode, FRAME_OFF


@@Exit:				pop bx
				db 0EAh									; jumps to the old handler
				old_08_OFS dw 0
				old_08_SEG dw 0
				endp
;-----------------------------------------------------------




;-----------------------------------------------------------
; New interrupt handler of the keyboard
;-----------------------------------------------------------
; This handler scans user's keystrokes.
;
; If user presses the hot key, it changes the value of
; "mode" variable, confirms an interrupt and exits.
;
; If user presses any other key, calls the old handler.
;-----------------------------------------------------------
New_09_Int			proc
				push ax

				in al, 60h								; saves scancode in AL
				cmp al, Hot_Key
				jne @@Skip

				inc cs:mode								; changes mode
				jmp @@Exit
				
@@Skip:				pop ax
				db 0EAh									; jumps to the old handler
				old_09_OFS dw 0
				old_09_SEG dw 0

@@Exit:				in al, 61h								; sends confirmation to the keyboard controller
				mov ah, al
				or al, 80h
				out 61h, al
				xchg ah, al
				out 61h, al

				mov al, 20h								; sends confirmation to the interrupt controller
				out 20h, al

				pop ax
				iret
				endp
;-----------------------------------------------------------




include RLib.asm

Program_End:
end				Start







-------------------------------------------------------------------------------------------------------------------------------> Time

       off             off             on             on             on             off             off             off
	-               -          Save_Image    Update_Image   Update_Image    Restore_Image        -               -
			 					 Show_Frame      Show_Frame	 Show_Frame									   
Mode:	0               0              1              2              2               3               0               0
