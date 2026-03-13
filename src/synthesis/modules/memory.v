module memory #(
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input rst_n,
    input we,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] data,
    output reg [DATA_WIDTH-1:0] out
);

    (* ram_init_file = FILE_NAME *) reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];    
    
    always @(posedge clk) begin
        if (we)
            mem[addr] = data;
        out <= mem[addr];
    end

endmodule
