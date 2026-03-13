module debouncer(
    input clk,
    input rst_n,
    input in,
    output out
);

    reg out_next, out_reg;
    reg [1:0] ff_next, ff_reg;                                      //nulti bit je nova vrednost, 1. bit je stara
    reg [7:0] cnt_next, cnt_reg;
    assign out = out_reg;

    assign in_changed = ff_reg[0] ^ ff_reg[1];                      //provera da li se desila promena sa 0 na 1 i obrnuto
    assign in_stable = (cnt_reg == 8'hFF) ? 1'b1 : 1'b0;            //ukoliko se poslednjih FF puta nije desila promena signal je stabilan

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            out_reg <= 1'b0;
            ff_reg <= 2'b00;
            cnt_reg <= 8'h00;
        end
        else begin
            out_reg <= out_next;
            ff_reg <= ff_next;
            cnt_reg <= cnt_next;
        end
    end

    always @(*) begin
        ff_next[0] = in;
        ff_next[1] = ff_reg[0];
        cnt_next = in_changed ? 0 : (cnt_reg + 1'b1);               //ukoliko se desila promena restujemo brojac, ukoliko nije inkrement
        out_next = in_stable ? ff_reg[1] : out_reg;                 //ukoliko je signal stabilan pustamo ga na izlaz
    end 


endmodule