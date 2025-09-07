module TESTBENCH_TOP (
    
);

reg clk, rst_n, control;
reg [15:0] in;

// clk_div #(10) divider(clk, rst_n, out);

wire[5:0] pc, sp, addr;
wire we,status;
wire[15:0] data, out, mem;

memory memory_inst(clk, we, rst_n, addr, data, mem);

cpu cpu_inst(clk, rst_n, mem, in, control, status, we, addr, data, out, pc, sp);

initial begin
    $monitor("Vreme: %2d, pc = %b, sp = %b, out = %b", $time, pc, sp, out);
    control = 1'b1;
    in = 16'h0008;
    rst_n = 1'b0;
    clk = 1'b0;
    #1 rst_n = 1'b1;
    #500 in = 16'h0009;
    #700 in = 16'h0003;
    #500 $finish;
end

always begin
    #5 clk = ~clk;
end
    
endmodule