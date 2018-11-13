#include p18f87k22.inc
	
	global setup_keypad, keypad_start, khigh, klow, test
	
acs0    udata_acs	    ;reserves space for variables used
test	res 1
khigh	res 1
klow	res 1
testreg1 res 1
testreg	res 1
keypad_delay	res 1

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
	movlw	0x01		; initiliases test value to se if keypad is pressed
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
	
	
test0	movlw	.130
	cpfseq	testreg
	bra	test1
	movlw	0x00
	movwf	0x03, ACCESS
	movlw	0x30 
	movwf	0x04
	call	Write
	goto	finish
test1	movlw	.17
	cpfseq	testreg
	bra	test2
	movlw	0x01
	movwf	khigh
	movlw	0x2E
	movwf	klow
	call	Write
	goto	finish
test2	movlw	.18
	cpfseq	testreg
	bra	test3
	movlw	0x01
	movwf	khigh
	movlw	0x0D
	movwf	klow
	call	Write
	goto	finish
test3	movlw	.20
	cpfseq	testreg
	bra	test4
	movlw	0x00
	movwf	khigh
	movlw	0xFE
	movwf	klow
	call	Write
	goto	finish
test4	movlw	.33
	cpfseq	testreg
	bra	test5
	movlw	0x00
	movwf	khigh
	movlw	0xE2
	movwf	klow
	call	Write
	goto	finish
test5	movlw	.34
	cpfseq	testreg
	bra	test6
	movlw	0x00
	movwf	khigh
	movlw	0xC9
	movwf	klow
	call	Write
	goto	finish
test6	movlw	.36
	cpfseq	testreg
	bra	test7
	movlw	0x00
	movwf	khigh
	movlw	0xBE
	movwf	klow	
	call	Write
	goto	finish
test7	movlw	.65
	cpfseq	testreg
	bra	test8
	movlw	0x00
	movwf	khigh
	movlw	0xA9
	movwf	klow
	call	Write
	goto	finish
test8	movlw	.66
	cpfseq	testreg
	bra	test9
	movlw	0x00
	movwf	khigh
	movlw	0x97
	movwf	klow
	call	Write
	goto	finish
test9	movlw	.68
	cpfseq	testreg
	bra	testA
	movlw	0x00
	movwf	khigh
	movlw	0x85
	movwf	klow
	call	Write
	goto	finish
testA	movlw	.129
	cpfseq	testreg
	bra	testB
	movlw	0x00
	movwf	khigh
	movlw	0x63 
	movwf	klow
	call	Write
	goto	finish
testB	movlw	.132
	cpfseq	testreg
	bra	testC
	movlw	0x00
	movwf	khigh
	movlw	0x42
	movwf	klow
	call	Write
	goto	finish
testC	movlw	.136
	cpfseq	testreg
	bra	testD
	movlw	0x00
	movwf	khigh
	movlw	0x21
	movwf	klow
	call	Write
	goto	finish
testD	movlw	.72
	cpfseq	testreg
	bra	testE
	movlw	0x0
	movwf	khigh
	movlw	0x10
	movwf	klow
	call	Write
	goto	finish
testE	movlw	.40
	cpfseq	testreg
	bra	testF
	movlw	0x00
	movwf	khigh
	movlw	0x0A
	movwf	klow
	call	Write
	goto	finish
testF	movlw	.24
	cpfseq	testreg
	bra	finish2
	movlw	0x00
	movwf	khigh
	movlw	0x01
	movwf	klow
	call	Write
	goto	finish
	
finish	
	bsf	PORTC, 1
	return
	
finish2	
	movlw	0x00
	bcf	PORTC, 1
	movwf	test
	movwf	PORTH
	movlw	0x01
	movwf   khigh
	movlw	0xFF
	movwf	klow
	return
	

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	keypad_delay	; decrement until zero
	bra delay
	return
	
Write	movlw	0x0A
	movwf	keypad_delay
	call	delay
	movff	klow, PORTH
	return


    end