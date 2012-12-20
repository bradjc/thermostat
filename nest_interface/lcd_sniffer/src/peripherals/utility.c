
#include "msp430.h"

#include "utility.h"

void delay(register uint16_t delayCycles) {
#ifdef __GNUC__
	__asm__ (
		"    sub   #20, %[delayCycles]\n"
		"1:  sub   #4, %[delayCycles] \n"
		"    nop                      \n"
		"    jc    1b                 \n"
		"    inv   %[delayCycles]     \n"
		"    rla   %[delayCycles]     \n"
		"    add   %[delayCycles], r0 \n"
		"    nop                      \n"
		"    nop                      \n"
		"    nop                      \n"
		:                                 // no output
		: [delayCycles] "r" (delayCycles) // input
		:                                 // no memory clobber
	);
#else
	__asm(
		"    sub   #20,r12\n"
		"    sub   #4,r12\n"
		"    nop\n"
		"    jc    $-4\n"
		"    inv   r12\n"
		"    rla   r12\n"
		"    add   r12,r0\n"
		"    nop\n"
		"    nop\n"
		"    nop\n"
	);
#endif
	//   ret provided by C
}

void util_disableWatchdog(void) {
	WDTCTL = WDTPW + WDTHOLD;
}

void util_boardInit(void) {

	// Pin setup determined from TinyOS.

	P1SEL = 0;
	P2SEL = 0;
	P3SEL = 0;
	P4SEL = 0;
	//P5SEL = 0x20; // output SMCLK on P5.5
    P5SEL = 0;
	P6SEL = 0;

	P1OUT = 0x00;
	P1DIR = 0x00;

	P2OUT = 0x00;
	P2DIR = 0x00;

	P3OUT = 0x00;
	P3DIR = 0x00;

	P4OUT = 0x00;
	P4DIR = 0x00;

	P5OUT = 0x00;

	//P5DIR = 0x20;
	P5DIR = 0x00;

	P6OUT = 0x00;
	P6DIR = 0x00;

	P1IE = 0;
	P2IE = 0;

	// Setup Clocks
    // BCSCTL1
    // .XT2OFF = 1; disable the external oscillator for SCLK and MCLK
    // .XTS = 0; set low frequency mode for LXFT1
    // .DIVA = 0; set the divisor on ACLK to 1
    // .RSEL, do not modify
    BCSCTL1 = XT2OFF | (BCSCTL1 & (RSEL2|RSEL1|RSEL0));

    BCSCTL1 |= RSEL0 + RSEL1 + RSEL2;
    DCOCTL |= DCO0 + DCO1 + DCO2;
    // BCSCTL2
    // .SELM = 0; select DCOCLK as source for MCLK
    // .DIVM = 0; set the divisor of MCLK to 1
    // .SELS = 0; select DCOCLK as source for SCLK
    // .DIVS = 2; set the divisor of SCLK to 4
    // .DCOR = 1; select internal resistor for DCO
    //BCSCTL2 = DIVS1 | DCOR;


}

void util_enableInterrupt(void) {
	__enable_interrupt();
}

void util_disableInterrupt(void) {
	__disable_interrupt();
}

void util_delayMs(uint16_t ms) {
	while (ms--) {
		__delay_cycles(16000000 / 1000);
	}
}

void util_delayCycles (uint16_t cycles) {
	cycles &= ~0x8;
	while (cycles-=8) {
		__delay_cycles(8);
	}
}

