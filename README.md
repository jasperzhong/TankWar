# TankWar（坦克大战）
数字逻辑大作业

已重构完毕，可以显示背景和两架坦克，可以移动坦克。

# Bugs（12.24）
- VGA显示略有偏移
- 键盘控制坦克移动有点迷啊...

# 代码规范
## 命名规范
- 所有信号名字一律**小写+下划线**
- 使用有意义的名字和规范的缩写
- 低电平有效的信号一律加上_n，比如rst_n
- 常量名一律**大写**,比如parameter CLK_PERIOD = 20;
- 避免使用数字或者reg作为后缀
- 同一信号在不同层次或者模块应该保证**命名的一致性**
- 总线命名必须从高位到低位，只允许[N:0] 不允许[0:N]

## 模块规范
- 模块名一律**首字母大写**，包括IP名，并且与文件名一致
- 实例化的名字格式：U_Xxxx_0
- 采用Verilog2001规范，即IO接口一律写在括号内，并且标明类型（wire/reg），并且独占一行
- 顶层模块**只允许实例化和声明信号**，不允许任何assign 或者 always，不能出现任何胶合逻辑
- 每一个文件只允许有一个模块，该模块的测试文件
- 每一个模块应在开始处标明文件名，功能描述，引用的模块等信息

## Net和Register
- 一个reg变量**只允许在一个always内赋值**
- 同一个信号赋值不允许同时使用阻塞和非阻塞方式
- 变量的赋值要注明数字的宽度和进位制

## Expression
- 用括号表示运算优先级
- 一行只允许出现一个表达式
- 不允许给信号赋值x态

## Always语句
- 包含时序逻辑的电路必须用非阻塞赋值
- 纯组合逻辑电路必须使用阻塞赋值
- 复位信号一定要是异步的

## 选择分支语句
- 每一个if必须有一个else语句，没有else的语句可能会多出锁存器（条件的完整性）
- 每一个case必须有一个default语句，default允许空语句（条件的完整性）
- 禁止使用casex,casez
- case语句的item必须使用常数（最好在parameter定义过的）

## FSM
- 有限状态机的状态必须由parameter分配
- 有限状态机必须使用“三段式”写法：两个always模块产生当前状态和输出，再用一个组合always产生下一个状态<br/>
e.g.
``` javascript 
//当前状态
always @(posedge clk, negedge rst_n)
begin
  if(!rst_n)
    state <= STATIC;
  else
    state <= next_state;
end

//下一个状态
always @(state)
begin
  case (state)
    STATIC: next_state = xxxx;
    MOVE : next_state = xxxx;
    .....
  endcase
  /*
  建议用if-else实现，因为还有一些转移条件需要考虑
  */
end

//输出
always @(posedge clk, negedge rst_n)
begin
  if(!rst_n)
    out <= xxxx;
  else<
    out <= xxxx;
end
```


