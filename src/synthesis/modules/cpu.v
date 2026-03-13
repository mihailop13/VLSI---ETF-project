module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input rst_n,
    input [DATA_WIDTH - 1 : 0] mem,
    input [DATA_WIDTH - 1 : 0] in,
    input control,
    output status,
    output reg we,
    output [ADDR_WIDTH - 1 : 0] addr,
    output [DATA_WIDTH - 1 : 0] data,
    output [DATA_WIDTH - 1 : 0] out,
    output [ADDR_WIDTH - 1 : 0] pc,
    output [ADDR_WIDTH - 1 : 0] sp
);

    reg [DATA_WIDTH-1:0] out_reg, out_next;
    assign out = out_reg;

    //================================================ PC init ===========================================================

    reg pc_cl, pc_inc, pc_dec, pc_ld, pc_sr, pc_sl, pc_ir, pc_il;
    reg [ADDR_WIDTH - 1 : 0] pc_in;
    wire [ADDR_WIDTH - 1 : 0] pc_out;

    assign pc = pc_out;

    register #(.DATA_WIDTH(ADDR_WIDTH)) pc_reg (.clk(clk), .rst_n(rst_n), .cl(pc_cl), .ld(pc_ld), .in(pc_in), .inc(pc_inc),
            .dec(pc_dec), .sr(pc_sr), .ir(pc_ir), .sl(pc_sl), .il(pc_il), .out(pc_out));

    //================================================ SP init ===========================================================

    reg sp_cl, sp_inc, sp_dec, sp_ld, sp_sr, sp_sl, sp_ir, sp_il;
    reg [ADDR_WIDTH - 1 : 0] sp_in;
    wire [ADDR_WIDTH - 1 : 0] sp_out;

    assign sp = sp_out;

    register #(.DATA_WIDTH(ADDR_WIDTH)) sp_reg(.clk(clk), .rst_n(rst_n), .cl(sp_cl), .ld(sp_ld), .in(sp_in), .inc(sp_inc),
            .dec(sp_dec), .sr(sp_sr), .ir(sp_ir), .sl(sp_sl), .il(sp_il), .out(sp_out));

    //================================================ IR init ===========================================================

    reg ir_cl, ir_inc, ir_dec, ir_ld, ir_sr, ir_sl, ir_ir, ir_il;
    reg [31 : 0] ir_in;
    wire [31 : 0] ir_out;

    register #(.DATA_WIDTH(32)) IR (.clk(clk), .rst_n(rst_n), .cl(ir_cl), .ld(ir_ld), .in(ir_in), .inc(ir_inc),
            .dec(ir_dec), .sr(ir_sr), .ir(ir_ir), .sl(ir_sl), .il(ir_il), .out(ir_out));

    //================================================ MAR init ==========================================================

    reg MAR_cl, MAR_inc, MAR_dec, MAR_ld, MAR_sr, MAR_sl, MAR_ir, MAR_il;
    reg [ADDR_WIDTH - 1 : 0] MAR_in;
    wire [ADDR_WIDTH - 1 : 0] MAR_out;

    assign addr = MAR_out;

    register #(.DATA_WIDTH(ADDR_WIDTH)) MAR(.clk(clk), .rst_n(rst_n), .cl(MAR_cl), .ld(MAR_ld), .in(MAR_in), .inc(MAR_inc),
            .dec(MAR_dec), .sr(MAR_sr), .ir(MAR_ir), .sl(MAR_sl), .il(MAR_il), .out(MAR_out));

    //=============================================== MDR init =========================================================

    reg MDR_cl, MDR_inc, MDR_dec, MDR_ld, MDR_sr, MDR_sl, MDR_ir, MDR_il;
    reg [DATA_WIDTH - 1 : 0] MDR_in;
    wire [DATA_WIDTH - 1 : 0] MDR_out;

    //assign MDR_in = mem;
    assign data = MDR_out;

    register #(.DATA_WIDTH(DATA_WIDTH)) MDR(.clk(clk), .rst_n(rst_n), .cl(MDR_cl), .ld(MDR_ld), .in(MDR_in), .inc(MDR_inc),
            .dec(MDR_dec), .sr(MDR_sr), .ir(MDR_ir), .sl(MDR_sl), .il(MDR_il), .out(MDR_out));

    //=============================================== A init =========================================================

    reg A_cl, A_inc, A_dec, A_ld, A_sr, A_sl, A_ir, A_il;
    reg [DATA_WIDTH - 1 : 0] A_in;
    wire [DATA_WIDTH - 1 : 0] A_out;

    register #(.DATA_WIDTH(DATA_WIDTH)) A(.clk(clk), .rst_n(rst_n), .cl(A_cl), .ld(A_ld), .in(A_in), .inc(A_inc),
            .dec(A_dec), .sr(A_sr), .ir(A_ir), .sl(A_sl), .il(A_il), .out(A_out));

    //============================================= ALU init =====================================================

    reg [2:0] alu_oc;
    reg [DATA_WIDTH - 1 : 0] alu_a, alu_b;
    wire [DATA_WIDTH - 1 : 0] alu_out;

    alu #(.DATA_WIDTH(DATA_WIDTH)) alu_inst(.oc(alu_oc), .a(alu_a), .b(alu_b), .f(alu_out));

    //========================================== Operation codes ================================================

    localparam MOV = 4'b0000;
    localparam ADD = 4'b0001;
    localparam SUB = 4'b0010;
    localparam MUL = 4'b0011;
    localparam DIV = 4'b0100;
    localparam IN = 4'b0111;
    localparam OUT = 4'b1000;
    localparam STOP = 4'b1111;

    //============================================= Instruction state =================================================

    localparam RESET_PC = 8'hFE;
    localparam FETCH = 8'h00;
    localparam FETCH_WAIT = 8'h01;
    localparam FETCH2 = 8'h02;
    localparam FETCH2_WAIT = 8'h03;
    localparam DECODE = 8'h04;
    localparam DECODE_WAIT = 8'h05;
    localparam PC_UPDATE = 8'hFF;
    localparam DONE = 8'hFD;

    reg [7:0] state_reg, state_next, state_prev;

    //============================================ MOV states ======================================================

    localparam MOV_DIRECT2 = 8'h06;
    localparam MOV_DIRECT1 = 8'h07;
    localparam MOV_INDIRECT1 = 8'h08;
    localparam MOV_INDIRECT1_WAIT = 8'h09;
    localparam MOV_EX = 8'h0A;
    localparam MOV_INDIRECT2 = 8'h0B;
    localparam MOV_INDIRECT2_WAIT = 8'h0C;
    localparam MOV_INDIRECT_INDIRECT = 8'h0D;

    //============================================ ALU states ======================================================

    localparam OP2 = 8'h0E;
    localparam OP2_WAIT = 8'h0F;
    localparam OP1 = 8'h10;
    localparam OP1_WAIT = 8'h20;
    localparam ALU_EX = 8'h30;
    localparam ALU_WAIT = 8'h40;
    localparam ALU_WB_PREP = 8'h50;
    localparam ALU_WB = 8'h60;

    //============================================ IN states ======================================================

    localparam IN_OP = 8'h70;
    localparam IN_OP_WAIT = 8'h80;
    localparam IN_WAIT = 8'h90;
    localparam IN_WB = 8'hA0;

    //============================================ OUT states =====================================================

    localparam OUT_EX = 8'h11;
    localparam OP_OUT_WAIT = 8'h12;
    localparam OUT_WAIT = 8'h13;

    //============================================ STOP states =====================================================

    localparam STOP_OP1 = 8'h14;
    localparam STOP_OP1_WAIT = 8'h15;
    localparam STOP_OP2 = 8'h16;
    localparam STOP_OP2_WAIT = 8'h17;
    localparam STOP_OP3 = 8'h18;
    localparam STOP_OP3_WAIT = 8'h19;

    //============================================== Sequential ===================================================

    reg status_reg, status_next;

    assign status = status_reg;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state_reg <= RESET_PC;
            out_reg <= 0;
            status_reg <= 1'b0;
        end
        else begin
            out_reg <= out_next;
            state_prev <= state_reg;
            state_reg  <= state_next;
            status_reg <= status_next;
        end
    end

    //============================================ Combinational ======================================================

    wire [3:0] operation_code = ir_out[15:12];
    wire d1 = ir_out[11];
    wire [2:0] addr1 = ir_out[10:8];
    wire d2 = ir_out[7];
    wire [2:0] addr2 = ir_out[6:4];
    wire d3 = ir_out[3];
    wire [2:0] addr3 = ir_out[2:0];

    always @(*) begin
        // ================= DEFAULTS =================
        pc_in  = pc_out;
        pc_inc = 1'b0;
        pc_ld = 1'b0;

        MAR_in = MAR_out;
        MAR_ld = 1'b0;

        MDR_in = MDR_out;
        MDR_ld = 1'b0;

        A_in   = A_out;
        A_ld   = 1'b0;

        alu_oc = 3'b000;
        alu_a  = {DATA_WIDTH{1'b0}};
        alu_b  = {DATA_WIDTH{1'b0}};

        ir_in  = ir_out;
        ir_ld  = 1'b0;

        sp_in = sp_out;
        sp_ld = sp;

        we  = 1'b0;
        out_next = out_reg;

        status_next = status_reg;

        state_next = state_reg;

        if(operation_code != 4'b1111) begin
            case(state_reg)
                FETCH: begin
                    MAR_in = pc_out;                      //addr je output koji u ovom slucaju treba da bude pc_out da bi se dohvatila instrukcija
                    MAR_ld = 1'b1;
                    state_next = FETCH_WAIT;
                end
                FETCH_WAIT: begin
                    state_next = DECODE;
                end
                DECODE: begin
                    if(state_prev == FETCH2_WAIT) begin
                        ir_in[15 : 0] = ir_out;
                        ir_in[31 : 16] = mem;
                        ir_ld = 1'b1;
                    end
                    else begin
                        ir_in = {16'b0, mem};
                        ir_ld = 1'b1;
                    end
                    state_next = DECODE_WAIT;
                end
                FETCH2: begin
                    MAR_in = pc_out;                          //addr je output koji u ovom slucaju treba da bude pc_out da bi se dohvatila instrukcija
                    MAR_ld = 1'b1;
                    state_next = FETCH2_WAIT;
                end
                FETCH2_WAIT: begin
                    state_next = DECODE;
                end
                DECODE_WAIT: begin
                    if(state_prev == DECODE_WAIT) begin
                        case (operation_code)
                            ADD: begin
                                state_next = OP2;
                                alu_oc = 3'b000;
                            end 
                            SUB: begin
                                state_next = OP2;
                                alu_oc = 3'b001;
                            end
                            MUL: begin
                                state_next = OP2;
                                alu_oc = 3'b010;
                            end
                            MOV:begin
                                if(d2) 
                                    state_next = MOV_INDIRECT2;
                                else
                                    state_next = MOV_DIRECT2;
                            end 
                            DIV:begin
                                state_next = OP2;
                                alu_oc = 3'b011;
                            end 
                            IN:begin
                                if(d1)
                                    state_next = IN_OP;
                                else 
                                    state_next = IN_OP_WAIT;
                            end 
                            OUT: begin
                                state_next = OUT_EX;
                            end
                            default: begin
                                state_next = FETCH2;
                                pc_inc = 1'b1;
                            end  
                        endcase
                    end
                    else begin
                        if(operation_code == 4'b0111 | operation_code == 4'b1000)
                            MAR_in = addr1;
                        else begin
                            if(addr3 == 3'b000)
                                MAR_in = addr2;
                            else
                                MAR_in = addr3;
                        end
                        MAR_ld = 1'b1;
                    end
                end
                MOV_DIRECT2: begin
                    MDR_in = mem;
                    MDR_ld = 1'b1;
                    MAR_in = addr1;
                    MAR_ld = 1'b1;
                    if(d1)
                        state_next = MOV_INDIRECT1_WAIT;
                    else
                        state_next = MOV_EX;
                end
                MOV_DIRECT1: begin
                    MAR_in = addr1;
                    MDR_in = mem;
                    MDR_ld = 1'b1;
                    MAR_ld = 1'b1;
                    state_next = MOV_EX;
                end
                MOV_INDIRECT1: begin
                    MAR_in = mem[ADDR_WIDTH - 1: 0];
                    MAR_ld = 1'b1;
                    state_next = MOV_EX;
                end
                MOV_INDIRECT1_WAIT: begin
                    state_next = MOV_INDIRECT1;
                    //prazan takt, cekanje da se na mem liniji pojavi ono sto je na lokaciji addr1
                end    
                MOV_EX: begin
                    //addr postavlja uvek proslo stanje, tako da u ovom stanju samo postavim bit za upis
                    we = 1'b1;
                    state_next = PC_UPDATE;
                end
                MOV_INDIRECT2: begin
                    MAR_in = mem[ADDR_WIDTH - 1 : 0];
                    MAR_ld = 1'b1;
                    state_next = MOV_INDIRECT2_WAIT;
                end
                MOV_INDIRECT2_WAIT: begin
                    if(d1)
                        state_next = MOV_INDIRECT_INDIRECT;
                    else
                        state_next = MOV_DIRECT1;
                end
                MOV_INDIRECT_INDIRECT: begin
                    MDR_in = mem;
                    MDR_ld = 1'b1;
                    MAR_in = addr1;
                    MAR_ld = 1'b1;
                    state_next = MOV_INDIRECT1_WAIT;
                end
                OP2: begin   
                    if(!d3) begin
                        A_in = mem;
                        A_ld = 1'b1;
                        MAR_in = addr2;
                    end
                    else begin
                        MAR_in = mem[ADDR_WIDTH - 1 : 0];
                    end
                    MAR_ld = 1'b1;

                    if(!d2 & !d3)
                        state_next = OP1_WAIT;
                    else
                        state_next = OP2_WAIT;
                end
                OP2_WAIT: begin
                    //prazan takt cekanje
                    state_next = OP1;
                end
                OP1: begin
                    if(d3) begin
                        A_in = mem;
                        A_ld = 1'b1;
                        MAR_in = addr2;
                    end
                    else begin
                        MAR_in = mem[ADDR_WIDTH - 1 : 0];
                    end
                    MAR_ld = 1'b1;
                    state_next = OP1_WAIT;
                end
                OP1_WAIT: begin
                    if(d2 & d3)
                        state_next = ALU_WAIT;
                    else
                        state_next = ALU_EX;
                end
                ALU_EX: begin
                    if(d1) begin
                        MAR_in = addr1;
                        MAR_ld = 1'b1;
                        state_next = ALU_WAIT;
                    end
                    else
                        state_next = ALU_WB_PREP;
                end
                ALU_WAIT: begin
                    alu_a = mem;
                    alu_b = A_out;
                    if(state_prev == ALU_EX)begin
                        if(d1) begin
                            MAR_in = mem[ADDR_WIDTH - 1 : 0];
                            MAR_ld = 1'b1;
                            A_in = alu_out;
                            A_ld = 1'b1;
                        end
                        state_next = ALU_WB_PREP;
                    end
                    else if(state_prev == OP1_WAIT) begin
                        MAR_in = mem[ADDR_WIDTH - 1 : 0];
                        MAR_ld = 1'b1;
                    end
                    else
                        state_next = ALU_EX;
                end
                ALU_WB_PREP: begin
                    alu_a = mem;
                    alu_b = A_out;
                    case (operation_code)
                            ADD: begin
                                alu_oc = 3'b000;
                            end 
                            SUB: begin
                                alu_oc = 3'b001;
                            end
                            MUL: begin
                                alu_oc = 3'b010;
                            end
                            DIV:begin
                                alu_oc = 3'b011;
                            end 
                    endcase
                    if(d1) begin
                        MAR_in = mem[ADDR_WIDTH - 1 : 0];
                        MDR_in = A_out;
                    end
                    else begin
                        MAR_in = addr1;
                        MDR_in = alu_out;
                    end
                    MAR_ld = 1'b1;
                    MDR_ld = 1'b1;
                    state_next = ALU_WB;
                end
                ALU_WB: begin
                    we = 1'b1;
                    state_next = PC_UPDATE;
                end
                IN_OP: begin
                    MAR_in = mem[ADDR_WIDTH - 1 : 0];
                    MAR_ld = 1'b1;
                    state_next = IN_OP_WAIT;
                end
                IN_OP_WAIT: begin
                    state_next = IN_WAIT;
                    status_next = 1'b1;
                end
                IN_WAIT: begin
                    if(control != 1'b0) begin
                        MDR_in = {{12{1'b0}} ,in[3:0]};
                        MDR_ld = 1'b1;
                        state_next = IN_WB;
                        status_next = 1'b0;
                    end
                end
                IN_WB: begin
                    we = 1'b1;
                    state_next = PC_UPDATE;
                end
                OUT_EX: begin
                    if(!d1)begin
                        out_next = mem;
                        state_next = PC_UPDATE;
                    end
                    else begin
                        MAR_in = mem[ADDR_WIDTH - 1 : 0];
                        MAR_ld = 1'b1;
                        state_next = OP_OUT_WAIT;
                    end
                end
                OP_OUT_WAIT: begin
                    //prazan takt, cekanje
                    state_next = OUT_WAIT;
                end
                OUT_WAIT: begin
                    out_next = mem;
                    state_next = PC_UPDATE;
                end
                PC_UPDATE: begin
                    pc_inc = 1'b1;
                    state_next = FETCH;
                end
                RESET_PC: begin
                    sp_in = 6'b111111;
                    sp_ld = 1'b1;
                    pc_in  = 6'd8;
                    pc_ld  = 1'b1;
                    state_next = FETCH;
                end  
            endcase
        end
        else begin  //STOP instrukcija
            case(state_reg) 
                DECODE_WAIT: begin  //dolazim iz DECODE, tek su se addr1,2,3 pojavile
                    if(addr1 != 4'b0000) begin
                        MAR_in = addr1;
                        state_next = STOP_OP1;
                    end
                    else if(addr2 != 4'b0000) begin
                        MAR_in = addr2;
                        state_next = STOP_OP2;
                    end
                    else if(addr3 != 4'b0000) begin
                        MAR_in = addr3;
                        state_next = STOP_OP3;
                    end
                    else 
                        state_next = DONE;
                    MAR_ld = 1'b1;
                end
                STOP_OP1: begin
                    if(d1) begin
                        MAR_in = mem[ADDR_WIDTH - 1 : 0];
                        MAR_ld = 1'b1;
                        state_next = STOP_OP1_WAIT;
                    end
                    else begin
                        out_next = mem;
                        if(addr2 != 4'b0000) begin
                            MAR_in = addr2;
                            state_next = STOP_OP2;
                        end
                        else if(addr3 != 4'b0000) begin
                            MAR_in = addr3;
                            state_next = STOP_OP3;
                        end
                        else 
                            state_next = DONE;
                        MAR_ld = 1'b1;
                    end
                end
                STOP_OP1_WAIT: begin
                    out_next = mem;
                    state_next = DONE;
                    if(addr2 != 4'b0000) begin
                        MAR_in = addr2;
                        state_next = STOP_OP2;
                    end
                    else if(addr3 != 4'b0000) begin
                        MAR_in = addr3;
                        state_next = STOP_OP3;
                    end
                    else 
                        state_next = DONE;
                    MAR_ld = 1'b1;
                end
                STOP_OP2: begin
                    if(d2) begin
                        MAR_in = mem[ADDR_WIDTH - 1 : 0];
                        MAR_ld = 1'b1;
                        state_next = STOP_OP2_WAIT;
                    end
                    else begin
                        out_next = mem;
                        if(addr3 != 4'b0000) begin
                            MAR_in = addr3;
                            MAR_ld = 1'b1;
                            state_next = STOP_OP3;
                        end
                        else 
                            state_next = DONE;
                    end
                end
                STOP_OP2_WAIT: begin
                    out_next = mem;
                    if(addr3 != 4'b0000) begin
                        MAR_in = addr3;
                        MAR_ld = 1'b1;
                        state_next = STOP_OP3;
                    end
                    else 
                        state_next = DONE;
                end
                STOP_OP3: begin
                    if(d3) begin
                        MAR_in = mem[ADDR_WIDTH - 1 : 0];
                        MAR_ld = 1'b1;
                        state_next = STOP_OP3_WAIT;
                    end
                    else begin
                        out_next = mem;
                        state_next = DONE;
                    end
                        
                end
                STOP_OP3_WAIT: begin
                    out_next = mem;
                    state_next = DONE;
                end
                DONE: begin
                    
                end
            endcase
        end
    end

endmodule