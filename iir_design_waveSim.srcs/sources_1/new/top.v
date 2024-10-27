`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/24 22:53:53
// Design Name: 
// Module Name: top
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


module top(
    input wire clk,
    input wire [23:0] datain,
    input wire data_in_valid,
    
    output wire [23:0] dataout,
    output wire data_out_valid,
    
    output wire [63:0] xn_1,
    output wire [63:0] xn_2,
    output wire [63:0] yn_1,
    output wire [63:0] yn_2,
    output wire [63:0] xn,
    
    output wire [63:0] floatadd_a_data,
    output wire floatadd_a_valid,
    output wire [63:0] floatadd_b_data,
    output wire floatadd_b_valid,
    output wire [63:0] floatadd_out_data,
    output wire floatadd_out_valid,
    
    output wire [63:0] floatmulti_a_data,
    output wire floatmulti_a_valid,
    output wire [63:0] floatmulti_b_data,
    output wire floatmulti_b_valid,
    output wire [63:0] floatmulti_out_data,
    output wire floatmulti_out_valid,
    
    output wire [63:0] d2l,
    output wire [63:0] d2r,
    output wire [63:0] d2t,
    output wire [63:0] d1l,
    output wire [63:0] d1m,
    output wire [63:0] d1lm,
    output wire [63:0] d1t,
    output wire [63:0] ynl,
    // Machine variable
    output wire [4:0] st_next,
    output wire [4:0] st_cur
    );
    // Parameter zone  // TODO: Move them to become input wire, parameters coming in from the outside
    //reg [63:0] a0 = 64'h3F53C838DB03A294;
    //reg [63:0] a1 = 64'h3F63C838DB03A294;
    //reg [63:0] a2 = 64'h3F53C838DB03A294;
    //reg [63:0] b1 = 64'h3FFE63AA866C6F75;
    //reg [63:0] b2 = 64'hBFECEEE57E8EE62E;
    
    wire [63:0] float_data_1;
    wire float_1_valid;
    wire [63:0] float_data_2;
    wire float_2_valid;
    
    
    
    floating_point_2 fixed_to_float(
        .aclk(clk),
        .s_axis_a_tdata(datain),
        .s_axis_a_tvalid(data_in_valid),
        
        .m_axis_result_tdata(float_data_1),
        .m_axis_result_tvalid(float_1_valid)
    );
    
    filter biquad_filter(
        .clk(clk),
        .rstn(1'b1),
        .data_in(float_data_1),
        .data_in_valid(float_1_valid),
        
        .data_out(float_data_2),
        .data_out_valid(float_2_valid),
        
        .a0(64'h3F53C838DB03A294),
        .a1(64'h3F63C838DB03A294),
        .a2(64'h3F53C838DB03A294),
        .b1(64'h3FFE63AA866C6F75),
        .b2(64'hBFECEEE57E8EE62E),
        
        .xn_1(xn_1),
        .xn_2(xn_2),
        .yn_1(yn_1),
        .yn_2(yn_2),
        .xn(xn),
        .floatadd_a_data(floatadd_a_data),
        .floatadd_a_valid(floatadd_a_valid),
        .floatadd_b_data(floatadd_b_data),
        .floatadd_b_valid(floatadd_b_valid),
        .floatadd_out_data(floatadd_out_data),
        .floatadd_out_valid(floatadd_out_valid),
        .floatmulti_a_data(floatmulti_a_data),
        .floatmulti_a_valid(floatmulti_a_valid),
        .floatmulti_b_data(floatmulti_b_data),
        .floatmulti_b_valid(floatmulti_b_valid),
        .floatmulti_out_data(floatmulti_out_data),
        .floatmulti_out_valid(floatmulti_out_valid),
        .d2l(d2l),
        .d2r(d2r),
        .d2t(d2t),
        .d1l(d1l),
        .d1m(d1m),
        .d1lm(d1lm),
        .d1t(d1t),
        .ynl(ynl),
        .st_next(st_next),
        .st_cur(st_cur)
        
    );
    
    floating_point_3 float_to_fixed(
        .aclk(clk),
        .s_axis_a_tdata(float_data_2),
        .s_axis_a_tvalid(float_2_valid),
        
        .m_axis_result_tdata(dataout),
        .m_axis_result_tvalid(data_out_valid)
    );
    
endmodule
