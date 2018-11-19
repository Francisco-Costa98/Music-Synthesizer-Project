#include p18f87k22.inc
	extern LCD_Clear, LCD_Send_Byte_D, LCD_Cursor_R, LCD_Cursor_L
	global setup_keypad, keypad_start, khigh, klow, test, a_test, chord_test
	
acs0    udata_acs	    ; reserves space for variables used
test		res 1	    ; reserves space for test if zero
khigh		res 1	    ; reserves space for frequencies
klow		res 1	    ; reserves space for frequencies
testreg1	res 1	    ; reserves space for test
testreg		res 1	    ; reserves space for test
keypad_delay	res 1	    ; reserves space for delay
ascii_note	res 1	    ; reserves space for storing ascii character
a_test		res 1	    ; reserves space for a button test
chord_test	res 1	    ; reserves space for chord test

keypad    code		    ;main code
    

setup_keypad				; routine to set up keypad
	banksel PADCFG1			; PADCFG1 is not in Access Bank!!
	bsf	PADCFG1, RJPU, BANKED	; PortE pull-ups on
	movlb	0x00			; set BSR back to Bank 0
	setf	TRISJ, ACCESS		; Tri-state PortE	
	clrf	LATJ			;clears latch J
	clrf	LATH			;clears latch H
	movlw	0x00			;sets portH to output port
	movwf	TRISH, ACCESS
	movlw	0x0A			; values moved into delay register
	movwf	keypad_delay
	movlw	0x00			;initialises value for khigh
	movwf	khigh
	movlw	0xa9			;initialises value for klow
	movwf	klow
	return

	
	
keypad_start			;routine to read keypad
	;call	LCD_Clear	;clears LCD
	movlw	0x5f
	movwf	ascii_note	;moves underscore to ascii writter if nothing is pressed
	movlw	0x00		; initiliases test value to se if keypad is pressed
	movwf	a_test		; tests if c is pressed
	movwf	chord_test	; tests if chord is pressed
	movlw	0x01
	movwf	test		;moves into the test register
	movlw	0x0F		; lights up one side of portJ (keypad port) for logic operations
	movwf	TRISJ, ACCESS	; moves value to port j
	movlw	0x0A		;delay keypad register set up
	movwf	keypad_delay	;moves value to delay register
	call	delay		;delays keypad
	movff	PORTJ, testreg1	;moves value presed in port J to test register one
	movlw	0x00
	addwf	testreg1, 0, 0	; moves test register value to w register
	sublw	0x0F		; subtracts value from 0F to see which bit its pressed
	movwf	testreg1	;moves value of pressed bit to test register 1
	
	movlw	0xF0		; lights up other side of the keypad port (port J)
	movwf	TRISJ, ACCESS	;moves value to portj
	movlw	0x0A		;delay keypad register set up
	movwf	keypad_delay	;moves value to delay register
	call	delay		;delays keypad
	movff	PORTJ, testreg	;moves value in port j to test register
	movlw	0x00
	addwf	testreg, 0, 0	; moves test register value to w register
	sublw	0xF0		; subtracts value from F0 to find which bit is pressed on the left side
	movwf	testreg		;moves pressed bit into test register
	movlw	0x00
	addwf	testreg1, 0, 0	; movest pressed bit on the right hand side to w register
	addwf	testreg, 1, 0	;adds both left pressed bit and right pressed bit togehter
	movlw	0x0A		;delay keypad register set up
	movwf	keypad_delay	;moves value to delay register
	call	delay		;delays keypad
	; we now have the combined value of the pressed bits in the test register
	; this number is unique for each pressed number
	; in the next sequence of tests we compare this number with the known possible values for what we 
	; know this number could be, if there is a match we branch to the finish routine, if there are
	; no matchess we branch to the finish 2 routine
	; if there is a match we move the required khigh and klow values to what frequency we
	; want that number to correspond to 
	
test0	movlw	.130
	cpfseq	testreg
	bra	test1
	movlw	0x00
	movwf	khigh
	movlw	0x7E 
	movwf	klow
	call	Write
	goto	finish
test1	movlw	.17
	cpfseq	testreg
	bra	test2
	movlw	0x01
	movwf	khigh
	movlw	0x2E
	movwf	klow
	movlw	0x41
	movwf	ascii_note
	call	Write
	goto	finish
test2	movlw	.18
	cpfseq	testreg
	bra	test3
	movlw	0x01
	movwf	khigh
	movlw	0x0D
	movwf	klow
	movlw	0x42
	movwf	ascii_note
	call	Write
	goto	finish
test3	movlw	.20
	cpfseq	testreg
	bra	test4
	movlw	0x00
	movwf	khigh
	movlw	0xFE
	movwf	klow
	movlw	0x43
	movwf	ascii_note
	call	Write
	goto	finish
test4	movlw	.33
	cpfseq	testreg
	bra	test5
	movlw	0x00
	movwf	khigh
	movlw	0xE2
	movwf	klow
	movlw	0x44
	movwf	ascii_note
	call	Write
	goto	finish
test5	movlw	.34
	cpfseq	testreg
	bra	test6
	movlw	0x00
	movwf	khigh
	movlw	0xC9
	movwf	klow
	movlw	0x45
	movwf	ascii_note
	call	Write
	goto	finish
test6	movlw	.36
	cpfseq	testreg
	bra	test7
	movlw	0x00
	movwf	khigh
	movlw	0xBE
	movwf	klow	
	movlw	0x46
	movwf	ascii_note
	call	Write
	goto	finish
test7	movlw	.65
	cpfseq	testreg
	bra	test8
	movlw	0x00
	movwf	khigh
	movlw	0xA9
	movwf	klow
	movlw	0x47
	movwf	ascii_note
	call	Write
	goto	finish
test8	movlw	.66
	cpfseq	testreg
	bra	test9
	movlw	0x00
	movwf	khigh
	movlw	0x97
	movwf	klow
	movlw	0x48
	movwf	ascii_note
	call	Write
	goto	finish
test9	movlw	.68
	cpfseq	testreg
	bra	testA
	movlw	0x00
	movwf	khigh
	movlw	0x87
	movwf	klow
	movlw	0x49
	movwf	ascii_note
	call	Write
	goto	finish
testA	movlw	.129
	cpfseq	testreg
	bra	testB
	movlw	0x00
	;movwf	khigh
	movlw	0x63 
	;movwf	klow
	movlw	0x01
	movwf	a_test
	call	Write_Song
	goto	finish
testB	movlw	.132
	cpfseq	testreg
	bra	testC
	movlw	0x00
	movwf	khigh
	movlw	0x45
	movwf	klow
	call	Write
	goto	finish
testC	movlw	.136
	cpfseq	testreg
	bra	testD
	movlw	0x01
	movwf	khigh
	movlw	0x8f
	movwf	klow
	movlw	0x01
	movwf	chord_test
	movlw	0x00
	movwf	test
	call	Write
	goto	finish
testD	movlw	.72
	cpfseq	testreg
	bra	testE
	movlw	0x01
	movwf	khigh
	movlw	0xa7
	movwf	klow
	movlw	0x01
	movwf	chord_test
	movlw	0x00
	movwf	test
	call	Write
	goto	finish
testE	movlw	.40
	cpfseq	testreg
	bra	testF
	movlw	0x01
	movwf	khigh
	movlw	0xda
	movwf	klow
	movlw	0x01
	movwf	chord_test
	movlw	0x00
	movwf	test
	call	Write
	goto	finish
testF	movlw	.24
	cpfseq	testreg
	bra	finish2
	movlw	0x02
	movwf	khigh
	movlw	0x34
	movwf	klow
	movlw	0x01
	movwf	chord_test
	movlw	0x00
	movwf	test
	call	Write
	goto	finish
	
finish			    ; finish routine 
	bsf	PORTC, 1    ; lights up a bit in port c to show us a value has been passed through
	return		    ; returns to main code
	
finish2			    ; finish two routine
	bcf	PORTC, 1    ; clears a bit in port C to let us know no value is being read
	movlw	0x00	    ; moves zero into the w register
	movwf	test	    ; moves value of zero into test value for use in main routine
	movwf	PORTH	    ; turns off portH to show us no values are being read
	movlw	0x01	    ; sets values of khigh
	movwf   khigh	    ; gives khigh a high value to give our clock time to run the rest of the commands
	movlw	0xFF	    ; sets value of klow
	movwf	klow	    ; sets high value of klow to give our clock time to run the rest of the commands
	return		    ; returns to main code
	

; ******* DELAYS **********
delay				; a delay subroutine 
	decfsz	keypad_delay	; decrement register until zero
	bra delay		; loops until delay register is zero
	return
	
; ********** FUNCTIONS WHICH WRITE TO LCD ********	
Write				; a routine to write our klow values to port h 
	movf	ascii_note
	call	LCD_Send_Byte_D ; sends ascii to lcd
	call	LCD_Cursor_R	; moves cursor right
	movlw	0x0A		; sets up keypad_delay register
	movwf	keypad_delay	; moves value into register
	call	delay		; calls delay
	movff	klow, PORTH	; moves klow value to port h
	return

Write_Song			; subroutine writes the word song when right key is pressed
	movlw	0x53
	;call LCD_Send_Byte_D
	movlw	0x6f
	;call LCD_Send_Byte_D
	movlw	0x6e
	;call LCD_Send_Byte_D
	movlw	0x67
	;call LCD_Send_Byte_D
	
	return
	
    end