	#include p18f87k22.inc
	
	extern  setup_keypad, keypad_start, khigh, klow, test, LCD_Setup, c_test

acs0    udata_acs		    ; reserves space for variables used
	counter res 1		    ; reserves one bite for counter 
	delayreg res 1		    ; reserve one byte for delay register
	thic1 res 1
	thic2 res 1
	thic3 res 1
	song_counter res 1
 
rst	code	0		    ; reset vector
	goto	setup		    ; goes to code setup
	
main	code
	
setup	call	setup_keypad	    ; sets up keypad
	call	LCD_Setup	    ; sets up LCD
	movlw	0x00		    ; moves value of 0 to w register
	movwf	TRISD, ACCESS	    ; sets port d to output
	movwf	TRISC, ACCESS	    ; sets port c to output
	bcf	EECON1, CFGS	    ; point to Flash program memory  
	bsf	EECON1, EEPGD	    ; access Flash program memory
	call	counter_reset	    ; sets up table and counter for reading data
	goto	start		    ; goes to start of code
	; ******* My data **
myTable  db	0x7f, 0x99, 0xb3, 0xca, 0xdd, 0xed, 0xf8, 0xfd, 0xfd, 0xf8, 0xed, 0xdd, 0xca, 0xb3, 0x99, 0x7f, 0x65, 0x4b, 0x34, 0x21, 0x11, 0x06, 0x01, 0x01, 0x06, 0x11, 0x21, 0x34, 0x4b, 0x65	
songTable db	0x68, 0x41, 0x99, 0xFF, 0xDE, 0x67
chordTable db	0xfc, 0xba, 0x7b, 0x41, 0x1d, 0x18, 0x2f, 0x58, 0x82, 0xa0, 0xaa, 0xa3, 0x92, 0x82, 0x7e, 0x87, 0x98, 0xa6, 0xa8, 0x96, 0x73, 0x47, 0x24, 0x17, 0x28, 0x56, 0x94, 0xcf, 0xf5
 
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
	movwf	delayreg		    ; moves delayvalue to register 0x53
	call	clk_delay	    ; calls delay
	bsf	PORTC, 0	    ; sets clock enable bit
	return

clk_delay			    ; clock delay routine
	decfsz delayreg		    ; decrement register 0x53 until zero
	bra clk_delay		    ; loops until register is zero
	return

	
int_hi	code 0x0008		    ; high vector, no low vector
	btfss	PIR4,CCP4IF	    ; check that this is timer1 interrupt
	retfie	FAST		    ; if not then return
	call	keypad_start	    ; calls keypad start routine
	movff	khigh, CCPR4H	    ; from keypad start routine moves value of khigh to CCP register
	movff	klow, CCPR4L	    ; from keypad start routine moves value of klow to CCP register
	tstfsz	c_test, 0	    ; checks if c is pressed on the keypad, if nothing is pressed no values are read
	call	play_song
	tstfsz	test, 0		    ; checks if nothing is pressed on the keypad, if nothing is pressed no values are read
	call	read		    ; reads values from table
	bcf	PIR4,CCP4IF	    ; clear interrupt flag
	retfie	FAST		    ; fast return from interrupt
	
counter_reset			    ; counter reset routine to reset the counter when it goes to zero 
	movlw	upper(chordTable)	    ; address of data in PM
	movwf	TBLPTRU		    ; load upper bits to TBLPTRU
	movlw	high(chordTable)	    ; address of data in PM
	movwf	TBLPTRH		    ; load high byte to TBLPTRH
	movlw	low(chordTable)	    ; address of data in PM
	movwf	TBLPTRL		    ; load low byte to TBLPTRL
	movlw	.29		    ; 30 bytes to read
	movwf 	counter		    ; our counter register
	return
	
read				    ; read routine to  read values from table
	tblrd*+			    ; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTD	    ; move read data from TABLAT to (FSR0), increment FSR0	
	call	clock_pulse	    ; calls clock pulse to read in values
	dcfsnz	counter		    ; count down to zero
	call	counter_reset	    ; if counte is zero, the counter is reset
	return	
	
play_song
	call song_setup
	call read_song
	movlw 0x10
	movwf thic1
	movwf thic2
	movwf thic3
	call thicc_delay
	call counter_reset
	return
	
	
song_setup
	movlw	upper(songTable)	    ; address of data in PM
	movwf	TBLPTRU		    ; load upper bits to TBLPTRU
	movlw	high(songTable)	    ; address of data in PM
	movwf	TBLPTRH		    ; load high byte to TBLPTRH
	movlw	low(songTable)	    ; address of data in PM
	movwf	TBLPTRL		    ; load low byte to TBLPTRL
	movlw	.6		    ; 30 bytes to read
	movwf 	counter		    ; our counter register
	return

read_song			    ; read routine to read values from table
	tblrd*+			    ; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, CCPR4L	    ; move read data from TABLAT to (FSR0), increment FSR0	
	call	clock_pulse	    ; calls clock pulse to read in values
	dcfsnz	song_counter		    ; count down to zero
	call	song_setup	    ; if counte is zero, the counter is reset
	return	
	
thicc_delay	decfsz thic1 ; decrement until zero
	bra thicc_delay
	call delay2	
	return
	
delay2	decfsz thic2 ; decrement until zero	
	bra delay2
	call delay3
	return
		
delay3	decfsz thic3 ; decrement until zero	
	bra delay3
	return
	
	
	end
