#include <stdio.h>
#include <stdlib.h>
#include "Vthruwire.h"
#include "verilated.h"
#include <iostream>

using namespace std;

int main(int argc, char **argv) { 
    Verilated::commandArgs(argc, argv);

    // Instantiate our design
    Vthruwire *tb = new Vthruwire;

    // 20 timesteps
    for (int k=0; k<20; k++) {
        tb->i_sw = (k & 2) >> 1;

        tb->eval();

        printf("k = %d, sw = %d, led = %d\n", k, tb->i_sw, tb->o_led);
    }
}