#include <stdio.h>
#include <stdlib.h>
#include <iostream>

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vblinky.h"

using namespace std;

void tick(int tickcount, Vblinky *tb, VerilatedVcdC *tfp) {
    tb->eval();
    if (tfp) // 2ns before tick
        tfp->dump(tickcount * 10 - 2);
    tb->i_clk = 1;
    tb->eval();
    if (tfp) // 2ns before tick
        tfp->dump(tickcount * 10);
    tb->i_clk = 0;
    tb->eval();
    if (tfp) { // 5ns after tick
        tfp->dump(tickcount * 10 + 5);
        tfp->flush();
    }
}

int main(int argc, char **argv) { 
    Verilated::commandArgs(argc, argv);

    // Instantiate our design
    Vblinky *tb = new Vblinky;

    int last_led;

    // Add trace functionality
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    tb->trace(tfp, 99);
    tfp->open("blinky_trace.vcd");
    uint64_t tickcount = 0;

    // 1<<20 timesteps
    last_led = tb->o_led;
    for (int k=0; k<(1<<20); k++) {
        // Timer tick
        tick(++tickcount, tb, tfp);

        if (last_led != tb->o_led) {
            printf("k = %7d, led=%d\n", k, tb->o_led);
            last_led = tb->o_led;
        }
    }
}