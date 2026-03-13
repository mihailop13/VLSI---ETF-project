module color_codes(
    input [5:0] num,
    output reg [23:0] code
);

wire [3:0] ones = num % 10;
wire [3:0] tens = num / 10;

always @(*) begin

    case(ones)
        0: code[11:0] = 12'h000;
        1: code[11:0] = 12'hF00;
        2: code[11:0] = 12'hF80;
        3: code[11:0] = 12'hFF0;
        4: code[11:0] = 12'h0F0;
        5: code[11:0] = 12'h0FF;
        6: code[11:0] = 12'h08F;
        7: code[11:0] = 12'h00F;
        8: code[11:0] = 12'hF0F;
        9: code[11:0] = 12'hFFF;
        default: code[11:0] = 12'h000;
    endcase

    case(tens)
        0: code[23:12] = 12'h000;
        1: code[23:12] = 12'hF00;
        2: code[23:12] = 12'hF80;
        3: code[23:12] = 12'hFF0;
        4: code[23:12] = 12'h0F0;
        5: code[23:12] = 12'h0FF;
        6: code[23:12] = 12'h08F;
        7: code[23:12] = 12'h00F;
        8: code[23:12] = 12'hF0F;
        9: code[23:12] = 12'hFFF;
        default: code[23:12] = 12'h000;
    endcase
end

endmodule