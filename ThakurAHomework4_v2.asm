;Programmer: Clinton Rogers
;Date: 11/17/2020
;Description: It's a word guessing game, player doesn't win until they
;guess the word. They lose if they guess wrong 6 times.

;Name: Asutosh Thakur
;Date: 12/1/2020
;Description: It's a typical hangman game, where you have 6 guesses to guess a word. With every wrong guess resulting in part of the hangman being drawn on the screen.
.ORIG x3000
JSR CLRSCREEN

AND R3, R3, x0 ;set wrong guesses conter
AND R4, R4, x0 ;set char difference
ADD R5, R5, #6 ;set try counter
LEA R6, GUESSED ;store word to be guessed
LEA R1, WORD ;store word to be guessed
ST R3, WRONG_GUESSES ;Set wrong guesses conter to R0
JSR PRINTHANG ;Print hangman
LEA R0, GUESSED ;load the winning string 
TRAP x22;Display winning message
LOOP ;loop for checking the guessed char and drawing the hangman accordingly. The maxinum amount of time this will go on for is 6 interations.
LDR R7, R1, #0;store current char of the word to be guessed
BRz ENDGAME: ;If we have reached the end of the word to be guessed, we are done with the loop.
ADD R5, R5, #0 ;Calls the try counter
BRz ENDGAME: ;If the try counter is 0, we are done with the loop
TRAP x23 ;get user-input
LDR R7, R1, #0 ;store current char of the word to be guessed
NOT R0, R0 ;turning assci value of the word to be guessed char negative, step 1: flip the bits      
ADD R0, R0, #1 ;turning assci value of the word to be guessed char negative, step 2: add 1, for 2s compliment     
ADD R4, R0, R7 ;subtract the assci values of the current char of the word to be guessed and of the guessed char to see if there is a match. 
 
BRnp NOT_SAME ;if there isn't a match we will go to the branch for dealing with different chars, other wise we can continue while assuming there is a match
ADD R6, R6, #1 ;go to next char for the guessed word
ADD R1, R1, #1 ;go to next char for the word to be guessed
STR R7,R6,#-1 ;place the correct char to the current location of the guessed word
ADD R5, R5, #-1 ;try counter goes down by 1
LEA R0, GUESSED ;load the guessed string 
TRAP x22;Display guessed string 	
BR LOOP  ;go to the next interation

NOT_SAME ;branch where we suppose there wasn't a match                    
ADD R3, R3, x1 ;R0 goes up by 1	
ST R3, WRONG_GUESSES ;Store R3 in wrong guesses
JSR PRINTHANG ;Print hangman
ADD R5, R5, #-1 ;try counter goes down by 1
LEA R0, GUESSED ;load the guessed string  
TRAP x22;Display guessed string 
BR LOOP  ;go to the next interation

ENDGAME: ADD R7, R7, 0  ;calls the currect char of the word to be guessed

BRz BINGO  ;if it is empty, we go the branch where we win, otherwise we will we have lost
LEA R0, LOSE ;load the losing string
TRAP x22 ;Display losing message
BR DONE ;go to the branch where we halt
        
BINGO 
LEA R0, WIN ;load the winning string 
TRAP x22;Display winning message	 		
BR DONE  ;go to the branch where we halt  

DONE TRAP x25 ;this is the branch where the program is over
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DATA;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;WORD TO GUESS
WORD	.STRINGZ "HEY"

;Guessed so far
GUESSED	.STRINGZ "***"

;Guess Again
MESSAGE .STRINGZ "Guess Again!"

;You Win Message
WIN	.STRINGZ "\nYou win!"

;You Lose Message
LOSE	.STRINGZ "\nYou lose!"

;Start Message
START .STRINGZ "Welcome to hangman! The goal is to guess letters of a word. If you guess wrong 6 times, you lose!"


;Register Save space
SAVE_REG0	.FILL x0
SAVE_REG1	.FILL x0
SAVE_REG2	.FILL x0
SAVE_REG3	.FILL x0
SAVE_REG4	.FILL x0
SAVE_REG5	.FILL x0
SAVE_REG6	.FILL x0
SAVE_REG7	.FILL x0

;ASCII REFERENCE CHART
C_I	.FILL x49
C_O	.FILL x4F
C_STAR	.FILL x2A
C_DASH	.FILL x2D
C_SPACE .FILL x20 
C_SLASH .FILL x2F
C_BSLSH .FILL x5C

WRONG_GUESSES	.FILL x0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DATA;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SUB ROUTINES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CLRSCREEN ;Clear Screen subroutine;
	ST R2, SAVE_REG2	;Save register 2
	LD R2, SCREEN_ROWS	;Loop counter to clear screen
	LEA R0, BLANK 		;Load up blank line for TRAP
	ST R7, SAVE_REG7	;Save register 7 since TRAP will erase it
LOOPC	TRAP x22		;Print blank line
	ADD R2, R2, #-1		;Decrement counter
	BRp LOOPC		
	LD R2, SAVE_REG2	;Restore register 2
	LD R7, SAVE_REG7	;Restore register 7
	RET
SCREEN_ROWS .FILL #32	
BLANK	.STRINGZ "\n"

PRINTHANG ;Prints the hang person, provided the wrong guess stored at WRONG_GUESSES label
	ST R0, SAVE_REG0
	ST R1, SAVE_REG1
	ST R2, SAVE_REG2
	ST R3, SAVE_REG3
	ST R4, SAVE_REG4
	ST R5, SAVE_REG5
	ST R6, SAVE_REG6
	ST R7, SAVE_REG7

	LEA R2, DRAWARRAY	;Set up pointer to string
	LD R3, OFFSET		;Use this to offset to the correct position in the string/array
	
	;Determine if we should draw the head
	LD R1, WRONG_GUESSES
	BRz BYPASS
	
	;Draw in the head
	ADD R2, R2, R3	; Advance pointer to O for head
	LD R4, C_O	; Load up O for head.
	STR R4, R2, #0	; Replace space with O
	
	;Determine if we should draw the body
	ADD R1,R1 #-1
	BRz BYPASS

	;Draw the body
	ADD R2, R2, #14	; Advance pointer to I for body
	LD R4, C_I	; Load up I for head.
	STR R4, R2, #0	; Replace space with I


	;Determine if we should draw the left arm
	ADD R1,R1 #-1
	BRz BYPASS

	;Draw the left arm
	ADD R2, R2, #-1	; Advance pointer to - for left arm
	LD R4, C_DASH	; Load up - for left arm
	STR R4, R2, #0	; Replace space with -

	;Determine if we should draw the right arm
	ADD R1,R1 #-1
	BRz BYPASS

	;Draw the right arm
	ADD R2, R2, #2	; Advance pointer to - for right arm
	LD R4, C_DASH	; Load up - for right arm
	STR R4, R2, #0	; Replace space with -

	;Determine if we should draw the left leg
	ADD R1,R1 #-1
	BRz BYPASS

	;Draw the left leg
	ADD R2, R2, #13	; Advance pointer to / left leg
	LD R4, C_SLASH 	; Load up / for left leg
	STR R4, R2, #0	; Replace space with /


	;Determine if we should draw the right leg
	ADD R1,R1 #-1
	BRz BYPASS

	;Draw the left leg
	ADD R2, R2, #2	; Advance pointer to \ right leg
	LD R4, C_BSLSH 	; Load up \ for right leg
	STR R4, R2, #0	; Replace space with \

	
BYPASS	LEA R0, DRAWARRAY
	TRAP x22
	
	LD R0, SAVE_REG0
	LD R1, SAVE_REG1
	LD R2, SAVE_REG2
	LD R3, SAVE_REG3
	LD R4, SAVE_REG4
	LD R5, SAVE_REG5
	LD R6, SAVE_REG6
	LD R7, SAVE_REG7
	RET


OFFSET	.FILL #42
DRAWARRAY .STRINGZ "   ============\n   []       |\n   []        \n   []         \n   []         \n   []\n======================\n"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SUB ROUTINES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.END