`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/25 15:55:55
// Design Name: 
// Module Name: Debouncer
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


module Debouncer(
    input clk_50m,
    input input0,
    input input1,
    output reg output0,
    output reg output1
    );
    reg [4:0] cnt0, cnt1;
    reg Iv0 = 0, Iv1 = 0;
    reg out0, out1;
    
    always @(posedge clk_50m)
    begin
        if(input0 == Iv0)
        begin
            if(cnt0 == 19)
                output0 <= input0;
            else
                cnt0 <= cnt0 + 1;
        end
        else
        begin
            cnt0 <= 5'b00000;
            Iv0 <= input0;
        end
        
        if(input1 == Iv1)
        begin
            if(cnt1 == 19)
                output1 <= input1;
            else
                cnt1 <= cnt1 + 1;
        end
        else
        begin
            cnt1 <= 5'b00000;
            Iv1 <= input1;
        end
    end
    
endmodule
