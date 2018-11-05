	#include p18f87k22.inc

rst	code	0x0000	; reset vector
	

	goto	setup
	
setup	movlw	0x00
	movwf	TRISD, ACCESS
	movwf	TRISE, ACCESS
	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
myArray	res 0x80	; Address in RAM for data
	goto	start
	; ******* My data and where to put it in RAM *
myTable  db	0x7F, 0x93, 0xA6, 0xB9, 0xCA, 0xD9, 0xE6, 0xF0, 0xF8, 0xFC, 0xFE, 0xFC, 0xF8, 0xF0, 0xE6, 0xD9, 0xCA, 0xB9, 0xA6, 0x93, 0x7F, 0x6B, 0x58, 0x45, 0x34, 0x25, 0x18, 0x0E, 0x06, 0x02, 0x00, 0x02, 0x06, 0x0E, 0x18, 0x25, 0x34, 0x45, 0x58, 0x6B
	constant    counter=0x10   ; Address of counter variable
main	code
start	clrf	TRISD	
	call table_read
	goto	start
	
clock_pulse
	movlw	0x00
	movwf	PORTE, ACCESS
	movlw	0xA0
	movwf	0x19
	call	clk_delay
	movlw	0x01
	movwf	PORTE, ACCESS
	return
	
delay	decfsz 0x20 ; decrement until zero
	bra delay	
	return

delay2	decfsz 0x21 ; decrement until zero
	bra delay2	
	return

clk_delay decfsz 0x19 ; decrement until zero
	bra clk_delay	
	return
	
	return
	
table_read lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	.40		;22 bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0	; move read data from TABLAT to (FSR0), increment FSR0	
	movff	INDF0, PORTD
	call	clock_pulse
	movlw	0xAA
	movwf	0x20
	movlw	0x01
	movwf	0x21
	call	delay
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
	return
	
	
	end
