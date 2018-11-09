#include p18f87k22.inc
	
	global setup_keypad, keypad_start, khigh, klow
	
acs0    udata_acs
khigh	res 1
klow	res 1
testreg1 res 1
testreg	res 1
keypad_delay	res 1

keypad    code


setup_keypad	
	banksel PADCFG1 ; PADCFG1 is not in Access Bank!!
	bsf	PADCFG1, REPU, BANKED ; PortE pull-ups on
	movlb	0x00 ; set BSR back to Bank 0
	setf	TRISE, ACCESS ; Tri-state PortE	
	clrf	LATE
	clrf	LATH
	movlw	0x0F
	movwf	TRISE, ACCESS
	movlw	0x00
	movwf	TRISH, ACCESS
	movlw	0x0A
	movwf	keypad_delay
	return

	
	
keypad_start	
	movlw	0x0F
	movwf	TRISE, ACCESS
	movlw	0x0A
	movwf	keypad_delay
	call	delay
	movff	PORTE, testreg1
	movlw	0x00
	addwf	testreg1, 0, 0
	sublw	0x0F
	movwf	testreg1
	
	movlw	0xF0
	movwf	TRISE, ACCESS
	movlw	0x0A
	movwf	keypad_delay
	call	delay
	movff	PORTE, testreg
	movlw	0x00
	addwf	testreg, 0, 0
	sublw	0xF0
	movwf	testreg
	movlw	0x00
	addwf	testreg1, 0, 0
	addwf	testreg, 1, 0
	movlw	0x0A
	movwf	keypad_delay
	call	delay
	
	
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
	movlw	0x08
	movwf	khigh
	movlw	0x38
	movwf	klow
	call	Write
	goto	finish
test9	movlw	.68
	cpfseq	testreg
	bra	testA
	movlw	0x09
	movwf	khigh
	movlw	0x39
	movwf	klow
	call	Write
	goto	finish
testA	movlw	.129
	cpfseq	testreg
	bra	testB
	movlw	0x0A
	movwf	khigh
	movlw	0x41 
	movwf	klow
	call	Write
	goto	finish
testB	movlw	.132
	cpfseq	testreg
	bra	testC
	movlw	0x0B
	movwf	khigh
	movlw	0x42
	movwf	klow
	call	Write
	goto	finish
testC	movlw	.136
	cpfseq	testreg
	bra	testD
	movlw	0x0C
	movwf	khigh
	movlw	0x43
	movwf	klow
	call	Write
	goto	finish
testD	movlw	.72
	cpfseq	testreg
	bra	testE
	movlw	0x0D
	movwf	khigh
	movlw	0x44
	movwf	klow
	call	Write
	goto	finish
testE	movlw	.40
	cpfseq	testreg
	bra	testF
	movlw	0x0E
	movwf	khigh
	movlw	0x45
	movwf	klow
	call	Write
	goto	finish
testF	movlw	.24
	cpfseq	testreg
	bra	finish2
	movlw	0x0F
	movwf	khigh
	movlw	0x46
	movwf	klow
	call	Write
	goto	finish
	
finish	
	movff	klow, PORTH
	goto	keypad_start
	return
	
finish2	
	bra finish
	

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	keypad_delay	; decrement until zero
	bra delay
	return
	
Write	movlw	0x0A
	movwf	keypad_delay
	call	delay
	
	;movlw	0xFF
	;movwf	0x20, ACCESS
	;movlw	0x10
	;movwf	0x22
	;call	phat_delay
	return
	
phat_delay	decfsz 0x20 ; decrement until zero
	bra phat_delay
	call delay2	
	return
	
delay2	decfsz 0x21 ; decrement until zero	
	bra phat_delay
	call delay3
	return
		
delay3	decfsz 0x22 ; decrement until zero	
	bra phat_delay
	return

    end