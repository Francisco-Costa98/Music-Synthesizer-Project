	#include p18f87k22.inc

rst	code	0x0000	; reset vector
	goto	start
	
setup	movlw	0x00
	movwf	TRISD, ACCESS
	movwf	TRISE, ACCESS
	
main	code
start	clrf	TRISD	
	movlw	0x45
	movwf	PORTD, ACCESS
	movlw	0x00
	movwf	PORTE, ACCESS
	movlw	0x01
	movwf	PORTE, ACCESS
	goto	start
	

	end
