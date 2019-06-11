#include <stdio.h>
#include <stdlib.h>
#include "Vblinky.h"
#include "verilated.h"
#include <iostream>

using namespace std;

void tick(Vblinky *tb) {
    tb->eval();
    tb->i_clk = 1;
    tb->eval();
    tb->i_clk = 0;
    tb->eval();
}

int main(int argc, char **argv) { 
    Verilated::commandArgs(argc, argv);

    // Instantiate our design
    Vblinky *tb = new Vblinky;

    int last_led;

    // 1<<20 timesteps
    last_led = tb->o_led;
    for (int k=0; k<(1<<20); k++) {
        // Timer tick
        tick(tb);

        if (last_led != tb->o_led) {
            printf("k = %7d, led=%d\n", k, tb->o_led);
            last_led = tb->o_led;
        }
    }
}