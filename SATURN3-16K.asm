LABEL	INST	OPER	INDEX	COMMENT
INIT	LDX	$38		load TOM pointer into XR
	DEX			move pointer down 1 page (256 bytes)
	DEX			move pointer down another page
	STX	$38		update pointer
	LDA	#$05		load 05 into AC (logical)
	LDX	#$02		load 02 into XR (physical)
	LDY	#$00		load 00 into YR (command)
	JSR	$FFBA		call SETLFS
	LDA	@PARAMS(LEN)		load length of PARAMS into AC
	LDX	@PARAMS(LO)		load lo byte of PARAMS into XR
	LDY	@PARAMS(HI)		load hi byte of PARAMS into YR
	JSR	$FFBD		call SETNAM
	JSR	$FFC0		call OPEN
	LDA	#$C0		load 192 into AC
	STA	$A9		store AC into 159 (initialize RINONE)
	JSR	$FFCC		call CLRCHN - reset to defaults
	LDA	#$93		load 147 into AC (CLR HOME)
	JSR	$FFD2		call CHROUT
	LDX	@SCREENMODE		load SCREENMODE into XR
	STX	$900F		store XR into 36879
	LDA	#$0E		load 14 into AC (LOWER CASE)
	JSR	$FFD2		call CHROUT
	LDA	@CHARCOLOR		load default char color into AC
	JSR	$FFD2		call CHROUT
	LDX	@BANNER(LO)		load BANNER lo byte into XR
	STX	$FB		store XR into 252 (zero page)
	LDX	@BANNER(HI)		load BANNER hi byte into XR
	STX	$FC		store XR into 253 (zero page)
	LDX	@BANNER(LEN)		load BANNER length into XR
	STX	$FD		store XR into 254 (zero page)
	JSR	%PRINT		call PRINT
	LDA	@PARAMS		load PARAMS into AC
	CMP	#$08		compare to 08 (1200 baud)
	BEQ	%DISPLAY1200		if equal, branch to DISPLAY1200
DISPLAY300	LDX	@BANNER300(LO)		load BANNER300 lo byte into XR
	STX	$FB		store XR into 252 (zero page)
	LDX	@BANNER300(HI)		load BANNER300 hi byte into XR
	STX	$FC		store XR into 253 (zero page)
	LDX	@BANNER300(LEN)		load BANNER300 length into XR
	STX	$FD		store XR into 254 (zero page)
	JSR	%PRINT		call PRINT
	JMP	%ALMOSTREADY		jump to ALMOSTREADY
DISPLAY1200	LDX	@BANNER1200(LO)		load BANNER1200 lo byte into XR
	STX	$FB		store XR into 252 (zero page)
	LDX	@BANNER1200(HI)		load BANNER1200 hi byte into XR
	STX	$FC		store XR into 253 (zero page)
	LDX	@BANNER1200(LEN)		load BANNER1200 length into XR
	STX	$FD		store XR into 254 (zero page)
	JSR	%PRINT		call PRINT
ALMOSTREADY	LDA	@MODE		load MODE into AC
	CMP	#$01		compare to 01 (ASCII mode)
	BEQ	%DISPLAYASC		if equal, branch to DISPLAYASC
DISPLAYPET	LDX	@BANNERPET(LO)		load BANNERPET lo byte into XR
	STX	$FB		store XR into 252 (zero page)
	LDX	@BANNERPET(HI)		load BANNERPET hi byte into XR
	STX	$FC		store XR into 253 (zero page)
	LDX	@BANNERPET(LEN)		load BANNERPET length into XR
	STX	$FD		store XR into 254 (zero page)
	JSR	%PRINT		call PRINT
	JMP	%READY		jump to READY
DISPLAYASC	LDX	@BANNERASC(LO)		load BANNERASC lo byte into XR
	STX	$FB		store XR into 252 (zero page)
	LDX	@BANNERASC(HI)		load BANNERASC hi byte into XR
	STX	$FC		store XR into 253 (zero page)
	LDX	@BANNERASC(LEN)		load BANNERASC length into XR
	STX	$FD		store XR into 254 (zero page)
	JSR	%PRINT		call PRINT
READY	LDX	@PROMPT(LO)		load PROMPT lo byte into XR
	STX	$FB		store XR into 252 (zero page)
	LDX	@PROMPT(HI)		load PROMPT hi byte into XR
	STX	$FC		store XR into 253 (zero page)
	LDX	@PROMPT(LEN)		load PROMPT length into XR
	STX	$FD		store XR into 254 (zero page)
	JSR	%PRINT		call PRINT
XREMOTE	JSR	$FFCC		call CLRCHN
	JSR	%CURSORON		call CUSORON
	LDX	#$05		load 5 into AC (RS232)
	JSR	$FFC6		call CHKIN
	JSR	$FFE4		call GETIN
	CMP	#$07		compare AC to 7 (BELL)
	BNE	%XRCONT		if not 7, branch to XRCONT
	JMP	%BELL		otherwise, jump to BELL
XRCONT	CMP	#$00		compare AC to zero (NULL)
	BEQ	%XLOCAL		if NULL, branch to XLOCAL
	STA	@AC		push AC onto stack
	JSR	$FFCC		call CLRCHN - reset to defaults
	JSR	%CURSOROFF		call CURSOROFF
	LDA	@AC		pull AC off of stack
	LDX	@MODE		load MODE into XR
	CPX	#$01		compare MODE to 01 (ASCII MODE)
	BEQ	%LINK-CONVERTR		if 01 (ASCII MODE) branch to LINK-CONVERTR
XRRETURN	STA	@AC		push AC onto stack
	LDA	@COLORMODE		load COLORMODE into AC
	CMP	#$00		compare to zero (normal color)
	BEQ	%XOUT		if zero, branch to XOUT
	CMP	#$01		compare to one (cyan color)
	BEQ	%XCYAN		if equal, branch to XCYAN
	LDA	#$1F		otherwise load BLUE into AC
	JSR	$FFD2		call CHROUT
	JMP	%XOUT		jump to XOUT
XCYAN	LDA	#$9F		load CYAN into AC
	JSR	$FFD2		call CHROUT
XOUT	LDA	@AC		pull AC off of stack
	JSR	$FFD2		call CHROUT
	JSR	%CHECKQUOTE		call CHECKQUOTE
XLOCAL	JSR	$FFCC		call CLRCHN - reset to defaults
	JSR	%CURSORON		call CURSORON
	JSR	$FFE4		call GETIN
	CMP	#$00		compare AC to zero (NULL)
	BEQ	%XREMOTE		branch back to XREMOTE
	CMP	#$85		compare AC to 133 (F1 key)
	BEQ	%LINK-PAUSE		if F1 then branch to LINK-PAUSE
	CMP	#$86		compare AC to 134 (F3 key)
	BEQ	%LINK-MODE		if F3 then branch to LINK-MODE
	CMP	#$8A		compare AC to 138 (F4 key)
	BEQ	%LINK-BAUD		if F4 then branch to LINK-BAUD
	CMP	#$87		compare AC to 135 (F5 key)
	BEQ	%LINK-COLOR		if F5 then branch to LINK-COLOR
	CMP	#$88		compare AC to 136 (F7 key)
	BEQ	%EXIT		if F7 then branch to EXIT
	STA	@AC		push AC onto stack
	LDX	#$05		load 5 into XR (RS232)
	JSR	$FFC9		call CHKOUT
	LDA	@AC		pull AC off of stack
	LDX	@MODE		load MODE into XR
	CPX	#$01		compare MODE to 01 (ASCII MODE)
	BEQ	%LINK-CONVERTL		if 01 (ASCII MODE) branch to LINK-CONVERTL
XLRETURN	JSR	$FFD2		call CHROUT
	JMP	%XREMOTE		jump to back to XREMOTE
LINK-PAUSE	JMP	%PAUSE		jump to PAUSE
LINK-BAUD	JMP	%TOGGLEBAUD		jump to TOGGLEBAUD
LINK-MODE	JMP	%TOGGLEMODE		jump to TOGGLEMODE
LINK-COLOR	JMP	%TOGGLECOLOR		jump to TOGGLECOLOR
LINK-CONVERTR	JMP	%CONVERTR		jump to CONVERTR
LINK-CONVERTL	JMP	%CONVERTL		jump to CONVERTL
BELL	LDA	#$C3		load 195 into AC
	STA	$900C		store AC into 36876 (note)
	LDA	#$0A		load 10 into AC
	STA	$900E		store AC into 36878 (volume)
	LDY	#$00		intialize counter to zero
	STY	$A2		clear out low Jiffy byte
BELL-LOOP	LDY	$A2		load low Jiffy byte into YR
	CPY	#$14		compare to 20
	BCC	%BELL-LOOP		if less, branch to BELL-LOOP
	LDY	#$00		load zero into YR
	STY	$900E		store AC into 36878 (volume)
	LDY	#$00		intialize counter to zero
	STY	$A2		clear out low Jiffy byte
BELL-LOOP2	LDY	$A2		load low Jiffy byte into YR
	CPY	#$28		compare counter to 40
	BCC	%BELL-LOOP2		if less, branch to BELL-LOOP2
	JMP	%XLOCAL		jump to XLOCAL
EXIT	LDA	#$05		load 5 into AC (RS232)
	JSR	$FFC3		call CLOSE
	JSR	$FFE7		call CLOSEALL
	LDX	$38		load TOM pointer into XR
	INX			move pointer up 1 page (256 bytes)
	INX			move pointer up another page
	STX	$38		update pointer
	JSR	$FFCC		call CLRCHN - reset to defaults
	JSR	%CURSOROFF		call CURSOROFF
	RTS			return from subroutine
CHECKQUOTE	CMP	#$22		compare char with 34 (quote char)
	BNE	%CQEXIT		if not, then just exit
	LDX	#$00		otherwise, load zero into XR
	STX	$D4		store XR into 212 - disable quote mode
CQEXIT	RTS			return from subroutine
GETCURPOS	LDA	$D1		load cursor position lo byte from 209 into AC
	STA	$FB		store AC into 252 (zero page)
	LDA	$D2		load cursor position hi byte from 210 into AC
	STA	$FC		store AC into 253 (zero page)
	CLC			clear carry flag
	LDA	$FB		load lo byte into AC
	ADC	$D3		add cursor column to position from 211 into AC
	STA	$FB		update lo byte from AC
	LDA	$FC		load hi byte into AC
	ADC	#$00		add zero into AC (to force any roll over from above)
	STA	$FC		update hi byte from AC
	LDA	#$00		load zero into AC
	STA	$FD		store zero into 253
	LDA	#$84		load 33792 (COLOR RAM) into AC
	STA	$FE		store color RAM address into 254
	CLC			clear carry flag
	LDA	$FD		load 253 into AC
	ADC	$FB		add 251 to AC
	STA	$FD		update 253
	LDA	$FE		load 254 into AC
	ADC	$FC		add 252 to AC
	STA	$FE		update 254
	LDY	#$00		load zero into YR
	LDX	@COLORMODE		load COLORMODE into XR
	CPX	#$02		compare with 02 (LIGHT mode)
	BEQ	%GCPLIGHT		if equal, branch to GCPLIGHT
	LDA	#$01		load 1 into AC (WHITE)
	JMP	%GCPEXIT		jump to GCPEXIT
GCPLIGHT	LDA	#$06		load 6 into AC (BLUE)
GCPEXIT	STA	($FD)	Y	
	RTS			return from subroutine
CURSORON	LDX	@CURSOR		load value of CURSOR into XR
	CPX	#$01		compare with 1 = ON,
	BEQ	%CNEXIT		if cursor already on, then exit
	JSR	%GETCURPOS		call GETCURPOS
	LDY	#$00		load zero into YR
	LDA	($FB)	Y	load screen code under cursor into AC
	ORA	#$80		OR value with 128 = turn cursor ON
	STA	($FB)	Y	update screen code
	LDX	#$01		load one into XR
	STX	@CURSOR		update cursor tracker to ON
CNEXIT	RTS			return from subroutine
CURSOROFF	LDX	@CURSOR		load value of CURSOR into XR
	CPX	#$00		compare with 0 = OFF
	BEQ	%CFEXIT		if cursor already off, then exit
	LDY	#$00		load zero into YR
	LDA	($FB)	Y	load screen code under cursor into AC
	AND	#$7F		AND value with 127 = turn cursor OFF
	STA	($FB)	Y	update screen code
	LDX	#$00		load zero into XR
	STX	@CURSOR		update cursor tracker to OFF
CFEXIT	RTS			return from subroutine
PRINT	JSR	$FFCC		call CLRCHN
	JSR	%CURSOROFF		call CUSOROFF
	LDY	#$00		load zero into YR (counter)
PRINTNC	LDA	($FB)	Y	load next char into AC
	JSR	$FFD2		call CHROUT
	INY			increment Y by 1
	CPY	$FD		compare Y with LEN in 254
	BNE	%PRINTNC		if not equal, branch back to PRINTNC
	RTS			otherwise, return from subroutine
REMOTEPRINT	JSR	$FFCC		call CLRCHN
	JSR	%CURSOROFF		call CUSOROFF
	LDX	#$05		load 5 into XR (RS232)
	JSR	$FFC9		call CHKOUT
	LDY	#$00		load zero into YR (counter)
RPRINTNC	LDA	($FB)	Y	load next char into AC
	JSR	$FFD2		call CHROUT
	INY			increment Y by 1
	CPY	$FD		compare Y with LEN in 254
	BNE	%RPRINTNC		if not equal, branch back to RPRINTNC
	JSR	$FFCC		call CLRCHN
	RTS			return from subroutine
PAUSE	LDX	@FILLMODE		load FILLMODE color into XR
	STX	$900F		store XR into 36879
	LDX	#$01		load 01 into XR (BUFFER ON)
	STX	@BS		save 01 into BUFFER STATUS
	LDX	#$00		load 00 into XR
	STX	$4F		store 00 into 79 (BUFFER FILL LO BYTE)
	STX	$51		store 00 into 81 (BUFFER DRAIN LO BYTE)
	LDX	#$17		load 17 into XR
	STX	$50		store 17 into 80 (BUFFER FILL HI BYTE)
	STX	$52		store 17 into 82 (BUFFER DRAIN LO BYTE)
PREMOTE	JSR	$FFCC		call CLRCHN
	LDX	#$05		load 5 into AC (RS232)
	JSR	$FFC6		call CHKIN
	JSR	$FFE4		call GETIN
	CMP	#$00		compare to zero (NULL)
	BEQ	%PLOCAL		if NULL, branch to PLOCAL
	LDY	#$00		load zero into YR
	STA	($4F)	Y	save char from RS232 into BUFFER
	JSR	$FFCC		call CLRCHN
	CLC			clear carry flag
	LDA	$4F		load contents of 79 into AC
	ADC	#$01		add one to contents of 79
	STA	$4F		update 79
	LDA	$50		load contents of 80 into AC
	ADC	#$00		add zero to contents of 80 (force carry)
	STA	$50		update 80
	CMP	#$5E		compare BUFFER FILL address with 24064 (top of RAM)
	BEQ	%BUFFERFULL		if equal, jump to BUFFERFULL
	JMP	%PLOCAL		otherwise, jump to PLOCAL
BUFFERFULL	LDA	#$03		load 03 into AC
	STA	@BS		update BUFFER STATUS
PLOCAL	JSR	$FFCC		call CLRCHN
	JSR	$FFE4		call GETIN
	CMP	#$85		compare AC to 133 (F1 key)
	BNE	%PDECIDE		if not F1, branch to PDECIDE
	LDA	#$02		load 02 into AC (DRAIN)
	STA	@BS		update BUFFER STATUS
	JMP	%PAUSEDRAIN		jump to PAUSEDRAIN
PDECIDE	LDA	@BS		load BUFFER STATUS into AC
	CMP	#$00		compare to 00 (BUFFER OFF)
	BEQ	%PAUSEEXIT		if OFF, branch to PAUSEEXIT
	CMP	#$01		compare to 01 (FILLING)
	BEQ	%PREMOTE		if FILLING, branch to PREMOTE
	CMP	#$02		compare to 02 (DRAINING)
	BEQ	%PAUSEDRAIN		if DRAINING, branch to PAUSEDRAIN
	CMP	#$03		compare to 03 (FULL)
	BEQ	%PLOCAL		if FULL, branch to PLOCAL
PAUSEDRAIN	LDX	@DRAINMODE		load DRAINMODE color into XR
	STX	$900F		store XR into 36879
PDCHECK	LDX	$4F		load contents of 79 into XR (BUFFER FILL LO BYTE)
	CPX	$51		compare to contents of 81 (BUFFER DRAIN LO BYTE)
	BEQ	%PDCHECK2		if equal, branch to PDCHECK2
	JMP	%PAUSEDRAIN2		otherwise jump to PAUSEDRAIN2
PDCHECK2	LDX	$50		load contents of 80 into XR (BUFFER FILL HI BYTE)
	CPX	$52		compare to contents of 82 (BUFFER DRAIN HI BYTE)
	BNE	%PAUSEDRAIN2		if not equal, branch to PAUSEDRAIN2
	JMP	%PAUSEEXIT		otherwise jump to PAUSEEXIT
PAUSEDRAIN2	JSR	%CURSORON		call CUSORON
	LDY	#$00		load zero into YR
	LDA	($51)	Y	load next char from BUFFER into AC
	STA	@AC		push AC onto stack
	JSR	%CURSOROFF		call CURSOROFF
	LDA	@COLORMODE		load COLORMODE into AC
	CMP	#$00		compare to zero (NORMAL mode)
	BEQ	%PDOUT		if zero, branch to PDOUT
	CMP	#$01		compare to one (DARK mode)
	BEQ	%PDDARK		if equal, branch to PDDARK
	LDA	#$1F		otherwise load BLUE into AC
	JSR	$FFD2		call CHROUT
	JMP	%PDOUT		jump to PDOUT
PDDARK	LDA	#$9F		load CYAN into AC
	JSR	$FFD2		call CHROUT
PDOUT	LDA	@AC		pull AC off of stack
	JSR	$FFD2		call CHROUT
	JSR	%CHECKQUOTE		call CHECKQUOTE
	JSR	%WAIT		call WAIT (to slow down output)
	CLC			clear carry flag
	LDA	$51		load contents of 81 into AC
	ADC	#$01		add one to contents of 81
	STA	$51		update 81
	LDA	$52		load contents of 82 into AC
	ADC	#$00		add zero to contents of 82 (force carry)
	STA	$52		update 82
	CMP	#$5E		compare BUFFER FILL address with 24064 (top of RAM)
	BEQ	%PAUSEEXIT		if equal, jump to PAUSEEXIT
	JSR	$FFE4		call GETIN
	CMP	#$85		compare AC to 133 (F1 key)
	BNE	%PAUSECONT		if not F1, branch to PAUSECONT
	LDX	@FILLMODE		load FILLMODE color into XR
	STX	$900F		store XR into 36879
	LDX	#$01		load one into XR
	STX	@BS		update BUFFER STATUS
	JMP	%PREMOTE		jump to PREMOTE
PAUSECONT	JMP	%PDCHECK		otherwise, jump back to PDCHECK
PAUSEEXIT	LDA	#$00		load zero into AC
	STA	@BS		update BUFFER STATUS
	LDX	@SCREENMODE		load SCREENMODE into XR
	STX	$900F		store XR into 36879
	LDA	@CHARCOLOR		load CHARCOLOR into AC
	JSR	$FFD2		call CHROUT
	JMP	%XREMOTE		jump back to XREMOTE
WAIT	LDY	#$00		load zero into YR
	LDX	#$00		load zero into XR
WAITLOOP	CPY	#$FF		compare YR with 255
	BEQ	%WAITNEXT		if 255, branch to WAITNEXT
	INY			otherwise increment YR by one
	JMP	%WAITLOOP		jump back to WAITLOOP
WAITNEXT	INX			increment XR by one
	CPX	#$02		compare XR to 2 (3 loops, 0,1,2)
	BEQ	%WAITEXIT		if equal, branch to WAITEXIT
	LDY	#$00		load zero into YR
	JMP	%WAITLOOP		jump back to WAITLOOP
WAITEXIT	RTS			return from subroutine
TOGGLEBAUD	LDA	@PARAMS		load PARAMS into AC
	CMP	#$08		compare to 8 = 1200 baud
	BEQ	%300BAUD		if 1200 baud, branch to 300BAUD
1200BAUD	LDA	#$08		load 08 into AC
	STA	@PARAMS		store 08 into PARAMS (08 = 1200 baud)
	JSR	%EXIT		call EXIT
	JMP	%INIT		jump to INIT
300BAUD	LDA	#$06		load 06 into AC
	STA	@PARAMS		store 06 into PARAMS (06 = 300 baud)
	JSR	%EXIT		call EXIT
	JMP	%INIT		jump to INIT
TOGGLEMODE	LDA	@MODE		load MODE into AC
	CMP	#$00		compare to 0 = PETSCII
	BEQ	%ASCIIMODE		if PETSCII, branch to ASCIIMODE
PETSCIIMODE	LDA	#00		load 01 into AC
	STA	@MODE		store 00 into MODE (00 = PETCII mode)
	JSR	%EXIT		call EXIT
	JMP	%INIT		jump to INIT
ASCIIMODE	LDA	#01		load 01 into AC
	STA	@MODE		store 01 into MODE (01 = ASCII mode)
	JSR	%EXIT		call EXIT
	JMP	%INIT		jump to INIT
TOGGLECOLOR	LDA	@COLORMODE		load COLORMODE into AC
	CMP	#$00		compare to MODE 0 (NORMAL COLOR MODE)
	BEQ	%DARKMODE		if equal, branch to DARKMODE
	CMP	#$01		compare to MODE 1 (CYN on BLK - DARK MODE)
	BEQ	%LIGHTMODE		if equal, branch to LIGHTMODE
NORMALMODE	LDA	#$08		load 08 into AC
	STA	@SCREENMODE		update SCREENMODE with 08 (BLK/BLK)
	LDA	#$0A		load 10 into AC
	STA	@FILLMODE		update FILLMODE with 10 (BLK/RED)
	LDA	#$0F		load 15 into AC
	STA	@DRAINMODE		update DRAINMODE with 15 (BLK/YEL)
	LDA	#$05		load 5 into AC 
	STA	@CHARCOLOR		update CHARCOLOR with 5 (WHT)
	LDA	#$00		load zero into AC
	STA	@COLORMODE		update COLORMODE with zero (NORMAL)
	JMP	%COLORDONE		jump to COLORDONE
DARKMODE	LDA	#$08		load 08 into AC
	STA	@SCREENMODE		update SCREENMODE with 08 (BLK/BLK)
	LDA	#$0A		load 10 into AC
	STA	@FILLMODE		update FILLMODE with 10 (BLK/RED)
	LDA	#$0F		load 15 into AC
	STA	@DRAINMODE		update DRAINMODE with 15 (BLK/YEL)
	LDA	#$9F		load 159 into AC (CYAN)
	STA	@CHARCOLOR		update CHARCOLOR with 159 (CYAN)
	LDA	#$01		load one into AC
	STA	@COLORMODE		update COLORMODE with one (CYN/BLK)
	JMP	%COLORDONE		jump to COLORDONE
LIGHTMODE	LDA	#$1B		load 27 into AC
	STA	@SCREENMODE		update SCREENMODE with 27 (WHT/CYN)
	LDA	#$1A		load 26 into AC
	STA	@FILLMODE		update FILLMODE with 26 (WHT/RED)
	LDA	#$1F		load 31 into AC
	STA	@DRAINMODE		update DRAINMODE with 31 (WHT/YEL)
	STA	@CHARCOLOR		update CHARCOLOR with 31 (BLU)
	LDA	#$02		load two into AC
	STA	@COLORMODE		update COLORMODE with two (BLU/WHT)
COLORDONE	JSR	%EXIT		call EXIT
	JMP	%INIT		jump to INIT
CONVERTR	CMP	#$08		compare AC to 08 (back space)
	BNE	%CRCONT		if not equal, branch to CRCONT
	LDA	#$14		load 20 into AC (CBM back space)
	JMP	%CREXIT		jump to CREXIT
CRCONT	CMP	#$41		compare AC with 65 (A)
	BCC	%CREXIT		if less than A, branch to CREXIT
	CMP	#$5B		compare AC with 91 (Z plus 1 char)
	BCC	%CRADD32		if less than, branch to CRADD32
	CMP	#$61		compare AC with 97 (a)
	BCC	%CREXIT		if less than a, branch to CREXIT
	CMP	#$7B		compare AC with 123 (z plus 1 char)
	BCC	%CRSUB32		if less than, branch to CRSUB32
	CMP	#$60		compare AC with 96
	BCC	%CREXIT		if less than, branch to CREXIT
	CMP	#$80		compare AC to 128
	BCC	%CRADD96		if less than, branch to CRADD96
	JMP	%CREXIT		otherwise jump to CREXIT
CRADD96	JSR	%ADD96		call ADD96
	CMP	#$81		compare AC to 129
	BCC	%CREXIT		if less than 129, branch to CREXIT
	CMP	#$9B		compare AC to 155
	BCC	%CRADD32		if less than, branch to CRADD32
	JMP	%CREXIT		jump to CREXIT
CRSUB32	JSR	%SUB32		call SUB32
	JMP	%CREXIT		jump to CREXIT
CRADD32	JSR	%ADD32		call ADD32
CREXIT	JMP	%XRRETURN		jump back to XRRETURN
ADD32	CLC			clear carry flag
	ADC	#$20		add 32 to AC
	RTS			return from subroutine
SUB32	SEC			set carry flag
	SBC	#$20		subtract 32 from AC
	RTS			return from subroutine
ADD96	CLC			clear carry flag
	ADC	#$60		add 96 to AC
	RTS			return from subroutine
SUB96	SEC			set carry flag
	SBC	#$60		subtract 96 from AC
	RTS			return from subroutine
CONVERTL	CMP	#$14		compare AC to 20 (back space)
	BNE	%CLCONT		if not equal, branch to CLCONT
	LDA	#$08		load 08 into AC (ASC back space)
	JMP	%CLEXIT		jump to CLEXIT
CLCONT	CMP	#$0D		compare AC to 13 (RETURN)
	BNE	%CLCONT2		if not equal, branch to CLCONT2
	JSR	$FFD2		send CHAR[13] out RS232
	LDA	#$0A		load 10 into AC (LINEFEED)
	JMP	%CLEXIT		jump to CLEXIT
CLCONT2	CMP	#$41		compare AC with 65 (A)
	BCC	%CLEXIT		if less than a, branch to CLEXIT
	CMP	#$5B		compare AC with 91 (Z plus 1 char)
	BCC	%CLADD32		if less than, branch to CLADD32
	CMP	#$61		compare AC with 97 (a)
	BCC	%CLEXIT		if less than A, branch to CLEXIT
	CMP	#$7B		compare AC with 123 (z plus 1 char)
	BCC	%CLSUB32		if less than, branch to CLSUB32
	CMP	#$C0		compare AC with 192
	BCC	%CLEXIT		if less than, branch to CLEXIT
	CMP	#$E0		compare AC to 224
	BCC	%CLSUB96		if less than, branch to CLSUB96
	JMP	%CLEXIT		otherwise jump to CLEXIT
CLSUB96	JSR	%SUB96		call SUB96
	CMP	#$61		compare AC to 97
	BCC	%CLEXIT		if less than 129, branch to CLEXIT
	CMP	#$7B		compare AC to 123
	BCC	%CLSUB32		if less than, branch to CLSUB32
	JMP	%CLEXIT		jump to CLEXIT
CLSUB32	JSR	%SUB32		call SUB32
	JMP	%CLEXIT		jump to CLEXIT
CLADD32	JSR	%ADD32		call ADD32
CLEXIT	JMP	%XLRETURN		jump back to XLRETURN
DEBUG	JSR	%EXIT		call EXIT
	LDA	#$44		load 68 into AC (D)
	JSR	$FFD2		call CHROUT
	RTS			return from subroutine

