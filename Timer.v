`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2023 02:05:58 PM
// Design Name: 
// Module Name: Timer
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


module Timer(
    input clk,
    input [9:0] final_value,
    input reset,
    input enable,
    output done
    );
    
    reg [9:0] Q_reg,Q_next;
    
    always @(posedge clk,negedge reset) begin
        if(!reset)
            Q_reg <= 'b0;
        else if(enable)
            Q_reg <= Q_next;
        else
            Q_reg <= Q_reg;
    end
    
    assign done = (Q_reg == final_value);
    
    always @(*) begin
        Q_next = done?('b0):(Q_reg + 1);
    end
    
endmodule
