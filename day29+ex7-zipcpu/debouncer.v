`default_nettype	none
module debouncer(
    input wire i_clk,
    input wire i_btn,
    output reg o_debounced
);
    parameter TIME_PERIOD = 75000;

    reg r_btn, r_aux;
    reg [16:0] timer;

    // 2FF sync
    initial { r_btn, r_aux } = 2'b00;
    always @(posedge i_clk)
        {r_btn, r_aux} <= {r_aux, i_btn};
    
    initial timer = 0;
    always @(posedge i_clk)
    if (timer != 0)
        timer <= timer - 1;
    else if (r_btn != o_debounced) begin
        timer <= TIME_PERIOD - 1;
        o_debounced <= r_btn;
    end
    
    initial o_debounced = 0;
    always @(posedge i_clk)
    if (timer == 0)
        o_debounced <= r_btn;
endmodule