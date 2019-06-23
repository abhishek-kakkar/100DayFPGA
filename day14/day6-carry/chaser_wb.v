module chaser_wb(
    input wire          i_clk,

    input wire          i_cyc,
    input wire          i_stb,
    input wire          i_we,
    input wire          i_addr,
    input wire [31:0]   i_data,
    output wire         o_stall,
    output reg          o_ack,
    output wire [31:0]  o_data,

    output reg  [7:0]   o_led
);
    parameter WIDTH = 24;

    wire            busy;
    reg     [4:0]   state;

    // For clock divider
    reg     [WIDTH-1:0] cntr;
    reg                 adv;
    
    initial state = 0;

    // Verilator lint_off UNUSED
    wire [33:0] unused;
    assign unused = { i_cyc, i_addr, i_data };
    // Verilator lint_on UNUSED

    initial o_ack = 1'b0;
    always @(posedge i_clk)
        o_ack <= (i_stb) && (!o_stall);
    
    assign o_stall = (busy) && (i_we);
    assign o_data = { 27'h0, state };

    assign busy = (state != 0);

    // Clock divider
    always @(posedge i_clk)
    begin
        if ((i_stb) && (i_we) && (!o_stall))
            cntr <= 0;
        else if (cntr >= 2**WIDTH - 1) begin
            cntr <= 0;
            adv <= 1;
        end else begin
            cntr <= cntr + 1;
            adv <= 0;
        end
    end

    always @(posedge i_clk)
    begin
        if ((i_stb) && (i_we) && (!o_stall))
            state <= 5'h1;
        else if (adv == 1'h1) begin
            if (state >= 5'hF)
                state <= 5'h0;
            else if (state != 0)
                state <= state + 1'h1;
        end

        case (state)
            5'h1: o_led <= 8'h01;
            5'h2: o_led <= 8'h02;
            5'h3: o_led <= 8'h04;
            5'h4: o_led <= 8'h08;
            5'h5: o_led <= 8'h10;
            5'h6: o_led <= 8'h20;
            5'h7: o_led <= 8'h40;
            5'h8: o_led <= 8'h80;
            5'h9: o_led <= 8'h40;
            5'hA: o_led <= 8'h20;
            5'hB: o_led <= 8'h10;
            5'hC: o_led <= 8'h08;
            5'hD: o_led <= 8'h04;
            5'hE: o_led <= 8'h02;
            5'hF: o_led <= 8'h01;
            default: o_led <= 8'h00;
        endcase
    end
endmodule