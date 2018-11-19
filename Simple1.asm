	#include p18f87k22.inc
	
	extern  setup_keypad, keypad_start, khigh, klow, test, LCD_Setup, a_test, chord_test, o_test, b_test

acs0    udata_acs		    ; reserves space for variables used
counter		res 1		    ; reserves one bite for counter 
delayreg	res 1		    ; reserve one byte for delay register
delayadrs0	res 1		    ; reserves byte for cascading delay register
song_counter0	res 1		    ; reserves byte for song counter
fullsong0	res 1
delayadrs1	res 1		    ; reserves byte for cascading delay register
song_counter1	res 1		    ; reserves byte for song counter
fullsong1	res 1
delayadrs2	res 1		    ; reserves byte for cascading delay register
song_counter2	res 1		    ; reserves byte for song counter
fullsong2	res 1
 
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
	movwf	fullsong0	    ; stores it in the count checker
	movlw	0x0A
	movwf	delayadrs0
	movlw	0xF0
	movwf	fullsong1	    ; stores it in the count checker
	movlw	0x08
	movwf	delayadrs1
	call	song_setup0
	call	fsrload0
	call	song_setup1
	call	fsrload1
	call	song_setup2
	call	fsrload2
	movlw	0xF0		    ; gives 2 full loops of each note for song play 
	movwf	fullsong2	    ; stores it in the count checker
	movlw	0x0B
	movwf	delayadrs2
	call	counter_reset	    ; sets up table and counter for reading data
	goto	start		    ; goes to start of code
	; ******* My data **
myTable  db	0x7f, 0x99, 0xb3, 0xca, 0xdd, 0xed, 0xf8, 0xfd, 0xfd, 0xf8, 0xed, 0xdd, 0xca, 0xb3, 0x99, 0x7f, 0x65, 0x4b, 0x34, 0x21, 0x11, 0x06, 0x01, 0x01, 0x06, 0x11, 0x21, 0x34, 0x4b, 0x65	
songTable0 db	0x64, 0x6a, 0x64, 0x6a, 0x64, 0x86, 0x71, 0x7e, 0x97, 0xfe, 0xc9, 0x97, 0x86, 0x86, 0xC9, 0x9f, 0x86, 0x7e, 0x7e, 0xc9, 0x64, 0x6a, 0x64, 0x6a, 0x64, 0x86, 0x71, 0x7e, 0x97, 0x97
songTable1 db	0x97, 0x71, 0x97, 0x71, 0x97, 0x71, 0x97, 0x9f, 0x97, 0x97, 0x9f, 0x97, 0x9f, 0xb3, 0xa9, 0xb3, 0xbe, 0xbe, 0xe2
songTable2 db	0xe2, 0x71, 0x97, 0xa9, 0x54, 0x97, 0x59, 0x97, 0xe2, 0x71, 0x97, 0xa9, 0x54, 0x97, 0x59, 0x97, 0xc9, 0x71, 0x97, 0xa9, 0x54, 0x97, 0x59, 0x97, 0xc9, 0x71, 0x97, 0xa9, 0x54, 0x97, 0x59, 0x97 
chordTable db	0xfc, 0xba, 0x7b, 0x41, 0x1d, 0x18, 0x2f, 0x58, 0x82, 0xa0, 0xaa, 0xa3, 0x92, 0x82, 0x7e, 0x87, 0x98, 0xa6, 0xa8, 0x96, 0x73, 0x47, 0x24, 0x17, 0x28, 0x56, 0x94, 0xcf, 0xf5
	constant 	song0=0x100
	constant	song1=0x140
	constant	song2=0x180
	
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
	tstfsz	a_test, 0	    ; checks if a is pressed on the keypad
	call	songloop0	    ; calls song sub-routine if A is pressed
	tstfsz	a_test, 0	    ; checks if a is pressed on the keypad, if nothing is pressed no values are read
	bra	jump		    ; calls song sub-routine if A is pressed
	tstfsz	o_test, 0	    ; checks if a is pressed on the keypad
	call	songloop1	    ; calls song sub-routine if 0 is pressed
	tstfsz	o_test, 0	    ; checks if a is pressed on the keypad, if nothing is pressed no values are read
	bra	jump		     ; calls song sub-routine if 0 is pressed
	tstfsz	b_test, 0	    ; checks if a is pressed on the keypad
	call	songloop2	    ; calls song sub-routine if 0 is pressed
	tstfsz	b_test, 0	    ; checks if a is pressed on the keypad, if nothing is pressed no values are read
	bra	jump		     ; calls song sub-routine if 0 is pressed
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
	
; ********* PLAYS BEETHOVEN SONG *************	
	
songloop0
	dcfsnz	fullsong0			     
	call	song_delay0
	return
	
play_song0			    ; subroutine to play song
	movlw	0xF0		    ; gives 2 full loops of each note for song play
	movwf	fullsong0	    ; stores it in the count checker
	movlw	0x0A
	movwf	delayadrs0
	call	read_song0	    ; calls next delay
	return
	

read_song0			    ; read routine to read values from table
	movff	POSTINC0, CCPR4	    ; move read data from FSR0 to CCPR4 , increment FSR0
	movlw	0x00
	movwf	CCPR4H
	dcfsnz	song_counter0	    ; count down to zero
	call	song_counterreset0   ; if counter is zero, the counter is reset
	return	
		
song_setup0 	
	lfsr	FSR0, song0	; Load FSR0 with address in RAM	
	movlw	upper(songTable0); address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(songTable0)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(songTable0)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	.30		; 31 notes to read
	movwf 	song_counter0	; our counter register
	return
	
fsrload0 
	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move read data from TABLAT to (FSR0), increment FSR0	
	decfsz	song_counter0	; count down to zero
	bra	fsrload0	; keep going until finished
	call	song_counterreset0
	return
	
song_counterreset0
	movlw	.30		; 5 notes to read
	movwf 	song_counter0	; our counter register
	lfsr	FSR0, song0
	return
		
; ********* PLAYS CANTINA SONG *************	
	
songloop1
	dcfsnz	fullsong1			     
	call	song_delay1
	return
	
play_song1			    ; subroutine to play song
	movlw	0xF0		    ; gives 2 full loops of each note for song play
	movwf	fullsong1	    ; stores it in the count checker
	movlw	0x08
	movwf	delayadrs1
	call	read_song1	    ; calls next delay
	return
	

read_song1			    ; read routine to read values from table
	movff	POSTINC1, CCPR4	    ; move read data from FSR0 to CCPR4 , increment FSR0
	movlw	0x00
	movwf	CCPR4H
	dcfsnz	song_counter1	    ; count down to zero
	call	song_counterreset1   ; if counte is zero, the counter is reset
	return	
		
song_setup1	
	lfsr	FSR1, song1	; Load FSR0 with address in RAM	
	movlw	upper(songTable1); address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(songTable1)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(songTable1)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	.19		; 5 notes to read
	movwf 	song_counter1	; our counter register
	return
	
fsrload1 
	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC1; move read data from TABLAT to (FSR1), increment FSR1
	decfsz	song_counter1	; count down to zero
	bra	fsrload1		; keep going until finished
	call	song_counterreset1
	return
	
song_counterreset1
	movlw	.19		; 5 notes to read
	movwf 	song_counter1	; our counter register
	lfsr	FSR1, song1
	return
	
; ********* PLAYS SWEET CHILD O'MINE *************	
	
songloop2
	dcfsnz	fullsong2			     
	call	song_delay2
	return
	
play_song2			    ; subroutine to play song
	movlw	0xF0		    ; gives 2 full loops of each note for song play
	movwf	fullsong2	    ; stores it in the count checker
	movlw	0x0B
	movwf	delayadrs2
	call	read_song2	    ; calls next delay
	return
	

read_song2			    ; read routine to read values from table
	movff	POSTINC2, CCPR4	    ; move read data from FSR0 to CCPR4 , increment FSR0
	movlw	0x00
	movwf	CCPR4H
	dcfsnz	song_counter2	    ; count down to zero
	call	song_counterreset2   ; if counte is zero, the counter is reset
	return	
		
song_setup2	
	lfsr	FSR2, song2	; Load FSR0 with address in RAM	
	movlw	upper(songTable2); address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(songTable2)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(songTable2)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	.31		; 5 notes to read
	movwf 	song_counter2	; our counter register
	return
	
fsrload2
	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC2; move read data from TABLAT to (FSR1), increment FSR1
	decfsz	song_counter2	; count down to zero
	bra	fsrload2		; keep going until finished
	call	song_counterreset2
	return
	
song_counterreset2
	movlw	.31		; 5 notes to read
	movwf 	song_counter2	; our counter register
	lfsr	FSR2, song2
	return
	
; ********* DELAYS AND CLOCK PULSES********
	
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

song_delay0
	dcfsnz delayadrs0	    ; decrement until zero
	call play_song0		    ; branch back to delay
	return
	
song_delay1
	dcfsnz delayadrs1	    ; decrement until zero
	call play_song1		    ; branch back to delay
	return

song_delay2
	dcfsnz delayadrs2	    ; decrement until zero
	call play_song2		    ; branch back to delay
	return
	end
