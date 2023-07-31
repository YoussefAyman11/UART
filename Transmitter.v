`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2023 03:32:53 PM
// Design Name: 
// Module Name: Transmitter
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


module Transmitter
    #(parameter data_bits = 8,stop_ticks = 16)(
    input clk,
    input reset,
    input tx_start,
    input [data_bits-1:0] data_in,
    input timer_done,
    output data_out,
    output reg tx_done
    );
    
    localparam idle = 'b00;
    localparam start = 'b01;
    localparam data = 'b10;
    localparam stop = 'b11;
    
    reg [$clog2(data_bits)-1:0] n_reg,n_next;
    reg [1:0] state_reg,state_next;
    reg [$clog2(stop_ticks)-1:0] cntr_reg,cntr_next;
    reg data_reg,data_next;

    
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
        tx_done = 'b0;
        case(state_reg)
            idle: begin
                data_next = 1;
                if(tx_start) begin
                    state_next = start;
                    cntr_next = 0;
                end
                else begin
                    state_next = idle;
                end
            end
            
            start: begin
                data_next = 0;
                if(timer_done) begin
                    if(cntr_next == 15) begin
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
                data_next = data_in[n_reg];
                if(timer_done) begin
                    if(cntr_next == 15) begin
                        cntr_next = 0;
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
                data_next = 1;
                if(timer_done) begin
                    if(cntr_next == stop_ticks-1) begin
                        tx_done = 'b1;
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
