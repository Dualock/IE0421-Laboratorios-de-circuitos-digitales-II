#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LOOP_WAIT_LIMIT 10000
#define MULTIPLIER0 0x10000004
#define MULTIPLIER1 0x10000008

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

static void placeInMem4(uint32_t i) {
	*((volatile uint32_t *)MULTIPLIER0) = i;
}
static void placeInMem8(uint32_t i) {
	*((volatile uint32_t *)MULTIPLIER1) = i;
}

void main() {
	uint32_t number_to_display = 0;
	uint32_t counter = 0;
	putuint(number_to_display);
	uint32_t i;
	for(i=0; i <= 901; i++){
		counter = 0;
		if(i==0){
			placeInMem4(1);
			placeInMem8(7);
		}else if(i == 450){
			placeInMem4(2);
			placeInMem8(15);
		}else if(i == 900){
			placeInMem4(6);
			placeInMem8(10);
		}
	}
	while (counter < LOOP_WAIT_LIMIT) {
		counter++;
	}
}



