;
; Programa, kurios parametrai - failų vardai.
; Išveda kiekvieno failo statistinius duomenis: \
; kiek buvo simbolių, kiek buvo žodžių, kiek mažųjų raidžių, kiek didžiųjų.
;

.model small
.stack 100h

.data
	; failu reikmenys
	inputFile_name db 255 dup (?)
	inputFile_handle dw 0
	inputFile_Buffer db 1000 dup (0)
	
	; zinutes
	msg_help1 db 'Kvieskite programa taip: "u duomenuFailas.txt"', '$'

	newLine db 13, 10, "$"			; pirma "Carriage return" ir tada "enter"
	
	msgerror_fileOpen db "Klaida atidarant faila", "$"
	msgerror_fileRead db "Klaida skaitant faila", "$"
	
	msg_symbol db "Simboliu skaicius: ", "$"
	msg_lowerCase db "Mazuju raidziu skaicius: ", "$"
	msg_upperCase db "Didziuju raidziu skaicius: ", "$"
	msg_words db "Zodziu skaicius: ", "$"
	
.code 

start:
	; sukeliam data ir DS
	mov dx, @data
	mov ds, dx
	
	; gaunam failo pavadinima is parametro 
	call getFileName		
	
	; atidarom faila
	mov ah, 3Dh						
	mov al, 0
	mov dx, offset inputFile_name
	int 21h
	jc error_fileOpen		; jei failo atidaryti nepavyko
	
	; skaitom is faila
	;mov [inputFile_handle], ax
	mov bx, ax
	
	mov ah, 3Fh
	mov cx, 1000
	mov dx, offset inputFile_Buffer
	int 21h
	jc skaitymoKlaida
	
	; spausdinam ivesti
	;push ax ; Issaugome steke registrus,
	;push bx ; kurie keisis (((AS NZN AR MAN CIA REIK TU REGISTRU CIA NUKOPINAU)))
		;mov ah,40h
		;mov bx,1
		;int 21h 
	;pop bx ; Atstatome issaugotus registrus
	;pop ax
	
	; skaiciavimas
	mov bx, offset inputFile_Buffer

	xor cx, cx
skaiciavimas1:					; einam per inputFile_Buffer kol baigias ir skaiciuojam simbolius
	mov al, [bx] 
	
	cmp al, 0
	je skaiciavimas1_Baigtas
	mov dl, al
	inc bx
	inc cx
	jmp skaiciavimas1
skaiciavimas1_Baigtas:
	
	mov ah, 09h
	mov dx, offset msg_symbol
	int 21h
	
	
	mov ax, cx					; spausdinam simboliu skaiciu
	call write_decimal
	
	mov ah, 09h					;newline
	mov dx, offset newLine		;
	int 21h						;
	
	call count_letterTypes		;"si" - mazosios raides
	;							;"di" - didziosios raides, 
	;							;"cx" - zodis

	mov ah, 09h					;newline
	mov dx, offset msg_words	;
	int 21h						;
	mov ax, cx					; spausdinam zodziu skaiciu
	call write_decimal
	
	mov ah, 09h					;newline
	mov dx, offset newLine		;
	int 21h						;
	
	mov ah, 09h
	mov dx, offset msg_lowerCase
	int 21h
	mov ax, si					; spausdinam mazuju raidziu sk
	call write_decimal
	
	mov ah, 09h					;newline
	mov dx, offset newLine		;
	int 21h						;
	
	mov ah, 09h
	mov dx, offset msg_upperCase
	int 21h
	mov ax, di					; spausdinam didziuju raidziu sk
	call write_decimal
	
	; spausdinam failo pavadinima
	;mov ah, 09h
	;mov dx, offset newLine
	;int 21h
	
	;mov dx, offset inputFile_name
	;int 21h

	; PABAIGA
	mov al, 0				
pabaiga:	
    mov ah, 4ch             
               
    int 21h     

error_fileOpen:				; jei failo nepavyksta atidaryt
	mov ah, 09h
	mov dx, offset msgerror_fileOpen
	int 21h	
	jmp pabaiga
	
skaitymoKlaida:				; jei nepavyksta skaityt
	mov ah, 09h
	mov dx, offset msgerror_fileRead
	int 21h	
	jmp pabaiga
	
	

	;skaiciuoja: "si" - mazosios raides, "di" - didziosios raides, "cx" - zodziai
count_letterTypes proc 	  
	mov bx, offset inputFile_Buffer

	xor cx, cx
	xor si, si
	xor di, di
	
	mov dl, [bx]
	cmp dl, 0
	je end_count_letterTypes
	

	
skaiciavimas2:					; einam per inputFile_Buffer ir skaiciuojam viska
	mov al, [bx] 
	
	cmp al, 0
	je nulis	;pasibaige
	
	cmp al, ' '
	je tarpas
	cmp al, 13
	je eilPab
	
	cmp al, 65					
	jae daugiau65
		
daugiau65:
	cmp al, 90
	jbe daugiau65maziau90
	cmp al, 97
	jae daugiau97
	
daugiau97:						
	cmp al, 122
	jbe daugiau97maziau122
	
daugiau97maziau122:				; mazoji raide
	inc si
	jmp skaiciavimas2_pab
	
daugiau65maziau90:				; didzioji raide
	inc di
	jmp skaiciavimas2_pab
	
tarpas:
	cmp dl, 33
	jae zodis
	jmp skaiciavimas2_pab

eilPab:
	dec di
	cmp dl, 33
	jae zodis
	jmp skaiciavimas2_pab
	
zodis:
	inc cx
	jmp skaiciavimas2_pab

nulis:
	cmp dl, 33
	jae zodisPab
	jmp end_count_letterTypes
	
zodisPab:						; tekstas baiges
	inc cx
	jmp end_count_letterTypes
	
skaiciavimas2_pab:
	mov dl, [bx]
	inc bx
	jmp skaiciavimas2

end_count_letterTypes:

ret
	
	
write_decimal proc
	
	;xor dx, dx
	xor cx, cx
	mov bx, 10

calculate:
	xor dx, dx
	cmp ax, 10
	jb end_of_number
	; jei > 10
	div bx ; ax / 10
	;mov dl, ah
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

	; gauna failo varda is parametru
getFileName proc
	mov si, 80h					; tikrinam ar ivesti parametrai, jei ne metam errora
	mov dl, es:[si]
	cmp dl, 0
	je parametruKlaida
	
	mov si, 82h					; tikrinam ar ivesti parametrai, jei ne metam errora
	mov dl, es:[si]
	cmp dl, "?"
	je parametruKlaida

	mov si, 82h
	xor di, di ; tas pats kas "mov di, 0", di naudosim eiti per inputFile_name
	
newChar:						; ciklas, kuriame perkeliam po viena parametro 
	mov dl, es:[si]				; simboli i inputFile_name
	
	;cmp dl, 0				
	cmp dl, ' '
	je end_getFileName			
	cmp dl, 13				
	je end_getFileName			
	
	mov inputFile_name[di], dl
	inc si
	inc di
	jmp newChar
	
	
parametruKlaida:				; jei klaidingi parametrai
	mov ah, 09h					; 
	mov dx, offset msg_help1	; 
	int 21h						
	
	mov ah, 4Ch
	mov al, 0
	int 21h
	
end_getFileName:				; proc getFileName pabaiga
	;inc di
	; jei sito ner, i inputFile_name iraso ir uzsilikusi msg_help
	mov inputFile_name[di], "$"	; uzbaigiam failo varda
	
ret



end start
