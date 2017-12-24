`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/22 18:51:24
// Design Name: 
// Module Name: Keyboard
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


module Keyboard(
    input wire clk_50m,
    input wire kclk,
    input wire kdata,
    output reg [4:0] player1_btns,
    output reg [4:0] player2_btns
    );
    
    reg [10:0] datacur;
    reg [3:0] cnt;
    reg isBreak;
    
    localparam 
        UP1 = 8'h1D,
        DOWN1 = 8'h1B,
        LEFT1 = 8'h1C,
        RIGHT1 = 8'h23,
        FIRE1 = 8'h29,
        
        UP2 = 8'h43,
        DOWN2 = 8'h42,
        LEFT2 = 8'h3B,
        RIGHT2 = 8'h4B,
        FIRE2 = 8'h5A;
    
    initial
    begin
        cnt = 4'b0000;
        isBreak = 1'b0;
    end
    
    always @(negedge kclk)
    begin      
        if(isBreak == 1'b1)
            case(datacur[8:1])
                UP1,DOWN1,LEFT1,RIGHT1: begin player1_btns = 5'b00000; end
                UP2,DOWN2,LEFT2,RIGHT2: begin player2_btns = 5'b00000; end
            endcase              
        else 
        begin
            if(cnt == 0)
            begin
                //Íæ¼Ò1
                case (datacur[8:1])
                    UP1:    player1_btns = 5'b00001;
                    DOWN1:  player1_btns = 5'b00010;
                    LEFT1:  player1_btns = 5'b00100;
                    RIGHT1: player1_btns = 5'b01000;
                    FIRE1:  player1_btns = 5'b10000;
                    default:
                        player1_btns = 5'b00000;
                endcase
                
                //Íæ¼Ò2
                case (datacur[8:1])
                    UP2:    player2_btns = 5'b00001;
                    DOWN2:  player2_btns = 5'b00010;
                    LEFT2:  player2_btns = 5'b00100;
                    RIGHT2: player2_btns = 5'b01000;
                    FIRE2:  player2_btns = 5'b10000;
                    default:
                        player2_btns = 5'b00000;
                endcase                
             end
        end
    end
    
    always @(negedge kclk)
    begin
        datacur[cnt] = kdata;
        cnt = cnt + 1;
        if(cnt == 11) 
            cnt = 4'b0;
    end
    
    always @(*)
        if(datacur[cnt] == 8'hF0)
            isBreak = 1'b1;
        else    
            isBreak = 1'b0;
            
endmodule
