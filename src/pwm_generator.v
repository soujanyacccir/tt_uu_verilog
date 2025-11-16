/*
 * Copyright (c) 2025 Michael Pichler
 * SPDX-License-Identifier: Apache-2.0
 */

/*
	Generates a PWM-Signal with dutycycle between 0 and 1 (10 steps --> 0, 0.111, 0.222, ..., 0.888, 1) 
*/


`default_nettype none
`ifndef __PWM_GENERATOR__
`define __PWM_GENERATOR__


module pwm_generator (
    input wire [3:0] 	duty_level_i,   // duty_cycle_level input (0-9)
    input wire		    clk_i,			// clock
	input wire		    rst_i,			// reset 
    output wire       	pwm_sig_o       // pwm_signal
);

reg [3:0] pwm_count;
reg pwm_sig;

    always @(posedge clk_i) begin
       if (rst_i == 1'b1 || pwm_count >= 8) begin		// reset the pwm-period if reset is active or end of period is reached
        pwm_count <= {4'b0}; 							// reset the counter value
      end else if (pwm_count < 4'd9) begin
        //increment the counter value by 1
        pwm_count <= pwm_count + 4'b0001; 				// increase value by 1
      end
      if (pwm_count >= duty_level_i) begin          	// pwm low when pwm_cont is lower than duty_cycle_level (0..9)
        pwm_sig <= 0;
      end else begin                          			// pwm high when pwm_count is higher
        pwm_sig <= 1;
      end
    end

    assign pwm_sig_o = pwm_sig; 
endmodule

`endif
`default_nettype wire
