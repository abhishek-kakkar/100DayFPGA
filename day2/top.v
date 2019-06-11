module top(
    input CLK,
    output LED
);
    wire CLK;
    wire LED;

    blinky #(
        .WIDTH(24)
    ) test (
        .i_clk(CLK),
        .o_led(LED)
    );
endmodule