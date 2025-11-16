// pwm_generator.v  (fixed wrap at 9)
`default_nettype none
`ifndef __PWM_GENERATOR__
`define __PWM_GENERATOR__

module pwm_generator (
    input wire [3:0]  duty_level_i,   // duty_cycle_level input (0-9)
    input wire        clk_i,          // clock
    input wire        rst_i,          // reset (active-high)
    output wire       pwm_sig_o       // pwm_signal (active-high)
);

reg [3:0] pwm_count;
reg pwm_sig;

always @(posedge clk_i) begin
    if (rst_i) begin
        pwm_count <= 4'd0;
        pwm_sig   <= 1'b0;
    end else begin
        // wrap 0..9 period
        if (pwm_count == 4'd9)
            pwm_count <= 4'd0;
        else
            pwm_count <= pwm_count + 4'd1;

        // compare
        pwm_sig <= (pwm_count < duty_level_i) ? 1'b1 : 1'b0;
    end
end

assign pwm_sig_o = pwm_sig;

endmodule
`endif
`default_nettype wire
