`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/20 00:40:48
// Design Name: 
// Module Name: VGA_sprite
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Sprite Generator
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGA_sprite
    #(parameter WIDTH = 800,
                 HEIGHT = 525,
                 REAL_WIDTH = 640,
                 REAL_HEIGHT = 480,
                 ADDR_WIDTH = 31
                 )
(
        input wire clk25m,    
        input wire rst_n,      
        input wire  [7:0] data_in,
        input wire [9:0] pos_x, pos_y,
        output wire hsync,    
        output wire vsync,    
        output reg  [11:0] rgb,
        output reg  [ADDR_WIDTH:0] address
        );    
        
        wire[9:0] px;
        wire[9:0] py;
        wire  valid;

        always @ (posedge clk25m, negedge rst_n) 
            if(!rst_n)
                address <= 0;
            else
                if(valid)
                      address <= px + py*REAL_WIDTH;
                else
                      address <= 0;
       
       always @ (posedge clk25m, negedge rst_n)
            if(!rst_n)
                rgb <= 0;
            else
                begin
                    if(valid) begin
                        rgb[3:0] <= {data_in[7:5],1'b0};
                        rgb[7:4] <= {data_in[4:2],1'b0};
                        rgb[11:8] <= {data_in[1:0],1'b0};
                    end
                    else
                        rgb <= 0;
                end
                                  
       VGA_sync    #(
             .WIDTH(WIDTH),
             .HEIGHT(HEIGHT),
             .REAL_WIDTH(REAL_WIDTH),
             .REAL_HEIGHT(REAL_HEIGHT)
             ) 
        vga_scan
       (
            .clk(clk25m),
            .rst_n(rst_n),
            .pos_x(pos_x),
            .pos_y(pos_y),
            .valid(valid),
            .hsync(hsync),
            .vsync(vsync),
            .px(px),
            .py(py)
       );
  
endmodule  

