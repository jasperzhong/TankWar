`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/20 00:58:17
// Design Name: 
// Module Name: VGA_sync
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

module VGA_sync
    #(parameter WIDTH = 800,
                 HEIGHT = 525,
                 REAL_WIDTH = 640,
                 REAL_HEIGHT = 480
                )
(  
        input   wire            clk,  
        input   wire            rst_n,  
        input   wire    [9:0]   pos_x,
        input   wire    [9:0]   pos_y,        
        output  wire            valid,
        output  wire            hsync,                 //行同步信号  
        output  wire            vsync,                 //场同步信号  
        output  wire    [9:0]   px,               //待显示待像素的x坐标  
        output  wire    [9:0]   py                //待显示待像素的y坐标   
        );  
        
        reg [9:0] pixel_x;
        reg [9:0] pixel_y;
        
        assign hsync = (pixel_x > 95);
        always @(posedge clk,  negedge rst_n)  
            if(!rst_n)  
                pixel_x <= 10'b0;  
            else       
                if(pixel_x == WIDTH - 1)  
                    pixel_x <= 10'b0; 
                else 
                    pixel_x <= pixel_x + 1'b1;   
                  
         assign vsync = (pixel_y > 1);                
         always @(posedge clk, negedge rst_n)  
            if(!rst_n)  
               pixel_y <= 10'b0;
            else  
               if(pixel_x == WIDTH - 1)  
                    if(pixel_y == HEIGHT - 1)  
                        pixel_y <= 10'b0;  
                    else
                        pixel_y <= pixel_y + 1'b1;   
                        
         assign px = pixel_x - pos_x - 1;
         assign py = pixel_y - pos_y - 1;
         assign valid = (pixel_x>pos_x  && pixel_x<pos_x+REAL_WIDTH+1) &&
                        (pixel_y>pos_y  && pixel_y<pos_y+REAL_HEIGHT+1);
endmodule  