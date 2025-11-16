// gpio_reg.v
`default_nettype none
module gpio_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        mem_valid,
    input  wire [31:0] mem_addr,
    input  wire [31:0] mem_wdata,
    input  wire [3:0]  mem_wstrb,
    output reg  [31:0] mem_rdata,
    output reg         mem_ready,
    input  wire [1:0]  btns,
    output wire [3:0]  pwm_duty_reg,
    output wire [3:0]  display_val_reg,
    output wire [1:0]  anim_reg
);

    reg [3:0] pwm_reg;
    reg [3:0] disp_reg;
    reg [1:0] anim_r;

    assign pwm_duty_reg = pwm_reg;
    assign display_val_reg = disp_reg;
    assign anim_reg = anim_r;

    always @(*) begin
        mem_rdata = 32'd0;
        mem_ready = 1'b0;
        if (mem_valid) begin
            case (mem_addr[3:0])
                4'h0: begin mem_rdata = {28'd0, pwm_reg}; mem_ready = 1'b1; end
                4'h4: begin mem_rdata = {28'd0, disp_reg}; mem_ready = 1'b1; end
                4'h8: begin mem_rdata = {30'd0, anim_r}; mem_ready = 1'b1; end
                4'hC: begin mem_rdata = {30'd0, btns}; mem_ready = 1'b1; end
                default: begin mem_rdata = 32'd0; mem_ready = 1'b1; end
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            pwm_reg <= 4'd0;
            disp_reg <= 4'd0;
            anim_r <= 2'd0;
        end else begin
            if (mem_valid && |mem_wstrb) begin
                case (mem_addr[3:0])
                    4'h0: pwm_reg <= mem_wdata[3:0];
                    4'h4: disp_reg <= mem_wdata[3:0];
                    4'h8: anim_r <= mem_wdata[1:0];
                endcase
            end
        end
    end
endmodule
`default_nettype wire
