#include <stdint.h>

// Address value of variables for RISC-V Implementation
#define START_POINT         (* (volatile uint8_t * ) 0x02000000)
#define END_POINT           (* (volatile uint8_t * ) 0x02000004)
#define NODE_POINT          (* (volatile uint8_t * ) 0x02000008)
#define CPU_DONE            (* (volatile uint8_t * ) 0x0200000c)
// #define HW                  ((volatile uint8_t * ) 0x02000010)
uint8_t *HW = (uint8_t *) 0x02000010;


uint8_t is_node_present(uint8_t node_id) {
    for (uint8_t i = 0; i < 15; ++i) { 
        if (HW[i] == node_id) {
            return i; 
        }
    }
    return 255; 
}



int main(){
// uint8_t HighWay[15]={6, 0, 10, 26, 28, 30, 23, 21, 18, 16, 14, 12, 11, 1, 2};
HW[0] = 6;
HW[1] = 0;
HW[2] = 10;
HW[3] = 26;
HW[4] = 28;
HW[5] = 30;
HW[6] = 23;
HW[7] = 21;
HW[8] = 18;
HW[9] = 16;
HW[10] = 14;
HW[11] = 12;
HW[12] = 11;
HW[13] = 1;
HW[14] = 2;

NODE_POINT = START_POINT;  

uint8_t HW_S = is_node_present(START_POINT);

if (HW_S == 255) {
    // Determine search range and direction based on START_POINT
    uint8_t max_offset = (START_POINT < 11) ? 3 : 2;

    while (max_offset > 0) {
    HW_S = is_node_present(START_POINT - max_offset);
    if (HW_S != 255) {
        // HW node found
        if (START_POINT >= 11 && max_offset == 2) {
            // Extra step for the top part logic
            NODE_POINT = (START_POINT - 1);
        }
        NODE_POINT = (START_POINT - max_offset);
        break;
    }
    max_offset--;
}
}

uint8_t DES_INT = 255;
uint8_t HW_D = is_node_present(END_POINT);
    
if (HW_D == 255) { //node not in HW
    uint8_t max_offset = (END_POINT < 11) ? 3 : 2;
    while (max_offset > 0) {
        HW_D = is_node_present(END_POINT - max_offset);
        if (HW_D != 255) {
            if(max_offset == 2){
                DES_INT = (END_POINT - 1);
            }
            break;
        }
        max_offset--;
    }
}

// Optimized logic for path planning
while (HW_S != HW_D) {
    if (HW_S > HW_D) {
        // Decrement HW_S and update path
        NODE_POINT = HW[--HW_S];
    } else {
        // Increment HW_S and update path
        NODE_POINT = HW[++HW_S];
    }
}

if (NODE_POINT != END_POINT) {
    NODE_POINT = (DES_INT != 255) ? DES_INT : END_POINT;
    if (DES_INT != 255) {
        NODE_POINT = END_POINT;
    }
}



// flag indicating program execution is complete
CPU_DONE = 1;

return 0;
}