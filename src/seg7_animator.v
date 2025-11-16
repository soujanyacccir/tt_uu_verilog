/*
 * Copyright (c) 2025 Michael Pichler
 * SPDX-License-Identifier: Apache-2.0
 */


/*
	 This module makes the LEDs of a 7-segment display flash or rotate.
   Modes:
   mode_i = 0 → Flash (all on/off)
   mode_i = 1 → Rotate (chase segment animation)
*/

`default_nettype none
`ifndef __SEG7_ANIMATOR__
`define __SEG7_ANIMATOR__

module seg7_animator (
    input  wire       clk_i,     // clock input
    input  wire       rst_i,     // active-high reset
    input  wire [0:0] mode_i,    // 0 = flash, 1 = rotate
    output reg  [6:0] seg_o      // 7-segment output
);

	reg [14:0] tick_counter;     // for timing
    reg [2:0]  seg_index;        // which segment is active in rotation mode
    reg        flash_state;      // toggle state for flashing

    always @(posedge clk_i) begin
        if (rst_i) begin
            tick_counter <= 0;
            seg_index    <= 0;
            flash_state  <= 0;
            seg_o        <= 7'b0000000;
        end else begin
            // create a slow tick
            tick_counter <= tick_counter + 1;

			if (tick_counter == 15'd20_000_000) begin //flash every 0.4 s at f_clk = 50MHz 
                tick_counter <= 0;

                if (mode_i == 1'b0) begin
                    // FLASH MODE
                    flash_state <= ~flash_state;
                    seg_o <= flash_state ? 7'b1111111 : 7'b0000000;
                end else begin
                    // ROTATE MODE
                    if (seg_index >= 3'd5) begin
                        seg_index <= 3'd0;       // Reset back to 0 after reaching 5
                    end else begin
                      seg_index <= seg_index + 1;
                    end

                    case (seg_index)
                        3'd0: seg_o <= 7'b0000001; // segment a
                        3'd1: seg_o <= 7'b0000010; // segment b
                        3'd2: seg_o <= 7'b0000100; // segment c
                        3'd3: seg_o <= 7'b0001000; // segment d
                        3'd4: seg_o <= 7'b0010000; // segment e
                        3'd5: seg_o <= 7'b0100000; // segment f
                        default: seg_o <= 7'b0000000;
                    endcase
                end
            end
        end
    end

endmodule

`endif
`default_nettype wire

