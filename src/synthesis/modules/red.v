module red (
    input clk,
    input rst_n,
    input in,
    output out
);

    reg ff1_next, ff1_reg;  // trenutna vrednost
    reg ff2_next, ff2_reg;  // prosla vrednost

    assign out = ff1_reg & ~ff2_reg;        // ako je sada kec, a na proslom je bila nula znaci da se desila uzlazna ivica

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            ff1_reg <= 1'b0;
            ff2_reg <= 1'b0;
        end
        else begin
            ff1_reg <= ff1_next;
            ff2_reg <= ff2_next;
        end
    end

    always @(*) begin
        ff1_next = in;
        ff2_next = ff1_reg;
    end
    
endmodule