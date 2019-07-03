// Recreated from the 6th ZipCPU tutorial

`default_nettype	none

module txdata(
    input wire i_clk,
    input wire i_stb,
    input wire [31:0] i_data,
    input wire i_reset,

    output wire o_busy,
    output wire o_uart_tx
);
    parameter UART_SETUP = 24'd139;

    reg tx_stb;
    reg [7:0] tx_data;
    wire tx_busy;

    reg [3:0] state;
    reg [31:0] sreg;
    reg [7:0] hex;

`ifndef FORMAL
    txuart #(UART_SETUP[23:0]) txuart_i(
        .i_clk(i_clk),
        .i_wr(tx_stb),
        .i_data(tx_data),
        .o_uart_tx(o_uart_tx),
        .o_busy(tx_busy)
    );
`else
    (* anyseq *) wire serial_busy, serial_out;
    assign	o_uart_tx = serial_out;
    assign	tx_busy = serial_busy;
`endif

    initial state = 0;
    initial tx_stb = 1'b0;
    always @(posedge i_clk) begin
        if (i_reset) begin
            state <= 0;
            tx_stb <= 0;
        end else if (!o_busy) begin
            if (i_stb) begin
                state <= 1;
                tx_stb <= 1;
            end
        end else if ((tx_stb)&&(!tx_busy)) begin
            state <= state + 1;
            if (state >= 4'hD) begin
                tx_stb <= 1'b0;
                state <= 0;
            end
        end
    end

    assign o_busy = tx_stb | tx_busy;

    initial sreg = 0;
    always @(posedge i_clk)
    if (!o_busy)
        sreg <= i_data;
    else if (!(tx_busy) && (state > 4'h2))
        sreg <= {sreg[27:0], 4'h0};

    always @(posedge i_clk)
    case (sreg[31:28])
    4'h0: hex <= "0";
    4'h1: hex <= "1";
    4'h2: hex <= "2";
    4'h3: hex <= "3";
    4'h4: hex <= "4";
    4'h5: hex <= "5";
    4'h6: hex <= "6";
    4'h7: hex <= "7";
    4'h8: hex <= "8";
    4'h9: hex <= "9";
    4'hA: hex <= "A";
    4'hB: hex <= "B";
    4'hC: hex <= "C";
    4'hD: hex <= "D";
    4'hE: hex <= "E";
    4'hF: hex <= "F";
    endcase

    always @(posedge i_clk)
    if (!tx_busy)
        case (state)
        4'h1: tx_data <= "0";
        4'h2: tx_data <= "x";
        4'h3: tx_data <= hex;
        4'h4: tx_data <= hex;
        4'h5: tx_data <= hex;
        4'h6: tx_data <= hex;
        4'h7: tx_data <= hex;
        4'h8: tx_data <= hex;
        4'h9: tx_data <= hex;
        4'hA: tx_data <= hex;
        4'hB: tx_data <= "\r";
        4'hC: tx_data <= "\n";
        default: tx_data <= "0";
        endcase

`ifdef	FORMAL
    initial	assume(i_reset);

    reg	f_past_valid;
    initial	f_past_valid = 1'b0;
    always @(posedge i_clk)
        f_past_valid = 1'b1;

    //
    // Make some assumptions about tx_busy
    //
    // it needs to become busy upon a request given to it
    // but not before.  Upon a request, it needs to stay
    // busy for a minimum period of time
    initial	assume(!tx_busy);
    always @(posedge i_clk)
    if ($past(i_reset))
        assume(!tx_busy);
    else if (($past(tx_stb))&&(!$past(tx_busy)))
        assume(tx_busy);
    else if (!$past(tx_busy))
        assume(!tx_busy);

    reg	[1:0]	f_minbusy;
    initial	f_minbusy = 0;
    always @(posedge i_clk)
    if ((tx_stb)&&(!tx_busy))
        f_minbusy <= 2'b01;
    else if (f_minbusy != 2'b00)
        f_minbusy <= f_minbusy + 1'b1;

    always @(*)
    if (f_minbusy != 0)
        assume(tx_busy);


    //
    // Some cover statements
    //
    // You should be able to "see" your design working from these
    // If not ... modify them until you can.
    //
    // always @(posedge i_clk)
    // if (f_past_valid)
    //     cover($fell(o_busy));

    // always @(posedge i_clk)
    // if ((f_past_valid)&&(!$past(i_reset)))
    //     cover($fell(o_busy));

    // always @(posedge i_clk)
    // if ((f_past_valid)&&(i_stb))
    //     cover($rose(i));
    reg f_seen_data;
    initial f_seen_data = 0;
    always @(posedge i_clk) 
    if (i_reset)
        f_seen_data <= 0;
    else if ((i_stb) && !(o_busy) && (i_data == 32'h12345678))
        f_seen_data <= 1;

    always @(posedge i_clk)
    if ((f_past_valid)&&(!$past(i_reset)) && f_seen_data)
        cover($fell(o_busy));

    //
    // Some assertions about our sequence of states
    //
    reg	[15:0]	p1reg;
    initial	p1reg = 0;
    reg [31:0] fv_data;

    always @(*) begin
        assert(tx_stb != (state == 0));
        assert(state >= 0 && state <= 4'hD);
    end

    always @(posedge i_clk)
    if (i_reset)
        p1reg <= 0;
    else if ((i_stb)&&(!o_busy)&&(!tx_busy))
    begin
        p1reg <= 1;
        fv_data <= i_data;
        assert(p1reg[11:0] == 0);
    end else if (p1reg) begin
        if (p1reg != 1)
            assert($stable(fv_data));
        if (!tx_busy)
            p1reg <= { p1reg[11:0], 1'b0 };
        if ((!tx_busy)||(f_minbusy==0))
        begin
            if (p1reg[0])
            begin
                assert((tx_data == "0")&&(state == 1));
                assert((sreg == fv_data));
            end
            if (p1reg[1])
            begin
                assert((tx_data == "0")&&(state == 2));
                assert((sreg == fv_data));
            end
            if (p1reg[2])
            begin
                assert((tx_data == "x")&&(state == 3));
                assert((sreg == fv_data));
            end
            if (p1reg[3])
            begin
                if (fv_data[31:28] > 9)
                    assert((tx_data == "A" + fv_data[31:28] - 10)&&(state == 4));
                else
                    assert((tx_data == "0" + fv_data[31:28])&&(state == 4));
                assert((sreg == {fv_data[27:0], 4'h0}));
            end
            if (p1reg[4])
            begin
                if (fv_data[27:24] > 9)
                    assert((tx_data == "A" + fv_data[27:24] - 10)&&(state == 5));
                else
                    assert((tx_data == "0" + fv_data[27:24])&&(state == 5));
                assert((sreg == {fv_data[23:0], 8'h0}));
            end
            if (p1reg[5])
            begin
                if (fv_data[23:20] > 9)
                    assert((tx_data == "A" + fv_data[23:20] - 10)&&(state == 6));
                else
                    assert((tx_data == "0" + fv_data[23:20])&&(state == 6));
                assert((sreg == {fv_data[19:0], 12'h0}));
            end
            if (p1reg[6])
            begin
                if (fv_data[19:16] > 9)
                    assert((tx_data == "A" + fv_data[19:16] - 10)&&(state == 7));
                else
                    assert((tx_data == "0" + fv_data[19:16])&&(state == 7));
                assert((sreg == {fv_data[15:0], 16'h0}));
            end
            if (p1reg[7])
            begin
                if (fv_data[15:12] > 9)
                    assert((tx_data == "A" + fv_data[15:12] - 10)&&(state == 8));
                else
                    assert((tx_data == "0" + fv_data[15:12])&&(state == 8));  
                assert((sreg == {fv_data[11:0], 20'h0}));
            end
            if (p1reg[8])
            begin
                if (fv_data[11:8] > 9)
                    assert((tx_data == "A" + fv_data[11:8] - 10)&&(state == 9));
                else
                    assert((tx_data == "0" + fv_data[11:8])&&(state == 9));
                assert((sreg == {fv_data[7:0], 24'h0}));
            end
            if (p1reg[9])
            begin
                if (fv_data[7:4] > 9)
                    assert((tx_data == "A" + fv_data[7:4] - 10)&&(state == 10));
                else
                    assert((tx_data == "0" + fv_data[7:4])&&(state == 10));  
                assert((sreg ==  {fv_data[3:0], 28'h0}));
            end
            if (p1reg[10])
            begin
                if (fv_data[3:0] > 9)
                    assert((tx_data == "A" + fv_data[3:0] - 10)&&(state == 11));
                else
                    assert((tx_data == "0" + fv_data[3:0])&&(state == 11));
                assert((sreg == 32'h0));
            end
            if (p1reg[11])
            begin
                assert((tx_data == "\r")&&(state == 12));
            end
            if (p1reg[12])
            begin
                assert((tx_data == "\n")&&(state == 13));
            end
            assert(p1reg <= 13'b1000000000000);
        end
    end else
        assert(state == 0);

`endif
endmodule