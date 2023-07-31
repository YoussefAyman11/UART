`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/31/2023 07:10:38 AM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb();

parameter clk_period = 10;
reg clk = 0;
always #(clk_period/2) clk = ~clk;
parameter data_bits = 8;
parameter stop_ticks = 16;


reg reset;
reg [data_bits-1:0] data_in;
reg rd_en;
reg wr_en;
reg [9:0] timer_final_value;
wire rx_empty;
wire [data_bits-1:0] data_out;
wire tx_full;

top #(.data_bits(data_bits),.stop_ticks(stop_ticks)) dut(
    .clk(clk),
    .reset(reset),
    .data_in(data_in),
    .rd_en(rd_en),
    .wr_en(wr_en),
    .timer_final_value(timer_final_value),
    .rx_empty(rx_empty),
    .data_out(data_out),
    .tx_full(tx_full)
);

initial begin
timer_final_value = 'd650;
rd_en = 0;
reset = 0;
#(clk_period);
reset = 1;
#(10*clk_period);
wr_en = 1;
data_in = 'b10011010;
#10;
wr_en = 0;
#10;
wr_en = 1;
data_in = 'b01101011;
#10;
wr_en = 0;
#10;
wr_en = 1;
data_in = 'b11001000;
#10;
wr_en = 0;
#(400000*clk_period);
rd_en = 1;
#(clk_period)
rd_en = 0;
#(10000*clk_period);
rd_en = 1;

data_in = 'b00110101;
wr_en = 1;
#(300000*clk_period);

$finish();
end


endmodule
