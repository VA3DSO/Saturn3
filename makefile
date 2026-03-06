# Makefile for Saturn3

# Compiler and Flags
CC      = cl65
TARGET  = vic20
CFG     = s3.cfg
CFLAGS  = -t $(TARGET) --config $(CFG) -Cl -O -DEXP8K

# Sources and Output Binaries
SRC    = s3.c
OUT    = s3.prg

# Default target
all: $(OUT)
	c1541 /home/rick/Sync/Computers/Commodore/Disks/VIC-20.dhd < inst.txt

$(OUT): $(SRC)
	$(CC) $(CFLAGS) -o $(OUT) $(SRC)

# Clean Up Build Artifacts
clean:
	rm -f *.o *.prg
	@echo "Clean complete."

.PHONY: all clean	