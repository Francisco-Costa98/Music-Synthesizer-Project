	#include p18f87k22.inc

rst	code	0x0000	; reset vector
	goto	start
	
setup	movlw	0x00
	movwf	TRISD, ACCESS
	movwf	TRISE, ACCESS
	
main	code
start	clrf	TRISD	
	movlw	0xAA
	movwf	PORTD, ACCESS
	call	clock_pulse
	movlw	0xFF
	movwf	0x20
	call	delay
	movlw	0xFF
	movwf	PORTD, ACCESS
	call	clock_pulse
	movlw	0xFF
	movwf	0x20
	call	delay
	goto	start
	
clock_pulse
	movlw	0x00
	movwf	PORTE, ACCESS
	movlw	0xFF
	movwf	0x20
	call	delay
	movlw	0x01
	movwf	PORTE, ACCESS
	return
	
delay	decfsz 0x20 ; decrement until zero
	bra delay	
	return

	end
