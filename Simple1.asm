	#include p18f87k22.inc
	
	extern  setup_keypad, keypad_start, khigh, klow, test

acs0    udata_acs		    ; reserves space for variables used
	counter res 1		    ; reserves one bite for counter 
 
rst	code	0		    ; reset vector
	goto	setup		    ; goes to code setup
	
main	code
	
setup	call	setup_keypad	    ; sets up keypad
	movlw	0x00		    ; moves value of 0 to w register
	movwf	TRISD, ACCESS	    ; sets port d to output
	movwf	TRISC, ACCESS	    ; sets port c to output
	bcf	EECON1, CFGS	    ; point to Flash program memory  
	bsf	EECON1, EEPGD	    ; access Flash program memory
	call	counter_reset	    ; sets up table and counter for reading data
	goto	start		    ; goes to start of code
	; ******* My data **
myTable  db	0x7f, 0x99, 0xb3, 0xca, 0xdd, 0xed, 0xf8, 0xfd, 0xfd, 0xf8, 0xed, 0xdd, 0xca, 0xb3, 0x99, 0x7f, 0x65, 0x4b, 0x34, 0x21, 0x11, 0x06, 0x01, 0x01, 0x06, 0x11, 0x21, 0x34, 0x4b, 0x65	

start	clrf	LATC		    ; clears port c outputs	
	clrf	LATD		    ; Clear PORTD outputs
	movlw b'00110001'	    ; Set timer1 to 16-bit, Fosc/1:8
	movwf	T1CON		    ; = 16MHz clock rate, approx 1sec rollover
	banksel CCPTMRS1	    ; CCPTMRS1 is in banked ram
	bcf	CCPTMRS1, C4TSEL1   ; chooses to use timer1
	bcf	CCPTMRS1, C4TSEL0   ; chooses to use timer1
	bsf	PIR4, CCP4IE	    ; sets interupt enable bit
	movlw b'00001011'	    ; Set special event mode	   
	movwf	CCP4CON		    
	bsf	PIE4, CCP4IE	    ; sets interrupt enable bit
	bsf	INTCON,PEIE
	bsf	INTCON,GIE	    ; Enable all interrupts
	goto $			    ; Sit in infinite loop
	
clock_pulse			    ; clock pulse routine to make DAC read in values
	bcf	PORTC, 0	    ; clears clock enable bit
	movlw	0x0A		    ; sets up a delay
	movwf	0x53		    ; moves delayvalue to register 0x53
	call	clk_delay	    ; calls delay
	bsf	PORTC, 0	    ; sets clock enable bit
	return

clk_delay			    ; clock delay routine
	decfsz 0x53		    ; decrement register 0x53 until zero
	bra clk_delay		    ; loops until register is zero
	return

	
int_hi	code 0x0008		    ; high vector, no low vector
	btfss	PIR4,CCP4IF	    ; check that this is timer1 interrupt
	retfie	1		    ; if not then return
	call	keypad_start	    ; calls keypad start routine
	movff	khigh, CCPR4H	    ; from keypad start routine moves value of khigh to CCP register
	movff	klow, CCPR4L	    ; from keypad start routine moves value of klow to CCP register
	tstfsz	test, 0		    ; checks if nothing is pressed on the keypad, if nothing is pressed no values are read
	call	read		    ; reads values from table
	bcf	PIR4,CCP4IF	    ; clear interrupt flag
	retfie	FAST		    ; fast return from interrupt
	
counter_reset			    ; counter reset routine to reset the counter when it goes to zero 
	movlw	upper(myTable)	    ; address of data in PM
	movwf	TBLPTRU		    ; load upper bits to TBLPTRU
	movlw	high(myTable)	    ; address of data in PM
	movwf	TBLPTRH		    ; load high byte to TBLPTRH
	movlw	low(myTable)	    ; address of data in PM
	movwf	TBLPTRL		    ; load low byte to TBLPTRL
	movlw	.30		    ; 30 bytes to read
	movwf 	counter		    ; our counter register
	return
	
read				    ; read routine to read values from table
	tblrd*+			    ; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTD	    ; move read data from TABLAT to (FSR0), increment FSR0	
	call	clock_pulse	    ; calls clock pulse to read in values
	dcfsnz	counter		    ; count down to zero
	call	counter_reset	    ; if counte is zero, the counter is reset
	return	
	
	end
