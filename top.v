`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/30/2023 11:44:26 PM
// Design Name: 
// Module Name: top
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


module top
    #(parameter data_bits = 8,stop_ticks = 16)(
    input clk,
    input reset,
    input [data_bits-1:0] data_in,
    input rd_en,
    input wr_en,
    input [9:0] timer_final_value,
    output rx_empty,
    output [data_bits-1:0] data_out,
    output tx_full
    );
    
    wire rx_in,timer_done_sig,rx_done_sig,tx_done_sig,tx_fifo_empty;
    wire [data_bits-1:0] rx_out,tx_in;
    
    Timer t(
        .clk(clk),
        .reset(reset),
        .final_value(timer_final_value),
        .enable('b1),
        .done(timer_done_sig)
    );
    
    Receiver #(.data_bits(data_bits),.stop_ticks(stop_ticks)) rx(
        .clk(clk),
        .reset(reset),
        .data_in(rx_in),
        .timer_done(timer_done_sig),
        .data_out(rx_out),
        .rx_done(rx_done_sig)
    );
    
    fifo_generator_0 rx_fifo (
        .clk(clk),      // input wire clk
        .srst(~reset),    // input wire srst
        .din(rx_out),      // input wire [7 : 0] din
        .wr_en(rx_done_sig),  // input wire wr_en
        .rd_en(rd_en),  // input wire rd_en
        .dout(data_out),    // output wire [7 : 0] dout
        .full(),    // output wire full
        .empty(rx_empty)  // output wire empty
);

    Transmitter #(.data_bits(data_bits),.stop_ticks(stop_ticks)) tx(
        .clk(clk),
        .reset(reset),
        .tx_start(~tx_fifo_empty),
        .data_in(tx_in),
        .timer_done(timer_done_sig),
        .data_out(rx_in),
        .tx_done(tx_done_sig)
    );

    fifo_generator_0 tx_fifo (
        .clk(clk),      // input wire clk
        .srst(~reset),    // input wire srst
        .din(data_in),      // input wire [7 : 0] din
        .wr_en(wr_en),  // input wire wr_en
        .rd_en(tx_done_sig),  // input wire rd_en
        .dout(tx_in),    // output wire [7 : 0] dout
        .full(tx_full),    // output wire full
        .empty(tx_fifo_empty)  // output wire empty
);
    
endmodule
