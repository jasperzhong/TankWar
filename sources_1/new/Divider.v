`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/20 08:09:31
// Design Name: 
// Module Name: ex7
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


module Divider
#(parameter DIV = 20)
(
    input I_CLK,
    input rst_n,
    output O_CLK
    );
    reg clk = 0;
    reg [31:0] cnt;
    
    always @(posedge I_CLK)
    begin
        if(!rst_n)
        begin
            cnt <= 32'd0;
            clk <= 0;
        end
        else 
        begin
          if(cnt == (DIV/2)-1)
          begin
            cnt <= 32'd0;
            clk <= ~clk;
          end
          else
            cnt <= cnt + 32'd1;
        end
    end
    
    assign O_CLK = clk;

endmodule
