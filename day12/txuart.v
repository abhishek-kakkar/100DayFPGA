`default_nettype    none

module txuart(
    input wire i_clk,

    input wire i_wr,
    input wire [7:0] i_data,

    output reg o_busy,
    output wire o_uart_tx
);
    // 115200 @16 MHz
    parameter   [23:0]  CLOCKS_PER_BAUD = 24'd139;
    reg         [23:0]  counter;
    reg         [3:0]   state;

    reg                 baud_stb;

    reg         [8:0]   lcl_data;

    localparam  [3:0]   START = 4'h0,
        BIT_ZERO              = 4'h1,
        BIT_ONE               = 4'h2,
        BIT_TWO               = 4'h3,
        BIT_THREE             = 4'h4,
        BIT_FOUR              = 4'h5,
        BIT_FIVE              = 4'h6,
        BIT_SIX               = 4'h7,
        BIT_SEVEN             = 4'h8,
        LAST                  = 4'h8,
        IDLE                  = 4'hF;

    initial o_busy = 1'b0;
    initial state = IDLE;
    always @(posedge i_clk)
    if ((i_wr) && (!o_busy))
        { o_busy, state } <= { 1'b1, START };
    else if (baud_stb) begin
        if (state == IDLE)
            { o_busy, state } <= { 1'b0, IDLE };
        else if (state < LAST) begin
            o_busy <= 1'b1;
            state <= state + 1'b1;
        end else
            { o_busy, state } <= { 1'b1, IDLE };
    end

    initial lcl_data = 9'h1FF;
    always @(posedge i_clk)
    if ((i_wr) && (!o_busy))
        lcl_data <= { i_data, 1'b0 };
    else if (baud_stb)
        lcl_data <= { 1'b1, lcl_data[8:1] };

    assign o_uart_tx = lcl_data[0];

    initial baud_stb = 1'b1;
    initial counter = 0;
    always @(posedge i_clk) begin
        if ((i_wr) && (!o_busy)) begin
            counter <= CLOCKS_PER_BAUD - 1'b1;
            baud_stb <= 1'b0;
        end else if (!baud_stb) begin
            baud_stb <= (counter == 24'h01);
            counter <= counter - 1'b1;
        end else if (state != IDLE) begin
            counter <= CLOCKS_PER_BAUD - 1'b1;
            baud_stb <= 1'b0;
        end
    end
endmodule