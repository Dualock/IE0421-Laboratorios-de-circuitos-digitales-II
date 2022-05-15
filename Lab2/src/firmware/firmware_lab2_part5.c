#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LOOP_WAIT_LIMIT 10000
#define MULTIPLIER0 0xFFFFFFF0
#define MULTIPLIER1 0xFFFFFFF4
#define RESULT0 0xFFFFFFF8
#define RESULT1 0xFFFFFFFC

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
uint32_t readMemFC() {
	return *((volatile uint32_t *)RESULT1);
}

void main() {
	uint32_t number_to_display = 0;
	uint32_t counter = 0;
	putuint(number_to_display);
	uint32_t i;
	uint32_t temp0;
	uint32_t temp1;
	uint32_t count;
	for(i=0; i <= 1401; i++){
		counter = 0;
		if(i==0){
			placeInMemF0(25);
			placeInMemF4(7);
		}else if(i == 200){
			placeInMemF0(635);
			placeInMemF4(1023);
		}else if(i == 400){
			placeInMemF0(2157297371);
			placeInMemF4(662);
		}else if(i == 600){
			placeInMemF0(9813723);
			placeInMemF4(6036761403);
		}else if(i == 800){
			placeInMemF4(3628800);
		}else if(i == 1000){
			placeInMemF0(1);
		}else if(i == 1200){
			placeInMemF0(4068839099);
		}else if(i == 1400){
			placeInMemF0(23);
		}
		count = 0;
		temp0 = readMemF8();
		temp1 = readMemFC();
		while(temp0){
			count += temp0 & 1;
			temp0 >>= 1;
		}
		while(temp1){
			count += temp1 & 1;
			temp1 >>= 1;
		}
		putuint(count);
	}
	while (counter < LOOP_WAIT_LIMIT) {
		counter++;
	}
}



