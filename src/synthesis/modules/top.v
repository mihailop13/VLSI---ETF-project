module top #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [1:0] kbd,
    input [2:0] btn,
    input [8:0] sw,
    output [13:0] mnt,
    output [9:0] led,
    output [27:0] hex
);

//============================================ CLK_DIV init ======================================================

    wire clk_div_out;

    clk_div #(.DIVISOR(DIVISOR)) CLK_DIV(.clk(clk), .rst_n(rst_n), .out(clk_div_out));

//============================================ CPU init ======================================================

    wire we;
    wire [ADDR_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] data;
    wire [DATA_WIDTH-1:0] out;
    wire [ADDR_WIDTH-1:0] pc_out;
    wire [ADDR_WIDTH-1:0] sp_out;

    wire [DATA_WIDTH-1:0] mem_to_cpu;

    wire control;
    wire status;
    wire [DATA_WIDTH - 1:0] in;

    wire [DATA_WIDTH - 1:0] cpu_out;
    assign led[4:0] = cpu_out[4:0];
    assign led[5] = status;
    assign led[6] = control;

    cpu #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
    ) cpu_inst (
    .clk(clk_div_out), .rst_n(rst_n), .mem(mem_to_cpu), .in(num_out), .status(status), .control(control), .we(we), .addr(addr), .data(data), .out(cpu_out), .pc(pc_out), .sp(sp_out));

    //========================================= PS2 init ===================================================

    wire [15:0] ps2_to_scan;

    ps2 ps2_inst(.clk(clk), .ps2_clk(kbd[0]), .ps2_data(kbd[1]), .rst_n(rst_n), .code(ps2_to_scan));

    //========================================= SCAN_CODES init ===================================================

    wire [3:0] num_out;

    scan_codes scan_inst(.clk(clk_div_out), .rst_n(rst_n), .code(ps2_to_scan), .control(control), .status(status), .num(num_out));

    //========================================= COLOR_CODES init ===================================================

    wire [23:0] color_to_vga;
    color_codes color_inst(.num(cpu_out[5:0]), .code(color_to_vga));

    //=============================================== VGA init =====================================================

    vga vga_inst(.clk(clk), .rst_n(rst_n), .code(color_to_vga), .hsync(mnt[13]), .vsync(mnt[12]), .red(mnt[11:8]), .green(mnt[7:4]), .blue(mnt[3:0]));

    //=========================================== MEMORY init ======================================================

    memory #(.FILE_NAME(FILE_NAME), .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) mem (
    .clk(clk_div_out), .rst_n(rst_n), .we(we), .addr(addr), .data(data), .out(mem_to_cpu));

    //============================================ BCD init ======================================================

    wire [3: 0] bcd1_ones, bcd2_ones;
    wire [3: 0] bcd1_tens, bcd2_tens;
    bcd BCD1(.in(pc_out), .ones(bcd1_ones), .tens(bcd1_tens));
    bcd BCD2(.in(sp_out), .ones(bcd2_ones), .tens(bcd2_tens));

    //============================================ SSD init ======================================================

    ssd SSD1(.in(bcd1_ones), .out(hex[6:0]));
    ssd SSD2(.in(bcd1_tens), .out(hex[13:7]));
    ssd SSD3(.in(bcd2_ones), .out(hex[20:14]));
    ssd SSD4(.in(bcd2_tens), .out(hex[27:21]));

endmodule