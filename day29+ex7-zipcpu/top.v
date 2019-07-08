`default_nettype none

module top(
    input wire CLK,

    output wire PIN_1,
    output wire PIN_2,
    output wire PIN_3,
    output wire PIN_4,
    output wire PIN_5,
    output wire PIN_6,
    output wire PIN_7,
    output wire PIN_8,
    input wire PIN_9,

    inout USBN,
    inout USBP,
    output USBPU

);
`define USB_UART 1

    assign USBPU = 1'b1;

    wire clk_48mhz;
    wire clk_locked;

    pll pll48( .clock_in(CLK), .clock_out(clk_48mhz), .locked( clk_locked ) );

    reg [5:0] reset_cnt = 0;
    wire reset = ~reset_cnt[5];
    always @(posedge clk_48mhz)
        if ( clk_locked )
            reset_cnt <= reset_cnt + {5'b0, reset};
    
    wire uart_tx;

    thedesign mydesign(
        .i_clk(CLK),
        .i_clk48(clk_48mhz),
        .i_reset(reset),
        .i_event(!PIN_9),
        .usb_p(USBP),
        .usb_n(USBN),
        .o_uart_tx(uart_tx),
        .o_debug({PIN_8, PIN_7, PIN_6, PIN_5, PIN_4, PIN_3, PIN_2, PIN_1}),
    );
endmodule