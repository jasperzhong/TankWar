`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/20 00:02:42
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
    input   wire        clk,  //50MHZ
    input   wire        rst_n,  //复位信号
    //VGA
    output  wire         hsync,    //行同步信号
    output  wire         vsync,    //场同步信号
    output  wire [11:0]  rgb,
    
    //keyborad
    input   wire        kclk,
    input   wire        kdata
    );
    
    localparam SPEED = 1;     //每一个指令走1个单位
    
    
//====================VGA===========================//
    //VGA时钟
    wire clk25m;
    //地图数据线
    wire [31:0] address_map;
    wire [7:0]  data_map;
    //红色坦克数据线
    reg [1:0] direction;  //方向：上下左右
    reg [1:0] state;   //状态：静止，移动，开火，死亡
    reg [9:0] red_tank_pos_x=250;   //水平方向位置
    reg [9:0] red_tank_pos_y=150;   //竖直方向位置
    wire [9:0] address_red_tank; //取ROM的地址
    wire [7:0]  data_red_tank;   //ROM返回的数据
    
//====================Keyborad===========================//
    wire clk50m;
    //接收到的指令
    wire up1, down1, left1, right1, fire1;   //Player
    wire clk_1000hz;
    
    keyborad kborad(
            .clk(clk50m),
            .kclk(kclk),
            .kdata(kdata),
            .up1(up1),.down1(down1),.left1(left1),.right1(right1)
    );
    
    Divider #(.DIV(100000))
        division(
            .I_CLK(clk),
            .rst_n(rst_n),
            .O_CLK(clk_1000hz)
        );    
    always @(posedge clk_1000hz) begin
        if(up1 == 1'b1) 
            red_tank_pos_y <= red_tank_pos_y - SPEED;
        if(down1 == 1'b1)
            red_tank_pos_y <= red_tank_pos_y + SPEED;
        if(left1 == 1'b1)
            red_tank_pos_x <= red_tank_pos_x - SPEED;
        if(right1 == 1'b1)
            red_tank_pos_x <= red_tank_pos_x + SPEED;
    end
        
    
    //输出25MHZ和50MHZ的时钟
    clk_to_25m clkdiv1(
         .clk_in1(clk),
         .clk_out1(clk25m),
         .clk_out2(clk50m)
    );
    /*
    //建立静态地图
    VGA_sprite Map(
        .clk25m(clk25m),
        .rst_n(rst_n),
        .data_in(data_map),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb),
        .address(address_map)
    );
    
    //地图ROM
    ROM_map map(
        .clka(clk25m),
        .addra(address_map),
        .douta(data_map)
    );
     */
    
    //建立红色坦克
    VGA_sprite #(
            .REAL_WIDTH(32),
            .REAL_HEIGHT(32),
            .ADDR_WIDTH(9)
    )   
    Red_tank 
    (
        .clk25m(clk25m),
        .rst_n(rst_n),
        .data_in(data_red_tank),
        .pos_x(red_tank_pos_x),
        .pos_y(red_tank_pos_y),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb),
        .address(address_red_tank)
    );
    
    //红色坦克ROM
    ROM_red_tank red_tank(
        .clka(clk25m),
        .addra(address_red_tank),
        .douta(data_red_tank)
    );
   
    
endmodule
