`default_nettype    none

module helloworld(
    input wire i_clk,
`ifdef VERILATOR
    output wire [31:0] o_setup,
`endif
    output wire o_uart_tx
);
    parameter CLOCK_RATE_HZ = 16000000;
    parameter BAUD_RATE = 115200;

    parameter INITIAL_UART_SETUP = (CLOCK_RATE_HZ / BAUD_RATE);

    reg     [7:0]   tx_data;
    wire            tx_busy;
    reg             tx_stb;
    reg     [3:0]   tx_index;

    reg      [27:0] hz_counter;
    reg             tx_restart;

`ifdef VERILATOR
    assign o_setup = INITIAL_UART_SETUP;
`endif

    txuart #(
        .CLOCKS_PER_BAUD(INITIAL_UART_SETUP[23:0])
    ) mytxuart (
        .i_clk(i_clk),
        .i_wr(tx_stb),
        .i_data(tx_data),
        .o_busy(tx_busy),
        .o_uart_tx(o_uart_tx)
    );

    initial tx_stb = 1'b0;
    always @(posedge i_clk)
    if (tx_restart)
        tx_stb <= 1'b1;
    else if ((tx_stb) && (!tx_busy) && (tx_index == 4'hF))
        tx_stb <= 1'b0;

    initial hz_counter = 28'h16; 
    always @(posedge i_clk)
    if (hz_counter == 0)
        hz_counter <= CLOCK_RATE_HZ - 1'b1;
    else
        hz_counter <= hz_counter - 1'b1;

    initial tx_restart = 0;
    always @(posedge i_clk)
        tx_restart <= (hz_counter == 1);

    initial tx_index = 4'h0;
    always @(posedge i_clk)
    if ((tx_stb) && (!tx_busy))
        tx_index <= tx_index + 1;

    always @(posedge i_clk)
    case(tx_index)
    4'h0: tx_data <= "H";
    4'h1: tx_data <= "e";
    4'h2: tx_data <= "l";
    4'h3: tx_data <= "l";
    4'h4: tx_data <= "o";
    4'h5: tx_data <= ",";
    4'h6: tx_data <= " ";
    4'h7: tx_data <= "W";
    4'h8: tx_data <= "o";
    4'h9: tx_data <= "r";
    4'hA: tx_data <= "l";
    4'hB: tx_data <= "d";
    4'hC: tx_data <= "!";
    4'hD: tx_data <= " ";
    4'hE: tx_data <= "\r";
    4'hF: tx_data <= "\n";
    endcase

`ifdef	FORMAL
	reg	f_past_valid;
	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	always @(*)
	if ((tx_stb)&&(!tx_busy))
	begin
		case(tx_index)
		4'h0: assert(tx_data <= "H");
		4'h1: assert(tx_data <= "e");
		4'h2: assert(tx_data <= "l");
		4'h3: assert(tx_data <= "l");
		//
		4'h4: assert(tx_data <= "o");
		4'h5: assert(tx_data <= ",");
		4'h6: assert(tx_data <= " ");
		4'h7: assert(tx_data <= "W");
		//
		4'h8: assert(tx_data <= "o");
		4'h9: assert(tx_data <= "r");
		4'ha: assert(tx_data <= "l");
		4'hb: assert(tx_data <= "d");
		//
		4'hc: assert(tx_data <= "!");
		4'hd: assert(tx_data <= " ");
		4'he: assert(tx_data <= "\r");
		4'hf: assert(tx_data <= "\n");
		//
		endcase
	end

	always @(posedge i_clk)
	if ((f_past_valid)&&($changed(tx_index)))
		assert(($past(tx_stb))&&(!$past(tx_busy))
				&&(tx_index == $past(tx_index)+1));
	else if (f_past_valid)
		assert(($stable(tx_index))
				&&((!$past(tx_stb))||($past(tx_busy))));

	always @(posedge i_clk)
	if (tx_index != 4'h0)
		assert(tx_stb);

`endif

endmodule