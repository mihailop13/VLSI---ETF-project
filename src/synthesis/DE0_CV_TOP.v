// ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
// Copyright (c) 2014 by Terasic Technologies Inc.
// ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development
//   Kits made by Terasic. Other use of this code, including the selling,
//   duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods. Terasic provides no warranty regarding the use
//   or functionality of this code.
//
// ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
//
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Yue Yang          :| 08/25/2014:| Initial Revision
// ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 

module DE0_CV_TOP(input CLOCK2_50,
                  input CLOCK3_50,
                  inout CLOCK4_50,
                  input CLOCK_50,
                  output [12:0] DRAM_ADDR,
                  output [1:0] DRAM_BA,
                  output DRAM_CAS_N,
                  output DRAM_CKE,
                  output DRAM_CLK,
                  output DRAM_CS_N,
                  inout [15:0] DRAM_DQ,
                  output DRAM_LDQM,
                  output DRAM_RAS_N,
                  output DRAM_UDQM,
                  output DRAM_WE_N,
                  inout [35:0] GPIO_0,
                  inout [35:0] GPIO_1,
                  output [6:0] HEX0,
                  output [6:0] HEX1,
                  output [6:0] HEX2,
                  output [6:0] HEX3,
                  output [6:0] HEX4,
                  output [6:0] HEX5,
                  input [3:0] KEY,
                  output [9:0] LEDR,
                  inout PS2_CLK,
                  inout PS2_CLK2,
                  inout PS2_DAT,
                  inout PS2_DAT2,
                  input RESET_N,
                  output SD_CLK,
                  inout SD_CMD,
                  inout [3:0] SD_DATA,
                  input [9:0] SW,
                  output [3:0] VGA_B,
                  output [3:0] VGA_G,
                  output VGA_HS,
                  output [3:0] VGA_R,
                  output VGA_VS);
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
    //  REG/WIRE declarations
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 

    //assign {HEX0_DP, HEX1_DP, HEX2_DP, HEX3_DP} = 4'hF;

	localparam ADDR_WIDTH = 6;
    localparam DATA_WIDTH = 16;

	wire [27:0] hex_out;

    // ================= CPU =================

	assign HEX0 = hex_out[6:0];
	assign HEX1 = hex_out[13:7];
	assign HEX2 = hex_out[20:14];
	assign HEX3 = hex_out[27:21];
    assign HEX4 = 7'b0;
    assign HEX5 = 7'b0;

    top top_inst(.clk(CLOCK_50), .rst_n(SW[9]), .btn(~KEY[2:0]), .sw(SW[8:0]), .kbd({PS2_DAT, PS2_CLK}),
     .led(LEDR), .hex(hex_out), .mnt({VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B}));


endmodule
