100D LDX $38      ; load TOM pointer into XR
100F DEX       ; move pointer down 1 page (256 bytes)
1010 DEX       ; move pointer down another page
1011 STX $38      ; update pointer
1013 LDA #$05      ; load 05 into AC (logical)
1015 LDX #$02      ; load 02 into XR (physical)
1017 LDY #$00      ; load 00 into YR (command)
1019 JSR $FFBA      ; call SETLFS
101C LDA #$02      ; load length of PARAMS into AC
101E LDX #$FD      ; load lo byte of PARAMS into XR
1020 LDY #$13      ; load hi byte of PARAMS into YR
1022 JSR $FFBD      ; call SETNAM
1025 JSR $FFC0      ; call OPEN
1028 LDA #$C0      ; load 192 into AC
102A STA $A9      ; store AC into 159 (initialize RINONE)
102C JSR $FFCC      ; call CLRCHN - reset to defaults
102F LDA #$93      ; load 147 into AC (CLR HOME)
1031 JSR $FFD2      ; call CHROUT
1034 LDX #$08      ; load 08 into XR (BLACK ON BLACK)
1036 STX $900F      ; store XR into 36879
1039 LDA #$0E      ; load 14 into AC (LOWER CASE)
103B JSR $FFD2      ; call CHROUT
103E LDX #$C4      ; load BANNER lo byte into XR
1040 STX $FC      ; store XR into 252 (zero page)
1042 LDX #$13      ; load BANNER hi byte into XR
1044 STX $FD      ; store XR into 253 (zero page)
1046 LDX #$19      ; load BANNER length into XR
1048 STX $FE      ; store XR into 254 (zero page)
104A JSR $115B      ; call PRINT
104D LDA $13FD      ; load PARAMS into AC
1050 CMP #$08      ; compare to 08 (1200 baud)
1052 BEQ $1066      ; if equal, branch to DISPLAY1200
1054 LDX #$E7      ; load BANNER300 lo byte into XR
1056 STX $FC      ; store XR into 252 (zero page)
1058 LDX #$13      ; load BANNER300 hi byte into XR
105A STX $FD      ; store XR into 253 (zero page)
105C LDX #$0A      ; load BANNER300 length into XR
105E STX $FE      ; store XR into 254 (zero page)
1060 JSR $115B      ; call PRINT
1063 JMP $1075      ; jump to READY
1066 LDX #$F1      ; load BANNER1200 lo byte into XR
1068 STX $FC      ; store XR into 252 (zero page)
106A LDX #$13      ; load BANNER1200 hi byte into XR
106C STX $FD      ; store XR into 253 (zero page)
106E LDX #$0B      ; load BANNER1200 length into XR
1070 STX $FE      ; store XR into 254 (zero page)
1072 JSR $115B      ; call PRINT
1075 LDX #$DD      ; load PROMPT lo byte into XR
1077 STX $FC      ; store XR into 252 (zero page)
1079 LDX #$13      ; load PROMPT hi byte into XR
107B STX $FD      ; store XR into 253 (zero page)
107D LDX #$0A      ; load PROMPT length into XR
107F STX $FE      ; store XR into 254 (zero page)
1081 JSR $115B      ; call PRINT
1084 JSR $FFCC      ; call CLRCHN
1087 JSR $112E      ; call CUSORON
108A LDX #$05      ; load 5 into AC (RS232)
108C JSR $FFC6      ; call CHKIN
108F JSR $FFE4      ; call GETIN
1092 CMP #$07      ; compare AC to 7 (BELL)
1094 BEQ $10D4      ; if BELL, branch to BELL
1096 CMP #$00      ; compare AC to zero (NULL)
1098 BEQ $10A8      ; if NULL, branch to XLOCAL
109A PHA       ; push AC onto stack
109B JSR $FFCC      ; call CLRCHN - reset to defaults
109E JSR $1146      ; call CURSOROFF
10A1 PLA       ; pull AC off of stack
10A2 JSR $FFD2      ; call CHROUT
10A5 JSR $110F      ; call CHECKQUOTE
10A8 JSR $FFCC      ; call CLRCHN - reset to defaults
10AB JSR $112E      ; call CURSORON
10AE JSR $FFE4      ; call GETIN
10B1 CMP #$00      ; compare AC to zero (NULL)
10B3 BEQ $1084      ; branch back to XREMOTE
10B5 CMP #$88      ; compare AC to 136 (F7 key)
10B7 BEQ $10FA      ; if F7 then branch to EXIT
10B9 CMP #$85      ; compare AC to 133 (F1 key)
10BB BEQ $10CE      ; if F1 then branch to LINK-PAUSE
10BD CMP #$87      ; compare AC to 135 (F5 key)
10BF BEQ $10D1      ; if F5 then branch to LINK-BAUD
10C1 PHA       ; push AC onto stack
10C2 LDX #$05      ; load 5 into XR (RS232)
10C4 JSR $FFC9      ; call CHKOUT
10C7 PLA       ; pull AC off of stack
10C8 JSR $FFD2      ; call CHROUT
10CB JMP $1084      ; jump to back to XREMOTE
10CE JMP $1189      ; jump to PAUSE
10D1 JMP $123D      ; jump to TOGGLEBAUD
10D4 LDA #$C3      ; load 195 into AC
10D6 STA $900C      ; store AC into 36876 (note)
10D9 LDA #$0A      ; load 10 into AC
10DB STA $900E      ; store AC into 36878 (volume)
10DE LDY #$00      ; intialize counter to zero
10E0 STY $A2      ; clear out low Jiffy byte
10E2 LDY $A2      ; load low Jiffy byte into YR
10E4 CPY #$14      ; compare to 20
10E6 BCC $10E2      ; if less, branch to BELL-LOOP
10E8 LDY #$00      ; load zero into YR
10EA STY $900E      ; store AC into 36878 (volume)
10ED LDY #$00      ; intialize counter to zero
10EF STY $A2      ; clear out low Jiffy byte
10F1 LDY $A2      ; load low Jiffy byte into YR
10F3 CPY #$28      ; compare counter to 40
10F5 BCC $10F1      ; if less, branch to BELL-LOOP2
10F7 JMP $10A8      ; jump to XLOCAL
10FA LDA #$05      ; load 5 into AC (RS232)
10FC JSR $FFC3      ; call CLOSE
10FF JSR $FFE7      ; call CLOSEALL
1102 LDX $38      ; load TOM pointer into XR
1104 INX       ; move pointer up 1 page (256 bytes)
1105 INX       ; move pointer up another page
1106 STX $38      ; update pointer
1108 JSR $FFCC      ; call CLRCHN - reset to defaults
110B JSR $1146      ; call CURSOROFF
110E RTS       ; return from subroutine
110F CMP #$22      ; compare char with 34 (quote char)
1111 BNE $1117      ; if not, then just exit
1113 LDX #$00      ; otherwise, load zero into XR
1115 STX $D4      ; store XR into 212 - disable quote mode
1117 RTS       ; return from subroutine
1118 LDA $D1      ; load cursor position lo byte from 209 into AC
111A STA $FC      ; store AC into 252 (zero page)
111C LDA $D2      ; load cursor position hi byte from 210 into AC
111E STA $FD      ; store AC into 253 (zero page)
1120 CLC       ; clear carry flag
1121 LDA $FC      ; load lo byte into AC
1123 ADC $D3      ; add cursor column to position from 211 into AC
1125 STA $FC      ; update lo byte from AC
1127 LDA $FD      ; load hi byte into AC
1129 ADC #$00      ; add zero into AC (to force any roll over from above)
112B STA $FD      ; update hi byte from AC
112D RTS       ; return from subroutine
112E LDX $13C3      ; load value of CURSOR into XR
1131 CPX #$01      ; compare with 1 = ON,
1133 BEQ $1145      ; if cursor already on, then exit
1135 JSR $1118      ; call GETCURPOS
1138 LDY #$00      ; load zero into YR
113A LDA ($FC),Y      ; load screen code under cursor into AC
113C ORA #$80      ; OR value with 128 = turn cursor ON
113E STA ($FC),Y      ; update screen code
1140 LDX #$01      ; load one into XR
1142 STX $13C3      ; update cursor tracker to ON
1145 RTS       ; return from subroutine
1146 LDX $13C3      ; load value of CURSOR into XR
1149 CPX #$00      ; compare with 0 = OFF
114B BEQ $115A      ; if cursor already off, then exit
114D LDY #$00      ; load zero into YR
114F LDA ($FC),Y      ; load screen code under cursor into AC
1151 AND #$7F      ; AND value with 127 = turn cursor OFF
1153 STA ($FC),Y      ; update screen code
1155 LDX #$00      ; load zero into XR
1157 STX $13C3      ; update cursor tracker to OFF
115A RTS       ; return from subroutine
115B JSR $FFCC      ; call CLRCHN
115E JSR $1146      ; call CUSOROFF
1161 LDY #$00      ; load zero into YR (counter)
1163 LDA ($FC),Y      ; load next char into AC
1165 JSR $FFD2      ; call CHROUT
1168 INY       ; increment Y by 1
1169 CPY $FE      ; compare Y with LEN in 254
116B BNE $1163      ; if not equal, branch back to PRINTNC
116D RTS       ; otherwise, return from subroutine
116E JSR $FFCC      ; call CLRCHN
1171 JSR $1146      ; call CUSOROFF
1174 LDX #$05      ; load 5 into XR (RS232)
1176 JSR $FFC9      ; call CHKOUT
1179 LDY #$00      ; load zero into YR (counter)
117B LDA ($FC),Y      ; load next char into AC
117D JSR $FFD2      ; call CHROUT
1180 INY       ; increment Y by 1
1181 CPY $FE      ; compare Y with LEN in 254
1183 BNE $117B      ; if not equal, branch back to RPRINTNC
1185 JSR $FFCC      ; call CLRCHN
1188 RTS       ; return from subroutine
1189 LDX #$0A      ; load 10 into XR (BLACK ON RED)
118B STX $900F      ; store XR into 36879
118E LDX #$01      ; load 01 into XR (BUFFER ON)
1190 STX $13FC      ; save 01 into BUFFER STATUS
1193 LDX #$00      ; load 00 into XR
1195 STX $4F      ; store 00 into 79 (BUFFER FILL LO BYTE)
1197 STX $51      ; store 00 into 81 (BUFFER DRAIN LO BYTE)
1199 LDX #$14      ; load 14 into XR
119B STX $50      ; store 14 into 80 (BUFFER FILL HI BYTE)
119D STX $52      ; store 14 into 82 (BUFFER DRAIN LO BYTE)
119F JSR $FFCC      ; call CLRCHN
11A2 LDX #$05      ; load 5 into AC (RS232)
11A4 JSR $FFC6      ; call CHKIN
11A7 JSR $FFE4      ; call GETIN
11AA CMP #$00      ; compare to zero (NULL)
11AC BEQ $11CE      ; if NULL, branch to PLOCAL
11AE LDY #$00      ; load zero into YR
11B0 STA ($4F),Y      ; save char from RS232 into BUFFER
11B2 JSR $FFCC      ; call CLRCHN
11B5 CLC       ; clear carry flag
11B6 LDA $4F      ; load contents of 79 into AC
11B8 ADC #$01      ; add one to contents of 79
11BA STA $4F      ; update 79
11BC LDA $50      ; load contents of 80 into AC
11BE ADC #$00      ; add zero to contents of 80 (force carry)
11C0 STA $50      ; update 80
11C2 CMP #$1C      ; compare BUFFER FILL address with 7168 (top of RAM)
11C4 BEQ $11C9      ; if equal, jump to BUFFERFULL
11C6 JMP $11CE      ; otherwise, jump to PLOCAL
11C9 LDA #$03      ; load 03 into AC
11CB STA $13FC      ; update BUFFER STATUS
11CE JSR $FFCC      ; call CLRCHN
11D1 JSR $FFE4      ; call GETIN
11D4 CMP #$85      ; compare AC to 133 (F1 key)
11D6 BNE $11E0      ; if not F1, branch to PDECIDE
11D8 LDA #$02      ; load 02 into AC (DRAIN)
11DA STA $13FC      ; update BUFFER STATUS
11DD JMP $11F3      ; jump to PAUSEDRAIN
11E0 LDA $13FC      ; load BUFFER STATUS into AC
11E3 CMP #$00      ; compare to 00 (BUFFER OFF)
11E5 BEQ $1230      ; if OFF, branch to PAUSEEXIT
11E7 CMP #$01      ; compare to 01 (FILLING)
11E9 BEQ $119F      ; if FILLING, branch to PREMOTE
11EB CMP #$02      ; compare to 02 (DRAINING)
11ED BEQ $11F3      ; if DRAINING, branch to PAUSEDRAIN
11EF CMP #$03      ; compare to 03 (FULL)
11F1 BEQ $11CE      ; if FULL, branch to PLOCAL
11F3 LDX #$0F      ; load 15 into XR (BLACK ON YELLOW)
11F5 STX $900F      ; store XR into 36879
11F8 LDX $4F      ; load contents of 79 into XR (BUFFER FILL LO BYTE)
11FA CPX $51      ; compare to contents of 81 (BUFFER DRAIN LO BYTE)
11FC BEQ $1201      ; if equal, branch to PDCHECK2
11FE JMP $120A      ; otherwise jump to PAUSEDRAIN2
1201 LDX $50      ; load contents of 80 into XR (BUFFER FILL HI BYTE)
1203 CPX $52      ; compare to contents of 82 (BUFFER DRAIN HI BYTE)
1205 BNE $120A      ; if not equal, branch to PAUSEDRAIN2
1207 JMP $1230      ; otherwise jump to PAUSEEXIT
120A JSR $112E      ; call CUSORON
120D LDY #$00      ; load zero into YR
120F LDA ($51),Y      ; load next char from BUFFER into AC
1211 PHA       ; push AC onto stack
1212 JSR $1146      ; call CURSOROFF
1215 PLA       ; pull AC off of stack
1216 JSR $FFD2      ; call CHROUT
1219 JSR $110F      ; call CHECKQUOTE
121C CLC       ; clear carry flag
121D LDA $51      ; load contents of 81 into AC
121F ADC #$01      ; add one to contents of 81
1221 STA $51      ; update 81
1223 LDA $52      ; load contents of 82 into AC
1225 ADC #$00      ; add zero to contents of 82 (force carry)
1227 STA $52      ; update 82
1229 CMP #$1C      ; compare BUFFER FILL address with 7168 (top of RAM)
122B BEQ $1230      ; if equal, jump to PAUSEEXIT
122D JMP $11F8      ; otherwise, jump back to PDCHECK
1230 LDA #$00      ; load zero into AC
1232 STA $13FC      ; update BUFFER STATUS
1235 LDX #$08      ; load 08 into XR (BLACK ON BLACK)
1237 STX $900F      ; store XR into 36879
123A JMP $1084      ; jump back to XREMOTE
123D LDA $13FD      ; load PARAMS into AC
1240 CMP #$08      ; compare to 8 = 1200 baud
1242 BEQ $124F      ; if 1200 baud, branch to 300BAUD
1244 LDA #$08      ; load 08 into AC
1246 STA $13FD      ; store 08 into PARAMS (08 = 1200 baud)
1249 JSR $10FA      ; call EXIT
124C JMP $100D      ; jump to INIT
124F LDA #$06      ; load 06 into AC
1251 STA $13FD      ; store 06 into PARAMS (06 = 300 baud)
1254 JSR $10FA      ; call EXIT
1257 JMP $100D      ; jump to INIT

VARIABLES:
START	END	CODE	NAME	LEN	VALUE		COMMENT
13C3	13C3	f 13C3 13C3 00	CURSOR	1	\00		cursor 0 = OFF, 1 = ON
13C4	13DC	f 13C4 13DC 12,9f,20,20,20,20,20,20,20,73,41,54,55,52,4E,20,33,20,20,20,20,20,20,20,92	BANNER	25	\12\9f       sATURN 3       \92		program banner
13DD	13E6	f 13DD 13E6 05,0d,0d,72,65,61,64,79,2E,0d	PROMPT	10	\05\0d\0dready.\0d		prompt text
13E7	13F0	f 13E7 13F0 0d,05,33,30,30,20,62,61,75,64	BANNER300	10	\0d\05300 baud		display 300 baud
13F1	13FB	f 13F1 13FB 0d,05,31,32,30,30,20,62,61,75,64	BANNER1200	11	\0d\051200 baud		display 1200 baud
13FC	13FC	f 13FC 13FC 00	BS	1	\00		buffer status
13FD	13FE	f 13FD 13FE 06,00	PARAMS	2	\06\00		comm params, 08 = 1200 baud, 06 = 300 baud

