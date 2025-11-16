// seg7_animator.v (tick counter widened)
`default_nettype none
`ifndef __SEG7_ANIMATOR__
`define __SEG7_ANIMATOR__

module seg7_animator (
    input  wire       clk_i,     // clock input
    input  wire       rst_i,     // active-high reset
    input  wire [0:0] mode_i,    // 0 = flash, 1 = rotate
    output reg  [6:0] seg_o      // 7-seg output {a,b,c,d,e,f,g}
);

    reg [24:0] tick_counter;     // widened: supports up to ~33M
    reg [2:0]  seg_index;
    reg        flash_state;

    always @(posedge clk_i) begin
        if (rst_i) begin
            tick_counter <= 25'd0;
            seg_index    <= 3'd0;
            flash_state  <= 1'b0;
            seg_o        <= 7'b0000000;
        end else begin
            tick_counter <= tick_counter + 25'd1;

            if (tick_counter >= 25'd20_000_000) begin
                tick_counter <= 25'd0;

                if (mode_i == 1'b0) begin
                    // FLASH MODE
                    flash_state <= ~flash_state;
                    seg_o <= flash_state ? 7'b1111111 : 7'b0000000;
                end else begin
                    // ROTATE MODE, include segment g optionally (this rotates a..f)
                    if (seg_index >= 3'd5)
                        seg_index <= 3'd0;
                    else
                        seg_index <= seg_index + 3'd1;

                    case (seg_index)
                        3'd0: seg_o <= 7'b0000001; // a
                        3'd1: seg_o <= 7'b0000010; // b
                        3'd2: seg_o <= 7'b0000100; // c
                        3'd3: seg_o <= 7'b0001000; // d
                        3'd4: seg_o <= 7'b0010000; // e
                        3'd5: seg_o <= 7'b0100000; // f
                        default: seg_o <= 7'b0000000;
                    endcase
                end
            end
        end
    end

endmodule
`endif
`default_nettype wire
