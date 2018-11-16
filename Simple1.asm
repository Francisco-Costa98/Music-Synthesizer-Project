	#include p18f87k22.inc
	
	extern  setup_keypad, keypad_start, khigh, klow, test, LCD_Setup, a_test, chord_test

acs0    udata_acs		    ; reserves space for variables used
counter res 1		    ; reserves one bite for counter 
delayreg res 1		    ; reserve one byte for delay register
delayadrs1 res 1		    ; reserves byte for cascading delay register
delayadrs2 res 1		    ; reserves byte for cascading delay register
delayadrs3 res 1		    ; reserves byte for cascading delay register
song_counter res 1	    ; reserves byte for song counter
fullsong    res 1
 
rst	code	0		    ; reset vector
	goto	setup		    ; goes to code setup
	
main	code
	
setup	call	setup_keypad	    ; sets up keypad
	call	LCD_Setup	    ; sets up LCD
	movlw	0x00		    ; moves value of 0 to w register
	movwf	TRISD, ACCESS	    ; sets port d to output
	movwf	TRISC, ACCESS	    ; sets port c to output
	movwf	PORTH, ACCESS
	bcf	EECON1, CFGS	    ; point to Flash program memory  
	bsf	EECON1, EEPGD	    ; access Flash program memory
	movlw	0xF0		    ; gives 2 full loops of each note for song play 
	movwf	fullsong	    ; stores it in the count checker
	movlw	0x07
	movwf	delayadrs1
	call	song_setup
	call	fsrload
	call	counter_reset	    ; sets up table and counter for reading data
	goto	start		    ; goes to start of code
	; ******* My data **
myTable  db	0x7f, 0x99, 0xb3, 0xca, 0xdd, 0xed, 0xf8, 0xfd, 0xfd, 0xf8, 0xed, 0xdd, 0xca, 0xb3, 0x99, 0x7f, 0x65, 0x4b, 0x34, 0x21, 0x11, 0x06, 0x01, 0x01, 0x06, 0x11, 0x21, 0x34, 0x4b, 0x65	
songTable db	0x0079, 
 ;0x006A, 0x0064, 0x006A, 0x0064, 0x0086, 0x0071, 0x007E, 0x0097, 0x0097, 0x00FE, 0x00C9, 0x0097, 0x0086, 0x0086, 0x0029, 0x009F, 0x0086, 0x007E, 0x007E, 0x00C9, 0x0064, 0x006A, 0x0064, 0x006A, 0x0064, 0x0086, 0x0071, 0x007E, 0x0097, 0x0097
chordTable db	0xfc, 0xba, 0x7b, 0x41, 0x1d, 0x18, 0x2f, 0x58, 0x82, 0xa0, 0xaa, 0xa3, 0x92, 0x82, 0x7e, 0x87, 0x98, 0xa6, 0xa8, 0x96, 0x73, 0x47, 0x24, 0x17, 0x28, 0x56, 0x94, 0xcf, 0xf5
	constant 	song1=0x400
	
start	clrf	LATD
	clrf	LATC		    ; clears port c outputs	
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
	
int_hi	code 0x0008		    ; high vector, no low vector
	btfss	PIR4,CCP4IF	    ; check that this is timer1 interrupt
	retfie	FAST		    ; if not then return
	call	keypad_start	    ; calls keypad start routine
	tstfsz	a_test, 0	    ; checks if a is pressed on the keypad, if nothing is pressed no values are read
	call	songloop	    ; calls song sub-routine if c is pressed
	tstfsz	a_test, 0	    ; checks if a is pressed on the keypad, if nothing is pressed no values are read
	bra	jump		    ; calls song sub-routine if c is pressed
	movff	khigh, CCPR4H	    ; from keypad start routine moves value of khigh to CCP register
	movff	klow, CCPR4L	    ; from keypad start routine moves value of klow to CCP register
	tstfsz	chord_test, 0	    ; checks if chord key is pressed on the keypad, if nothing is pressed no values are read
	call	read_chord	    ; plays chord if certain buttons are pressed
	tstfsz	test, 0		    ; checks if nothing is pressed on the keypad, if nothing is pressed no values are read
jump	call	read		    ; reads values from table
	movff	CCPR4L, PORTH
	bcf	PIR4,CCP4IF	    ; clear interrupt flag
	retfie	FAST		    ; fast return from interrupt
	
; ******** PLAYS NOTES ******
	
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
	
read				    ; read routine to  read values from table
	tblrd*+			    ; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTD	    ; move read data from TABLAT to (FSR0), increment FSR0	
	call	clock_pulse	    ; calls clock pulse to read in values
	dcfsnz	counter		    ; count down to zero
	call	counter_reset	    ; if counte is zero, the counter is reset
	return

; ******* PLAYS CHORDS **********	
	
chord_setup			    ; counter reset routine to reset the counter when it goes to zero 
	movlw	upper(chordTable)   ; address of data in PM
	movwf	TBLPTRU		    ; load upper bits to TBLPTRU
	movlw	high(chordTable)    ; address of data in PM
	movwf	TBLPTRH		    ; load high byte to TBLPTRH
	movlw	low(chordTable)	    ; address of data in PM
	movwf	TBLPTRL		    ; load low byte to TBLPTRL
	movlw	.29		    ; 30 bytes to read
	movwf 	counter		    ; our counter register
	return
	
read_chord
	tblrd*+			    ; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTD	    ; move read data from TABLAT to PORTD	
	call	clock_pulse	    ; calls clock pulse to read in values
	dcfsnz	counter		    ; count down to zero
	call	chord_setup	    ; if count is zero, the counter is reset
	return	
	
; ********* PLAYS SONGS *************	
	
songloop
	dcfsnz	fullsong			     
	call	song_delay
	return
	
play_song			    ; subroutine to play song
	movlw	0xF0		    ; gives 2 full loops of each note for song play
	movwf	fullsong	    ; stores it in the count checker
	movlw	0x07
	movwf	delayadrs1
	call	read_song	    ; calls next delay
	return
	

read_song			    ; read routine to read values from table
	movff	POSTINC0, CCPR4	    ; move read data from TABLAT to (FSR0), increment FSR0
	dcfsnz	song_counter	    ; count down to zero
	call	song_counterreset   ; if counte is zero, the counter is reset
	return	
		
song_setup 	
	lfsr	FSR0, song1	; Load FSR0 with address in RAM	
	movlw	upper(songTable); address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(songTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(songTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	.1		; 5 notes to read
	movwf 	song_counter	; our counter register
	return
	
fsrload 
	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move read data from TABLAT to (FSR0), increment FSR0	
	decfsz	song_counter	; count down to zero
	bra	fsrload		; keep going until finished
	call	song_counterreset
	return
	
song_counterreset
	movlw	.1		; 5 notes to read
	movwf 	song_counter	; our counter register
	lfsr	FSR0, song1
	return
		

; ********* DELAYS AND CLOCK PULSES********
	
big_delay	
	decfsz delayadrs1	    ; decrement until zero
	bra big_delay		    ; branch back to delay
	call delay2		    ; calls next delay
	return	
	
delay2	decfsz delayadrs2	    ; decrement until zero	
	bra delay2		    ; branch back to delay
	call delay3		    ; calls next delay
	return
		
delay3	decfsz delayadrs3	    ; decrement until zero	
	bra delay3		    ; branch back to delay
	return
	
clock_pulse			    ; clock pulse routine to make DAC read in values
	bcf	PORTC, 0	    ; clears clock enable bit
	movlw	0x0A		    ; sets up a delay
	movwf	delayreg	    ; moves delayvalue to register 0x53
	call	clk_delay	    ; calls delay
	bsf	PORTC, 0	    ; sets clock enable bit
	return

clk_delay			    ; clock delay routine
	decfsz delayreg		    ; decrement register 0x53 until zero
	bra clk_delay		    ; loops until register is zero
	return

song_delay
	dcfsnz delayadrs1	    ; decrement until zero
	call play_song		    ; branch back to delay
	return
	
	end
