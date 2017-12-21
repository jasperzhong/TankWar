`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/21 01:22:44
// Design Name: 
// Module Name: player_controller
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


module player_controller(
    input wire up, down, left, right, fire,
    input wire speed,
    input wire [9:0] prev_x, prev_y,
    output wire direction,
    output wire state,
    output reg next_x, next_y
    );
    
    assign direction = (up == 1)? 2'b00 :
                       (down==1)? 2'b01 :
                       (left==1)? 2'b10 :
                       (right==1)?2'b11 : 2'b00;
    assign state = (up || down || left || right)? 2'b01 : 
                    (fire) ? 2'b01 : 2'b10;
    
    //Move
    always @(*) begin
        next_x = prev_x;
        next_y = prev_y;
        if(up) 
            next_y = prev_y - speed;
        if(down)
            next_y = prev_y + speed;
        if(left)
            next_x = prev_x - speed;
        if(right)
            next_x = prev_x + speed;
    end
    
endmodule
