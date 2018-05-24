; NASM Skeleton
;
; November 15, 2011
 
    org 100h
 
section .text    

start:                 		      ; creates a space and starting value needed for startDisplayLoop  
    mov ah, 06         		      ; service 06h (display ASCII)
    mov dl, 10        		      ; move line return ASCII into dl where it will be read
    int 21h           		      ; call interrupt 21 (display ASCII) displays line return
    mov dl, 13       		      ; move carriage return ASCII into dl where it will be read
    int 21h             	      ; call interrupt 21 (display ASCII) displays carriage return
    mov  bx, message    	      ; get address of first character in message

startDisplayLoop:      		      ; loop used to display the input message
    mov dl, [bx]       		      ; get character at address in BX
    inc bx             		      ; point BX to next char in message
    cmp dl, 0          		      ; Is DL = null (that is, 0)?
    je  startingValues                ; If yes, then jump to label startingValues
    mov ah, 06          	      ; If no, then call int 21h service 06h
    int 21h             	      ; to print the character
    jmp startDisplayLoop              ; Repeat for the next character

startingValues:        		      ; starting values needed for inputLoop
    mov [counter], byte 0             ; moves into counter a value of 0
    mov bx, input  		      ; get address of first character of input  

inputLoop:         		      ; Loop that gets ad displays character input
    mov ah, 00h    		      ; service 00h (get keystroke)
    int 16h        		      ; call interrupt 16h (AH=00h)      
                   		      ; character read will now be in AL
    cmp al, 48     		      ; checks to see if a decimal digit is being entered
    jl start       		      ; if not, jump to start label
    cmp al, 57     		      ; checks to see if a decimal digitr is being entered
    jg start       		      ; if not, jump to start label
    mov [bx], al   		      ; If the ASCII entered is a number, then store the character in input
    mov dl, al   		      ; move character value into dl where it will be read
    mov ah, 06   		      ; If no, then call int 21h service 06h
    int 21h        		      ; call interrupt 21 (display ASCII) displays the number just typed
    inc bx          		      ; point BX to next character of input
    add [counter], byte 1 	      ; increment counter
    cmp [counter], byte 4 	      ; compares counter to 4
    je  makeIntValues      	      ; If counter is equal to 4, then jump to makeIntValues label
    jmp inputLoop         	      ; Repeat loop if counter is not equal to 4

makeIntValues:      		      ; starting values needed for makeIntLoop
    mov bx, input 		      ; get address of first character in input
    sub dx, dx    		      ; clears out dx
    sub ax, ax    		      ; clears out ax
    mov cx, 1000   		      ; sets the value of cx to 1000 (used to make the digits go into the appropriate place value) 
    mov [counter], byte 4 	      ; sets counter variable to 4

makeIntLoop:              	      ; loop that creates an integer value based on user input
    mov al, [bx]          	      ; moves into al the fist digit entered
    sub al, 30h          	      ; subtracts 48 from the value to convert from ASCII to a decimal number
    mul cx                	      ; multiplys the digit by cx to get the appropriate place value
    add [intNum], ax      	      ; adds the new value into a variable called intNum where the decimal number will be stored
    mov ax, cx            	      ; moves the value in cx into ax
    mov cl, 10            	      ; moves 10 into cl
    div cl                	      ; divides what is in ax by 10 (used so that the next digit will have a place value to the left of the current one)
    mov cx, ax           	      ; moves the new value in ax back into cx
    inc bx               	      ; points bx to the next character of input
    sub [counter], byte 1 	      ; decreases the value in counter by 1
    cmp [counter], byte 0 	      ; checks to see if counter is equal 0 
    jg makeIntLoop        	      ; If no, repeat loop
    jmp makeHexValues    	      ; If yes, jump to makeHexValues label

makeHexValues:           	      ; starting values needed for makeHexLoop
    mov cx, 16           	      ; moves into cx 16, the divisor needed to convert from decimal to hexadecimal
    mov ax, [intNum]     	      ; moves into ax the number that was input by the user (in integer form)
    mov bx, hexNum       	      ; gets address of first character in hexNum
    add bx, 3            	      ; points bx to the fourth character in hexNum
    sub dx, dx            	      ; clears out dx
    mov [counter], byte 4 	      ; moves into counter the value of 4

makeHexLoopPart1:        	      ; First part of the loop used to convert decimal values into hexadecimal (converts values into ASCII)
    div cx               	      ; divide intNum by 16 to get convert part of the number into hexadecimal
    cmp dl, 9                         ; Compares the remainder of the division to 9
    jg convertToASCII1                ; jump to label convertToASCII1 if it is greater than 9
    cmp dl, 10                        ; Compares the remainder of division is less than 10
    jl convertToASCII2                ; jump to label convertToASCII2 if it is less than 10

makeHexLoopPart2:                     ; Second part of the loop used to convert decimal values into hexadecimal (stores converted values) 
    mov [bx], dl                      ; moves into hexNum a hexadecimal digit that was converted into ASCII
    dec bx                            ; points bx to the previous character in hexNum
    sub dx, dx                        ; clears out dx
    sub [counter], byte 1             ; decreases counter by 1
    cmp [counter], byte 0             ; Compares counter to 0
    je makeBinaryValues               ; jump to makeBinaryValues label if it is eqial to 0
    jmp makeHexLoopPart1              ; If not, repeat loop (starting at makeHexLoopPart1)

convertToASCII1:                      ; Used to convert values greater than 9 into ASCII
    add dl, 37h                       ; adds 55 to the value in dx to convert the hexdecimal digit into its ASCII equivalent
    jmp makeHexLoopPart2              ; jumps to second part of makeHexLoop 

convertToASCII2:                      ; Used to convert values less than 10 into ASCII
    add dl, 30h                       ; adds 48 to the value in dx to convert the hexdecimal digit into its ASCII equivalent
    jmp makeHexLoopPart2              ; jumps to second part of makeHexLoop

makeBinaryValues:                     ; starting values needed for makeBinaryLoop
    mov cx, 2                         ; moves into cx a value of 2, the divisor needed to convert from decimal to binary
    mov si, 3                         ; moves into si a value of 3 (needed to determine value to be converted from hexadecimal to decimal)
    mov ax, [hexNum + si]             ; moves into ax the fourth character in hexNum 
    mov bx, binaryNum                 ; gets address of first character in binaryNum 
    add bx, 15                        ; points bx to the sixteenth character in binaryNum
    sub dx, dx                        ; clears out dx
    mov [counter], byte 4             ; moves into counter the value of 4

hexFromASCII:                         ; converts from ASCII to the decimal equivalent of a hexadecimal number
    cmp ax, 57                        ; compares ax to 57
    jg convertFromASCII1              ; jump to label convertFromASCII1 if it is greater than 57
    cmp ax, 58                        ; compates ax to 58
    jl convertFromASCII2              ; jump to label convertFromASCII2 if it is less than 58

makeBinaryLoop:                       ; loop that converts hexadecimal to binary
    div cx                            ; divides ax by 2 to convert part of the number into binary
    add dl, 30h                       ; adds 48 to the value in dl to convert the binary digit into its ASCII equivalent
    mov [bx], dl                      ; moves into binaryNum the binary digit that was converted into ASCII
    dec bx                            ; points bx to the previous character in binaryNum
    sub dx, dx                        ; clears out dx
    sub [counter], byte 1             ; decreases counter by 1
    cmp [counter], byte 0             ; compares counter to 0
    je makeBinaryChangeValues         ; if it is equal to 0, jump to makeBinaryChangeValues to update values to convert the next hexadecimal digit to binary
    jmp makeBinaryLoop                ; if not, repeat loop (starting at makeBinaryLoop)

makeBinaryChangeValues:               ; changes the values needed to convert the next hexadecimal digit into binary
    dec si                            ; decreases the value in si by 1
    cmp si, -1                        ; compares si to -1
    je displayBinaryResultValues      ; if it is equal to -1, jump to displayBinaryResultValues label
    mov [counter], byte 4             ; if not, reset the value in counter to 4   
    sub ax, ax                        ; clear out ax
    mov al, [hexNum + si]             ; move into al the previous character in hexNum
    jmp hexFromASCII                  ; jump to label hexFromASCII

convertFromASCII1:                    ; Used to convert hexadecimal values greater than 9 into their decimal equivalent
    sub ax, 37h                       ; subtracts 55 from the value in ax to convert the ASCII character into its hexadecimal value equivalent
    jmp makeBinaryLoop                ; jumps to label makeBinaryLoop

convertFromASCII2:                    ; Used to convert hexadecimal values greaterless than 10 into their decimal equivalent
    sub ax, 30h                       ; subtracts 48 from the value in ax to convert the ASCII character into its hexadecimal value equivalent
    jmp makeBinaryLoop                ; jumps to label makeBinaryLoop


displayBinaryResultValues:            ; creates two spaces and starting value needed for displayBinaryResultLoop
    mov ah, 06                        ; service 06h (display ASCII)
    mov dl, 10                        ; move line return ASCII into dl where it will be read
    int 21h                           ; call interrupt 21 (display ASCII) displays line return
    int 21h                           ; call interrupt 21 (display ASCII) displays line return
    mov dl, 13                        ; move carriage return ASCII into dl where it will be read
    int 21h                           ; call interrupt 21 (display ASCII) displays carriage return    
    mov  bx, binaryMessage            ; get address of first character in binaryMessage

displayBinaryResultLoop:              ; loop used to display to binary conversion result message
    mov dl, [bx]                      ; get character at address in BX
    inc bx                            ; point BX to next character in binaryMessage
    cmp dl, 0                         ; Is DL = null (that is, 0)?
    je  displayBinaryValues           ; If yes, then jump to displayBinaryValues label
    mov ah, 06                        ; If no, then call int 21h service 06h
    int 21h                           ; to print the character
    jmp displayBinaryResultLoop       ; Repeat for the next character

displayBinaryValues:        	      ; starting value needed for displayBinaryLoop
    mov  bx, binaryNum        	      ; get address of first character in binaryNum

displayBinaryLoop:             	      ; loop used to display the binary result
    mov dl, [bx]                      ; get character at address in BX
    inc bx                    	      ; point BX to next character in binaryNum
    cmp dl, 0                 	      ; Is DL = null (that is, 0)?
    je  displayHexResultValues 	      ; If yes, then jump to displayHexResultValues label
    mov ah, 06               	      ; If no, then call int 21h service 06h
    int 21h                	      ; to print the character
    jmp displayBinaryLoop     	      ; Repeat for the next character   

displayHexResultValues:               ; creates two spaces and starting value needed for displayHexResultLoop
    mov ah, 06                        ; service 06h (display ASCII)
    mov dl, 10                        ; move line return ASCII into dl where it will be read
    int 21h                           ; call interrupt 21 (display ASCII) displays line return
    int 21h                           ; call interrupt 21 (display ASCII) displays line return
    mov dl, 13                        ; move carriage return ASCII into dl where it will be read
    int 21h                           ; call interrupt 21 (display ASCII) displays carriage return       
    mov  bx, hexMessage               ; get address of first character in hexMessage

displayHexResultLoop:                 ; loop used to display to hexadecimal conversion result message
    mov dl, [bx]           	      ; get character at address in BX
    inc bx                     	      ; point BX to next character in hexMessage
    cmp dl, 0                  	      ; Is DL = null (that is, 0)?
    je  displayHexValues  	      ; If yes, then jump to displayHexValues label
    mov ah, 06              	      ; If no, then call int 21h service 06h
    int 21h                 	      ;    to print the character
    jmp displayHexResultLoop 	      ; Repeat for the next character

displayHexValues:         	      ; starting value needed for displayHexLoop
    mov  bx, hexNum      	      ; get address of first character in hexNum

displayHexLoop:              	      ; loop used to display the hexadecimal result
    mov dl, [bx]            	      ; get character at address in BX
    inc bx                  	      ; point BX to next char in hexNum
    cmp dl, 0              	      ; Is DL = null (that is, 0)?
    je  quit               	      ; If yes, then quit
    mov ah, 06             	      ; If no, then call int 21h service 06h
    int 21h                	      ; to print the character
    jmp displayHexLoop     	      ; Repeat for the next character   

quit:                      	      ; terminates the program after creating a space (just to look neater)
    mov ah, 06            	      ; service 06h (display ASCII)
    mov dl, 10            	      ; move line return ASCII into dl where it will be read
    int 21h               	      ; call interrupt 21 (display ASCII) displays line return  
    int 20h                	      ; all interrupt 20 to terminate the program

section .data
    message dw "Enter a 4 digit decimal number: ", 0            ; message displayed that asks user for input
    counter db 0                                                ; counter variable used to keep track of loop iterations
    input   TIMES 5 db 0   ; reserves 5 bytes (each byte = 0)   ; null string where the user's input will be stored (in ASCII)
    hexNum TIMES 5 db 0                                         ; null string where the converted hexadecimal value will be stored (in ASCII)
    intNum dw 0                                                 ; null value where the user's input will be stored after being converted into a decimal value
    binaryNum TIMES 17 db 0                                     ; null string where the converted binary value will be stored (in ASCII)
    binaryMessage dw "Binary Conversion Result: ", 0            ; message displayed that tells the user that the following will be the converted binary number
    hexMessage dw "Hexadecimal Conversion Result: ", 0          ; message displayed that tells the user that the following will be the converted hexadecimal number
