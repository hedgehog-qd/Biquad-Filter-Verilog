`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/23 23:42:42
// Design Name: 
// Module Name: top_tb
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


module top_tb;

    reg clk;
    reg [23:0] input_data [0:44100-1]; // 声明一个数组来存储输入数据
    reg [23:0] inputdatashow = 'b0;
    reg input_data_valid;
    wire [23:0] output_data;
    wire output_data_valid;
    
    
    reg [15:0] input_index; // 循环变量，声明在外部
    // 实例化滤波器模块
    top top_module(
        .clk(clk),
        .datain(input_data[input_index]), // 使用有效信号选择输入
        .data_in_valid(input_data_valid),
        
        .dataout(output_data),
        .data_out_valid(output_data_valid)
    );
    
    

    always #5 clk = ~clk;  // 产生时钟信号
    
    initial begin
        clk = 1'b0;
        input_data_valid = 1'b0; // 初始化输入数据有效信号
        input_index = 0; // 初始化索引

        // 读取输入信号
        $readmemh("C:\\Users\\ASUS\\Downloads\\input_signal.txt", input_data); // 读取TXT文件

        // 模拟过程
        #15; 
        input_data_valid = 1'b1; // 激活输入数据有效信号
        
        // 循环读取数据
        for (input_index = 0; input_index < 44100; input_index = input_index + 1) begin
            inputdatashow = $signed(input_data[input_index]);
            input_data_valid = 1'b1;
            #30;  // 等待30ns
            input_data_valid = 1'b0;
            #2500;  // 等待3000ns
        end

        input_data_valid = 1'b0; // 结束时设置为无效
        #10000; // 等待足够时间观察输出
        $stop(2); // 停止仿真
    end
    
endmodule

