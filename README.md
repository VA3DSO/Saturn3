# Saturn 3
Saturn 3 - a pausable PETSCII terminal program for the Commodore VIC-20. Also includes Xmodem upload and download.

## The Challenge
Using a 22-column VIC-20 can be challenging when visiting bulletin board systems run on Commodore 64's and 128's. Their 40 and 80 column formats can 
cause havoc on a VIC-20. Obviously, the PETSCII graphics will not look right, but more importantly the text scrolls off the screen far too quickly.
Most boards have a feature to let you pause the output - but it varies from board to board. Image BBS, C*Base and Color 64 don't always do it the
same way. And if you're VIC is running at 300 baud, the 256 byte buffer usually fills up before you have the chance to hit the key that pauses the
output from the BBS.  

## The Solution
This program uses the 8K block of high RAM on the VIC-20 ($A000 - $BFFF) as an extended buffer to store characters while you pause the screen 
display and read what is there currently.  Saturn 3 is a terminal that allows pausing on the client side. So when 
you are on a BBS, if you press the F1 key, the terminal will stop outputting to the screen, and instead send characters to the 8K input buffer. 
Pressing F1 again will output those buffer characters to the screen, and then operations will resume normally.  

You'll know that the pause feature is activated because when you press F1 the first time, the screen border will turn from black to red. Then when 
you press F1 again (to "drain" the buffer back onto the screen), the border will turn to yellow. Once all the characters from the buffer have been
output, the border returns to black. While emptying the buffer (yellow border) you can hit F1 yet again to enable the pause (red border). This way
you can work your way through a long text file. As long as the 8192 byte buffer doesn't fill up, you will be fine.

This terminal will allow you to surf pretty much any BBS, and read messages and small bulletins without having to constantly try to re-read them to get a
look at all the text.  

## System Requirements
Saturn 3 runs on an expanded VIC-20. Specifically, it requires a 35K expansion that includes the upper $A000-$BFFF block. It also requires a Hayes compatible 
modem (ie: 1670) or a modern WiFi modem (ie: Strikelink). It can run at 300 baud or 1200 baud.

## Instructions
- download the s3.c and s3.cfg files
- using the cc65 compiler, compile the code into a PRG file - for example:
```
  cl65 -t vic20 --config s3.cfg -Cl -O -o s3.prg -DEXP8K s3.c
```
- alternatively, download the supplied PRG or D64 files
- transfer the PRG file onto a media your VIC-20 can read (you are on your own for this step!)
- boot up your expanded VIC-20 (ie: using a VIC-2407 cartridge)
- type: LOAD"S3",8
- type: RUN
- the terminal program should load and indicate "READY."
- to dial a BBS, type something like:
```
  atdt bbs.deepskies.com:6400
```
- interact with the BBS as you'd like
- Function Keys Assignments:
  - F1: pause the screen output
  - F1 (again): resume the screen ouput
  - F2: toggle 5 different colour schemes
  - F3: download a file via Xmodem
  - F4: upload a file via Xmodem
  - F5: toggle baud rate (300/1200)
  - F6: toggle local echo on/off
  - F7: exit the program
  - F8: display help

Please report any bugs to sysop@deepskies.com and we'll see what we can do to fix them.

Enjoy!
