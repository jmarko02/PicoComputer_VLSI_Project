module bcd (
    input [5:0] in,
    output [3:0] ones,
    output [3:0] tens 
);
    // genvar i;
    // generate 
    //     for (i = 0; i < 2 ; i = i + 1 ) begin
    //         wire [3:0] digit = in / 10**i % 10;
    //         hex hex_inst(digit, out[ (4*(i+1)-1) : 4 * i]);                
    //     end
    // endgenerate
    assign ones = in % 10;
    assign tens = in / 10;
endmodule