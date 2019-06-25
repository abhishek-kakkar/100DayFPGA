module counter(
    input wire i_clk,
    input wire i_event,
    input wire i_reset,
    output reg [31:0] o_counter
);
    initial o_counter = 0;
    always @(posedge i_clk)
    if (i_reset)
        o_counter <= 0;
    else if (i_event)
        o_counter <= o_counter + 1'b1;
endmodule