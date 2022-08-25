#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define IRQ_REGISTERS_MEMORY_ADD 0x10000008
#define SELECTOR_TXT_DISPLAY 0x10000010
#define LOOP_WAIT_LIMIT 650000

uint32_t global_counter = 0;

static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;
}

static void putuint2(uint32_t i) {
	*((volatile uint32_t *)IRQ_REGISTERS_MEMORY_ADD) = i;
}

static void putuint_sel(uint32_t i) {
	*((volatile uint32_t *)SELECTOR_TXT_DISPLAY) = i;
}


uint32_t *irq(uint32_t *regs, uint32_t irqs) {
    return regs;
}


void main() {
	uint32_t selector = 0;
	uint32_t counter = 0;

	while (1) {
		counter = 0;
		putuint_sel(selector);
		while (counter < LOOP_WAIT_LIMIT) {
			counter++;
		}
		if(selector < 8){
			selector++;
		}
		else{
			selector = 0;
		}
	}
}
