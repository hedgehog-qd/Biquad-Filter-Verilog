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
    reg [23:0] input_data [0:44100-1]; // ����һ���������洢��������
    reg [23:0] inputdatashow = 'b0;
    reg input_data_valid;
    wire [23:0] output_data;
    wire output_data_valid;
    
    
    reg [15:0] input_index; // ѭ���������������ⲿ
    // ʵ�����˲���ģ��
    top top_module(
        .clk(clk),
        .datain(input_data[input_index]), // ʹ����Ч�ź�ѡ������
        .data_in_valid(input_data_valid),
        
        .dataout(output_data),
        .data_out_valid(output_data_valid)
    );
    
    

    always #5 clk = ~clk;  // ����ʱ���ź�
    
    initial begin
        clk = 1'b0;
        input_data_valid = 1'b0; // ��ʼ������������Ч�ź�
        input_index = 0; // ��ʼ������

        // ��ȡ�����ź�
        $readmemh("C:\\Users\\ASUS\\Downloads\\input_signal.txt", input_data); // ��ȡTXT�ļ�

        // ģ�����
        #15; 
        input_data_valid = 1'b1; // ��������������Ч�ź�
        
        // ѭ����ȡ����
        for (input_index = 0; input_index < 44100; input_index = input_index + 1) begin
            inputdatashow = $signed(input_data[input_index]);
            input_data_valid = 1'b1;
            #30;  // �ȴ�30ns
            input_data_valid = 1'b0;
            #2500;  // �ȴ�3000ns
        end

        input_data_valid = 1'b0; // ����ʱ����Ϊ��Ч
        #10000; // �ȴ��㹻ʱ��۲����
        $stop(2); // ֹͣ����
    end
    
endmodule

