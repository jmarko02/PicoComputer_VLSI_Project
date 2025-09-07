module vga (
    input clk,
    input rst_n,
    input [23:0] code,
    output wire hsync,
    output wire vsync,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue
);

    localparam X_VIS = 800;
    localparam X_FRONTPORCH = 56;
    localparam X_SYNCPULSE = 120;
    localparam X_BACKPORCH = 64;

    localparam X_SYNCSTART = X_VIS + X_FRONTPORCH;
    localparam X_SYNCEND = X_SYNCSTART + X_SYNCPULSE;
    localparam X_LINEEND = X_SYNCEND + X_BACKPORCH;

    
    localparam Y_VIS = 600;
    localparam Y_FRONTPORCH = 37;
    localparam Y_SYNCPULSE = 6;
    localparam Y_BACKPORCH = 23;

    localparam Y_SYNCSTART = Y_VIS + Y_FRONTPORCH;
    localparam Y_SYNCEND = Y_SYNCSTART + Y_SYNCPULSE;
    localparam Y_LINEEND = Y_SYNCEND + Y_BACKPORCH;


    reg [10:0] x_reg, x_next;
    reg [9:0] y_reg, y_next;

    assign {red, green, blue} = (x_reg < X_VIS && y_reg < Y_VIS) ?
    (x_reg < (X_VIS/2) ? code[23:12] : code[11:0]) : 0;

    assign hsync = x_reg >= X_SYNCSTART && x_reg < X_SYNCEND;
    assign vsync = y_reg >= Y_SYNCSTART && y_reg < Y_SYNCEND;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            x_reg <= 0;
            y_reg <= 0;
        end
        else begin
            x_reg <= x_next;
            y_reg <= y_next;
        end
    end

    always @(*) begin
        if (x_reg == X_LINEEND - 1) begin
            x_next = 0;
            if (y_reg == Y_LINEEND - 1)
                y_next = 0;
            else
                y_next = y_reg + 1;
        end else begin
            x_next = x_reg + 1; 
            y_next = y_reg;
        end
    end
    
endmodule