module blinky(i_clk, o_led);
    input wire  i_clk;
    output wire o_led;
    parameter   WIDTH = 27;

    reg [WIDTH-1:0] counter;

    initial begin
        counter = 0;
    end

    always @(posedge i_clk)
    begin
        counter <= counter + 1'b1;
    end

    assign o_led = counter[WIDTH-1];
endmodule