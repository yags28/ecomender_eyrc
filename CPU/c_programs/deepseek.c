
/*
* EcoMender Bot (EB): Task 2B Path Planner
*
* This program computes the valid path from the start point to the end point.
* Make sure you don't change anything outside the "Add your code here" section.
*/

#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <limits.h>
#define V 32
#define STACK_SIZE 8  // Increased stack size to avoid overflow
#define MAX_PATH 12   // Limit the path size to fit in memory


#ifdef __linux__ // for host pc

    #include <stdio.h>

    void _put_byte(char c) { putchar(c); }

    void _put_str(char *str) {
        while (*str) {
            _put_byte(*str++);
        }
    }

    void print_output(uint8_t num) {
        if (num == 0) {
            putchar('0'); // if the number is 0, directly print '0'
            _put_byte('\n');
            return;
        }

        if (num < 0) {
            putchar('-'); // print the negative sign for negative numbers
            num = -num;   // make the number positive for easier processing
        }

        // convert the integer to a string
        char buffer[20]; // assuming a 32-bit integer, the maximum number of digits is 10 (plus sign and null terminator)
        uint8_t index = 0;

        while (num > 0) {
            buffer[index++] = '0' + num % 10; // convert the last digit to its character representation
            num /= 10;                        // move to the next digit
        }
        // print the characters in reverse order (from right to left)
        while (index > 0) { putchar(buffer[--index]); }
        _put_byte('\n');
    }

    void _put_value(uint8_t val) { print_output(val); }

#else  // for the test device

    void _put_value(uint8_t val) { }
    void _put_str(char *str) { }

#endif

// main function
int main(int argc, char const *argv[]) {

    #ifdef __linux__

        const uint8_t START_POINT   = atoi(argv[1]);
        const uint8_t END_POINT     = atoi(argv[2]);
        uint8_t NODE_POINT          = 0;
        uint8_t CPU_DONE            = 0;
        uint8_t DIRECTION_NEED = 0;
        uint8_t SECOND_LAST = 14;
    #else
        // Address value of variables for RISC-V Implementation
        #define START_POINT         (* (volatile uint8_t * ) 0x02000000)
        #define END_POINT           (* (volatile uint8_t * ) 0x02000004)
        #define NODE_POINT          (* (volatile uint8_t * ) 0x02000008)
        #define CPU_DONE            (* (volatile uint8_t * ) 0x0200000c)
        #define DIRECTION_NEED  (*((volatile uint8_t *) 0x02000010))  // Direction Printer
        #define SECOND_LAST  (*((volatile uint8_t *) 0x02000012))


    #endif

    uint32_t graph[V] ;
graph[0] = 0xfd190529;
graph[1] = 0x109fd2d;
graph[2] = 0x15110d05;
graph[3] = 0x9fdfdfd;
graph[4] = 0xfdfdfd09;
graph[5] = 0xfdfd09fd;
graph[6] = 0x25211d01;
graph[7] = 0x19fdfdfd;
graph[8] = 0xfdfdfd19;
graph[9] = 0xfdfd19fd;
graph[10] = 0x69012d61;
graph[11] = 0x2905314d;
graph[12] = 0x2dfd3935;
graph[13] = 0xfd31fdfd;
graph[14] = 0x3d31fd41;
graph[15] = 0xfdfd39fd;
graph[16] = 0x4539fd49;
graph[17] = 0xfdfdfd41;
graph[18] = 0xfd554d41;
graph[19] = 0x512dfd49;
graph[20] = 0xfdfd4dfd;
graph[21] = 0x5d5949fd;
graph[22] = 0xfdfdfd55;
graph[23] = 0xfd796155;
graph[24] = 0xfd29655d;
graph[25] = 0x61fdfdfd;
graph[26] = 0x71fd296d;
graph[27] = 0xfd69fdfd;
graph[28] = 0xfd697579;
graph[29] = 0x71fdfdfd;
graph[30] = 0x717d5dfd;
graph[31] = 0xfdfdfd79;
   uint8_t path[MAX_PATH];
    uint8_t idx = 0;

    // Function to extract neighbor at given position from encoded node
uint8_t get_neighbor(uint32_t encoded_node, uint8_t pos) {
    // uint8_t neighbor_weight = (encoded_node >> (pos * 8)) & 0xFF;
    // uint8_t neighbor = (neighbor_weight >> 2) & 0x3F;
    // return (neighbor == 0x3F) ? 0xFF : neighbor;  // Return 33 for invalid neighbors
    uint8_t n = (encoded_node >> (pos << 3)) & 0xFF;
    return ((n >> 2) & 0x3F) == 0x3F ? 0xFF : (n >> 2) & 0x3F;
}


// Function to determine turn based on previous, current, and next points
// Function to determine turn based on previous, current, and next points
uint8_t determine_turn_opt(uint8_t prev, uint8_t curr, uint8_t next, uint32_t graph[V]) {
    uint8_t prev_pos = 0xFF, next_pos = 0xFF;
    uint32_t node = graph[curr];
    //f (prev == 0xFF) return 0;    // No turn needed at start
    //if (next == 0xFF) return 0;  //No turn needed at end


    // Find positions of previous and next nodes in the neighbor list
    for (uint8_t i = 0; i < 4; i++) {
        uint8_t neighbor = get_neighbor(node, i);
        if (neighbor == prev) prev_pos = i;
        if (neighbor == next) next_pos = i;
    }

    // If not found, return 0xFF (invalid)
   // if (prev_pos == 0xFF || next_pos == 0xFF) return 0xFF;

    // Handle wrap-around cases in a circular manner
    uint8_t diff = ((next_pos - prev_pos )+ 4) & 3;  

    // Use a lookup table to avoid conditionals
    uint8_t turn_table[4];  // 0 = Forward, 1 = Left, 2 = Right
    turn_table[3] = 2;
    turn_table[2] = 0;
    turn_table[1] = 1;
    turn_table[0] = 3;
    return turn_table[diff];
}
    // Iterative DFS to find path from start to end
bool iterative_dfs(uint8_t path[MAX_PATH],uint8_t *idx) {   // uint8_t path[MAX_PATH];
    uint8_t stack[STACK_SIZE];
    uint8_t path_stack[STACK_SIZE];  // Stack to track path indices for backtracking
    uint8_t sp = 0;  // Stack pointer
    uint8_t visited[4] = {0};  // Bitmap for visited nodes (32 bits total)
    *idx = 0;
    stack[sp] = START_POINT;
    path_stack[sp] = *idx;  // Store current path index
    sp++;

    while (sp > 0) {
        // Pop current node
        sp--;
        uint8_t node = stack[sp];
        *idx = path_stack[sp];  // Restore path index for backtracking

        uint8_t node_byte = node >> 3;
        uint8_t node_bit = 1 << (node & 7);


       // if (visited[node]) continue;  
        //visited[node] = true;
       if (visited[node_byte] & node_bit) {
            continue;
        }
        // Mark as visited
        visited[node_byte] |= node_bit;

        // Add to path
        path[(*idx)++] = node;

        // Check if we reached the end
        if (node == END_POINT) {
            // Apply turning logic to the path and store turns in the array
             for (uint8_t i = 0; i < *idx; i++) {
               // final_path[i] = path[i];
               if (i < (*idx - 1)){
               DIRECTION_NEED = determine_turn_opt(SECOND_LAST, path[i], path[i + 1], graph);
               _put_str("=====================================");
               _put_str("Direction Checking\n");
               _put_value(DIRECTION_NEED);
               //(i > 0 ? path[i - 1] : SECOND_LAST )
               SECOND_LAST = path[i];
               }
               NODE_POINT = path[i];
               //NODE_POINT = sp;
            }
           // *final_idx = *idx;
            return true;
            //CPU_DONE = 1;
        //    while (1);
        }

        // Count valid neighbors first
        uint8_t valid_neighbors = 0;
        uint8_t neighbors[4];

        for (int8_t i = 3; i >= 0; i--) {
            uint8_t neighbor = get_neighbor(graph[node], i);
            if (neighbor != 0xFF) {  // Valid neighbor
                uint8_t neighbor_byte = neighbor >> 3;
                uint8_t neighbor_bit = 1 << (neighbor & 7);

                if (!(visited[neighbor_byte] & neighbor_bit)) {
                    neighbors[valid_neighbors++] = neighbor;
                }
            }
        }

        // Add valid unvisited neighbors to stack
        for (int8_t i = 0; i < valid_neighbors && sp < STACK_SIZE; i++) {
            stack[sp] = neighbors[i];
            path_stack[sp] = *idx;  // Store current path length for backtracking
            sp++;
        }

        // If no valid neighbors were found, backtrack
        if (valid_neighbors == 0 && *idx > 0) {
            (*idx)--;  // Remove current node from path
        }
    }

    return false;  // No path found
}

    // Find path using iterative DFS
    if (iterative_dfs(path,&idx )) {
             if (NODE_POINT == END_POINT)
             {
                 CPU_DONE = 1;
             }
        }
  //  return 0;  // This line will never be reached


    
    // #ifdef __linux__    // for host pc

    //     _put_str("######### Planned Path #########\n");
    //     for (int i = 0; i < idx; ++i) {
    //         _put_value(DIRECTION_NEED[i]);
    //     }
    //     _put_str("################################\n");

    // #endif

    return 0;
}

