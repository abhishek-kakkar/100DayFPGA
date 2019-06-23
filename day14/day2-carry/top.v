module top(
    input wire CLK,
    output wire PIN_1,
    output wire PIN_2,
    output wire PIN_3,
    output wire PIN_4,
    output wire PIN_5,
    output wire PIN_6,
    output wire PIN_7,
    output wire PIN_8
);
    blinky #(
        .WIDTH(24)
    ) test (
        .i_clk(CLK),
        .o_led(PIN_2)
    );

    assign {PIN_1, PIN_3, PIN_4, PIN_5, PIN_6, PIN_7, PIN_8} = 7'b0;
endmodule