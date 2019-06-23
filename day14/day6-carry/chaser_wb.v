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

    output reg  [5:0]   o_led
);
    parameter WIDTH = 24;

    wire            busy;
    reg     [3:0]   state;

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
    assign o_data = { 28'h0, state };

    assign busy = (state != 0);

    // Clock divider
    always @(posedge i_clk)
    begin
        if (cntr >= 2**WIDTH - 1) begin
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
            state <= 4'h1;
        else if (adv == 1'h1) begin
            if (state >= 4'hB)
                state <= 4'h0;
            else if (state != 0)
                state <= state + 1'h1;
        end

        case (state)
            4'h1: o_led <= 6'h01;
            4'h2: o_led <= 6'h02;
            4'h3: o_led <= 6'h04;
            4'h4: o_led <= 6'h08;
            4'h5: o_led <= 6'h10;
            4'h6: o_led <= 6'h20;
            4'h7: o_led <= 6'h10;
            4'h8: o_led <= 6'h08;
            4'h9: o_led <= 6'h04;
            4'hA: o_led <= 6'h02;
            4'hB: o_led <= 6'h01;
            default: o_led <= 6'h00;
        endcase
    end
endmodule