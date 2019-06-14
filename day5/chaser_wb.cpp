#include <stdio.h>
#include <stdlib.h>
#include <iostream>

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vchaser_wb.h"

using namespace std;

int tickcount = 0;
Vchaser_wb *tb;
VerilatedVcdC *tfp;

void tick(void) {
    tickcount++;
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

uint32_t wb_read(uint32_t addr)
{
    tb->i_cyc = tb->i_stb = 1;
    tb->i_we = 0; tb->eval();
    tb->i_addr = addr;

    while (tb->o_stall)
        tick();
    tick();
    tb->i_stb = 0;

    while(!tb->o_ack)
        tick();
    
    tb->i_cyc = tb->i_stb = 0;
    tb->eval();
    return tb->o_data;
}

void wb_write(uint32_t addr, uint32_t data)
{
    tb->i_cyc = tb->i_stb = 1;
    tb->i_we = 1; tb->eval();
    tb->i_addr = addr;
    tb->i_data = data;

    while(tb->o_stall)
        tick();
    tick();
    tb->i_stb = 0;

    while(!tb->o_ack)
        tick();
    
    tb->i_cyc = tb->i_stb = 0;
    tb->eval();
}

int main(int argc, char **argv) { 
    Verilated::commandArgs(argc, argv);

    // Instantiate our design
    tb = new Vchaser_wb;

    int last_led, last_state = 0, state = 0;

    // Add trace functionality
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    tb->trace(tfp, 99);
    tfp->open("chaser_wb_trace.vcd");

    last_led = tb->o_led;

    // Read from the current state
    printf("Initial state is: 0x%02x\n", wb_read(0));

    for (int cycle=0; cycle<2; cycle++) {
        
        for (int i=0;i<5;i++)
            tick();
        
        wb_write(0, 0);

        while ((state = wb_read(0)) != 0) {
            if ((state != last_state) || (tb->o_led != last_led)) {
                printf("%6d: State #%2d ", tickcount, state);

                for (int j=0; j<6; j++) {
                    if (tb->o_led & (1 << j))
                        printf("o");
                    else
                        printf("-");
                }
                printf("\n");
            }

            last_state = state;
            last_led = tb->o_led;
        }
    }
    

    tfp->close();
    delete tfp;
    delete tb;
}
