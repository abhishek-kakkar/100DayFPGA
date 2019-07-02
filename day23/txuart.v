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

`ifdef	FORMAL

`ifdef	TXUART
`define	ASSUME	assume
`else
`define	ASSUME	assert
`endif

	// Setup

	reg	f_past_valid;

	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	// Any outstanding request that was busy on the last cycle,
	// should remain busy on this cycle
	initial	`ASSUME(!i_wr);
	always @(posedge i_clk)
		if ((f_past_valid)&&($past(i_wr))&&($past(o_busy)))
		begin
			`ASSUME(i_wr   == $past(i_wr));
			`ASSUME(i_data == $past(i_data));
		end

	//////////////////////////////////
	//
	// The contract
	//
	//////////////////////////////////

	reg	[7:0]	fv_data;
	always @(posedge i_clk)
	if ((i_wr)&&(!o_busy))
		fv_data <= i_data;

	always @(posedge i_clk)
	case(state)
	IDLE:		assert(o_uart_tx == 1'b1);
	START:		assert(o_uart_tx == 1'b0);
	BIT_ZERO:	assert(o_uart_tx == fv_data[0]);
	BIT_ONE:	assert(o_uart_tx == fv_data[1]);
	BIT_TWO:	assert(o_uart_tx == fv_data[2]);
	BIT_THREE:	assert(o_uart_tx == fv_data[3]);
	BIT_FOUR:	assert(o_uart_tx == fv_data[4]);
	BIT_FIVE:	assert(o_uart_tx == fv_data[5]);
	BIT_SIX:	assert(o_uart_tx == fv_data[6]);
	BIT_SEVEN:	assert(o_uart_tx == fv_data[7]);
	9 : assert(0);
    10 : assert(0);
    11 : assert(0);
    12 : assert(0);
    13 : assert(0);
    14 : assert(0);
	endcase

	//////////////////////////////////
	//
	// Internal state checks
	//
	//////////////////////////////////
    always @(*)
    case(state)
    IDLE:		assert(lcl_data == 9'h1FF);
	START:		assert(lcl_data == {fv_data[7:0], 1'b0});
	BIT_ZERO:	assert(lcl_data == {1'b1, fv_data[7:0]});
	BIT_ONE:	assert(lcl_data == {2'b11, fv_data[7:1]});
	BIT_TWO:	assert(lcl_data == {3'b111, fv_data[7:2]});
	BIT_THREE:	assert(lcl_data == {4'b1111, fv_data[7:3]});
	BIT_FOUR:	assert(lcl_data == {5'b11111, fv_data[7:4]});
	BIT_FIVE:	assert(lcl_data == {6'b111111, fv_data[7:5]});
	BIT_SIX:	assert(lcl_data == {7'b1111111, fv_data[7:6]});
	BIT_SEVEN:	assert(lcl_data == {8'b11111111, fv_data[7:7]});
    9 : assert(0);
    10 : assert(0);
    11 : assert(0);
    12 : assert(0);
    13 : assert(0);
    14 : assert(0);
    endcase

	//
	// Check the baud counter
	//

	// The baud_stb needs to be identical to our counter being zero
	always @(posedge i_clk)
		assert(baud_stb == (counter == 0));


	always @(posedge i_clk)
	if ((f_past_valid)&&($past(counter != 0)))
		assert(counter == $past(counter - 1'b1));

	always @(posedge i_clk)
		assert(counter < CLOCKS_PER_BAUD);

	always @(posedge i_clk)
	if (!baud_stb)
		assert(o_busy);

    always @(posedge i_clk)
	if (state != IDLE)
		assert(o_busy);

`endif	// FORMAL
endmodule