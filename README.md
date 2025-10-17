# Saturn 3
Saturn 3 - a pausable PETSCII terminal program for the Commodore VIC-20

## The Challenge
Using a 22-column VIC-20 can be challenging when visiting bulletin board systems run on Commodore 64's and 128's. Their 40 and 80 column formats can 
cause havoc on a VIC-20. Obviously, the PETSCII graphics will not look right, but more importantly the text scrolls off the screen far too quickly.
Most boards have a feature to let you pause the output - but it varies from board to board. Image BBS, C*Base and Color 64 don't always do it the
same way. And if you're VIC is running at 300 baud, the 256 byte buffer usually fills up before you have the chance to hit the key that pauses the
output from the BBS.  

## The Solution
An unexpanded VIC-20 has 3.5K of RAM. 512 bytes of that is used by the RS232 input and output buffers leaving 3K for programming a terminal. Saturn 3
is a terminal that allows pausing on the client side. The code is only 1K in size, so that leaves 2K (2048 bytes) of extra input buffer. So when 
you are on a BBS, if you press the F1 key, the terminal will stop outputting to the screen, and instead send characters to the 2K input buffer. 
Pressing F1 again will output those buffer characters to the screen, and then operations will resume normally.  

You'll know that the pause feature is activated because when you press F1 the first time, the screen border will turn from black to red. Then when 
you press F1 again (to "drain" the buffer back onto the screen), the border will turn to yellow. Once all the characters from the buffer have been
output, the border returns to black. While emptying the buffer (yellow border) you can hit F1 yet again to enable the pause (red border). This way
you can work your way through a long text file. As long as the 2048 byte buffer doesn't fill up, you will be fine.

If 2048 bytes proves insufficient, I may release a version of this that runs on an expanded VIC and uses the expanded memory to provide an 8K, 16K
or even a 24K buffer. But I doubt that will be needed.

This terminal will allow you to surf pretty much any BBS, and read messages and small bulletins without having to constantly try to re-read them to get a
look at all the text.  

## System Requirements
Saturn 3 runs on an unexpanded VIC-20. It requires a Hayes compatible modem (ie: 1670) or a modern WiFi modem (ie: Strikelink). It can run at 
300 baud or 1200 baud. It will not work with any memory expanders installed. 

## Instructions
- download the Saturn3.d64 image
- figure out how to get the program (SATURN3.PRG) onto your VIC-20 (you are on your own for this step!)
- boot up your unexpanded VIC-20
- type: LOAD"SATURN3",8
- type: RUN
- the terminal program should load and indicate "READY"
- to dial a BBS, type something like: ATDT BBS.DEEPSKIES.COM:6400
- interact with the BBS as you'd like
- press the F1 key at anytime to pause the screen output
- press the F1 key again to resume the screen output
- press the F5 key to switch between 300 and 1200 baud
- press the F7 key to exit the terminal program

## 16K Version  
This program leverages the 16K RAM expander on the VIC-20 to provide a very large (approx 14K) buffer to store incoming characters so that you can pause the output at your leisure and read it on your 22-column VIC-20. I picked 16K because that is the expander I had as a kid with my VIC - but you could easily modify it to work with other memory configurations.

The 16K version has an function key changes:
- press the F1 key at anytime to pause the screen output
- press the F1 key again to resume the screen output
- press the F3 key to switch between PETSCII and ASCII mode
- press the F5 key to toggle between three different color modes:
  - black screen with color text
  - black screen with hard-coded cyan text
  - white screen wtih hard-coded blue text (default VIC colors)
- press the F6 key to switch between 300 and 1200 baud
- press the F7 key to exit the terminal program





