////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	thedesign_tb.cpp
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	To demonstrate a Verilator main() program that calls a local
//		serial port co-simulator.  This particular version also
//	demonstrates how an external event can be created within Verilator
//	by using the ncurses environment.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Written and distributed by Gisselquist Technology, LLC
//
// This program is hereby granted to the public domain.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.
//
////////////////////////////////////////////////////////////////////////////////
//
//
#include <verilatedos.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <signal.h>
#include <ncurses.h>
#include "verilated.h"
#include "Vthedesign.h"
#include "testb.h"
#include "uartsim.h"

#define	KEY_ESCAPE	27
#define	CTRL(X)		((X)&0x01f)

#ifdef	OLD_VERILATOR
#define	VVAR(A)	v__DOT_ ## A
#else
#define	VVAR(A)	thedesign__DOT_ ## A
#endif

#define	counterv	VVAR(_counter)

int	main(int argc, char **argv) {
	Verilated::commandArgs(argc, argv);
	TESTB<Vthedesign>	*tb
		= new TESTB<Vthedesign>;
	UARTSIM		*uart;
	unsigned	baudclocks;


	uart = new UARTSIM();
	baudclocks = tb->m_core->o_setup;
	uart->setup(baudclocks);

	tb->opentrace("thedesign.vcd");

	initscr();
	raw();
	noecho();
	keypad(stdscr, true);
	halfdelay(1);

	bool	done = false;
	unsigned	keypresses = 0;

	do {
		int	chv;

		done = false;
		tb->m_core->i_event = 0;

		chv = getch();
		if (chv == KEY_ESCAPE)
			done = true;
		else if (chv == CTRL('C'))
			done = true;
		else if (chv != ERR)
			tb->m_core->i_event = 1;

		for(int k=0; k<1500; k++) {
			tb->tick();
			(*uart)(tb->m_core->o_uart_tx);
			keypresses += tb->m_core->i_event;
			tb->m_core->i_event = 0;
		}
	} while(!done);

	endwin();

	printf("\n\nSimulation complete\n");
	printf("%4d key presses sent\n", keypresses);
	printf("%4d key presses registered\n", tb->m_core->counterv);
}
