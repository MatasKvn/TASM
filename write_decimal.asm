;
; This program prints contains the proc "write_decimal" which prints the number in ax in decimal form
;
.model small
.stack 100h

.data
	newLine db 13, 10, "A"
	bufftemp db ' '
	inputFile_Buffer db "abc xddA", 0
.code

start:

	mov ax, 10536
	call write_decimal




    ;return to DOS
    mov ah, 4ch             
    mov al, 0               
    int 21h                 
	

	
write_decimal proc
	
	;xor dx, dx
	xor cx, cx
	mov bx, 10

calculate:
	xor dx, dx
	cmp ax, 10
	jb end_of_number          ; if > 10
	
	div bx                     ; ax / 10
	add dx, 48
	
	push dx
	inc cx
	
	jmp calculate
	
end_of_number:
	mov dx, ax
	add dx, 48
	push dx
	inc cx
	
	mov ah, 02
	ciklas:
		pop dx
		int 21h
	loop ciklas
	
ret
	
end start

