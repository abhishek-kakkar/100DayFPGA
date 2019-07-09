// Recreated from ZipCPU tutorial 6 - txdata

`default_nettype none

`ifdef SYNTHESIS
    `define USB_UART
`endif

module thedesign(
    input wire i_clk,
    input wire i_reset,
    input wire i_btn,
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
    wire tx_stb, tx_busy, debounced;
    reg btn_event, last_debounced;
    wire [31:0] counter, tx_data;

    parameter CLOCK_RATE_HZ = 16_000_000;
    parameter BAUD_RATE = 115200;
    parameter UART_SETUP = CLOCK_RATE_HZ / BAUD_RATE;

`ifdef VERILATOR
    assign o_setup = UART_SETUP;
`endif

    debouncer mydebouncer(
        .i_clk(i_clk),
        .i_btn(i_btn),
        .o_debounced(debounced)
    );

    initial last_debounced = 0;
    always @(posedge i_clk)
        last_debounced <= debounced;

    initial btn_event = 0;
    always @(posedge i_clk)
        btn_event <= (debounced && !last_debounced);

    counter mycounter(
        .i_clk(i_clk),
        .i_event(btn_event),
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
        .o_uart_tx(o_uart_tx),
        .o_busy(tx_busy),
    `ifdef USB_UART
        .i_clk48(i_clk48),
        .usb_n(usb_n),
        .usb_p(usb_p),
    `endif
        .o_debug(o_debug)
    );
endmodule