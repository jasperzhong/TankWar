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
    input   wire        rst_n,  //��λ�ź�
    //VGA
    output  wire         hsync,    //��ͬ���ź�
    output  wire         vsync,    //��ͬ���ź�
    output  wire [11:0]  rgb,
    
    //keyborad
    input   wire        kclk,
    input   wire        kdata
    );
    
    localparam SPEED = 1;     //ÿһ��ָ����1����λ
    
    
//====================VGA===========================//
    //VGAʱ��
    wire clk25m;
    //��ͼ������
    wire [31:0] address_map;
    wire [7:0]  data_map;
    //��ɫ̹��������
    reg [1:0] direction;  //������������
    reg [1:0] state;   //״̬����ֹ���ƶ�����������
    reg [9:0] red_tank_pos_x=250;   //ˮƽ����λ��
    reg [9:0] red_tank_pos_y=150;   //��ֱ����λ��
    wire [9:0] address_red_tank; //ȡROM�ĵ�ַ
    wire [7:0]  data_red_tank;   //ROM���ص�����
    
//====================Keyborad===========================//
    wire clk50m;
    //���յ���ָ��
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
        
    
    //���25MHZ��50MHZ��ʱ��
    clk_to_25m clkdiv1(
         .clk_in1(clk),
         .clk_out1(clk25m),
         .clk_out2(clk50m)
    );
    /*
    //������̬��ͼ
    VGA_sprite Map(
        .clk25m(clk25m),
        .rst_n(rst_n),
        .data_in(data_map),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb),
        .address(address_map)
    );
    
    //��ͼROM
    ROM_map map(
        .clka(clk25m),
        .addra(address_map),
        .douta(data_map)
    );
     */
    
    //������ɫ̹��
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
    
    //��ɫ̹��ROM
    ROM_red_tank red_tank(
        .clka(clk25m),
        .addra(address_red_tank),
        .douta(data_red_tank)
    );
   
    
endmodule
