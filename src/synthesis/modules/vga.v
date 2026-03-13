module vga (
    input clk,
    input rst_n,
    input [23:0] code,
    output reg hsync,
    output reg vsync,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
);
    
//parametri za 800x600, 60Hz
localparam H_DISPLAY = 800;
localparam H_FRONT_PORCH = 56;
localparam H_SYNC_PULSE = 120;
localparam H_BACK_PORCH = 64;
localparam H_TOTAL = H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH ;

localparam V_DISPLAY = 600;
localparam V_FRONT_PORCH = 37;
localparam V_SYNC_PULSE = 6;
localparam V_BACK_PORCH = 23;
localparam V_TOTAL = V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

reg [11:0]h_counter;        //11 bita da bi se vrednost H_TOTAL = 1040 mogla procitati 
reg [10:0]v_counter;        //10 bita da bi se vrednost V_TOTAL = 666 mogla procitati

always @(posedge clk, negedge rst_n) begin      //brojanje za vertikalno i horizontalno

    if(!rst_n) begin
        h_counter <= 12'b0;
        v_counter <= 11'b0;
    end
    else begin
        if(h_counter < H_TOTAL - 1)
            h_counter <= h_counter + 1'b1;
        else begin
            if(v_counter == V_TOTAL - 1)
                v_counter <= 0;
            else
                v_counter <= v_counter + 1'b1;
            h_counter <= 0;
        end
    end

end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        hsync <= 1'b1;
        vsync <= 1'b1;
    end
    else begin
        hsync <= 1'b0;
        vsync <= 1'b0;
        if(h_counter >= H_DISPLAY + H_FRONT_PORCH && h_counter < H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE)
            hsync <= 1'b1;

        if(v_counter >= V_DISPLAY + V_FRONT_PORCH && v_counter < V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE)
            vsync <= 1'b1;
    end
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
       red <= 4'h0;
       green <= 4'h0;
       blue <= 4'h0; 
    end
    else begin
        red <= 4'h0;
        green <= 4'h0;
        blue <= 4'h0;
        if (h_counter < H_DISPLAY && v_counter < V_DISPLAY) begin
            if (h_counter < 400) begin              //leva polovina ekrana
                red <= code[23:20];
                green <= code[19:16];
                blue <= code[15:12];
            end
            else begin
                red <= code[11:8];
                green <= code[7:4];
                blue <= code[3:0];
            end
        end
    end
end

endmodule