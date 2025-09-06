module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input wire clk,
    input wire rst_n,
    input wire [DATA_WIDTH-1:0] mem,
    input wire [DATA_WIDTH-1:0] in,
    input wire control,
    output wire status,
    output wire we,
    output wire [ADDR_WIDTH-1:0] addr,
    output wire [DATA_WIDTH-1:0] data,
    output wire [DATA_WIDTH-1:0] out,
    output wire [ADDR_WIDTH-1:0] pc,
    output wire [ADDR_WIDTH-1:0] sp
);

    localparam HIGH = DATA_WIDTH - 1;

    reg [15:0] out_reg, out_next;
    reg status_reg, status_next;
    reg we_reg, we_next;

    assign status = status_reg;
    assign we = we_reg;
    assign addr = mar_out;
    assign data = mdr_out;
    assign out = out_reg;
    assign pc = pc_out;
    assign sp = sp_out;


    wire pc_ld, pc_inc;
    wire [ADDR_WIDTH - 1:0] pc_in, pc_out;
    register #(
        .DATA_WIDTH(ADDR_WIDTH)
    ) pc (
        .clk(clk),
        .rst_n(rst_n),
        .ld(pc_ld),
        .in(pc_in),
        .inc(pc_inc),
        .out(pc_out)
    );

    wire sp_ld, sp_dec, sp_inc;
    wire [ADDR_WIDTH - 1:0] sp_in, sp_out;
    register #(
        .DATA_WIDTH(ADDR_WIDTH)
    ) sp (
        .clk(clk),
        .rst_n(rst_n),
        .ld(sp_ld),
        .in(sp_in),
        .dec(sp_dec),
        .inc(sp_inc),
        .out(sp_out)
    );

    wire ir0_ld;
    wire [HIGH:0] ir0_in, ir0_out;
    register #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ir0 (
        .clk(clk),
        .rst_n(rst_n),
        .ld(ir0_ld),
        .in(ir0_in),
        .out(ir0_out)
    );  

    wire ir1_ld;
    wire [HIGH:0] ir1_in, ir1_out;
    register #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ir1 (
        .clk(clk),
        .rst_n(rst_n),
        .ld(ir1_ld),
        .in(ir1_in),
        .out(ir1_out)
    );

    wire acc_ld;
    wire [HIGH:0] acc_in, acc_out;
    register #(
        .DATA_WIDTH(DATA_WIDTH)
    ) acc (
        .clk(clk),
        .rst_n(rst_n),
        .ld(acc_ld),
        .in(acc_in),
        .out(acc_out)
    );

    wire mdr_ld;
    wire [HIGH:0] mdr_in, mdr_out;
    register #(
        .DATA_WIDTH(DATA_WIDTH)
    ) mdr (
        .clk(clk),
        .rst_n(rst_n),
        .ld(mdr_ld),
        .in(mdr_in),
        .out(mdr_out)
    );

    wire mar_ld;
    wire [ADDR_WIDTH - 1:0] mar_in, mar_out;
    register #(
        .DATA_WIDTH(ADDR_WIDTH)
    ) mar (
        .clk(clk),
        .rst_n(rst_n),
        .ld(mar_ld),
        .in(mar_in),
        .out(mar_out)
    );

    wire [2:0] alu_oc;
    wire [HIGH:0] alu_a, alu_b, alu_out;
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) alu1 (
        .oc(alu_oc),
        .a(alu_a),
        .b(alu_b),
        .f(alu_out)
    );
    
    localparam MOV                              = 4'b0000;
    localparam ADD                              = 4'b0001;
    localparam SUB                              = 4'b0010;
    localparam MUL                              = 4'b0011;
    localparam DIV                              = 4'b0100;
    localparam IN                               = 4'b0111;
    localparam OUT                              = 4'b1000;
    localparam STOP                             = 4'b1111;

    localparam STATE_INIT                       = 0;
    localparam STATE_FETCH                      = 1;
    localparam STATE_DECODE                     = 2;
    localparam STATE_EXECUTE                    = 3;
    localparam STATE_STORE                      = 4;
    localparam STATE_END                        = 5;

    localparam INIT_DO                          = 0;

    localparam FETCH_LOAD_MAR                   = 0;
    localparam FETCH_WAIT_MEM                   = 1;
    localparam FETCH_READ_MEM                   = 2;
    localparam FETCH_LOAD_IR0                   = 3;

    localparam DECODE_MOV_LD_MAR                = 0;
    localparam DECODE_MOV_IND_WAIT_MEM          = 1;
    localparam DECODE_MOV_IND_READ_MEM          = 2;
    localparam DECODE_MOV_IND_MDR_TO_MAR        = 3;
    localparam DECODE_MOV_WAIT_MEM              = 4;
    localparam DECODE_MOV_READ_MEM              = 5;
    localparam DECODE_MOV_MDR_TO_ACC            = 6;

    localparam DECODE_ARITHM_Y_TO_MAR           = 0;
    localparam DECODE_ARITHM_Y_IND_WAIT_MEM     = 1;
    localparam DECODE_ARITHM_Y_IND_READ_MEM     = 2;
    localparam DECODE_ARITHM_Y_IND_MDR_TO_MAR   = 3;
    localparam DECODE_ARITHM_Y_WAIT_MEM         = 4;
    localparam DECODE_ARITHM_Y_READ_MEM         = 5;
    localparam DECODE_ARITHM_Y_MDR_TO_ACC       = 6;
    localparam DECODE_ARITHM_Z_TO_MAR           = 7;
    localparam DECODE_ARITHM_Z_IND_WAIT_MEM     = 8;
    localparam DECODE_ARITHM_Z_IND_READ_MEM     = 9;
    localparam DECODE_ARITHM_Z_IND_MDR_TO_MAR   = 10;
    localparam DECODE_ARITHM_Z_WAIT_MEM         = 11;
    localparam DECODE_ARITHM_Z_READ_MEM         = 12;
    localparam DECODE_ARITHM_Z_MDR_TO_ACC       = 13;

    localparam DECODE_IN_SET_STATUS             = 0;
    localparam DECODE_IN_LOAD_ACC               = 1;

    localparam DECODE_OUT_X_TO_MAR              = 0;
    localparam DECODE_OUT_X_IND_WAIT_MEM        = 1;
    localparam DECODE_OUT_X_IND_READ_MEM        = 2;
    localparam DECODE_OUT_X_IND_MDR_TO_MAR      = 3;
    localparam DECODE_OUT_X_WAIT_MEM            = 4;
    localparam DECODE_OUT_X_READ_MEM            = 5;
    localparam DECODE_OUT_X_MDR_TO_OUT          = 6;

    localparam DECODE_STOP_X_TO_MAR             = 0;
    localparam DECODE_STOP_X_IND_WAIT_MEM       = 1;
    localparam DECODE_STOP_X_IND_READ_MEM       = 2;
    localparam DECODE_STOP_X_IND_MDR_TO_MAR     = 3;
    localparam DECODE_STOP_X_WAIT_MEM           = 4;
    localparam DECODE_STOP_X_READ_MEM           = 5;
    localparam DECODE_STOP_X_MDR_TO_OUT         = 6;
    localparam DECODE_STOP_Y_TO_MAR             = 0+7;
    localparam DECODE_STOP_Y_IND_WAIT_MEM       = 1+7;
    localparam DECODE_STOP_Y_IND_READ_MEM       = 2+7;
    localparam DECODE_STOP_Y_IND_MDR_TO_MAR     = 3+7;
    localparam DECODE_STOP_Y_WAIT_MEM           = 4+7;
    localparam DECODE_STOP_Y_READ_MEM           = 5+7;
    localparam DECODE_STOP_Y_MDR_TO_OUT         = 6+7;
    localparam DECODE_STOP_Z_TO_MAR             = 0+14;
    localparam DECODE_STOP_Z_IND_WAIT_MEM       = 1+14;
    localparam DECODE_STOP_Z_IND_READ_MEM       = 2+14;
    localparam DECODE_STOP_Z_IND_MDR_TO_MAR     = 3+14;
    localparam DECODE_STOP_Z_WAIT_MEM           = 4+14;
    localparam DECODE_STOP_Z_READ_MEM           = 5+14;
    localparam DECODE_STOP_Z_MDR_TO_OUT         = 6+14;

    localparam EXECUTE_DO                       = 0;

    localparam STORE_X_TO_MAR                   = 0;
    localparam STORE_X_IND_WAIT_MEM             = 1;
    localparam STORE_X_IND_READ_MEM             = 2;
    localparam STORE_X_IND_MDR_TO_MAR           = 3;
    localparam STORE_X_WRITE_MEM                = 4;

    localparam END_DO                           = 0;

    reg [2:0] state_reg, state_next;
    reg [4:0] substate_reg, substate_next;

    always @(posedge clk , negedge rst_n) begin
        if (!rst_n) begin
            out_reg <= {DATA_WIDTH{1'b0}};
            status_reg <= 1'b0;
            we_reg <= 1'b0;
            state_reg <= STATE_INIT;
            substate_reg <= 0;
        end else begin
            out_reg <= out_next;
            status_reg <= status_next;
            we_reg <= we_next;
            state_reg <= state_next;
            substate_reg <= substate_next;
        end
    end

    

    always @(*) begin

        state_next <= state_reg
        substate_next <= substate_reg

        out_next <= out_reg;
        status_next <= 0;
        we_next <= 0;
        
        pc_in <= 0;
        pc_ld <= 0;
        pc_inc <= 0;

        sp_in <= 0;
        sp_ld <= 0;
        sp_inc <= 0;
        sp_dec <= 0;

        mar_in <= 0;
        mar_ld <= 0;

        ir0_in <= 0;
        ir0_ld <= 0;

        ir1_in <= 0;
        ir1_ld <= 0;

        acc_in <= 0;
        acc_ld <= 0;

        mdr_in <= 0;
        mdr_ld <= 0;


        case (state_reg)
            STATE_INIT:
            begin
                pc_in <= 8;
                pc_ld <= 1;

                sp_in <= 63;
                sp_ld <= 1;

                state_next <= STATE_FETCH;
                substate_next <= FETCH_LOAD_MAR;
            end
            STATE_FETCH:
            begin
                case (substate_reg)
                    FETCH_LOAD_MAR:
                    begin
                        mar_in <= pc_out;
                        mar_ld <= 1;
                        pc_inc <= 1;
                        substate_next <= FETCH_WAIT_MEM;
                    end
                    FETCH_WAIT_MEM:
                    begin
                        // addr <= mar_out
                        substate_next <= FETCH_READ_MEM;
                    end
                    FETCH_READ_MEM:
                    begin
                        mdr_in <= mem;
                        mdr_ld <= 1;
                        substate_next <= FETCH_LOAD_IR0;
                    end
                    FETCH_LOAD_IR0:
                    begin
                        ir0_ld <= 1;
                        ir0_in <= mdr_out;
                        state_next <= STATE_DECODE;
                        substate_next <= 0;
                    end
                endcase
            end
            STATE_DECODE:
            begin
                wire [2:0] Xaddr = ir0_out[6:4];
                wire Xind = ir_out[7];
                wire [2:0] Yaddr = ir0_out[2:0];
                wire Yind = ir_out[3];
                wire [2:0] Zaddr = ir0_out[10:8];
                wire Zind = ir_out[11];
                
                case (opcode)
                    MOV:
                    begin
                        case (substate_reg)
                            DECODE_MOV_LD_MAR:
                            begin
                                mar_in <= {3'b000, Yaddr}
                                mar_ld <= 1;
                                if (Yind == 1'b1)
                                    substate_next <= DECODE_MOV_IND_WAIT_MEM;
                                else 
                                    substate_next <= DECODE_MOV_WAIT_MEM;
                            end
                            DECODE_MOV_IND_WAIT_MEM:
                            begin
                                // addr <= mar_out
                                substate_next <= DECODE_MOV_IND_READ_MEM;
                            end
                            DECODE_MOV_IND_READ_MEM:
                            begin
                                mdr_in <= mem;
                                mdr_ld <= 1;
                                substate_next <= DECODE_MOV_IND_MDR_TO_MAR;
                            end
                            DECODE_MOV_IND_MDR_TO_MAR:
                            begin
                                mar_in <= mdr_out[5:0];
                                mar_ld <= 1;
                                substate_next <= DECODE_MOV_WAIT_MEM;
                            end
                            DECODE_MOV_WAIT_MEM:
                            begin
                                // addr <= mar_out
                                substate_next <= DECODE_MOV_READ_MEM;
                            end
                            DECODE_MOV_READ_MEM:
                            begin
                                mdr_in <= mem;
                                mdr_ld <= 1;
                                substate_next <= DECODE_MOV_MDR_TO_ACC;
                            end
                            DECODE_MOV_MDR_TO_ACC:
                            begin
                                acc_in <= mdr_out;
                                acc_ld <= 1;
                                state_next <= STATE_STORE;
                                substate_next <= STORE_X_TO_MAR;
                            end
                        endcase
                    end
                    ADD:
                    begin
                        case (substate_reg)
                            DECODE_ARITHM_Y_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_IND_WAIT_MEM;
                            end
                            DECODE_ARITHM_Y_IND_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_IND_READ_MEM;
                            end
                            DECODE_ARITHM_Y_IND_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_IND_MDR_TO_MAR;
                            end
                            DECODE_ARITHM_Y_IND_MDR_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_WAIT_MEM;
                            end
                            DECODE_ARITHM_Y_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_READ_MEM;
                            end
                            DECODE_ARITHM_Y_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_MDR_TO_ACC;
                            end
                            DECODE_ARITHM_Y_MDR_TO_ACC:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_TO_MAR;
                            end
                            DECODE_ARITHM_Z_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_IND_WAIT_MEM;
                            end
                            DECODE_ARITHM_Z_IND_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_IND_READ_MEM;
                            end
                            DECODE_ARITHM_Z_IND_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_IND_MDR_TO_MAR;
                            end
                            DECODE_ARITHM_Z_IND_MDR_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_WAIT_MEM;
                            end
                            DECODE_ARITHM_Z_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_READ_MEM;
                            end
                            DECODE_ARITHM_Z_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_MDR_TO_ACC;
                            end
                            DECODE_ARITHM_Z_MDR_TO_ACC:
                            begin
                               
                                state_next <= STATE_STORE; 
                                substate_next <= EXECUTE_DO;
                            end
                        endcase
                    end
                    SUB:
                    begin
                        case (substate_reg)
                            DECODE_ARITHM_Y_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_IND_WAIT_MEM;
                            end
                            DECODE_ARITHM_Y_IND_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_IND_READ_MEM;
                            end
                            DECODE_ARITHM_Y_IND_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_IND_MDR_TO_MAR;
                            end
                            DECODE_ARITHM_Y_IND_MDR_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_WAIT_MEM;
                            end
                            DECODE_ARITHM_Y_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_READ_MEM;
                            end
                            DECODE_ARITHM_Y_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_MDR_TO_ACC;
                            end
                            DECODE_ARITHM_Y_MDR_TO_ACC:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_TO_MAR;
                            end
                            DECODE_ARITHM_Z_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_IND_WAIT_MEM;
                            end
                            DECODE_ARITHM_Z_IND_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_IND_READ_MEM;
                            end
                            DECODE_ARITHM_Z_IND_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_IND_MDR_TO_MAR;
                            end
                            DECODE_ARITHM_Z_IND_MDR_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_WAIT_MEM;
                            end
                            DECODE_ARITHM_Z_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_READ_MEM;
                            end
                            DECODE_ARITHM_Z_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_MDR_TO_ACC;
                            end
                            DECODE_ARITHM_Z_MDR_TO_ACC:
                            begin
                               
                                state_next <= STATE_STORE; 
                                substate_next <= EXECUTE_DO;
                            end
                        endcase
                    end
                    MUL:
                    begin
                        case (substate_reg)
                            DECODE_ARITHM_Y_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_IND_WAIT_MEM;
                            end
                            DECODE_ARITHM_Y_IND_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_IND_READ_MEM;
                            end
                            DECODE_ARITHM_Y_IND_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_IND_MDR_TO_MAR;
                            end
                            DECODE_ARITHM_Y_IND_MDR_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_WAIT_MEM;
                            end
                            DECODE_ARITHM_Y_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_READ_MEM;
                            end
                            DECODE_ARITHM_Y_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_MDR_TO_ACC;
                            end
                            DECODE_ARITHM_Y_MDR_TO_ACC:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_TO_MAR;
                            end
                            DECODE_ARITHM_Z_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_IND_WAIT_MEM;
                            end
                            DECODE_ARITHM_Z_IND_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_IND_READ_MEM;
                            end
                            DECODE_ARITHM_Z_IND_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_IND_MDR_TO_MAR;
                            end
                            DECODE_ARITHM_Z_IND_MDR_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_WAIT_MEM;
                            end
                            DECODE_ARITHM_Z_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_READ_MEM;
                            end
                            DECODE_ARITHM_Z_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_MDR_TO_ACC;
                            end
                            DECODE_ARITHM_Z_MDR_TO_ACC:
                            begin
                               
                                state_next <= STATE_STORE; 
                                substate_next <= EXECUTE_DO;
                            end
                        endcase
                    end
                    DIV:
                    begin
                        case (substate_reg)
                            DECODE_ARITHM_Y_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_IND_WAIT_MEM;
                            end
                            DECODE_ARITHM_Y_IND_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_IND_READ_MEM;
                            end
                            DECODE_ARITHM_Y_IND_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_IND_MDR_TO_MAR;
                            end
                            DECODE_ARITHM_Y_IND_MDR_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_WAIT_MEM;
                            end
                            DECODE_ARITHM_Y_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_READ_MEM;
                            end
                            DECODE_ARITHM_Y_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Y_MDR_TO_ACC;
                            end
                            DECODE_ARITHM_Y_MDR_TO_ACC:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_TO_MAR;
                            end
                            DECODE_ARITHM_Z_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_IND_WAIT_MEM;
                            end
                            DECODE_ARITHM_Z_IND_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_IND_READ_MEM;
                            end
                            DECODE_ARITHM_Z_IND_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_IND_MDR_TO_MAR;
                            end
                            DECODE_ARITHM_Z_IND_MDR_TO_MAR:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_WAIT_MEM;
                            end
                            DECODE_ARITHM_Z_WAIT_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_READ_MEM;
                            end
                            DECODE_ARITHM_Z_READ_MEM:
                            begin
                               
                                substate_next <= DECODE_ARITHM_Z_MDR_TO_ACC;
                            end
                            DECODE_ARITHM_Z_MDR_TO_ACC:
                            begin
                               
                                state_next <= STATE_STORE; 
                                substate_next <= EXECUTE_DO;
                            end
                        endcase
                    end
                    IN:
                    begin
                        case (substate_reg)
                            DECODE_IN_SET_STATUS:
                            begin
                                //ne mora ovo biti substate_next, pazi na skokove
                                substate_next <= DECODE_IN_LOAD_ACC;
                            end
                            DECODE_IN_LOAD_ACC:
                            begin
                                
                                state_next <= STATE_STORE;
                                substate_next <= STORE_X_TO_MAR;
                            end
                        endcase
                    end
                    OUT:
                    begin
                        case (substate_reg)
                            DECODE_OUT_X_TO_MAR:
                            begin
                                
                                substate_next <= DECODE_OUT_X_IND_WAIT_MEM;
                            end
                            DECODE_OUT_X_IND_WAIT_MEM:
                            begin
                                
                                substate_next <= DECODE_OUT_X_IND_READ_MEM;
                            end
                            DECODE_OUT_X_IND_READ_MEM:
                            begin
                                
                                substate_next <= DECODE_OUT_X_IND_MDR_TO_MAR;
                            end
                            DECODE_OUT_X_IND_MDR_TO_MAR:
                            begin
                                
                                substate_next <= DECODE_OUT_X_WAIT_MEM;
                            end
                            DECODE_OUT_X_WAIT_MEM:
                            begin
                                
                                substate_next <= DECODE_OUT_X_READ_MEM;
                            end
                            DECODE_OUT_X_READ_MEM:
                            begin
                                
                                substate_next <= DECODE_OUT_X_MDR_TO_OUT;
                            end
                            DECODE_OUT_X_MDR_TO_OUT:
                            begin
                                
                                state_next <= STATE_FETCH;
                                substate_next <= DECODE_IN_LOAD_ACC;
                            end
                        endcase
                    end
                    STOP:
                    begin
                        case (substate_reg)
                            DECODE_STOP_X_TO_MAR:
                            begin
                                
                                substate_next <= DECODE_STOP_X_IND_WAIT_MEM;
                            end
                            DECODE_STOP_X_IND_WAIT_MEM:
                            begin
                                
                                substate_next <= DECODE_STOP_X_IND_READ_MEM;
                            end
                            DECODE_STOP_X_IND_READ_MEM:
                            begin
                                
                                substate_next <= DECODE_STOP_X_IND_MDR_TO_MAR;
                            end
                            DECODE_STOP_X_IND_MDR_TO_MAR:
                            begin
                                
                                substate_next <= DECODE_STOP_X_WAIT_MEM;
                            end
                            DECODE_STOP_X_WAIT_MEM:
                            begin
                                
                                substate_next <= DECODE_STOP_X_READ_MEM;
                            end
                            DECODE_STOP_X_READ_MEM:
                            begin
                                
                                substate_next <= DECODE_STOP_X_MDR_TO_OUT;
                            end
                            DECODE_STOP_X_MDR_TO_OUT:
                            begin
                                
                                substate_next <= DECODE_STOP_Y_TO_MAR;
                            end
                            DECODE_STOP_Y_TO_MAR:
                            begin
                                
                                substate_next <= DECODE_STOP_Y_IND_WAIT_MEM;
                            end
                            DECODE_STOP_Y_IND_WAIT_MEM:
                            begin
                                
                                substate_next <= DECODE_STOP_Y_IND_READ_MEM;
                            end
                            DECODE_STOP_Y_IND_READ_MEM:
                            begin
                                
                                substate_next <= DECODE_STOP_Y_IND_MDR_TO_MAR;
                            end
                            DECODE_STOP_Y_IND_MDR_TO_MAR:
                            begin
                                
                                substate_next <= DECODE_STOP_Y_WAIT_MEM;
                            end
                            DECODE_STOP_Y_WAIT_MEM:
                            begin
                                
                                substate_next <= DECODE_STOP_Y_READ_MEM;
                            end
                            DECODE_STOP_Y_READ_MEM:
                            begin
                                
                                substate_next <= DECODE_STOP_Y_MDR_TO_OUT;
                            end
                            DECODE_STOP_Y_MDR_TO_OUT:
                            begin
                                
                                substate_next <= DECODE_STOP_Z_TO_MAR;
                            end
                            DECODE_STOP_Z_TO_MAR:
                            begin
                                
                                substate_next <= DECODE_STOP_Z_IND_WAIT_MEM;
                            end
                            DECODE_STOP_Z_IND_WAIT_MEM:
                            begin
                                
                                substate_next <= DECODE_STOP_Z_IND_READ_MEM;
                            end
                            DECODE_STOP_Z_IND_READ_MEM:
                            begin
                                
                                substate_next <= DECODE_STOP_Z_IND_MDR_TO_MAR;
                            end
                            DECODE_STOP_Z_IND_MDR_TO_MAR:
                            begin
                                
                                substate_next <= DECODE_STOP_Z_WAIT_MEM;
                            end
                            DECODE_STOP_Z_WAIT_MEM:
                            begin
                                
                                substate_next <= DECODE_STOP_Z_READ_MEM;
                            end
                            DECODE_STOP_Z_READ_MEM:
                            begin
                                
                                substate_next <= DECODE_STOP_Z_MDR_TO_OUT;
                            end
                            DECODE_STOP_Z_MDR_TO_OUT:
                            begin
                                
                                state_next <= STATE_END;
                                substate_next <= END_DO;
                            end
                        endcase
                    end
                endcase
            end
            STATE_EXECUTE:
            begin
                case (substate_reg)
                    EXECUTE_DO:
                    begin
                        acc_in <= alu_out;
                        acc_ld <= 1;
                        alu_a <= acc_out;
                        alu_b <= mdr_out;
                        case (opcode)
                            ADD: alu_oc <= 3'b000;
                            SUB: alu_oc <= 3'b001;
                            MUL: alu_oc <= 3'b010;
                            DIV: alu_oc <= 3'b011;
                        endcase
                        state_next <= STATE_STORE;
                        substate_next <= STORE_X_TO_MAR;
                    end
                endcase
            end
            STATE_STORE:
            begin
                case (substate_reg)
                    STORE_X_TO_MAR:
                    begin
                        mar_in <= Xaddr;
                        mar_ld <= 1;
                        if (Xind == 1'b1)
                            substate_next <= STORE_X_IND_WAIT_MEM;
                        else 
                            substate_next <= STORE_X_WRITE_MEM;    
                    end
                    STORE_X_IND_WAIT_MEM:
                    begin
                        //addr <= mar_out;
                        substate_next <= STORE_X_IND_READ_MEM;
                    end
                    STORE_X_IND_READ_MEM:
                    begin
                        mdr_in <= mem;
                        mdr_ld <= 1;
                        substate_next <= STORE_X_IND_MDR_TO_MAR;
                    end
                    STORE_X_IND_MDR_TO_MAR:
                    begin
                        mar_in <= mdr_out[5:0];
                        mar_ld <= 1;
                        substate_next <= STORE_X_WRITE_MEM;
                    end
                    STORE_X_WRITE_MEM:
                    begin
                        mdr_in <= acc_out;
                        mdr_ld <= 1;
                        we_next = 1;
                        state_next <= STATE_FETCH;
                        substate_next <= 0;
                    end
                endcase
            end
            STATE_END:
            begin
                case (substate_reg)
                    END_DO:
                    begin
                        state_next <= STATE_END;
                        substate_next <= END_DO;
                    end
                endcase
            end
        endcase
    end

endmodule