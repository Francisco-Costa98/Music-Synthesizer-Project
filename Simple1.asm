	#include p18f87k22.inc

code
	org 0x0
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100

setup	movlw	0x00
	movwf	TRISD, ACCESS
	movwf	TRISE, ACCESS
	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
myArray	res 0x80	; Address in RAM for data
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	.30		;22 bytes to read
	movwf 	counter		; our counter register
	goto	start
	; ******* My data and where to put it in RAM *
myTable  db	0x7f, 0x99, 0xb3, 0xca, 0xdd, 0xed, 0xf8, 0xfd, 0xfd, 0xf8, 0xed, 0xdd, 0xca, 0xb3, 0x99, 0x7f, 0x65, 0x4b, 0x34, 0x21, 0x11, 0x06, 0x01, 0x01, 0x06, 0x11, 0x21, 0x34, 0x4b, 0x65
	constant    counter=0x05   ; Address of counter variable
	

	
main	code
start	clrf	TRISD	
	clrf	LATD		    ; Clear PORTD outputs
	movlw b'00110111'	    ; Set timer1 to 16-bit, Fosc/1:8
	movwf	T1CON		    ; = 16MHz clock rate, approx 1sec rollover
	bsf	PIR4, CCP4IE	    ; sets interupt enable bit
	movlw b'00001011'	    ; Set special event mode
	movwf	CCP4CON		    ; initialises ccp4 module with timer1 for compare and timer2 for pwm
	movlw b'00000000'
	banksel CCPTMRS1
	movwf	CCPTMRS1, BANKED	    ; chooses to use timer1
	movlw	0x44
	movwf	CCPR4H
	movlw	0x11
	movwf	CCPR4L
	bsf	PIE4, CCP4IE	    ; sets interrupt enable bit
	bsf	INTCON,GIE	    ; Enable all interrupts
	bsf	INTCON,PEIE
	goto $			    ; Sit in infinite loop
	
clock_pulse
	movlw	0x00
	movwf	PORTE, ACCESS
	movlw	0x0A
	movwf	0x53
	call	clk_delay
	movlw	0x01
	movwf	PORTE, ACCESS
	return

clk_delay decfsz 0x53 ; decrement until zero
	bra clk_delay	
	return
	
	return
	
int_hi	code 0x0008		; high vector, no low vector
	btfss	PIE4,CCP4IF	; check that this is timer0 interrupt
	retfie	FAST		; if not then return
	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTD	; move read data from TABLAT to (FSR0), increment FSR0	
	call	clock_pulse
	dcfsnz	counter		; count down to zero
	call	counter_reset
	bcf	PIE4,CCP4IF	; clear interrupt flag
	bsf	PIE4, CCP4IE
	retfie	FAST		; fast return from interrupt
	
counter_reset
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	.30		;22 bytes to read
	movwf 	counter		; our counter register
	return
	
	end
