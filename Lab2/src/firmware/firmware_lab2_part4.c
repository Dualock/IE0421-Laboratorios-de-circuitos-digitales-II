#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LOOP_WAIT_LIMIT 10000
#define MULTIPLIER0 0xFFFFFFF0
#define MULTIPLIER1 0xFFFFFFF4
#define RESULT0 0xFFFFFFF8

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
static void placeInMemF0(uint32_t i) {
	*((volatile uint32_t *)MULTIPLIER0) = i;
}
static void placeInMemF4(uint32_t i) {
	*((volatile uint32_t *)MULTIPLIER1) = i;
}
uint32_t readMemF8() {
	return *((volatile uint32_t *)RESULT0);
}

void main() {
	uint32_t number_to_display = 0;
	uint32_t counter = 0;
	putuint(number_to_display);
	uint32_t i;
	uint32_t j;
	for(i=0; i <= 15; i++){
		counter = 0;
		placeInMemF0(i);
		for(j=0; j <= 15; j++){
			placeInMemF4(j);
			putuint(readMemF8());
		}
	}
	while (counter < LOOP_WAIT_LIMIT) {
		counter++;
	}
}



