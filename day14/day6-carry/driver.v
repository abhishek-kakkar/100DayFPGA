module driver(
    input wire i_clk,
    output wire [7:0] led,
    input wire sw
);
    chaser_wb #(
        .WIDTH(21)
    ) mychaser (
        .i_clk(i_clk),
        .o_led(led),
        .i_stb(sw),
        .i_we(1)
    );
endmodule