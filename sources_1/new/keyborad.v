`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/21 00:56:11
// Design Name: 
// Module Name: keyborad
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


module keyborad(
    input wire clk,
    input wire kclk,
    input wire kdata,
    output wire up1, down1, left1, right1, fire1   //Player1
    //output reg up2, down2, left2, right2, fire2
    );
    reg r_up1 = 0, r_down1 = 0, r_left1 = 0, r_right1 = 0, r_fire1 = 0;
    
    localparam 
        UP1 = 8'h1D,          //W
        DOWN1 = 8'h1B,        //S
        LEFT1 = 8'h1C,        //A
        RIGHT1 = 8'h23,       //D
        FIRE1 = 8'h29;        //Space
    
    reg [10:0] datacur;
    reg [7:0]  dataprev;
    reg [3:0] cnt = 4'b0;
    reg isBreak = 1'b0;
    //wire kclkf, kdataf;
    
    always @(negedge kclk) begin
        datacur[cnt] = kdata;
        cnt = cnt + 1;
        if(cnt == 11) cnt = 0;
        if(datacur[8:1] == 8'hF0) isBreak = 1;
        if(isBreak == 1'b1) begin
             r_up1 = 0;
             r_down1 = 0;
             r_left1 = 0;
             r_right1 = 0;
             r_fire1 = 0;
             if(cnt == 0)
                isBreak = 0;
         end
         else begin       
            if(datacur[8:1] == UP1 && cnt == 0) begin 
                r_up1 = 1;  r_down1 = 0; r_left1 = 0; r_right1 = 0; 
            end
            else if(datacur[8:1] == DOWN1 && cnt == 0)begin 
                r_up1 = 0;  r_down1 = 1; r_left1 = 0; r_right1 = 0; 
            end
            else if(datacur[8:1] == LEFT1 && cnt == 0) begin 
                r_up1 = 0;  r_down1 = 0; r_left1 = 1; r_right1 = 0; 
            end
            else if(datacur[8:1] == RIGHT1 && cnt == 0) begin 
                r_up1 = 0;  r_down1 = 0; r_left1 = 0; r_right1 = 1; 
            end
            if(datacur[8:1] == FIRE1 && cnt == 0) r_fire1 = 1;  
         end                       
    end
    
    assign up1 = r_up1;
    assign down1 = r_down1;
    assign left1 = r_left1;
    assign right1 = r_right1;
    assign fire1 = r_fire1;
    
endmodule
