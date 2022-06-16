#include <stdio.h>
#include "hardware.h"
#include <isr_compat.h>
#define WDTCTL_               0x0120    /* Watchdog Timer Control */
//#define WDTHOLD             (0x0080)
//#define WDTPW               (0x5A00)

#define METADATA_ADDR 0x140
#define CHAL_ADDR METADATA_ADDR
#define ERMIN_ADDR (CHAL_ADDR+32)
#define ERMAX_ADDR (ERMIN_ADDR+2)
#define ORMIN_ADDR (ERMAX_ADDR+2)
#define ORMAX_ADDR (ORMIN_ADDR+2)
#define EXEC_ADDR (ORMAX_ADDR+2)

// ERMIN/MAX_VAL should correspond to address of dummy_function
// Compile, verify in LST, compile again after modifying
#define ERMIN_VAL 0xe196
#define ERMAX_VAL 0xe1e2
#define ORMIN_VAL 0x200 
#define ORMAX_VAL 0x210

extern void VRASED (uint8_t *challenge, uint8_t *response, uint8_t operation); 

extern void my_memset(uint8_t* ptr, int len, uint8_t val);

extern void my_memcpy(uint8_t* dst, uint8_t* src, int size);

// ER STARTS HERE
__attribute__(( section( ".exec.call"), naked)) void startER() {
	dummy_function();
	__asm__ volatile("br #__exec_leave" "\n\t");
}

//DUMMY FUNCTION
__attribute__(( section( ".exec.body"))) void dummy_function() {
	uint8_t *out = (uint8_t*)(ORMIN_VAL);
	int i;
	for(i=0; i<32; i++) out[i] = i+i;

	
	// Modify IVT value, causing a violation.
  // EXEC flag now should be 0 
  *((uint16_t*)(0xFFF2)) = 0xE19C; // Set the ivt entry for this isr to a random address in the ER
	
}

//TCB ISR
__attribute__(( section( ".exec.body"))) ISR(PORT1, TCB){ // test ISR in ER
	P1IFG &= ~P1IFG;
	P5OUT = ~P5OUT;
}

// ER ENDS HERE
__attribute__(( section( ".exec.leave"), naked)) void exitER(){
	__asm__ volatile("ret" "\n\t");
}

void success() {
    __asm__ volatile("bis     #240,   r2" "\n\t");  
}

void fail() {
    __asm__ volatile("bis     #240,   r2" "\n\t");  
}

void setup (void) {
  // Disables WDT
  WDTCTL = WDTPW | WDTHOLD;          // Disable watchdog timer

  P1DIR  = 0x00;                     // Port 1.0-1.7 = input
  P1IE   = 0x01;                     // Port 1.0 interrupt enabled
  P1IES  = 0x00;                     // Port 1.0 interrupt edge selection (0=pos 1=neg)
  P1IFG  = 0x00;                     // Clear all Port 1 interrupt flags (just in case)

  P3DIR  = 0xFF; 		//output of main
  P3OUT = 0x00;
  
  P5DIR = 0xFF; 		//output of ISR
  P5OUT = 0x00;		
}

int main() {
	setup();
    uint8_t response[32];

    uint32_t* wdt = (uint32_t*)(WDTCTL_);
    *wdt = WDTPW | WDTHOLD;

    eint();
    // Fill METADATA buffer
    uint8_t *challenge = (uint8_t*)(CHAL_ADDR);
    my_memset(challenge, 32, 0x00);
    *((uint16_t*)(ERMIN_ADDR)) = ERMIN_VAL;
    *((uint16_t*)(ERMAX_ADDR)) = ERMAX_VAL;
    *((uint16_t*)(ORMIN_ADDR)) = ORMIN_VAL;
    *((uint16_t*)(ORMAX_ADDR)) = ORMAX_VAL;

    // Read METADATA buffer
    uint16_t ERmin = *((uint16_t*)(ERMIN_ADDR));
    uint16_t ERmax = *((uint16_t*)(ERMAX_ADDR));
    uint16_t ORmin = *((uint16_t*)(ORMIN_ADDR));
    uint16_t ORmax = *((uint16_t*)(ORMAX_ADDR));
    uint16_t exec = *((uint16_t*)(EXEC_ADDR));

    // Sanity check
    if(ERmin != ERMIN_VAL || ERmax != ERMAX_VAL || ORmin != ORMIN_VAL || ORmax != ORMAX_VAL || exec == 1) fail();

    // Execute ER
    ((void(*)(void))ERmin)();                        

    // Call VRASED
    VRASED(challenge, response, 0);                 

    // Write token to P3OUT one by one
    int i;
    for(i=0; i<32; i++) P3OUT = response[i];

    exec = *((uint16_t*)(EXEC_ADDR));
    if(exec != 1) fail();  

    success();
    
    return 0;
}