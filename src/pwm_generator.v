// pwm_generator.v
`default_nettype none
`ifndef __PWM_GENERATOR__
`define __PWM_GENERATOR__

module pwm_generator (
    input wire [3:0]  duty_level_i,
    input wire        clk_i,
    input wire        rst_i,      // active-high
    output wire       pwm_sig_o
);

reg [3:0] pwm_count;
reg pwm_sig;

always @(posedge clk_i) begin
    if (rst_i) begin
        pwm_count <= 4'd0;
        pwm_sig   <= 1'b0;
    end else begin
        if (pwm_count == 4'd9)
            pwm_count <= 4'd0;
        else
            pwm_count <= pwm_count + 4'd1;

        pwm_sig <= (pwm_count < duty_level_i) ? 1'b1 : 1'b0;
    end
end

assign pwm_sig_o = pwm_sig;

endmodule
`endif
`default_nettype wire
