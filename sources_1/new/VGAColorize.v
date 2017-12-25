`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/22 18:51:24
// Design Name: 
// Module Name: VGAColorize
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: иои╚
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGAColorize(
    input wire clk_25m,
    input wire rst_n,
    input wire valid,
    input wire [7:0] screen_data,
    output reg [11:0] rgb
    );
    
    always @(posedge clk_25m, negedge rst_n)
    begin
        if(!rst_n)
            rgb <= 12'b0;
        else if(valid)
        begin
            rgb[3:0] <= {screen_data[7:5], 1'b0};
            rgb[7:4] <= {screen_data[4:2], 1'b0};
            rgb[11:8]<= {screen_data[1:0], 2'b0};
        end
        else
            rgb <= 12'b0;
    end
    
endmodule
