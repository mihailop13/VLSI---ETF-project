module scan_codes (
    input clk,
    input rst_n,
    input [15:0] code,
    input status,
    output reg control,
    output reg [3:0] num
);

    reg [3:0] decoded_num;
    reg key_released;

    reg [15:0] code_prev;

    wire code_change = (code != code_prev);

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            decoded_num <= 4'h0;
            key_released <= 1'b0;
        end 
        else begin
            key_released <= 1'b0;
            decoded_num <= 4'h0;
            if(code_change) begin
                if(code[15:8] == 8'hF0 && code[7:0] != 8'hF0) begin     //ova vrednost 0xF0 se smatra kao break code, broj jedan dolazi kao 16, F0, 16
                    key_released <= 1'b1;
                    case(code[7:0])
                        8'h16: decoded_num <= 1;
                        8'h1E: decoded_num <= 2;
                        8'h26: decoded_num <= 3;
                        8'h25: decoded_num <= 4;
                        8'h2E: decoded_num <= 5;
                        8'h36: decoded_num <= 6;
                        8'h3D: decoded_num <= 7;
                        8'h3E: decoded_num <= 8;
                        8'h46: decoded_num <= 9;
                        8'h45: decoded_num <= 0;
                        default: decoded_num <= 4'hF;
                    endcase
                end
            end
            
        end  
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            control <= 1'b0;
        end
        else begin
            code_prev <= code;
            if (key_released && status && decoded_num != 4'hF) begin
                num <= decoded_num;
                control <= 1'b1;
            end
            else begin
                control <= 1'b0;
            end
        end
    end

endmodule