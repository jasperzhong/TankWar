`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/22 18:51:24
// Design Name: 
// Module Name: GameScene
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


module GameScene(
    input wire clk_25m,
    input wire rst_n,
    input wire [9:0] pixel_x,
    input wire [9:0] pixel_y,
    input wire [4:0] player1_btns,
    input wire [4:0] player2_btns,
    output reg [7:0] screen_data
    );
    
    //用于对应btns
    localparam 
        UP   = 5'b00001,
        DOWN = 5'b00010,
        LEFT = 5'b00100,
        RIGHT= 5'b01000,
        FIRE = 5'b10000;
    
    localparam
        DIR_UP   = 2'b00,
        DIR_DOWN = 2'b01,
        DIR_LEFT = 2'b10,
        DIR_RIGHT= 2'b11;
    
    localparam 
        TANK_WIDTH = 32,
        TANK_HEIGHT = 32;
    
    localparam 
        FLAG_TANK_CNT = 100000,
        FLAG_BULLET_CNT = 10000;
    
    reg flag;
    reg [31:0] flag_cnt;
    
    reg red_stop = 1'b0;
    reg green_stop = 1'b0;
    //坦克方向
    reg [2:0] red_tank_dir;
    reg [2:0] green_tank_dir;
    
    //坦克起始位置
    reg [9:0] red_tank_start_pos_x;
    reg [9:0] red_tank_start_pos_y;
    
    reg [9:0] green_tank_start_pos_x;
    reg [9:0] green_tank_start_pos_y;    
    
    //ROM数据
    reg [18:0] map_addr;
    wire [7:0] map_data;
    
    reg [9:0] red_tank_up_addr;
    wire [7:0] red_tank_up_data;
    
    reg [9:0] red_tank_left_addr;
    wire [7:0] red_tank_left_data;
    
    reg [9:0] green_tank_up_addr;
    wire [7:0] green_tank_up_data;
    
    reg [9:0] green_tank_left_addr;
    wire [7:0] green_tank_left_data;
    

    //ROM数据
    MapROM U_MAPROM_0(
        .clka(clk_25m),
        .addra(map_addr),
        .douta(map_data)
    );
    
    RedTankUpROM U_REDTANKUPROM_0(
        .clka(clk_25m),
        .addra(red_tank_up_addr),
        .douta(red_tank_up_data)
    );  
        
    RedTankLeftROM U_REDTANKLEFTROM_0(
        .clka(clk_25m),
        .addra(red_tank_left_addr),
        .douta(red_tank_left_data)
    );
    
    GreenTankUpROM U_GREENTANKUPROM_0(
        .clka(clk_25m),
        .addra(green_tank_up_addr),
        .douta(green_tank_up_data)
    );    
    
    GreenTankLeftROM U_GREENTANKLEFTROM_0(
        .clka(clk_25m),
        .addra(green_tank_left_addr),
        .douta(green_tank_left_data)
    );
    
    //红坦克方向  keyboard -> fsm   fsm下一个状态
    always @(posedge clk_25m, negedge rst_n)
    begin
        if(!rst_n)
            red_tank_dir <= DIR_UP;
        else
        begin
            case (player1_btns)
                UP:     red_tank_dir <= DIR_UP;
                DOWN:   red_tank_dir <= DIR_DOWN;
                LEFT:   red_tank_dir <= DIR_LEFT;
                RIGHT:  red_tank_dir <= DIR_RIGHT;
                default:red_tank_dir <= red_tank_dir;
            endcase
        end  
    end
    
    //绿坦克方向  keyboard -> fsm
    always @(posedge clk_25m, negedge rst_n)
    begin
        if(!rst_n)
            green_tank_dir <= DIR_UP;
        else
        begin
            case (player2_btns)
                UP:     green_tank_dir <= DIR_UP;
                DOWN:   green_tank_dir <= DIR_DOWN;
                LEFT:   green_tank_dir <= DIR_LEFT;
                RIGHT:  green_tank_dir <= DIR_RIGHT;
                default:green_tank_dir <= green_tank_dir;
            endcase
        end  
    end    
    
    //VGA显示  fsm -> VGA   fsm输出
    always @(posedge clk_25m, negedge rst_n)
    begin
        if(!rst_n)
        begin
            map_addr <= 19'b0;
            screen_data <= 8'b0;
        end
        else
        begin
            map_addr <= pixel_x + pixel_y*640;
            screen_data <= map_data;
        end
        
        if(!rst_n)
        begin
            red_tank_up_addr <= 10'b0;
            red_tank_left_addr <= 10'b0;
        end
        else
        begin
            case (red_tank_dir)
                DIR_UP: 
                    if((pixel_x == red_tank_start_pos_x) && (pixel_y == red_tank_start_pos_y))
                        red_tank_up_addr <= 5'b0;
                    else if((pixel_x >= red_tank_start_pos_x) && (pixel_x <= red_tank_start_pos_x + 31) &&
                    (pixel_y >= red_tank_start_pos_y) && (pixel_y <= red_tank_start_pos_y + 31))
                    begin
                        red_tank_up_addr <= red_tank_up_addr + 5'b1;
                        screen_data <= red_tank_up_data;
                    end
                    else
                        red_tank_up_addr <= red_tank_up_addr;
                DIR_DOWN:
                    if((pixel_x == red_tank_start_pos_x) && (pixel_y == red_tank_start_pos_y))
                        red_tank_up_addr <= 5'b11111;
                    else if((pixel_x >= red_tank_start_pos_x) && (pixel_x <= red_tank_start_pos_x + 31) &&
                    (pixel_y >= red_tank_start_pos_y) && (pixel_y <= red_tank_start_pos_y + 31))
                    begin
                        red_tank_up_addr <= red_tank_up_addr - 5'b1;
                        screen_data <= red_tank_up_data;
                    end
                    else
                        red_tank_up_addr <= red_tank_up_addr;     
                DIR_LEFT:
                    if((pixel_x == red_tank_start_pos_x) && (pixel_y == red_tank_start_pos_y))
                        red_tank_left_addr <= 5'b0;
                    else if((pixel_x >= red_tank_start_pos_x) && (pixel_x <= red_tank_start_pos_x + 31) &&
                    (pixel_y >= red_tank_start_pos_y) && (pixel_y <= red_tank_start_pos_y + 31))
                    begin
                        red_tank_left_addr <= red_tank_left_addr + 5'b1;
                        screen_data <= red_tank_left_data;
                    end
                    else
                        red_tank_left_addr <= red_tank_left_addr; 
                DIR_RIGHT:
                    if((pixel_x == red_tank_start_pos_x) && (pixel_y == red_tank_start_pos_y))
                        red_tank_left_addr <= 5'b11111;
                    else if((pixel_x >= red_tank_start_pos_x) && (pixel_x <= red_tank_start_pos_x + 31) &&
                    (pixel_y >= red_tank_start_pos_y) && (pixel_y <= red_tank_start_pos_y + 31))
                    begin
                        red_tank_left_addr <= red_tank_left_addr - 5'b1;
                        screen_data <= red_tank_left_data;
                    end
                    else
                        red_tank_left_addr <= red_tank_left_addr;                                                           
            endcase 
        end
        
        if(!rst_n)
        begin
            green_tank_up_addr <= 10'b0;
            green_tank_left_addr <= 10'b0;
        end
        else
        begin
            case (green_tank_dir)
                DIR_UP: 
                    if((pixel_x == green_tank_start_pos_x) && (pixel_y == green_tank_start_pos_y))
                        green_tank_up_addr <= 5'b0;
                    else if((pixel_x >= green_tank_start_pos_x) && (pixel_x <= green_tank_start_pos_x + 31) &&
                    (pixel_y >= green_tank_start_pos_y) && (pixel_y <= green_tank_start_pos_y + 31))
                    begin
                        green_tank_up_addr <= green_tank_up_addr + 5'b1;
                        screen_data <= green_tank_up_data;
                    end
                    else
                        green_tank_up_addr <= green_tank_up_addr;
                DIR_DOWN:
                    if((pixel_x == green_tank_start_pos_x) && (pixel_y == green_tank_start_pos_y))
                        green_tank_up_addr <= 5'b11111;
                    else if((pixel_x >= green_tank_start_pos_x) && (pixel_x <= green_tank_start_pos_x + 31) &&
                    (pixel_y >= green_tank_start_pos_y) && (pixel_y <= green_tank_start_pos_y + 31))
                    begin
                        green_tank_up_addr <= green_tank_up_addr - 5'b1;
                        screen_data <= green_tank_up_data;
                    end
                    else
                        green_tank_up_addr <= green_tank_up_addr;     
                DIR_LEFT:
                    if((pixel_x == green_tank_start_pos_x) && (pixel_y == green_tank_start_pos_y))
                        green_tank_left_addr <= 5'b0;
                    else if((pixel_x >= green_tank_start_pos_x) && (pixel_x <= green_tank_start_pos_x + 31) &&
                    (pixel_y >= green_tank_start_pos_y) && (pixel_y <= green_tank_start_pos_y + 31))
                    begin
                        green_tank_left_addr <= green_tank_left_addr + 5'b1;
                        screen_data <= green_tank_left_data;
                    end
                    else
                        green_tank_left_addr <= green_tank_left_addr; 
                DIR_RIGHT:
                    if((pixel_x == green_tank_start_pos_x) && (pixel_y == green_tank_start_pos_y))
                        green_tank_left_addr <= 5'b11111;
                    else if((pixel_x >= green_tank_start_pos_x) && (pixel_x <= green_tank_start_pos_x + 31) &&
                    (pixel_y >= green_tank_start_pos_y) && (pixel_y <= green_tank_start_pos_y + 31))
                    begin
                        green_tank_left_addr <= green_tank_left_addr - 5'b1;
                        screen_data <= green_tank_left_data;
                    end
                    else
                        green_tank_left_addr <= green_tank_left_addr;                                                           
            endcase 
        end        
   end
    
    //位置更新 
   always @(posedge clk_25m, negedge rst_n)
   begin
        if(!rst_n)
        begin
            red_tank_start_pos_x <= 60;
            red_tank_start_pos_y <= 60;
            red_stop <= 1'b0;
        end
        else if(map_data != 0 && (pixel_x >= red_tank_start_pos_x) && (pixel_x < red_tank_start_pos_x + 31)
        && (pixel_y >= red_tank_start_pos_y) && (pixel_y < red_tank_start_pos_y + 31))
            red_stop <= 1'b1;
        else if(flag == 1'b1)
        begin
            if(red_stop == 1'b0)
            begin
                case (player1_btns)
                    UP:     red_tank_start_pos_y <= red_tank_start_pos_y - 10'b1;
                    DOWN:   red_tank_start_pos_y <= red_tank_start_pos_y + 10'b1;
                    LEFT:   red_tank_start_pos_x <= red_tank_start_pos_x - 10'b1;
                    RIGHT:  red_tank_start_pos_x <= red_tank_start_pos_x + 10'b1;
                    default:
                    begin
                        red_tank_start_pos_x <= red_tank_start_pos_x;
                        red_tank_start_pos_y <= red_tank_start_pos_y;
                    end
                endcase
            end
            else if(red_stop == 1'b1)
            begin
                red_stop <= 1'b0;
                case (player1_btns)
                UP:     red_tank_start_pos_y <= red_tank_start_pos_y + 10'b1;
                DOWN:   red_tank_start_pos_y <= red_tank_start_pos_y - 10'b1;
                LEFT:   red_tank_start_pos_x <= red_tank_start_pos_x + 10'b1;
                RIGHT:  red_tank_start_pos_x <= red_tank_start_pos_x - 10'b1;
                default:
                begin
                    red_tank_start_pos_x <= red_tank_start_pos_x;
                    red_tank_start_pos_y <= red_tank_start_pos_y;
                end
                endcase            
            end
            else
            begin
                red_tank_start_pos_x <= red_tank_start_pos_x;
                red_tank_start_pos_y <= red_tank_start_pos_y;            
            end
        end    
        
        if(!rst_n)
        begin
            green_tank_start_pos_x <= 60;
            green_tank_start_pos_y <= 160;
            green_stop <= 1'b0;
        end
        else if(map_data != 0 && (pixel_x >= green_tank_start_pos_x) && (pixel_x < green_tank_start_pos_x + 31)
        && (pixel_y >= green_tank_start_pos_y) && (pixel_y < green_tank_start_pos_y + 31))
            green_stop <= 1'b1;
        else if(flag == 1'b1)
        begin
            if(green_stop == 1'b0)
            begin
                case (player2_btns)
                    UP:     green_tank_start_pos_y <= green_tank_start_pos_y - 10'b1;
                    DOWN:   green_tank_start_pos_y <= green_tank_start_pos_y + 10'b1;
                    LEFT:   green_tank_start_pos_x <= green_tank_start_pos_x - 10'b1;
                    RIGHT:  green_tank_start_pos_x <= green_tank_start_pos_x + 10'b1;
                    default:
                    begin
                        green_tank_start_pos_x <= green_tank_start_pos_x;
                        green_tank_start_pos_y <= green_tank_start_pos_y;
                    end
                endcase
            end
            else if(green_stop == 1'b1)
            begin
                green_stop <= 1'b0;
                case (player2_btns)
                UP:     green_tank_start_pos_y <= green_tank_start_pos_y + 10'b1;
                DOWN:   green_tank_start_pos_y <= green_tank_start_pos_y - 10'b1;
                LEFT:   green_tank_start_pos_x <= green_tank_start_pos_x + 10'b1;
                RIGHT:  green_tank_start_pos_x <= green_tank_start_pos_x - 10'b1;
                default:
                begin
                    green_tank_start_pos_x <= green_tank_start_pos_x;
                    green_tank_start_pos_y <= green_tank_start_pos_y;
                end
                endcase            
            end
            else
            begin
                green_tank_start_pos_x <= green_tank_start_pos_x;
                green_tank_start_pos_y <= green_tank_start_pos_y;            
            end
        end    
   end
   
   always @(posedge clk_25m, negedge rst_n)
   begin
        if(!rst_n)
        begin
            flag <= 1'b0;
            flag_cnt <= 0;
        end
        else if(flag_cnt === FLAG_TANK_CNT)
        begin
            flag <= 1'b1;
            flag_cnt <= 0;            
        end
        else
        begin
            flag <= 1'b0;
            flag_cnt <= flag_cnt + 1;              
        end
   end
endmodule
