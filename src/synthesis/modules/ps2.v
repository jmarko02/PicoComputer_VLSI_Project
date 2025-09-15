module ps2 (
    input clk,
    input rst_n,
    input ps2_clk,
    input ps2_data,
    output reg [15:0] code
);
    wire ps2_fall_event = ~ps2_sync[0] & ps2_sync[1];
    reg [1:0] ps2_sync;

    reg [10:0] shift_reg;

    integer counter;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            ps2_sync <= 2'b0;
        end
        else begin
            ps2_sync[0] <= ps2_clk;
            ps2_sync[1] <= ps2_sync[0];
        end   
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            counter <= 4'd0;
        end
        else if (ps2_fall_event) begin
            if(counter == 4'd10) begin
                counter <= 4'd0;
            end else begin
                counter <= counter + 4'd1;
            end
        end
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            shift_reg <= 11'd0;
            code <= 16'd0;
        end
        else if (ps2_fall_event) begin
            shift_reg <= {ps2_data, shift_reg[10:1]};
            if (counter == 0 && shift_reg[0] == 1'b0 && shift_reg[10] == 1'b1) begin
                if(^shift_reg[9:1] == 1'b1) begin
                    code <= {shift_reg[8:1], code[15:8]};
                end
                else begin
                    code <= {8'he0, code[15:8]};
                end
            end
        end
    end

    
endmodule