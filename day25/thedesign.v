// Recreated from ZipCPU tutorial 6 - txdata

`default_nettype none

`ifdef SYNTHESIS
    `define USB_UART
`endif

module thedesign(
    input wire i_clk,
    input wire i_reset,
    input wire i_event,
`ifdef VERILATOR
    output wire [31:0] o_setup,
`endif

`ifdef USB_UART
    input wire i_clk48,

    inout wire usb_p,
    inout wire usb_n,
`endif
    output wire o_uart_tx,
    output wire [7:0] o_debug
);
    wire tx_stb, tx_busy;
    wire [31:0] counter, tx_data;

    parameter CLOCK_RATE_HZ = 16_000_000;
    parameter BAUD_RATE = 115200;
    parameter UART_SETUP = CLOCK_RATE_HZ / BAUD_RATE;

`ifdef VERILATOR
    assign o_setup = UART_SETUP;
`endif

    counter mycounter(
        .i_clk(i_clk),
        .i_event(i_event),
        .i_busy(0),
        .i_reset(i_reset),
        .o_counter(counter)
    );

    chgdetector mychgdetector(
        .i_clk(i_clk),
        .i_data(counter),
        .i_busy(tx_busy),
        .o_stb(tx_stb),
        .o_data(tx_data)
    );

    txdata #(
        .UART_SETUP(UART_SETUP[23:0])
    ) myuart (
        .i_clk(i_clk),
        .i_stb(tx_stb),
        .i_data(tx_data),
        .i_reset(i_reset),
        .o_busy(tx_busy),
        .o_uart_tx(o_uart_tx),
        .o_debug(o_debug),
    `ifdef USB_UART
        .i_clk48(i_clk48),
        .usb_n(usb_n),
        .usb_p(usb_p)
    `endif
    );
endmodule