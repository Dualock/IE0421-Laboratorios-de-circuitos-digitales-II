#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LINKED_LIST_HEAD 0x00004000
#define LINKED_LIST_SIZE 0x0000FFFF
#define LOOP_WAIT_LIMIT 100000

static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;
}

static void addToList(uint32_t offset, uint32_t data){
	*((volatile uint32_t *)(LINKED_LIST_HEAD+offset)) = LINKED_LIST_HEAD+offset+8;
	*((volatile uint32_t *)(LINKED_LIST_HEAD+offset+4)) = data;
}

static void printList(){
	for(uint32_t i=0; i < (LINKED_LIST_SIZE-LINKED_LIST_HEAD); i+8){
			uint32_t counter = 0;
			putuint(*((volatile uint32_t *)(LINKED_LIST_HEAD+i)));
			putuint(32);
			while (counter < LOOP_WAIT_LIMIT) {
			counter++;
			}
		}
}

void main() {
	uint32_t counter = 0;
	while(1){
		for(uint32_t i=0; i < (LINKED_LIST_SIZE-LINKED_LIST_HEAD); i+8){
			addToList(i,counter);
			counter++;
		}
		printList();
	}
}
