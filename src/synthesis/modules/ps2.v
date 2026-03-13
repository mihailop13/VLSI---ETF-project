module ps2(
    input clk,
    input rst_n,
    input ps2_clk,
    input ps2_data,
    output reg [15:0] code
);

    // FSM stanja
    localparam PS2_START  = 2'd0;
    localparam PS2_DATA   = 2'd1;
    localparam PS2_PARITY = 2'd2;
    localparam PS2_STOP   = 2'd3;

    reg [1:0] state;

    reg [15:0] shift_reg;
    reg [7:0]  reg_data;
    reg [3:0]  counter;

    reg [2:0] clk_sync;

    reg [2:0] data_sync;

    // falling edge detekcija
    wire falling_edge = (clk_sync[2:1] == 2'b10);
    wire data = data_sync[2];

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            clk_sync <= 3'b111;
            data_sync <= 3'b111;
            code <= 16'd0;
        end
        else begin
            clk_sync <= {clk_sync[1:0], ps2_clk};
            data_sync <= {data_sync[1:0], ps2_data};
            code <= shift_reg;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= PS2_START;
            counter <= 4'd0;
            reg_data <= 8'd0;
            shift_reg <= 16'd0;
        end
        else begin
            if(falling_edge) begin
                case(state)
                    PS2_START: begin
                        counter  <= 4'd0;
                        reg_data <= 8'd0;
                        if(data == 1'b0)   // start bit mora biti 0
                            state <= PS2_DATA;
                        else begin
                            shift_reg <= 16'd0;
                        end
                    end
                    PS2_DATA: begin
                        reg_data <= {data, reg_data[7:1]};
                        counter  <= counter + 1'b1;

                        if(counter == 4'd7)
                            state <= PS2_PARITY;
                    end
                    PS2_PARITY: begin
                        if((^reg_data) != data)
                            state <= PS2_STOP;
                        else
                            state <= PS2_START; // parity error
                    end
                    PS2_STOP: begin
                        if(data == 1'b1) begin
                            shift_reg <= {shift_reg[7:0], reg_data};
                            state <= PS2_START;
                        end
                    end
                endcase
            end
        end 
            
    end

endmodule
