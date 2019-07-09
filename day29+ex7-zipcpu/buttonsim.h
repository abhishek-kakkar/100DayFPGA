// Recreated from ZipCPU example

#ifndef _BUTTONSIM_H
#define _BUTTONSIM_H

#define TIME_PERIOD 50000

class BUTTONSIM
{
private:
    int m_state, m_timeout;
public:
    BUTTONSIM()
    {
        m_state = 0;
        m_timeout = 0; 
    }

    void press(void)
    {
        m_state = 1;
        m_timeout = TIME_PERIOD;
    }

    bool pressed(void)
    {
        return m_state;
    }

    void release(void) {
        m_state = 0;
        m_timeout = TIME_PERIOD;
    }

    int operator ()(void) {
        if (m_timeout > 0)
            m_timeout--;
        if (m_timeout == TIME_PERIOD - 1) {
            return m_state;
        } else if (m_timeout > 0) {
            return rand() & 1;
        }
        return m_state;
    }
};
#endif