#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LOOP_WAIT_LIMIT 10000

uint32_t factorial(int n){
    uint32_t c;
    uint32_t result = 1;

    for (c = 1; c <= n; c++){
        result = result * c;
    }

    return result;
}

static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;
}

void main() {
	uint32_t number_to_display = 0;
	uint32_t counter = 0;
	uint32_t i;
	for(i=0; i <= 3; i++){
		counter = 0;
		switch(i){
			case 0:
				number_to_display = factorial(5);
				break;
			case 1:
				number_to_display = factorial(7);
				break;
			case 2:
				number_to_display = factorial(10);
				break;
			case 3:
				number_to_display = factorial(12);
				break;
			default:
				number_to_display = 0;
		}
		putuint(number_to_display);
		while (counter < LOOP_WAIT_LIMIT) {
			counter++;
		}
	}
}



