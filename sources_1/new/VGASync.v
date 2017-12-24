`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/22 18:51:24
// Design Name: 
// Module Name: VGASync
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 扫描VGA
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGASync(
    input wire clk_25m,
    input wire rst_n,
    output wire hsync,
    output wire vsync,
    output wire valid,
    output reg [9:0] pixel_x,
    output reg [9:0] pixel_y
    );
    
    localparam WIDTH = 800;
    localparam HEIGHT = 525;
    localparam HSYNC_START = 655;
    localparam HSYNC_END = 750;
    localparam VSYNC_START = 490;
    localparam VSYNC_END = 491;
    
    //行扫描
    always @(posedge clk_25m, negedge rst_n)
    begin
        if(!rst_n)
            pixel_x <= 0;
        else
        begin
            if(pixel_x == WIDTH - 1)
                pixel_x <= 10'b0;
            else
                pixel_x <= pixel_x + 10'b1;
        end
    end
    
    //场扫描
    always @(posedge clk_25m, negedge rst_n)
    begin
        if(!rst_n)
            pixel_y <= 0;
        else
        begin
            if(pixel_x == WIDTH - 1)
                if(pixel_y == HEIGHT - 1)   
                    pixel_y <= 10'b0;
                else
                    pixel_y <= pixel_y + 10'b1;
        end
    end
    
    //同步信号
    assign hsync = !((pixel_x >= HSYNC_START) && (pixel_x <= HSYNC_END));
    assign vsync = !((pixel_y >= VSYNC_START) && (pixel_y <= VSYNC_START));
    assign valid = ((pixel_x < 640) && (pixel_y < 480));
endmodule
