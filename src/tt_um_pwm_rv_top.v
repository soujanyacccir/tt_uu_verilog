// tt_um_pwm_rv_top.v
`default_nettype none

`include "counter_to_7seg.v"
`include "pwm_generator.v"
`include "seg7_animator.v"

module tt_um_pwm_rv_top (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // --- Simple CPU-memory bus signals (picorv32-style)
    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_rdata;

    // Instantiate picorv32 core (you must add picorv32.v to src/)
    picorv32 picorv32_core (
        .clk      (clk),
        .resetn   (rst_n),
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr (mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );

    // Memory map:
    // 0x0000_0000 - ROM (firmware)
    // 0x1000_0000 - MMIO
    wire rom_sel  = (mem_addr[31:12] == 20'h00000);
    wire mmio_sel = (mem_addr[31:12] == 20'h10000);

    // simple ROM (word-addressable)
    reg [31:0] rom_mem [0:4095]; // 4k words (16 KB)
    initial begin
        // place firmware.hex in project root (or src/) before simulation/build
        $readmemh("firmware.hex", rom_mem);
    end

    // MMIO registers
    reg [3:0] pwm_duty_reg;     // 0..9
    reg [3:0] display_val_reg;  // 0..9
    reg [1:0] anim_reg;         // bit0 = enable, bit1 = mode

    reg [31:0] mem_rdata_r;
    reg mem_ready_r;

    // Read multiplexer (combinational)
    always @(*) begin
        mem_rdata_r = 32'd0;
        mem_ready_r = 1'b0;
        if (mem_valid) begin
            if (rom_sel) begin
                mem_rdata_r = rom_mem[mem_addr[13:2]]; // word index
                mem_ready_r = 1'b1;
            end else if (mmio_sel) begin
                case (mem_addr[3:0])
                    4'h0: begin mem_rdata_r = {28'd0, pwm_duty_reg}; mem_ready_r = 1'b1; end
                    4'h4: begin mem_rdata_r = {28'd0, display_val_reg}; mem_ready_r = 1'b1; end
                    4'h8: begin mem_rdata_r = {30'd0, anim_reg}; mem_ready_r = 1'b1; end
                    4'hC: begin mem_rdata_r = {30'd0, ui_in[1:0]}; mem_ready_r = 1'b1; end
                    default: begin mem_rdata_r = 32'd0; mem_ready_r = 1'b1; end
                endcase
            end else begin
                mem_rdata_r = 32'd0;
                mem_ready_r = 1'b1;
            end
        end
    end

    // Write handling (synchronous)
    always @(posedge clk) begin
        if (!rst_n) begin
            pwm_duty_reg    <= 4'd0;
            display_val_reg <= 4'd0;
            anim_reg        <= 2'd0;
        end else begin
            if (mem_valid && mmio_sel && |mem_wstrb) begin
                case (mem_addr[3:0])
                    4'h0: pwm_duty_reg    <= mem_wdata[3:0];
                    4'h4: display_val_reg <= mem_wdata[3:0];
                    4'h8: anim_reg        <= mem_wdata[1:0];
                endcase
            end
        end
    end

    // Peripheral wires
    wire [6:0] seg7;
    wire pwm_sig;
    wire [6:0] seg7_animated;

    // 7-seg decoder for display_val_reg
    counter_to_7seg decoder(.count_i(display_val_reg), .seg_o(seg7));

    // pwm generator uses pwm_duty_reg
    pwm_generator pwm_inst(
        .duty_level_i(pwm_duty_reg),
        .clk_i(clk),
        .rst_i(~rst_n),
        .pwm_sig_o(pwm_sig)
    );

    // animator (independent)
    seg7_animator anim_inst(
        .clk_i(clk),
        .rst_i(~rst_n),
        .mode_i(anim_reg[1]),
        .seg_o(seg7_animated)
    );

    // select between animated or static
    wire [6:0] seg_out = (anim_reg[0]) ? seg7_animated : seg7;

    // drive top outputs: {pwm, seg6..seg0} => uo_out[7:0]
    assign uo_out = { pwm_sig, seg_out };
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // connect mem interface back to CPU
    assign mem_rdata = mem_rdata_r;
    assign mem_ready = mem_ready_r;

endmodule
