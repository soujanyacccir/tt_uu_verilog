// seg7_animator.v
`default_nettype none
`ifndef __SEG7_ANIMATOR__
`define __SEG7_ANIMATOR__

module seg7_animator (
    input  wire       clk_i,
    input  wire       rst_i,     // active-high
    input  wire [0:0] mode_i,
    output reg  [6:0] seg_o
);

    reg [24:0] tick_counter; // enough for 20_000_000 at 50 MHz
    reg [2:0] seg_index;
    reg flash_state;

    always @(posedge clk_i) begin
        if (rst_i) begin
            tick_counter <= 25'd0;
            seg_index <= 3'd0;
            flash_state <= 1'b0;
            seg_o <= 7'b0000000;
        end else begin
            tick_counter <= tick_counter + 25'd1;
            if (tick_counter >= 25'd20_000_000) begin
                tick_counter <= 25'd0;
                if (mode_i == 1'b0) begin
                    flash_state <= ~flash_state;
                    seg_o <= flash_state ? 7'b1111111 : 7'b0000000;
                end else begin
                    if (seg_index >= 3'd5) seg_index <= 3'd0; else seg_index <= seg_index + 3'd1;
                    case (seg_index)
                        3'd0: seg_o <= 7'b0000001;
                        3'd1: seg_o <= 7'b0000010;
                        3'd2: seg_o <= 7'b0000100;
                        3'd3: seg_o <= 7'b0001000;
                        3'd4: seg_o <= 7'b0010000;
                        3'd5: seg_o <= 7'b0100000;
                        default: seg_o <= 7'b0000000;
                    endcase
                end
            end
        end
    end

endmodule

`endif
`default_nettype wire
