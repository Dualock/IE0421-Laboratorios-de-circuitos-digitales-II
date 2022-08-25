#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LOOP_WAIT_LIMIT 1500000
#define LINKED_LIST_HEAD 0x4000
#define ELEMENTS 200
#define HALF_BYTE_STEP 0x00000004
#define BYTE_STEP 0x00000008

static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;
}

static void write(uint32_t index, uint32_t current_addr, uint32_t next_addr){
  *((volatile uint32_t *) current_addr) = next_addr;
  current_addr = current_addr + HALF_BYTE_STEP;
  *((volatile uint32_t *) current_addr) = index;
}
static uint32_t read(uint32_t addr){
  uint32_t return_data = *(volatile uint32_t *)addr;
  return return_data;
}
void main(){
  uint32_t index;
  uint32_t leds[8] = {0,0,0,0,0,0,0,0};
  uint32_t counter = 0;
  //Preparing to write data in the linked list
  uint32_t current_addr = LINKED_LIST_HEAD;
  uint32_t next_addr;
  for (index = 0; index < ELEMENTS; index++) {
    next_addr = current_addr + BYTE_STEP;
    write(index, current_addr, next_addr);
    current_addr = next_addr;
  }
    //Preparing to read data in the linked list
  current_addr = LINKED_LIST_HEAD;
  uint32_t even_numb;
  for (index = 0; index < ELEMENTS; index++) {
    even_numb = read(current_addr + HALF_BYTE_STEP);
    if(even_numb%2 == 0){
      leds[0] = leds[1];
      leds[1] = leds[2];
      leds[2] = leds[3];
      leds[3] = leds[4];
      leds[4] = leds[5];
      leds[5] = leds[6];
      leds[6] = leds[7];
      leds[7] = even_numb;
    }
    current_addr = read(current_addr);
  }
  // Put data into memory registers
  while (1) {
    for (int i = 0; i<8; i++){
      counter = 0;
      putuint(leds[i]);
      while (counter < LOOP_WAIT_LIMIT) {
        counter++;
      }
    }
  }
}
