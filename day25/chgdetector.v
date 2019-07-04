module chgdetector(
    input wire i_clk,
    input reg [31:0] i_data,
    input wire i_busy,
    output reg o_stb,
    output reg [31:0] o_data
);
    initial {o_stb, o_data} = 0;
    always @(posedge i_clk)
    if (!i_busy) begin
        o_stb <= 0;
        if (o_data != i_data) begin
            o_stb <= 1'b1;
            o_data <= i_data;
        end
    end
endmodule