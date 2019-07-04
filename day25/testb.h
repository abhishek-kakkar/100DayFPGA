/*
 * testb.h - Common header for simulated modules
 * Recreated from ZipCPU example #5 created by Dan Gisselquist
 */
#ifndef _TEST_B_H
#define _TEST_B_H

#include <stdio.h>
#include <stdint.h>
#include <verilated_vcd_c.h>

template <class VA> class TESTB {
public:
    VA              *m_core;
    VerilatedVcdC   *m_trace;
    uint64_t         m_tickcount;

    TESTB(void) : m_trace(NULL),
                  m_tickcount(0L) {
        m_core = new VA;
        Verilated::traceEverOn(true);
        m_core->i_clk = 0;
        eval();
    }

    virtual void eval(void) {
        m_core->eval();
    }

    virtual void tick(void) {
        m_tickcount++;

        eval();
        if (m_trace) m_trace->dump((vluint64_t)(10*m_tickcount-2));
        m_core->i_clk = 1;
        eval();
        if (m_trace) m_trace->dump((vluint64_t)(10*m_tickcount));
        m_core->i_clk = 0;
        eval();
        if (m_trace) {
            m_trace->dump((vluint64_t)(10*m_tickcount+5));
            m_trace->flush();
        }
    }

    virtual void opentrace(const char *vcdname) {
        m_trace = new VerilatedVcdC;
        m_core->trace(m_trace, 99);
        m_trace->open(vcdname);
    }

    virtual void closetrace(void) {
        if (m_trace) {
            m_trace->close();
            delete m_trace;
            m_trace = NULL; 
        }
    }

    uint64_t tickcount(void) {
		return m_tickcount;
	}

    virtual ~TESTB(void) {
        closetrace();
        delete m_core;
        m_core = NULL;
    }
};

#endif  // _TEST_B_H