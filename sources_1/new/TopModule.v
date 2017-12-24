`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/22 18:51:24
// Design Name: 
// Module Name: TopModule
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


module TopModule(
    input wire sys_clk,
    input wire sys_rst_n,
    //Keyoboard
    input wire kclk,
    input wire kdata,
    //VGA
    output wire hsync,
    output wire vsync,
    output wire [11:0] rgb
    );
    
    wire clk_50m,clk_25m;
    wire [9:0] pixel_x, pixel_y;
    wire [4:0] player1_btns, player2_btns;
    wire [7:0] screen_data;
    wire valid;
    
    ClkGen U_CLKGEN_0(
        .clk_in1(sys_clk),
        .clk_out1(clk_50m),
        .clk_out2(clk_25m)
    );
    
    GameScene U_GAMESCENE_0(
        .clk_25m(clk_25m),
        .rst_n(sys_rst_n),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .player1_btns(player1_btns),
        .player2_btns(player2_btns),
        .screen_data(screen_data)
    );
    
    Keyboard U_KEYBOARD_0(
        .clk_50m(clk_50m),
        .kclk(kclk),
        .kdata(kdata),
        .player1_btns(player1_btns),
        .player2_btns(player2_btns)
    );
    
    VGAColorize U_VGACOLORIZE_0(
        .clk_25m(clk_25m),
        .rst_n(sys_rst_n),
        .valid(valid),
        .screen_data(screen_data),
        .rgb(rgb)
    );
    
    VGASync U_VGASYNC_0(
        .clk_25m(clk_25m),
        .rst_n(sys_rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .valid(valid),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );
    
endmodule
