module chaser(
    input   i_clk,
    output  o_led
);
    parameter    WIDTH = 24;

    wire             i_clk;
    reg    [7:0]     o_led;
    reg    [3:0]     state;
    reg    [WIDTH:0] cntr;      // Internal counter for time division
    reg              adv_next;

    initial
    begin
        state = 0;
        o_led = 8'h01;
    end

    always @(posedge i_clk)
    begin
        if (cntr >= 2**WIDTH - 1) begin
            cntr <= 0;
            adv_next <= 1;
        end else begin
            cntr <= cntr + 1;
            adv_next <= 0;
        end
    end

    always @(posedge i_clk)
    begin
        if (adv_next) begin
            if (state >= 4'd14)
                state <= 0;
            else
                state <= state + 1;
        end
        case(state)
            0: o_led <= 8'h01;
            1: o_led <= 8'h02;
            2: o_led <= 8'h04;
            3: o_led <= 8'h08;
            4: o_led <= 8'h10;
            5: o_led <= 8'h20;
            6: o_led <= 8'h40;
            7: o_led <= 8'h80;
            8: o_led <= 8'h40;
            9: o_led <= 8'h20;
           10: o_led <= 8'h10;
           11: o_led <= 8'h08;
           12: o_led <= 8'h04;
           13: o_led <= 8'h02;
           default: o_led <= 'h01;
        endcase
    end
endmodule