#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LOOP_WAIT_LIMIT 10000
#define MULTIPLIER0 0x1000000C
#define MULTIPLIER1 0x10000010

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

static void placeInMemC(uint32_t i) {
	*((volatile uint32_t *)MULTIPLIER0) = i;
}
static void placeInMem10(uint32_t i) {
	*((volatile uint32_t *)MULTIPLIER1) = i;
}

void main() {
	uint32_t number_to_display = 0;
	uint32_t counter = 0;
	putuint(number_to_display);
	uint32_t i;
	for(i=0; i <= 1801; i++){
		counter = 0;
		if(i==0){
			placeInMemC(120);
			placeInMem10(5);
		}else if(i == 450){
			placeInMemC(47);
			placeInMem10(725);
		}else if(i == 900){
			placeInMemC(7628900);
			placeInMem10(611);
		}else if(i == 1350){
			placeInMemC(39916800);
			placeInMem10(1023);
		}else if(i == 1800){
			placeInMem10(9628800);
		}
	}
	while (counter < LOOP_WAIT_LIMIT) {
		counter++;
	}
}



