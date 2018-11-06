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
myTable  db	0x7f, 0x99, 0xb3, 0xca, 0xdd, 0xed, 0xf8, 0xfd, 0xfd, 0xf8, 0xed, 0xdd, 0xca, 0xb3, 0x99, 0x7f, 0x65, 0x4b, 0x34, 0x21, 0x11, 0x06, 0x01, 0x01, 0x06, 0x11, 0x21, 0x34, 0x4b, 0x65
	constant    counter=0x02   ; Address of counter variable
main	code
start	clrf	TRISD	
	call table_read
	goto	start
	
clock_pulse
	movlw	0x00
	movwf	PORTE, ACCESS
	movlw	0x0A
	movwf	0x53
	call	clk_delay
	movlw	0x01
	movwf	PORTE, ACCESS
	return
	
delay	decfsz 0x50 ; decrement until zero
	bra delay	
	return

delay2	decfsz 0x51 ; decrement until zero
	bra delay2	
	return

clk_delay decfsz 0x53 ; decrement until zero
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
	movlw	.30		;22 bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTD	; move read data from TABLAT to (FSR0), increment FSR0	
	call	clock_pulse
	movlw	0xAA
	movwf	0x50
;	movlw	0x01
;	movwf	0x51
	call	delay
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
	return
	
	
	end
