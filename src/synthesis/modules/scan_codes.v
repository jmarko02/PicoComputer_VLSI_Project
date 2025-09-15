 module scan_codes (
    input clk,
    input rst_n,
    input [15:0] code,
    input status,
    output reg control,
    output reg [3:0] num
);

    localparam SCANCODE_0 = 8'h45;
    localparam SCANCODE_1 = 8'h16;
    localparam SCANCODE_2 = 8'h1E;
    localparam SCANCODE_3 = 8'h26;
    localparam SCANCODE_4 = 8'h25;
    localparam SCANCODE_5 = 8'h2E;
    localparam SCANCODE_6 = 8'h36;
    localparam SCANCODE_7 = 8'h3D;
    localparam SCANCODE_8 = 8'h3E;
    localparam SCANCODE_9 = 8'h46;

    localparam SCANCODE_BREAK = 8'hF0;

    reg [3:0] num_prev;
    wire key_released = code[15:8] == SCANCODE_BREAK;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            control <= 1'b0;
            num <= 4'b0;
            num_prev <= 4'b0;
        end
        else begin
            if(status == 1'b1) begin 
                case (code[7:0]) 
                SCANCODE_0: 
                begin
                    num <= 0;
                end
                SCANCODE_1: 
                begin
                    num <= 1;
                end
                SCANCODE_2: 
                begin
                    num <= 2;
                end
                SCANCODE_3: 
                begin
                    num <= 3;
                end
                SCANCODE_4: 
                begin
                    num <= 4;
                end
                SCANCODE_5: 
                begin
                    num <= 5;
                end
                SCANCODE_6: 
                begin
                    num <= 6;
                end
                SCANCODE_7: 
                begin
                    num <= 7;
                end
                SCANCODE_8: 
                begin
                    num <= 8;
                end
                SCANCODE_9: 
                begin
                    num <= 9;
                end
                default: ;
                endcase
                if (key_released && num != num_prev) begin
                    control <= 1'b1;
                end
            end
            else begin 
                control <= 1'b0;
                num_prev <= num;
            end
        end
    end

endmodule