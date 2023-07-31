`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2023 02:10:55 PM
// Design Name: 
// Module Name: Receiver
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


module Receiver
    #(parameter data_bits = 8,stop_ticks = 16)(
    input clk,
    input reset,
    input data_in,
    input timer_done,
    output [data_bits-1:0] data_out,
    output reg rx_done
    );
    
    localparam idle = 'b00;
    localparam start = 'b01;
    localparam data = 'b10;
    localparam stop = 'b11;
    
    reg [1:0] state_reg,state_next;
    reg [$clog2(stop_ticks)-1:0] cntr_reg,cntr_next;
    reg [$clog2(data_bits)-1:0] n_reg,n_next;
    reg [data_bits-1:0]data_reg,data_next;
    
    always @(posedge clk,negedge reset) begin
        if(!reset) begin
            state_reg <= idle;
            cntr_reg <= 0;
            n_reg <= 0;
            data_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            cntr_reg <= cntr_next;
            n_reg <= n_next;
            data_reg <= data_next;
        end
    end
    
    always @(*) begin
        state_next = state_reg;
        cntr_next = cntr_reg;
        n_next = n_reg;
        data_next = data_reg;
        rx_done = 'b0;
        case(state_reg)
            idle: begin
                if(data_in == 0) begin
                    state_next = start;
                    cntr_next = 0;
                end
                else
                    state_next = idle;
            end
            
            start: begin
                if(timer_done) begin
                    if(cntr_next == 7) begin
                        cntr_next = 0;
                        n_next = 0;
                        state_next = data;
                    end
                    else begin
                        cntr_next = cntr_reg + 1;
                        state_next = start;
                    end
                end
                else
                    state_next = start;
            end
            
            data: begin
                if(timer_done) begin
                    if(cntr_next == 15) begin
                        cntr_next = 0;
                        data_next[n_reg] = data_in;
                        if(n_reg == data_bits-1)
                            state_next = stop;
                        else begin
                            state_next = data;
                            n_next = n_reg + 1;
                        end
                    end
                    else begin
                        cntr_next = cntr_reg + 1;
                        state_next = data;
                    end
                end
                else
                    state_next = data;
            end
            
            stop: begin
                if(timer_done) begin
                    if(cntr_next == stop_ticks-1) begin
                        rx_done = 'b1;
                        state_next = idle;
                    end
                    else begin
                        cntr_next = cntr_reg + 1;
                        state_next = stop;
                    end
                end
                else
                    state_next = stop;
            end
            
            default: state_next = idle;
        endcase
    end
    
    assign data_out = data_reg;
    
endmodule
