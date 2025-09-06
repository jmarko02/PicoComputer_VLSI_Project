module alu #(
    parameter DATA_WIDTH = 16
) (
    input [2:0] oc,
    input [HIGH : 0] a,
    input [HIGH : 0] b,
    output reg [HIGH : 0] f
);
    localparam HIGH = DATA_WIDTH - 1;

    always @(*) begin
        case (oc)
            3'b000: f = a + b;
            3'b001: f = a - b;
            3'b010: f = a * b;
            3'b011: f = a / b;
            3'b100: f = ~a;
            3'b101: f = a ^ b;
            3'b110: f = a | b;
            3'b111: f = a & b;
            default: ;
        endcase
    end
endmodule