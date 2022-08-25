#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LOOP_WAIT_LIMIT 50000000
#define LINKED_LIST_HEAD 0x4000
#define ELEMENTS 17
#define HALF_BYTE_STEP 0x00000004
#define BYTE_STEP 0x00000008

static void putuint(uint32_t i) {
	//*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;
}

static void write(uint32_t index, uint32_t current_addr, uint32_t next_addr){
  //*((volatile uint32_t *) current_addr) = next_addr;
  printf("%u \t %u \t\t %u \n", index, current_addr, next_addr);
  //printf("{%u,%u,%u},\n", index, current_addr, next_addr);

  current_addr = current_addr + HALF_BYTE_STEP;
  //*((volatile uint32_t *) current_addr) = index;
  printf("%u \t %u \t\t %u \n", index, current_addr, index);
  //printf("{%u,%u,%u}, \n", index, current_addr, index);
}
static uint32_t read(uint32_t addr){
  uint32_t return_data;
  uint32_t linked_list [2*ELEMENTS][3] =  {
                                  {0,16384,16392},
                                  {0,16388,0},
                                  {1,16392,16400},
                                  {1,16396,1},
                                  {2,16400,16408},
                                  {2,16404,2},
                                  {3,16408,16416},
                                  {3,16412,3},
                                  {4,16416,16424},
                                  {4,16420,4},
                                  {5,16424,16432},
                                  {5,16428,5},
                                  {6,16432,16440},
                                  {6,16436,6},
                                  {7,16440,16448},
                                  {7,16444,7},
                                  {8,16448,16456},
                                  {8,16452,8},
                                  {9,16456,16464},
                                  {9,16460,9},
                                  {10,16464,16472},
                                  {10,16468,10},
                                  {11,16472,16480},
                                  {11,16476,11},
                                  {12,16480,16488},
                                  {12,16484,12},
                                  {13,16488,16496},
                                  {13,16492,13},
                                  {14,16496,16504},
                                  {14,16500,14},
                                  {15,16504,16512},
                                  {15,16508,15},
                                  {16,16512,16520},
                                  {16,16516,16}
                                  };
  //uint32_t return_data = *(volatile uint32_t *)addr;
  for (int i = 0; i < 2*ELEMENTS; i++)
{
    for (int j = 0; j < 3; j++) {
      if(j == 1 && addr == linked_list[i][j]){
        return_data = linked_list[i][j+1];
      }
    }
}
  return return_data;
}
void main(){
  uint32_t index;
  uint32_t leds[8] = {0,0,0,0,0,0,0,0};
  uint32_t counter = 0;
  //Preparing to write data in the linked list
  uint32_t current_addr = LINKED_LIST_HEAD;
  uint32_t next_addr;
  printf("element  current_addr    data \n");
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
      printf("Numero par en la direccion %u dato %u \n", current_addr, even_numb);
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
  for (int i = 0; i < 8; i++)
  {
    printf("LEDS[%d] = %d\n", i, leds[i]);
  }
  // Put data into memory registers
  while (1) {
    counter = 0;
    for (int i = 0; i<8; i++){
      putuint(leds[i]);
    }
    while (counter < LOOP_WAIT_LIMIT) {
      counter++;
    }
  }

}
