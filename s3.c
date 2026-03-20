/*****************************************************************************/
/*                                                                           */
/*                                   s3.c                                    */
/*                                                                           */
/*                A terminal program for the expanded VIC-20                 */
/*                                                                           */
/*                                                                           */
/*                                                                           */
/* (C) 1982-2025, Rick Towns                                                 */
/*                Sudbury, Ontario                                           */
/*                CANADA                                                     */
/* EMail:         sysop@deepskies.com                                        */
/*                                                                           */
/* Acknowledgments:                                                          */
/*   Special thanks to Francesco Sblendorio (github.com/sblendorio) for his  */
/*   excellent victerm300 which inspired the writing of this program. Some   */
/*   of the functions here are based on some functions in victerm300.        */
/*                                                                           */
/*   Specifically: ascii translation, print, cursor_on, cursor_off and beep  */
/*                                                                           */
/* This software is provided 'as-is', without any expressed or implied       */
/* warranty.  In no event will the authors be held liable for any damages    */
/* arising from the use of this software.                                    */
/*                                                                           */
/* Permission is granted to anyone to use this software for any purpose,     */
/* including commercial applications, and to alter it and redistribute it    */
/* freely, subject to the following restrictions:                            */
/*                                                                           */
/* 1. The origin of this software must not be misrepresented; you must not   */
/*    claim that you wrote the original software. If you use this software   */
/*    in a product, an acknowledgment in the product documentation would be  */
/*    appreciated but is not required.                                       */
/* 2. Altered source versions must be plainly marked as such, and must not   */
/*    be misrepresented as being the original software.                      */
/* 3. This notice may not be removed or altered from any source              */
/*    distribution.                                                          */
/*                                                                           */
/*****************************************************************************/
#include <cbm.h>
#include <peekpoke.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

#pragma charmap(147, 147)
#pragma charmap(17, 17)

#define TRUE    1
#define FALSE   0
#define SUCCESS 0
#define ERROR   1
#define OFF     0
#define ON      1
#define RS      3
#define F1      133
#define F3      134
#define F5      135
#define F7      136
#define F2      137
#define F4      138
#define F6      139
#define F8      140
#define BUFFER  0xA000
#define BUFSIZE 0x2000
#define SC      0x900F

#define OK      0
#define TIMEOUT 1
#define CANCEL  2

#define SOH     1
#define EOT     4
#define ACK     6
#define NAK     21
#define CAN     24
#define PAD     0

#define JCH     160
#define JCM     161
#define JCL     162

#define MAXRETRIES 25

typedef struct {
    char bbsname[17];   // 16 chars + '\0'
    char url[33];       // 32 chars + '\0'
    char port[6];       // 5 chars + '\0'
    char id[11];        // 10 chars + '\0'
    char password[10];  // 9 chars + '\0'
} PBEntry;              // 77 total chars

#pragma bss-name("PHONEBK")
PBEntry Phonebook[20];
#pragma bss-name("BSS");

char f[] = {
    0,   0,   0, 137,   0,   0,   0,   0,  20,   0,   0,   0, 147,  13,   0,   0,
    146, 134,   0, 138,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,
    48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,
    64, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207,
    208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218,  91,  92,  93,  94,  95,
    0,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
    80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,   0,   0,   0,   0,   0,
    0,   0,   0, 137,   0,   0,   0,   0,  20,   0,   0,   0, 147,  13,   0,   0,
    146, 134,   0, 138,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,
    48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,
    64, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207,
    208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218,  91,  92,  93,  94,  95,
    0,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
    80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,   0,   0,   0,   0,   0
};
char t[] = {
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  13,   0,   0,
    0,   0,   0,   0,   8,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,
    48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,
    64,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
    112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,  91,  92,  93,  94,  95,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,  16,  17,   0,   0,   3,  19,   0,   0,   0,   0,   0,
    0,   0,  16,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
    80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
};

/* local functions */
void print(char*);
void dial(char*);
void putch(char);
void cursor_on(void);
void cursor_off(void);
void beep(void);
void show_banner(char);
void pause(void);
void sleep(void);
void nap(void);
void help(void);
void set_colour(char set_char);
void download(void);
void upload(void);
void input(char);
char getch(void);
char errorcheck(void);
void enjoythesilence(void);
void clear(char*);
void pad(char*);
void clearbuffer(void);
char inbyte(char, char*);
void outbyte(char ch);
char get_load_drive(void);
void load_phonebook(void);
void save_phonebook(char);
void show_phonebook(void);
void edit_entry(char);

/* global variables */
char CS = OFF, CM = 1, ECHO = OFF, PS = ON;
char I[40];

char main(void) {

    char exiting = FALSE;
    char ch;
    char *p = "x";

    p[0] = 8;

    set_colour(TRUE);
    show_banner(p[0]);

    cbm_open(5,2,3,p);
    POKE(169,192);

    load_phonebook();

    do {

        /* XLOCAL */

        ch = cbm_k_getin();
        if ((ch >= F1) && (ch <= F8)) {
            switch (ch) {
                case F1:
                    /* pause */
                    pause();
                    break;
                case F2:
                    /* colour */
                    CM++;
                    if (CM > 5) {
                        CM = 1;
                    }
                    set_colour(TRUE);
                    show_banner(p[0]);
                    break;
                case F3:
                    /* download */
                    download();
                    break;
                case F4:
                    /* upload */
                    upload();
                    break;
                case F5:
                    /* baud */
                    cbm_close(5);
                    if (p[0] == 8) {
                        p[0] = 6;
                    } else {
                        p[0] = 8;
                    }
                    cbm_open(5,2,3,p);
                    POKE(169,192);
                    show_banner(p[0]);
                    break;
                case F6:
                    /* petscii */
                    if (PS == OFF) {
                        print("\n\nPETSCII!\n\n");
                        PS = ON;
                    } else {
                        print("\n\nASCII!\n\n");
                        PS = OFF;
                    }
                    break;
                case F7:
                    /* exit */
                    cursor_off();
                    exiting = TRUE;
                    break;
                case F8:
                    /* help */
                    help();
                    break;
            }
        } else if (ch == 3) {
            /* phonebook */
            show_phonebook();
        } else if (ch != 0) {
            cbm_k_ckout(5);
            if (PS == OFF) {
                cbm_k_bsout(t[ch]);
            } else {
                cbm_k_bsout(ch);
            }
            cbm_k_clrch();
        }

        /* XREMOTE */
        cbm_k_chkin(5);
        ch = cbm_k_getin();
        cbm_k_clrch();
        if (ch != 0) {
            if (PS == OFF) {
                putch(f[ch]);
            } else {
                /* FILTER C64 COLORS */
                if ((ch == 129) || (ch == 149) || (ch == 150)) {
                    ch = 28;
                } else if ((ch == 151) || (ch == 152) || (ch == 155)) {
                    ch = 5;
                } else if (ch == 153) {
                    ch = 30;
                } else if (ch == 154) {
                    ch = 31;
                }

                putch(ch);
            }
        }

    } while(exiting == FALSE);

    cbm_close(5);

    return(SUCCESS);

}

void print(char *str) {

    cursor_off();

    while (*str) {
        __A__ = *str++;
        asm("jsr $ffd2");
    }

    cursor_on();

}

void dial(char *str) {

    while (*str) {
        __A__ = *str++;
        asm("jsr $ffd2");
        sleep();
    }

}

void putch(char ch) {

    cursor_off();
    cbm_k_bsout(ch);

    if (ch == 34) {
        POKE(212,0);
    }
    if (ch == 7) {
        beep();
    }
    if (CM > 2) {
        switch (CM) {
            case 3:
                cbm_k_bsout(5);
                break;
            case 4:
                cbm_k_bsout(31);
                break;
            case 5:
                cbm_k_bsout(30);
                break;
        }
    }

    cursor_on();

}

void cursor_on(void) {

    if (CS == OFF) {
        POKE(212, 0);
        POKE(216, 0);

        if (PEEK(204) != 0) {
            asm("ldy #$00");
            asm("sty $cc");
            CS = ON;
        }

    }

}

void cursor_off(void) {
    if (CS == ON) {
        asm("ldy $cc");
        asm("bne %g", exitloop);
        asm("ldy #$01");
        asm("sty $cd");
        loop:
        asm("ldy $cf");
        asm("bne %g", loop);
        exitloop:
        asm("ldy #$ff");
        asm("sty $cc");
        CS = OFF;
    }
}

void beep(void) {

    static unsigned long j;

    /* VIC 20 BEEP */
    POKE(0x900E, 15);
    POKE(0x900D, 0);
    POKE(0x900C, 230);
    for (j=0; j<1000; ++j) asm("nop");
    POKE(0x900E, 0);

}

void show_banner(char baud) {
    print("\223\016\300\300\300\300\300\300 \022SATURN\2223 \300\300\300\300\300\300\n\n");
    if (baud == 8) {
        print("1200 BAUD  ");
    } else {
        print("300 BAUD  ");
    }
    print("   \022F8\222 HELP\n\n");
    print("READY.\n");
    cursor_on();
}

char get_load_drive(void) {

    char drive = PEEK(186);

    if ((drive < 8) || (drive > 11)) {
        drive = 8;   /* fall back to 8 if something weird */
    }

    return drive;

}

void show_phonebook(void) {

    char i, ch;
    char dialing = TRUE;

    do {

        print("\223\022PHONE\222BOOK\n\n");

        for (i = 0; i < 20; i++) {
            sprintf(I, "%c %-5.5s %-3.3s %-9.9s\n", i + 193, Phonebook[i].bbsname, Phonebook[i].id, Phonebook[i].password); print(I);
        }

        print(" # to Dial or Z=Edit");

        ch = getch();

        if((ch == 13) || (ch == 3)) {
            print("\223");
            dialing = FALSE;
        } else if (ch == 'z') {
            for (i = 0; i < 19; i++) {
                putch(20);
            }
            print("Which # to Edit?");
            ch = getch();
            if ((ch >= 65) && (ch <= 84)) {
                ch = ch - 65;
                edit_entry(ch);
            }
        } else if ((ch >= 65) && (ch <= 84)) {

            ch = ch - 65;
            print("\223");

            cbm_k_ckout(5);
            dial("\nat\natdt ");
            dial(Phonebook[ch].url);
            dial(":");
            dial(Phonebook[ch].port);
            dial("\n");
            cbm_k_clrch();

            dialing = FALSE;
        }

    } while (dialing == TRUE);

}

void edit_entry(char record) {

    char ch, drive;
    PBEntry e;

    print("\223\022EDIT\222ENTRY\n\n");

    print("BBS:"); print(Phonebook[record].bbsname); print("\n");
    print("URL:"); print(Phonebook[record].url); print("\n");
    print("PRT:"); print(Phonebook[record].port); print("\n");
    print("UID:"); print(Phonebook[record].id); print("\n");
    print("PWD:"); print(Phonebook[record].password); print("\n\n");

    print("BBS?"); input(16);
    if (strlen(I) > 0) {
        strcpy(e.bbsname, I);
    } else {
        strcpy(e.bbsname, Phonebook[record].bbsname);
    }
    print("URL?"); input(32);
    if (strlen(I) > 0) {
        strcpy(e.url, I);
    } else {
        strcpy(e.url, Phonebook[record].url);
    }
    print("PRT?"); input(5);
    if (strlen(I) > 0) {
        strcpy(e.port, I);
    } else {
        strcpy(e.port, Phonebook[record].port);
    }
    print("UID?"); input(10);
    if (strlen(I) > 0) {
        strcpy(e.id, I);
    } else {
        strcpy(e.id, Phonebook[record].id);
    }
    print("PWD?"); input(9);
    if (strlen(I) > 0) {
        strcpy(e.password, I);
    } else {
        strcpy(e.password, Phonebook[record].password);
    }

    print("\nBBS:"); print(e.bbsname); print("\n");
    print("URL:"); print(e.url); print("\n");
    print("PRT:"); print(e.port); print("\n");
    print("UID:"); print(e.id); print("\n");
    print("PWD:"); print(e.password); print("\n");

    print("\nARE YOU SURE? (Y/N)");
    ch = getch();
    putch(toupper(ch));

    if ((ch == 'y') || (ch == 'Y')) {

        print("\n\nSaving...");

        strcpy(Phonebook[record].bbsname, e.bbsname);
        strcpy(Phonebook[record].url, e.url);
        strcpy(Phonebook[record].port, e.port);
        strcpy(Phonebook[record].id, e.id);
        strcpy(Phonebook[record].password, e.password);

        drive = get_load_drive();
        save_phonebook(drive);

    }

}

void load_phonebook(void) {

    char drive, err, i;
    char errbuf[3] = { 0 };
    char *filename = "s3pb";

    /* check if phone book file exists */
    drive = get_load_drive();
    cbm_open(15, drive, 15, "r:s3pb=s3pb");
    cbm_read(15, errbuf, 2);        // get first 2 chars from error channel
    err = (char)atoi(errbuf);       // convert errbuf to short int (char)
    cbm_close(15);

    if (err == 62) {

        /* file not found - create a new phone book */
        for (i = 0; i < 20; i++) {
            strcpy(Phonebook[i].bbsname, "     ");
            strcpy(Phonebook[i].url, "     ");
            strcpy(Phonebook[i].port, "    ");
            strcpy(Phonebook[i].id, "   ");
            strcpy(Phonebook[i].password, "         ");
        }

        save_phonebook(drive);

        /* at end, sett err to 63 so it loads next! */
        err = 63;

    }

    if (err == 63) {
        /* file already exists - let's load it! */
        cbm_k_setlfs(3, drive, 1);
        cbm_k_setnam("s3pb,u,r");
        cbm_k_load(0, 1);
    }

    if ((err != 62) && (err != 63)) {
        /* some other error has happend - just display error */
        print("\022ERROR\222:"); print(errbuf); print("\n");
    }

}

void save_phonebook(char drive) {

    cbm_open(15, drive, 15, "s:s3pb");
    cbm_close(15);

    cbm_k_setlfs(3, drive, 1);
    cbm_k_setnam("s3pb,u,w");
    cbm_k_save(0x0400, 0x0C00);

}
 
void pause(void) {

    char ch, pausing = TRUE, pcol, dcol;
    unsigned long BP = BUFFER, D = BUFFER;

    if (CM == 2) {
        pcol = 234;
        dcol = 239;
    } else if (CM == 4) {
        pcol = 26;
        dcol = 31;
    } else {
        pcol = 10;
        dcol = 15;
    }

    POKE(SC, pcol);

    cursor_on();

    do {

        /* XREMOTE */
        cbm_k_chkin(5);
        ch = cbm_k_getin();
        cbm_k_clrch();
        if (ch != 0) {
            POKE(BP, ch);
            BP++;
            if (BP > BUFFER + BUFSIZE -1) {
                BP--;
            }
        }

        /* XLOCAL */
        ch = cbm_k_getin();
        if (ch == F1) {
            if (pausing == TRUE) {
                pausing = FALSE;
                POKE(SC, dcol);
                cursor_off();
            } else {
                pausing = TRUE;
                POKE(SC, pcol);
                cursor_on();
            }
        }

        if ((pausing == FALSE) && (D < BP)) {

            do {

                ch = PEEK(D);

                if (ch > 0) {
                    putch(ch);
                }

                D++;
                if (D >= BP) {
                    break;
                }

                /* XLOCAL */
                ch = cbm_k_getin();
                if (ch == F1) {
                    if (pausing == TRUE) {
                        pausing = FALSE;
                        POKE(SC, dcol);
                        cursor_off();
                    } else {
                        pausing = TRUE;
                        POKE(SC, pcol);
                        cursor_on();
                    }
                }

                /* brief pause to slow down output ~1200 bps */
                nap();      

            } while (pausing == FALSE);

        }

    } while (pausing == TRUE);

    set_colour(FALSE);
    cursor_on();

}

void help(void) {
    print("\n\022F1\222 PAUSE   \022F2\222 COLOUR\n");
    print("\022F3\222 DOWNLD  \022F4\222 UPLOAD\n");
    print("\022F5\222 BAUD    \022F6\222 PETASC\n");
    print("\022F7\222 EXIT    \022F8\222 HELP\n\n");
    print(" \022RUN\222/\022STOP\222 PHONEBOOK\n\n");
    print("READY.\n");
    cursor_on();

}

void sleep(void) {
    int j;
    for (j=0; j<666; ++j) __asm__ ("nop");
}

void nap(void) {
    int j;
    /* quasi evil */
    for (j=0; j<333; ++j) __asm__ ("nop");
}

void set_colour(char set_char) {

    switch (CM) {
        case 1:
            POKE(SC, 8);
            if (set_char == TRUE) {
                cbm_k_bsout(5);
            }
            break;
        case 2:
            POKE(SC, 238);
            if (set_char == TRUE) {
                cbm_k_bsout(144);
            }
            break;
        case 3:
            POKE(SC, 8);
            if (set_char == TRUE) {
                cbm_k_bsout(5);
            }
            break;
        case 4:
            POKE(SC, 27);
            if (set_char == TRUE) {
                cbm_k_bsout(31);
            }
            break;
        case 5:
            POKE(SC, 8);
            if (set_char == TRUE) {
                cbm_k_bsout(30);
            }
            break;
    }

}

void download(void) {

    /* DOWNLOAD! */

    char ftype, packet[131], filename[20], ch, i, m, e, blk, chk, checksum, badbytes;
    char receiving = TRUE, p = 1, retries = 0, status = OK;

    print("\n\nXmodem Download!\n\n");

    print("Enter filename:\n>");
    input(16);

    if (strlen(I) > 0) {

        strcpy(filename, I);

        print("\nType (P/S/U)?\n>");
        ch = getch();
        ftype = tolower(ch);
        sprintf(filename, "%s,%c,w", filename, ftype);

        print("\n\nDownloading... \n\n");

        cbm_open(15, 8, 15, "");
        cbm_open(3, 8, 3, filename);

        e = errorcheck();

        if (e == 0) {

            /* send NAK to initiate transfer */
            outbyte(NAK);

            do {

                /* get control byte */
                ch = inbyte('S', &status);

                if ((ch == 1) && (status == OK)) {

                    /* SOH received! */

                    /* get packet! */
                    sprintf(I, "\n\n\236Block #%i:", p); print(I);
                    pad(packet);
                    badbytes = 0;
                    m = 0;

                    for (i = 0; i < 131; i++) {
                        ch = inbyte('S', &status);
                        if (status == OK) {
                            packet[i] = ch;
                            if ((i > 1) && (i < 130)) {
                                m = m + ch;
                            }
                            print("\237+");
                        } else {
                            print("\034.");
                            badbytes++;
                        }
                    }

                    if (badbytes == 0) {

                        blk = packet[0];
                        chk = packet[1];
                        checksum = packet[130];

                        /* validate packet */
                        if ((blk == p) && (255 - chk == blk) && (checksum == m)) {

                            /* its good! save it! */
                            for (i = 2; i < 130; ++i) {
                                cbm_k_ckout(3);
                                cbm_k_bsout(packet[i]);
                                cbm_k_clrch();
                            }
                            print("\036\272");
                            p++;
                            outbyte(ACK);

                        } else {

                            badbytes = 1;
                        }

                    }

                    if (badbytes > 0) {

                        /* bad packet! */
                        print("\034X");
                        enjoythesilence();
                        outbyte(NAK);

                        retries++;

                        if (retries > MAXRETRIES) {
                            status = CANCEL;
                            print("\034C");
                            outbyte(CAN);
                            outbyte(CAN);
                            outbyte(CAN);
                            receiving = FALSE;
                            break;
                        }
                    }


                } else if ((ch == 4) && (status == OK)) {

                    /* EOT received! */
                    print("\036E");
                    outbyte(ACK);
                    receiving = FALSE;

                } else {

                    status = CANCEL;
                    print("\034C");
                    outbyte(CAN);
                    outbyte(CAN);
                    outbyte(CAN);
                    receiving = FALSE;
                    break;

                }


            } while (receiving == TRUE);

            if (status == OK) {
                print("\n\n\005SUCCCES\n");
            } else {
                print("\n\n\005FAILURE\n");
            }

        }

        cbm_close(3);
        cbm_close(15);

        print("\nReady.\n");

        cursor_on();

    } else {

        print("\n\nABORTED!\n\n");
        print("Ready.\n");
    }

    beep();

}

void upload(void) {

    /* UPLOAD ! */

    char ftype, packet[128], ch, i, j, m, e, st, t;
    char filename[20], sending = TRUE, p = 1, retries = 0, status = OK, retry = FALSE;

    print("\n\nXmodem Upload!\n\n");

    print("Enter filename:\n>");
    input(16);

    if (strlen(I) > 0) {

        sprintf(filename, "%s,r", I, ftype);

        print("\n\n\005Uploading... \n\n");

        print("Waiting for server..\n");

        cbm_open(15, 8, 15, "");
        cbm_open(3, 8, 3, filename);

        e = errorcheck();

        if (e == 0) {

            for (t = 0; t < MAXRETRIES; t++) {

                /* wait for NAK from remote... */
                ch = inbyte('L', &status);

                if (ch == NAK) {
                    break;
                }

            }

            if (ch == NAK) {

                /* lets go! */
                do {

                    /* clear buffer */
                    clearbuffer();

                    /* header */
                    outbyte(SOH);
                    outbyte(p);
                    outbyte(255 - p);

                    sprintf(I, "\n\n\236Block #%i:", p); print(I);

                    if (retry == FALSE) {

                        m = 0;
                        pad(packet);

                        /* get bytes from disk */
                        for (i = 0; i < 128; i++) {
                            cbm_k_chkin(3);
                            ch = cbm_k_basin();
                            cbm_k_clrch();
                            st = cbm_k_readst();

                            if (st == 0) {
                                outbyte(ch);
                                print("\237+");
                                packet[i] = ch;
                                m = m + ch;
                            } else if (st == 64) {
                                /* end of file */
                                for (j = i; j < 128; j++) {
                                    print("\237+");
                                    outbyte(PAD);
                                    m = m + PAD;
                                }
                                i = 128;
                                break;
                            } else {
                                e = errorcheck();
                                status = CANCEL;
                                print("\034C");
                                outbyte(CAN);
                                outbyte(CAN);
                                outbyte(CAN);
                                sending = FALSE;
                                break;
                            }
                        }

                        outbyte(m);         /* checksum! */

                    } else {

                        m = 0;

                        /* re-send the packet */
                        for (i = 0; i < 128; i++) {
                            outbyte(packet[i]);
                            m = m + packet[i];
                            print("\237+");
                        }

                        outbyte(m);         /* checksum! */

                        retry = FALSE;

                    }

                    if ((st == 0) || (st ==64)) {

                        ch = inbyte('S', &status);

                        if (ch == ACK) {

                            print("\036\272");
                            p++;

                        } else if (ch == NAK) {

                            print("\034X");
                            retries++;

                            enjoythesilence();

                            if (retries > MAXRETRIES) {
                                status = CANCEL;
                                print("\034C");
                                outbyte(CAN);
                                outbyte(CAN);
                                outbyte(CAN);
                                sending = FALSE;
                                break;
                            }

                        } else if (ch == CAN) {
                            print("\034C");
                            sending = FALSE;
                            break;
                        }
                    }

                    if (st == 64) {

                        /* we are done! */

                        outbyte(EOT);

                        ch = inbyte('S', &status);

                        if (ch == NAK) {
                            /* send EOT again? */
                            outbyte(EOT);
                            ch = inbyte('S', &status);
                        }

                        if (ch == ACK) {
                            print("\036E");
                            print("\n\n\005SUCCESS\n");
                            outbyte(ACK);
                        } else {
                            print("\034C");
                            print("\n\n\005FAILURE\n");
                            outbyte(CAN);
                        }

                        sending = FALSE;

                    }

                } while (sending == TRUE);

            } else {

                print("\n\nABORTED!");

            }

        }

        cbm_close(3);
        cbm_close(15);

        print("\n\nReady.\n");

        cursor_on();

    } else {

        print("\n\nABORTED!\n\n");
        print("Ready.\n");

    }

    beep();

}

void input(char maxchars) {

    char ch;
    char i = 0, done = FALSE;

    clear(I);

    do {

        ch = getch();
        putch(ch);

        if (ch == 13) {
            done = TRUE;
            break;
        } else if (ch == 20) {
            if (i > 0) {
                I[i] = '\0';
                i--;
            }
        } else {
            if (i < maxchars) {
                I[i] = ch;
                i++;
            } else {
                putch(20);
            }
        }

    } while (done == FALSE);

}

char getch(void) {

    char ch = 0;

    cursor_on();

    do {

        /* XLOCAL */
        ch = cbm_k_getin();

    } while(ch == 0);

    return(ch);

}

char errorcheck() {

    /* assumes channel 15 is already open */

    char data[32];
    char err[3];
    int e = 0;

    cbm_read(15, data, 32);

    if ((data[0] != '0') || (data[1] != '0')) {
        print("\022ERROR: ");
        print(data);
        print("\222");
        err[0] = data[0];
        err[1] = data[1];
        err[2] = '\0';
        e = (char)atoi(err);
    }

    return e;

}

void enjoythesilence(void) {

    char ch, r;
    char outer = TRUE, inner = TRUE;

    POKE(JCL, 0);

    do {

        do {

            r = PEEK(668);

            cbm_k_chkin(5);
            ch = cbm_k_getin();
            cbm_k_clrch();

            if (PEEK(668) == r) {
                inner = FALSE;
            } else {
                POKE(JCL, 0);
            }

        } while (inner == TRUE);

    } while (PEEK(JCL) < 60);

}

void clear(char *str) {
    while (*str) {
        *str++ = '\0';
    }
}

void pad(char *str) {
    while(*str) {
        *str++ = PAD;
    }
}

void clearbuffer(void) {

    char ch;

    do {
        cbm_k_chkin(5);
        ch = cbm_k_getin();
        cbm_k_clrch();
    } while (PEEK(667) != PEEK(668));


}

void outbyte(char ch) {
    cbm_k_ckout(5);
    cbm_k_bsout(ch);
    cbm_k_clrch();
    /* sprintf(I, "SND:%i ", ch); print(I); */
}

char inbyte(char delay, char *status) {

    char ch = 0, s, lch;
    char listening = TRUE;

    *status = OK;

    if (delay == 'S') {
        /* short delay ~ 10 secs */
        delay = 3;
    } else if (delay == 'L') {
        /* long delay ~ 100 secs */
        delay = 24;
    } else {
        delay = 3;
    }

    /* set jiffy clock low + med bytes to zero */
    POKE(JCM, 0);
    POKE(JCL, 0);

    do {

        s = PEEK(668);

        /* XLOCAL */
        lch = cbm_k_getin();
        if (lch != 0) {
            *status = CANCEL;
            ch = CAN;
            break;
        }

        /* XREMOTE */
        cbm_k_chkin(5);
        ch = cbm_k_getin();
        cbm_k_clrch();

        if (PEEK(668) != s) {
            listening = FALSE;
        }

        if (PEEK(JCM) > delay) {
            *status = TIMEOUT;
            print("\034?");
            listening = FALSE;
        }

    } while (listening == TRUE);

    /* sprintf(I, "REC:%i ", ch); print(I); */

    return ch;

}
