module top(
    input wire CLK,

    output wire LED,
    output wire PIN_1,
    output wire PIN_2,
    output wire PIN_3,
    output wire PIN_4,
    output wire PIN_5,
    output wire PIN_6,
    output wire PIN_7,
    output wire PIN_8,
    
    input wire PIN_9
);

    driver mydriver(
        .i_clk(CLK),
        .led({PIN_6, PIN_5, PIN_4, PIN_3, PIN_2, PIN_1}),
        .sw(!PIN_9)
    );

    assign {LED, PIN_7, PIN_8} = 3'b0;
endmodule