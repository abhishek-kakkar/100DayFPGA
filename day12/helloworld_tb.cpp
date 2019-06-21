#include <Vhelloworld.h>
#include "uartsim.h"
#include "testb.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    TESTB<Vhelloworld> *tb = new TESTB<Vhelloworld>;
    UARTSIM *uart = new UARTSIM();
    unsigned int baudclocks;

    baudclocks = tb->m_core->o_setup;
    uart->setup(baudclocks);

    tb->opentrace("helloworld.vcd");

    for (int clocks=0; clocks<16*32*baudclocks; clocks++) {
        tb->tick();
        (*uart)(tb->m_core->o_uart_tx);
    }

    printf("\nSimulation Complete!\n");
}
