
module top #(
    parameter DIVISOR = 50000000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input wire clk,
    input wire [1:0] kbd,
    input wire [2:0] btn,
    input wire [9:0] sw,
    output wire [13:0] mnt,
    output wire [9:0] led,
    output wire [27:0] ssd
);

    wire rst_n = sw[9];

    wire divided_clk;
    
    wire [DATA_WIDTH - 1:0] mem_out;
    wire we;
    wire [ADDR_WIDTH - 1:0] mem_addr;
    wire [DATA_WIDTH - 1:0] mem_in;
    
    wire [DATA_WIDTH - 1:0] cpu_out;
    wire [ADDR_WIDTH - 1:0] cpu_pc;
    wire [ADDR_WIDTH - 1:0] cpu_sp;
    
    wire control;
    wire status;
    wire [DATA_WIDTH - 1:0] cpu_in;


    clk_div #(.DIVISOR(DIVISOR)
    ) clk_div1 (
        .clk(clk),
        .rst_n(rst_n), 
        .out(divided_clk)
    );

    memory #(
        .FILE_NAME(FILE_NAME),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)        
    ) mem1 (
        .clk(divided_clk),
        .we(we),
        .addr(mem_addr),
        .data(mem_in),
        .out(mem_out)
    );

    cpu #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) cpu1 (
        .clk(divided_clk),
        .rst_n(rst_n),
        .mem(mem_out),
        .in(cpu_in),
        .control(control),
        .status(status),
        .we(we),
        .data(mem_in),
        .addr(mem_addr),
        .out(cpu_out),
        .pc(cpu_pc),
        .sp(cpu_sp)
    );

    assign led[4:0] = cpu_out[4:0];
    assign led[5] = status;
    assign led[9:6] = 0;

    // only for testing, replace with PS2+scancodes
    assign control = btn[0];
    assign cpu_in = sw[5:0];

    wire [3:0] pc_ones;
    wire [3:0] pc_tens;
    bcd bcd_pc (
        .in(cpu_pc),
        .ones(pc_ones),
        .tens(pc_tens)
    );

    wire [3:0] sp_ones;
    wire [3:0] sp_tens;
    bcd bcd_sp (
        .in(cpu_sp),
        .ones(sp_ones),
        .tens(sp_tens)
    );

    ssd ssd_pc_ones (
        .in(pc_ones),
        .out(ssd[6:0])
    );

    ssd ssd_pc_tens (
        .in(pc_tens),
        .out(ssd[13:7])
    );

    ssd ssd_sp_ones (
        .in(sp_ones),
        .out(ssd[20:14])
    );

    ssd ssd_sp_tens (
        .in(sp_tens),
        .out(ssd[27:21])
    );

    wire [23:0] color_code;
    color_codes color_codes_cpu_out(
        .num(cpu_out[5:0]), 
        .code(color_code)
    );
    
    vga vga1 (
        .clk(divided_clk),
        .rst_n(rst_n),
        .code(color_code),
        .hsync(mnt[13]),
        .vsync(mnt[12]),
        .red(mnt[11:8]),
        .green(mnt[7:4]),
        .blue(mnt[3:0]),
    );

endmodule