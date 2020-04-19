;Coded by John West on April 18, 2020
;This program will test out the functions library to show the user of number formatted output
;

;
;Include our external functions library functions
%include "./functions64.inc"
 
SECTION .data
	;Welcome and goodbye prompts
	welcomePrompt	db	"Welcome to my 64 bit Program", 00h
	goodbyePrompt	db	"Program ending, have a great day!", 00h
	
	;Menu prompt
	menuPrompt		db 	"Encrypt/Decrypt Program", 0ah
					db	"1) Enter a String", 0ah
					db	"2) Enter an Encryption Key", 0ah
					db	"3) Print the input String", 0ah
					db	"4) Print the input Key", 0ah
					db	"5) Encrypt/Display the String", 0ah
					db	"6) Decrypt/Display the String", 0ah
					db	"x) Exit the Program", 0ah
					db	"Please enter one:", 0ah, 00h
					
	;User selection prompts
	option1Message	db	"Please enter a string: ", 00h
	option2Message	db	"Please enter a key for encrypting: ", 00h
	option3Message	db	"This is the string you input: ", 00h
	option4Message	db	"This is the key you input: ", 00h
	option5Message	db	"Encrypting your string...", 0ah
					db	"Here is your encrypted data: ", 00h
	option6Message	db	"Decrypting your string...", 0ah
					db	"Here is your decrypted data: ", 00h
	defaultMessage	db	"Error - select an option from the menu", 00h
	
	;Assembly switch statement
	CaseTable dq '1'										;One of the values we're looking for
		dq process1											;Quad is the size of a 64-bit address
		EntrySize equ ($ - CaseTable)
		dq '2'												;Case 2
		dq process2
		dq '3'												;Case 3
		dq process3
		dq '4'												;Case 4
		dq process4
		dq '5'												;Case 5
		dq process5
		dq '6'												;Case 6
		dq process6
	NumberOfEntries equ ($ - CaseTable) / EntrySize

	
SECTION .bss
	menuInput		resb 1								;Reserve memory for user input
		.len		equ ($-menuInput)					;Current address - address of user input.
	
	unchangedString	resb 255							;Reserve memory for unchanging string (option 1)
		.len		equ ($-unchangedString)				;Current address - address of user input.
	unchangedStrLength	resq 1							;We will store the length of the user input here
		
	encryptionKey	resb 255							;Reserve memory for encryption key (option 2)
		.len		equ ($-encryptionKey)				;Current address - address of user input.
	encryptKeyLength	resq 1							;We will store the length of the user input here
		
	encryptedString	resb 255							;Reserve memory for the string we are encrypting (option 5)
		.len		equ ($-encryptedString)				;Current address - address of encryptedString string
	encryptStrLength	resq 1							;We will store the length of the user input here
		
	decryptedString	resb 255							;Reserve memory for the string we are decrypting (option 6)
		.len		equ ($-decryptedString)				;Current address - address of decrypted string
	decryptStrLength resq 1								;We will store the length of the user input here
	
 
SECTION     .text
	global  _start
     
_start:
	nop
	
	push	welcomePrompt
	call	PrintString
	call	Printendl
	
	BeginWhile:												;Beginning of do-while loop
	call 	Printendl
	call	printMenu										;Call PrintMenu Procedure to display menu
	
	push	menuInput										;***This is how we get user input!***
	push	menuInput.len									;userInput memory area
	call	ReadText										;Reads the user input and places length into rax
	
	call	ClearKBuffer									;Clear buffer

	mov		rax, 0h
	mov		al, [menuInput]									;Move the menu input to al
	
	mov		rsi, CaseTable									;Move our address of list of case values into rsi
	mov		rcx, NumberOfEntries							;The number of items in our Case table
	CaseLoop:
		cmp	al, 'x'											;Compare what the user entered to 'x'
		je	EndLoop											;if input was equal to 'x', jump to the end of the program
		cmp al, [rsi]										;Compare use input with other switch cases
		jne	GotoNext										;Nope - let's go to the next
		call NEAR [rsi+8]									;Call our function
		jmp  BeginWhile										;If we find the choice, display the menu again
	GotoNext:
		add	rsi, EntrySize									;Move to the address of the next casetable entry
	loop CaseLoop
	
	;This is our default location
	push	defaultMessage									;Display default message if what the user entered doesnt exist
	call	PrintString
	call	Printendl
	DefaultJmp:
	jmp		BeginWhile										;If the user entered invalid menu option, jump back to beginWhile
	
	EndLoop:												;This is where we jump if the user quits
	
	push	goodbyePrompt
	call	PrintString
	call	Printendl
	call	Printendl
	
	nop
;
;Setup the registers for exit and poke the kernel
;Exit: 
Exit:
	mov		rax, 60					;60 = system exit
	mov		rdi, 0					;0 = return code
	syscall							;Poke the kernel


;Process to print the menu to the user
printMenu:
	push	menuPrompt
	call	PrintString
ret

;(Option1)
;This process clears any leftover user strings that were previously in
;unchangedString and modifiedString.
;Receives the string the user has entered
;This process also copies the user input string to the modified string.
process1:

	mov rcx, unchangedString.len						;Move the size of unchangedString.len to rcx
	mov rsi, 0											;Zero out rsi
	
	Loop1:
		mov BYTE [unchangedString + rsi], ''			;Clear out any previous data in unchangedString
		mov	al, [unchangedString + rsi]					;Move the blank character into al
		mov [encryptedString + rsi], al					;Clear out any previous data in encryptedString
		mov [decryptedString + rsi], al					;Clear out any previous data in decryptedString
		inc rsi											;Move to the next character
	loop Loop1

	push option1Message									;Display Option1 message, and get user input
	call PrintString									;
	push unchangedString								;
	push unchangedString.len							;
	call ReadText										;
	dec	rax												;Decriment rax to avoid using null terminator in the string 
	mov [unchangedStrLength], rax						;Set the size of the user's string
	mov	[encryptStrLength], rax							;Set the size of the user's string in encryptedLength
	
ret

;(Option2)
;This process clears any previous input in encryptionKey
;and receives the new encryption key the user has entered
process2:

	mov rcx, encryptionKey.len							;Move full size of encryptionKey to rcx
	mov rsi, 0											;Zero out rsi
	
	Loop3:
		mov BYTE [encryptionKey + rsi], ''				;Clear out any previous data in encryptionKey
		inc rsi											;
	loop Loop3

	push option2Message									;Display option2Message and get user input
	call PrintString									;
	push encryptionKey									;
	push encryptionKey.len								;
	call ReadText										;
	dec rax												;Decrement rax to avoid using null terminator in the key
	mov [encryptKeyLength], rax							;Move size of input user entered to encryptionKey length
	
ret

;(Option3)
;Process to display the user entered string (option3)
process3:
	push option3Message
	call PrintString
	push unchangedString
	call PrintString
ret

;(Option4)
;Process to display the user entered encryption key (option4)
process4:
	push option4Message
	call PrintString
	push encryptionKey
	call PrintString
ret

;(Option5)
;Process to encrypt the user string without changing original string (option5)
process5:
	
	push option5Message									;Display option5 message
	call PrintString									;
	
	mov	rcx, [unchangedStrLength]						;Set rcx to length of the user's input
	mov rsi, 0											;Zero out rsi
	
	mov rbx, [encryptKeyLength]							;Set rbx to length of the key in order to use for loop comparison
	mov rdi, 0											;Zero out rdi
	
	Loop4:
		mov	al, [encryptionKey + rdi]					;Move the encryptionKey char into al
		xor [unchangedString + rsi], al					;xor the unchangedString with the encryptionKey
		mov ah, [unchangedString + rsi]					;move the xor'd value to ah
		mov	[encryptedString + rsi], ah					;move the xor'd value into the encrypted string
		xor	[unchangedString + rsi], al					;restore the unchangedString to its original value
		inc rsi											;increment the encrypted string's index
		inc rdi											;increment the key's index
		cmp rbx, rdi									;compare the size of the key with the current index we're at in the string
		je restartKey									;if we're at the end of the key, jump to restartKey:
		jmp nextChar									;if we're not at the end of the key, jump to the next character
		restartKey:
			mov rdi, 0									;reset the index of the key, looping back around to the first char
		nextChar:
	loop Loop4
	
	push encryptedString
	call PrintString
	call Printendl
	
ret

;(Option6)
;Process to decrypt the user string without changing original string (option6)
process6:
	push option6Message									;Display option6 message
	call PrintString									;
	
	mov	rcx, [encryptStrLength]							;Move the length of the encryptedString to rcx
	mov rsi, 0											;Zero out rsi
	
	mov rbx, [encryptKeyLength]							;Move the length of the key to rbx
	mov rdi, 0											;Zero out rdi
	
	Loop5:
		mov	al, [encryptionKey + rdi]			;Move the encryptionKey char into al
		xor [encryptedString + rsi], al			;xor the encryptedString with the encryptionKey
		mov ah, [encryptedString + rsi]			;move the xor'd value to ah
		mov	[decryptedString + rsi], ah			;move the xor'd value into the decryptedString
		xor	[encryptedString + rsi], al			;restore the encryptedString to its original value
		inc rsi									;Increment to the next character in the encryptedString
		inc rdi									;Increment the key's index
		cmp rbx, rdi							;Check if we're at the end of the key
		je restartKey2							;If we're at the end of the key, jump to restartKey2
		jmp nextChar2							;Otherwise jump to the next character
		restartKey2:
			mov rdi, 0							;If we're at the last char in the key, restart it's index
		nextChar2:
	loop Loop5
	
	push decryptedString						;Display the decryptedString
	call PrintString							;
	call Printendl								;
	
ret

