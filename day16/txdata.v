module txdata(
    input wire i_clk,
    input wire i_stb,
    input reg [31:0] i_data,

    output wire o_busy,
    output reg o_uart_tx
);
    parameter UART_SETUP = 24'd139;

    reg tx_stb;
    reg [7:0] tx_data;
    wire tx_busy;

    reg [3:0] state;
    reg [31:0] sreg;
    reg [7:0] hex;

    txuart #(UART_SETUP[23:0]) txuart_i(
        .i_clk(i_clk),
        .i_wr(tx_stb),
        .i_data(tx_data),
        .o_uart_tx(o_uart_tx),
        .o_busy(tx_busy)
    );

    initial state = 0;
    initial tx_stb = 1'b0;
    always @(posedge i_clk) begin
        if (!o_busy) begin
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

    assign o_busy = (state != 0);

    initial sreg = 0;
    always @(posedge i_clk)
    if (!o_busy)
        sreg <= i_data;
    else if (!(tx_busy) && (state > 4'h1))
        sreg <= {i_data[27:0], 4'h0};

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
        default: tx_data <= "Q";
        endcase

    


endmodule