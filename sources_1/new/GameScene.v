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
        FLAG_TANK_CNT = 50000,
        FLAG_BULLET_CNT = 10000;
    
    reg flag;
    reg bullet_flag;
    reg [31:0] flag_cnt;
    reg [31:0] bullet_flag_cnt;
    
    reg red_stop = 1'b0;
    reg green_stop = 1'b0;
    //坦克方向
    reg [1:0] red_tank_dir;
    reg [1:0] green_tank_dir;
    
    //坦克起始位置
    reg [9:0] red_tank_start_pos_x;
    reg [9:0] red_tank_start_pos_y;
    
    reg [9:0] green_tank_start_pos_x;
    reg [9:0] green_tank_start_pos_y;    
    
    //子弹方向
    reg [1:0] red_bullet_dir;
    reg [1:0] green_bullet_dir;
    
    //子弹起始位置
    reg [9:0] red_bullet_start_pos_x;
    reg [9:0] red_bullet_start_pos_y;
    
    reg [9:0] green_bullet_start_pos_x;
    reg [9:0] green_bullet_start_pos_y;
    
    //是否发射了子弹
    reg red_bullet_active;
    reg green_bullet_active;
    
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
    
    //子弹ROM数据
    reg [6:0] red_bullet_up_addr;
    wire [7:0] red_bullet_up_data;
    
    reg [6:0] red_bullet_left_addr;
    wire [7:0] red_bullet_left_data;    
    
    reg [6:0] green_bullet_up_addr;
    wire [7:0] green_bullet_up_data;
    
    reg [6:0] green_bullet_left_addr;
    wire [7:0] green_bullet_left_data;
        
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
    
    //子弹数据
    BulletUpROM U_REDBULLETUPROM_0(
        .clka(clk_25m),
        .addra(red_bullet_up_addr),
        .douta(red_bullet_up_data)
    );
    
    BulletLeftROM U_REDBULLETLEFTROM_0(
        .clka(clk_25m),
        .addra(red_bullet_left_addr),
        .douta(red_bullet_left_data)
    );    
    
    BulletUpROM U_GREENBULLETUPROM_0(
        .clka(clk_25m),
        .addra(green_bullet_up_addr),
        .douta(green_bullet_up_data)
    );
    
    BulletLeftROM U_GREENBULLETLEFTROM_0(
        .clka(clk_25m),
        .addra(green_bullet_left_addr),
        .douta(green_bullet_left_data)
    );        
    
    
    //红坦克方向  keyboard -> fsm  
    always @(posedge clk_25m, negedge rst_n)
    begin
        if(!rst_n)
        begin
            red_tank_dir <= DIR_UP;
            red_bullet_active <= 1'b0;
        end
        else if(red_bullet_active == 1'b0 && player1_btns == FIRE) 
        begin
            red_bullet_active <= 1'b1;
            case (red_tank_dir)
                DIR_UP:     red_bullet_dir <= DIR_UP;
                DIR_DOWN:   red_bullet_dir <= DIR_DOWN;
                DIR_LEFT:   red_bullet_dir <= DIR_LEFT;
                DIR_RIGHT:  red_bullet_dir <= DIR_RIGHT;
                default:    red_bullet_dir <= red_bullet_dir;
            endcase
            if(red_bullet_active == 1'b1)
                red_tank_dir <= DIR_UP;
        end
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
        begin
            green_tank_dir <= DIR_UP;
            green_bullet_active <= 1'b0;
        end
        else if(green_bullet_active == 1'b0 && player2_btns == FIRE)
        begin
            green_bullet_active <= 1'b1;
            case (green_tank_dir)
                DIR_UP:     green_bullet_dir <= DIR_UP;
                DIR_DOWN:   green_bullet_dir <= DIR_DOWN;
                DIR_LEFT:   green_bullet_dir <= DIR_LEFT;
                DIR_RIGHT:  green_bullet_dir <= DIR_RIGHT;
                default:    green_bullet_dir <= green_bullet_dir;
            endcase
            green_bullet_start_pos_x <= green_tank_start_pos_x;
            green_bullet_start_pos_y <= green_tank_start_pos_y;            
        end
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
            map_addr <= 19'b00;
            screen_data <= 8'b0;
        end
        else
        begin
            map_addr <= pixel_x + pixel_y*640;
            screen_data <= map_data;
        end
        
        if(!rst_n)
        begin
            red_tank_up_addr <= 10'b10;
            red_tank_left_addr <= 10'b10;
        end
        else
        begin
            case (red_tank_dir)
                DIR_UP: 
                    if((pixel_x == red_tank_start_pos_x) && (pixel_y == red_tank_start_pos_y))
                        red_tank_up_addr <= 10'b10;
                    else if((pixel_x >= red_tank_start_pos_x) && (pixel_x <= red_tank_start_pos_x + 31) &&
                    (pixel_y >= red_tank_start_pos_y) && (pixel_y <= red_tank_start_pos_y + 31))
                    begin
                        red_tank_up_addr <= red_tank_up_addr + 10'b1;
                        screen_data <= red_tank_up_data;
                    end
                    else
                        red_tank_up_addr <= red_tank_up_addr;
                DIR_DOWN:
                    if((pixel_x == red_tank_start_pos_x) && (pixel_y == red_tank_start_pos_y))
                        red_tank_up_addr <= 10'b11111_11101;
                    else if((pixel_x >= red_tank_start_pos_x) && (pixel_x <= red_tank_start_pos_x + 31) &&
                    (pixel_y >= red_tank_start_pos_y) && (pixel_y <= red_tank_start_pos_y + 31))
                    begin
                        red_tank_up_addr <= red_tank_up_addr - 10'b1;
                        screen_data <= red_tank_up_data;
                    end
                    else
                        red_tank_up_addr <= red_tank_up_addr;     
                DIR_LEFT:
                    if((pixel_x == red_tank_start_pos_x) && (pixel_y == red_tank_start_pos_y))
                        red_tank_left_addr <= 10'b10;
                    else if((pixel_x >= red_tank_start_pos_x) && (pixel_x <= red_tank_start_pos_x + 31) &&
                    (pixel_y >= red_tank_start_pos_y) && (pixel_y <= red_tank_start_pos_y + 31))
                    begin
                        red_tank_left_addr <= red_tank_left_addr + 10'b1;
                        screen_data <= red_tank_left_data;
                    end
                    else
                        red_tank_left_addr <= red_tank_left_addr; 
                DIR_RIGHT:
                    if((pixel_x == red_tank_start_pos_x) && (pixel_y == red_tank_start_pos_y))
                        red_tank_left_addr <= 10'b11111_11101;
                    else if((pixel_x >= red_tank_start_pos_x) && (pixel_x <= red_tank_start_pos_x + 31) &&
                    (pixel_y >= red_tank_start_pos_y) && (pixel_y <= red_tank_start_pos_y + 31))
                    begin
                        red_tank_left_addr <= red_tank_left_addr - 10'b1;
                        screen_data <= red_tank_left_data;
                    end
                    else
                        red_tank_left_addr <= red_tank_left_addr;                                                           
            endcase 
        end
        
        if(!rst_n)
        begin
            red_bullet_active <= 1'b0;
            red_bullet_up_addr <= 7'b0;
            red_bullet_left_addr <= 7'b0;
        end
        else if(red_bullet_active == 1'b0)
        begin
            case (red_bullet_dir)
                 DIR_UP:
                    if((pixel_x == red_bullet_start_pos_x) && (pixel_y == red_bullet_start_pos_y))
                         red_bullet_up_addr <= 7'b0;
                    else if((pixel_x >= red_bullet_start_pos_x) && (pixel_x <= red_bullet_start_pos_x + 7) &&
                    (pixel_y >= red_bullet_start_pos_y) && (pixel_y <= red_bullet_start_pos_y + 14))
                    begin
                         red_bullet_up_addr <= red_bullet_up_addr + 7'b1;
                         screen_data <= red_bullet_up_data;
                    end
                    else
                         red_bullet_up_addr <= red_bullet_up_addr;
                  DIR_DOWN:
                    if((pixel_x == red_bullet_start_pos_x) && (pixel_y == red_bullet_start_pos_y))
                        red_bullet_up_addr <= 7'd120;
                    else if((pixel_x >= red_bullet_start_pos_x) && (pixel_x <= red_bullet_start_pos_x + 7) &&
                    (pixel_y >= red_bullet_start_pos_y) && (pixel_y <= red_bullet_start_pos_y + 14))
                    begin
                         red_bullet_up_addr <= red_bullet_up_addr - 7'b1;
                        screen_data <= red_bullet_up_data;
                    end
                    else
                         red_bullet_up_addr <= red_bullet_up_addr;
                  DIR_LEFT:
                    if((pixel_x == red_bullet_start_pos_x) && (pixel_y == red_bullet_start_pos_y))
                         red_bullet_left_addr <= 7'b0;
                    else if((pixel_x >= red_bullet_start_pos_x) && (pixel_x <= red_bullet_start_pos_x + 14) &&
                    (pixel_y >= red_bullet_start_pos_y) && (pixel_y <= red_bullet_start_pos_y + 7))
                    begin
                         red_bullet_left_addr <= red_bullet_left_addr + 7'b1;
                         screen_data <= red_bullet_left_data;
                    end
                    else
                         red_bullet_left_addr <= red_bullet_left_addr;                        
                  DIR_RIGHT:
                    if((pixel_x == red_bullet_start_pos_x) && (pixel_y == red_bullet_start_pos_y))
                         red_bullet_left_addr <= 7'd120;
                    else if((pixel_x >= red_bullet_start_pos_x) && (pixel_x <= red_bullet_start_pos_x + 14) &&
                    (pixel_y >= red_bullet_start_pos_y) && (pixel_y <= red_bullet_start_pos_y + 7))
                    begin
                         red_bullet_left_addr <= red_bullet_left_addr - 7'b1;
                         screen_data <= red_bullet_left_data;
                    end
                    else
                         red_bullet_left_addr <= red_bullet_left_addr;                                                 
            endcase
        end
                
                
        if(!rst_n)
        begin
            green_tank_up_addr <= 10'b10;
            green_tank_left_addr <= 10'b10;
        end
        else
        begin
            case (green_tank_dir)
                DIR_UP: 
                    if((pixel_x == green_tank_start_pos_x) && (pixel_y == green_tank_start_pos_y))
                        green_tank_up_addr <= 10'b10;
                    else if((pixel_x >= green_tank_start_pos_x) && (pixel_x <= green_tank_start_pos_x + 31) &&
                    (pixel_y >= green_tank_start_pos_y) && (pixel_y <= green_tank_start_pos_y + 31))
                    begin
                        green_tank_up_addr <= green_tank_up_addr + 10'b1;
                        screen_data <= green_tank_up_data;
                    end
                    else
                        green_tank_up_addr <= green_tank_up_addr;
                DIR_DOWN:
                    if((pixel_x == green_tank_start_pos_x) && (pixel_y == green_tank_start_pos_y))
                        green_tank_up_addr <= 10'b11111_11101;
                    else if((pixel_x >= green_tank_start_pos_x) && (pixel_x <= green_tank_start_pos_x + 31) &&
                    (pixel_y >= green_tank_start_pos_y) && (pixel_y <= green_tank_start_pos_y + 31))
                    begin
                        green_tank_up_addr <= green_tank_up_addr - 10'b1;
                        screen_data <= green_tank_up_data;
                    end
                    else
                        green_tank_up_addr <= green_tank_up_addr;     
                DIR_LEFT:
                    if((pixel_x == green_tank_start_pos_x) && (pixel_y == green_tank_start_pos_y))
                        green_tank_left_addr <= 10'b10;
                    else if((pixel_x >= green_tank_start_pos_x) && (pixel_x <= green_tank_start_pos_x + 31) &&
                    (pixel_y >= green_tank_start_pos_y) && (pixel_y <= green_tank_start_pos_y + 31))
                    begin
                        green_tank_left_addr <= green_tank_left_addr + 10'b1;
                        screen_data <= green_tank_left_data;
                    end
                    else
                        green_tank_left_addr <= green_tank_left_addr; 
                DIR_RIGHT:
                    if((pixel_x == green_tank_start_pos_x) && (pixel_y == green_tank_start_pos_y))
                        green_tank_left_addr <= 10'b11111_11101;
                    else if((pixel_x >= green_tank_start_pos_x) && (pixel_x <= green_tank_start_pos_x + 31) &&
                    (pixel_y >= green_tank_start_pos_y) && (pixel_y <= green_tank_start_pos_y + 31))
                    begin
                        green_tank_left_addr <= green_tank_left_addr - 10'b1;
                        screen_data <= green_tank_left_data;
                    end
                    else
                        green_tank_left_addr <= green_tank_left_addr;                                                           
            endcase 
        end
        
        if(!rst_n)
        begin
            green_bullet_active <= 1'b0;
            green_bullet_up_addr <= 7'b0;
            green_bullet_left_addr <= 7'b0;
        end
        else if(green_bullet_active == 1'b1)
        begin
            case (green_bullet_dir)
                 DIR_UP:
                    if((pixel_x == green_bullet_start_pos_x) && (pixel_y == green_bullet_start_pos_y))
                         green_bullet_up_addr <= 7'b0;
                    else if((pixel_x >= green_bullet_start_pos_x) && (pixel_x <= green_bullet_start_pos_x + 7) &&
                    (pixel_y >= green_bullet_start_pos_y) && (pixel_y <= green_bullet_start_pos_y + 14))
                    begin
                         green_bullet_up_addr <= green_bullet_up_addr + 7'b1;
                         screen_data <= green_bullet_up_data;
                    end
                    else
                         green_bullet_up_addr <= green_bullet_up_addr;
                  DIR_DOWN:
                    if((pixel_x == green_bullet_start_pos_x) && (pixel_y == green_bullet_start_pos_y))
                         green_bullet_up_addr <= 7'd120;
                    else if((pixel_x >= green_bullet_start_pos_x) && (pixel_x <= green_bullet_start_pos_x + 7) &&
                    (pixel_y >= green_bullet_start_pos_y) && (pixel_y <= green_bullet_start_pos_y + 14))
                    begin
                         green_bullet_up_addr <= green_bullet_up_addr - 7'b1;
                         screen_data <= green_bullet_up_data;
                    end
                    else
                         green_bullet_up_addr <= green_bullet_up_addr;
                  DIR_LEFT:
                    if((pixel_x == green_bullet_start_pos_x) && (pixel_y == green_bullet_start_pos_y))
                         green_bullet_left_addr <= 7'b0;
                    else if((pixel_x >= green_bullet_start_pos_x) && (pixel_x <= green_bullet_start_pos_x + 14) &&
                    (pixel_y >= green_bullet_start_pos_y) && (pixel_y <= green_bullet_start_pos_y + 7))
                    begin
                         green_bullet_left_addr <= green_bullet_left_addr + 7'b1;
                         screen_data <= green_bullet_left_data;
                    end
                    else
                         green_bullet_left_addr <= green_bullet_left_addr;                        
                  DIR_RIGHT:
                    if((pixel_x == green_bullet_start_pos_x) && (pixel_y == green_bullet_start_pos_y))
                         green_bullet_left_addr <= 7'd120;
                    else if((pixel_x >= green_bullet_start_pos_x) && (pixel_x <= green_bullet_start_pos_x + 14) &&
                    (pixel_y >= green_bullet_start_pos_y) && (pixel_y <= green_bullet_start_pos_y + 7))
                    begin
                         green_bullet_left_addr <= green_bullet_left_addr - 7'b1;
                         screen_data <= green_bullet_left_data;
                    end
                    else
                         green_bullet_left_addr <= green_bullet_left_addr;                                                 
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
        else if((map_data != 8'hFF) && (pixel_x >= red_tank_start_pos_x) && (pixel_x <= red_tank_start_pos_x + 31)
        && (pixel_y >= red_tank_start_pos_y) && (pixel_y <= red_tank_start_pos_y + 31))
            red_stop <= 1'b1;
        else if(flag == 1'b1)
        begin
            case(red_stop)
            1'b0:
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
            1'b1:
            begin
                red_stop <= 1'b0;
                case (red_tank_dir)
                    DIR_UP:     red_tank_start_pos_y <= red_tank_start_pos_y + 10'd10;
                    DIR_DOWN:   red_tank_start_pos_y <= red_tank_start_pos_y - 10'd10;
                    DIR_LEFT:   red_tank_start_pos_x <= red_tank_start_pos_x + 10'd10;
                    DIR_RIGHT:  red_tank_start_pos_x <= red_tank_start_pos_x - 10'd10;
                default:
                begin
                    red_tank_start_pos_x <= red_tank_start_pos_x;
                    red_tank_start_pos_y <= red_tank_start_pos_y;
                end
                endcase            
            end
            default:
            begin
                red_tank_start_pos_x <= red_tank_start_pos_x;
                red_tank_start_pos_y <= red_tank_start_pos_y;   
                red_stop <= 1'b0;         
            end
            endcase
        end    
        
        if(!rst_n)
        begin
            red_bullet_active <= 1'b0;
        end
        else if(player1_btns == FIRE)
        begin
            red_bullet_start_pos_x <= red_tank_start_pos_x + 15;
            red_bullet_start_pos_y <= red_tank_start_pos_y + 15;
        end
        else if((green_bullet_active == 1'b0) && (map_data != 8'hFF))
        begin
            case (green_bullet_dir)
                DIR_UP, DIR_DOWN:   if((pixel_x >= green_bullet_start_pos_x && pixel_x < green_bullet_start_pos_x + 7) 
                && (pixel_y >= green_bullet_start_pos_y) && (pixel_y < green_bullet_start_pos_x + 14))
                            green_bullet_active <= 1'b1;
                DIR_LEFT,DIR_RIGHT: if((pixel_x >= green_bullet_start_pos_x && pixel_x < green_bullet_start_pos_x + 14) 
                && (pixel_y >= green_bullet_start_pos_y) && (pixel_y < green_bullet_start_pos_x + 7))
                            green_bullet_active <= 1'b1;
           endcase
        end
        else if(red_bullet_active == 1'b0 && bullet_flag == 1'b1)
        begin
            case (red_bullet_dir)
                DIR_UP:     red_bullet_start_pos_y <= red_bullet_start_pos_y - 10'b1;
                DIR_DOWN:   red_bullet_start_pos_y <= red_bullet_start_pos_y + 10'b1;
                DIR_LEFT:   red_bullet_start_pos_x <= red_bullet_start_pos_x - 10'b1;
                DIR_RIGHT:  red_bullet_start_pos_x <= red_bullet_start_pos_x + 10'b1; 
                default:
                begin
                    red_bullet_start_pos_x <= red_bullet_start_pos_x;
                    red_bullet_start_pos_y <= red_bullet_start_pos_y;
                end                                               
            endcase
        end
        
        
        if(!rst_n)
        begin
            green_tank_start_pos_x <= 60;
            green_tank_start_pos_y <= 160;
            green_stop <= 1'b0;
        end
        else if((map_data != 8'hFF) && (pixel_x >= green_tank_start_pos_x) && (pixel_x <= green_tank_start_pos_x + 31)
        && (pixel_y >= green_tank_start_pos_y) && (pixel_y <= green_tank_start_pos_y + 31))
            green_stop <= 1'b1;
        else if(flag == 1'b1)
        begin
            case(green_stop)
            1'b0:
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
            1'b1:
            begin
                green_stop <= 1'b0; 
                case (green_tank_dir)
                DIR_UP:     green_tank_start_pos_y <= green_tank_start_pos_y + 10'd10;
                DIR_DOWN:   green_tank_start_pos_y <= green_tank_start_pos_y - 10'd10;
                DIR_LEFT:   green_tank_start_pos_x <= green_tank_start_pos_x + 10'd10;
                DIR_RIGHT:  green_tank_start_pos_x <= green_tank_start_pos_x - 10'd10;
                default:
                begin
                    green_tank_start_pos_x <= green_tank_start_pos_x;
                    green_tank_start_pos_y <= green_tank_start_pos_y;
                end
                endcase                 
            end
            default:
            begin
                green_tank_start_pos_x <= green_tank_start_pos_x;
                green_tank_start_pos_y <= green_tank_start_pos_y;   
                green_stop <= 1'b0;         
            end
            endcase
        end  
        
        if(!rst_n)
        begin
            green_bullet_active <= 1'b0;
        end
        else if((green_bullet_active == 1'b1) && (map_data != 8'hFF))
        begin
            case (green_bullet_dir)
                DIR_UP, DIR_DOWN:   if((pixel_x >= green_bullet_start_pos_x && pixel_x < green_bullet_start_pos_x + 7) 
                && (pixel_y >= green_bullet_start_pos_y) && (pixel_y < green_bullet_start_pos_x + 14))
                    green_bullet_active <= 1'b0;
                DIR_LEFT,DIR_RIGHT: if((pixel_x >= green_bullet_start_pos_x && pixel_x < green_bullet_start_pos_x + 14) 
                && (pixel_y >= green_bullet_start_pos_y) && (pixel_y < green_bullet_start_pos_x + 7))
                    green_bullet_active <= 1'b0;
            endcase
        end
        else if(green_bullet_active == 1'b1 && bullet_flag == 1'b1)
        begin
            case (green_bullet_dir)
                DIR_UP:     green_bullet_start_pos_y <= green_bullet_start_pos_y - 10'b1;
                DIR_DOWN:   green_bullet_start_pos_y <= green_bullet_start_pos_y + 10'b1;
                DIR_LEFT:   green_bullet_start_pos_x <= green_bullet_start_pos_x - 10'b1;
                DIR_RIGHT:  green_bullet_start_pos_x <= green_bullet_start_pos_x + 10'b1; 
                default:
                begin
                    green_bullet_start_pos_x <= green_bullet_start_pos_x;
                    green_bullet_start_pos_y <= green_bullet_start_pos_y;
                end                                               
            endcase
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
   
   always @(posedge clk_25m, negedge rst_n)
   begin
        if(!rst_n)
        begin
            bullet_flag <= 1'b0;
            bullet_flag_cnt <= 0;
        end
        else if(bullet_flag_cnt === FLAG_BULLET_CNT)
        begin
            bullet_flag <= 1'b1;
            bullet_flag_cnt <= 0;            
        end
        else
        begin
            bullet_flag <= 1'b0;
            bullet_flag_cnt <= bullet_flag_cnt + 1;              
        end
   end
      
endmodule
