`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/17 11:15:21
// Design Name: 
// Module Name: filter
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


module filter(
    input wire clk,
    input wire rstn,
    input wire [63:0] data_in,
    input wire data_in_valid,
    
    output reg [63:0] data_out,
    output reg data_out_valid,
    
    // filter parameter zone
    input wire [63:0] a0,
    input wire [63:0] a1,
    input wire [63:0] a2,
    input wire [63:0] b1,
    input wire [63:0] b2,
    
    // Biquad equation: y[n] = a0 * x[n] + d1
    //                  d1 = a1 * x[n-1] + b1 * y[n-1] + d2
    //                  d2 = a2 * x[n-2] + b2 * y[n-2]
    
    // TESTING AREA
    // Register zone
    output reg [63:0] xn_1 = 'b0,
    output reg [63:0] xn_2 = 'b0,
    output reg [63:0] yn_1 = 'b0,
    output reg [63:0] yn_2 = 'b0,
    output reg [63:0] xn = 'b0,
    
    output reg [63:0] floatadd_a_data = 'b0,
    output reg floatadd_a_valid = 'b0,
    output reg [63:0] floatadd_b_data = 'b0,
    output reg floatadd_b_valid = 'b0,
    output wire [63:0] floatadd_out_data,
    output wire floatadd_out_valid,
    
    output reg [63:0] floatmulti_a_data = 'b0,
    output reg floatmulti_a_valid = 'b0,
    output reg [63:0] floatmulti_b_data = 'b0,
    output reg floatmulti_b_valid = 'b0,
    output wire [63:0] floatmulti_out_data,
    output wire floatmulti_out_valid,
    
    output reg [63:0] d2l,
    output reg [63:0] d2r,
    output reg [63:0] d2t,
    output reg [63:0] d1l,
    output reg [63:0] d1m,
    output reg [63:0] d1lm,
    output reg [63:0] d1t,
    output reg [63:0] ynl,
    // Machine variable
    output reg [4:0] st_next = 'b0,
    output reg [4:0] st_cur = 'b0
    );
    // IP cores
    floating_point_0 floating_add(
        .aclk(clk),
        .s_axis_a_tdata(floatadd_a_data),
        .s_axis_a_tvalid(floatadd_a_valid),
        .s_axis_b_tdata(floatadd_b_data),
        .s_axis_b_tvalid(floatadd_b_valid),
        
        .m_axis_result_tdata(floatadd_out_data),
        .m_axis_result_tvalid(floatadd_out_valid)
    );
    
    floating_point_1 floating_multiply(
        .aclk(clk),
        .s_axis_a_tdata(floatmulti_a_data),
        .s_axis_a_tvalid(floatmulti_a_valid),
        .s_axis_b_tdata(floatmulti_b_data),
        .s_axis_b_tvalid(floatmulti_b_valid),
        
        .m_axis_result_tdata(floatmulti_out_data),
        .m_axis_result_tvalid(floatmulti_out_valid)
    );
    
    // Machine state decode
    parameter   IDLE    = 5'd0;
    parameter   d2a2    = 5'd1;
    parameter   d2a2_t  = 5'd2;
    parameter   d2b2    = 5'd3;
    parameter   d2b2_t  = 5'd4;
    parameter   d2      = 5'd5;
    parameter   d2_t    = 5'd6;
    parameter   d1a1    = 5'd7;
    parameter   d1a1_t  = 5'd8;
    parameter   d1b1    = 5'd9;
    parameter   d1b1_t  = 5'd10;
    parameter   d1left  = 5'd11;
    parameter   d1left_t= 5'd12;
    parameter   d1      = 5'd13;
    parameter   d1_t    = 5'd14;
    parameter   ynleft  = 5'd15;
    parameter   ynleft_t= 5'd16;
    parameter   yn      = 5'd17;
    parameter   yn_t    = 5'd18;
    
    
    // State transfer
    always@(posedge clk) begin
        st_cur <= st_next;
    end
    
    // State switch
    always@(*) begin
        case(st_cur)
            IDLE:  begin// Here we wait for the new data coming in
                if(data_in_valid == 1'b1) begin  // here we pass data to multiply: a2 * x[n-2]
                    xn = data_in;
                    floatmulti_a_data = a2;
                    floatmulti_a_valid = 1'b1;
                    floatmulti_b_data = xn_2;
                    floatmulti_b_valid = 1'b1;
                    
                    st_next = d2a2;
                end else
                    st_next = IDLE;  // data input is not ready, we still waiting here
                end
            d2a2: begin
                if(floatmulti_out_valid == 1'b1) begin  // we get the multiply data
                    d2l = floatmulti_out_data;
                    floatmulti_a_valid = 1'b0;  // remember to clean up
                    floatmulti_b_valid = 1'b0;  // clean up
                    
                    st_next = d2a2_t;
                end else
                    st_next = d2a2;  // multiply ip still calculating
                end
            d2a2_t: begin
                if(floatmulti_out_valid == 1'b0) begin  // clean up completed - we start the next multiply
                    floatmulti_a_data = b2;
                    floatmulti_a_valid = 1'b1;
                    floatmulti_b_data = yn_2;
                    floatmulti_b_valid = 1'b1;
                    
                    st_next = d2b2;
                end else
                    st_next = d2a2_t;  // waiting for cleaning up
                end
            d2b2: begin
                if(floatmulti_out_valid == 1'b1) begin  // multiply finished
                    d2r = floatmulti_out_data;
                    floatmulti_a_valid = 1'b0;
                    floatmulti_b_valid = 1'b0;  // clean up
                    
                    st_next = d2b2_t;
                end else
                    st_next = d2b2;  // waiting for multiply finish
            end
            d2b2_t: begin
                if(floatmulti_out_valid == 1'b0) begin  // cleaning up finished
                    floatadd_a_data = d2l;
                    floatadd_a_valid = 1'b1;
                    floatadd_b_data = d2r;
                    floatadd_b_valid = 1'b1;
                    
                    st_next = d2;
                end else
                    st_next = d2b2_t;  // waiting for cleaning up
            end
            d2: begin
                if(floatadd_out_valid == 1'b1) begin
                    d2t = floatadd_out_data;
                    floatadd_a_valid = 1'b0;
                    floatadd_b_valid = 1'b0;
                    d2l = 'b0;  // QUESTION: is it necessary to reset?
                    d2r = 'b0;  // same
                    
                    st_next = d2_t;
                end else
                    st_next = d2;  // add not finished
            end
            d2_t: begin
                if(floatadd_out_valid == 1'b0) begin
                    floatmulti_a_data = a1;  // start the multiply
                    floatmulti_a_valid = 1'b1;
                    floatmulti_b_data = xn_1;
                    floatmulti_b_valid = 1'b1;
                    
                    st_next = d1a1;
                end else
                    st_next = d2_t;  // waiting for cleaning up
            end
            d1a1: begin
                if(floatmulti_out_valid == 1'b1) begin
                    d1l = floatmulti_out_data;
                    floatmulti_a_valid = 1'b0;
                    floatmulti_b_valid = 1'b0;
                    
                    st_next = d1a1_t;
                end else
                    st_next = d1a1;  // waiting for multiply
            end
            d1a1_t: begin
                if(floatmulti_out_valid == 1'b0) begin
                    floatmulti_a_data = b1;
                    floatmulti_a_valid = 1'b1;
                    floatmulti_b_data = yn_1;
                    floatmulti_b_valid = 1'b1;
                    
                    st_next = d1b1;
                end else
                    st_next = d1a1_t;  // waiting for cleaning up
            end
            d1b1: begin
                if(floatmulti_out_valid == 1'b1) begin
                    d1m = floatmulti_out_data;
                    floatmulti_a_valid = 1'b0;
                    floatmulti_b_data = 1'b0;
                    
                    st_next = d1b1_t;
                end else
                    st_next = d1b1;  // waiting for multiply complete
            end
            d1b1_t: begin
                if(floatmulti_out_valid == 1'b0) begin
                    floatadd_a_data = d1l;
                    floatadd_a_valid = 1'b1;
                    floatadd_b_data = d1m;
                    floatadd_b_valid = 1'b1;
                    
                    st_next = d1left;
                end else
                    st_next = d1b1_t;  // waiting for cleaning up
            end
            d1left: begin
                if(floatadd_out_valid == 1'b1) begin
                    d1lm = floatadd_out_data;
                    floatadd_a_valid = 1'b0;
                    floatadd_b_valid = 1'b0;
                    d1l = 'b0;  // same QUESTION as the upper one
                    d1m = 'b0;  // same
                    
                    st_next = d1left_t;
                end else
                    st_next = d1left;  // waiting for adder finish
            end
            d1left_t: begin
                if(floatadd_out_valid == 1'b0) begin
                    floatadd_a_data = d1lm;
                    floatadd_a_valid = 1'b1;
                    floatadd_b_data = d2t;
                    floatadd_b_valid = 1'b1;
                    
                    st_next = d1;
                end else
                    st_next = d1left_t;  // waiting for cleaning up
            end
            d1: begin
                if(floatadd_out_valid == 1'b1) begin
                    d1t = floatadd_out_data;
                    floatadd_a_valid = 1'b0;
                    floatadd_b_valid = 1'b0;
                    d1lm = 'b0;
                    d2t = 'b0;
                    
                    st_next = d1_t;
                end else
                    st_next = d1;  // waiting for our adder
            end
            d1_t: begin
                if(floatadd_out_valid == 1'b0) begin
                    floatmulti_a_data = a0;
                    floatmulti_a_valid = 1'b1;
                    floatmulti_b_data = xn;
                    floatmulti_b_valid = 1'b1;
                    
                    st_next = ynleft;
                end else
                    st_next = d1_t;  // waiting for cleaning up
            end
            ynleft: begin
                if(floatmulti_out_valid == 1'b1) begin
                    ynl = floatmulti_out_data;
                    floatmulti_a_valid = 1'b0;
                    floatmulti_b_valid = 1'b0;
                    
                    st_next = ynleft_t;
                end else
                    st_next = ynleft;  // waiting for multiply
            end
            ynleft_t: begin
                if(floatmulti_out_valid == 1'b0) begin
                    floatadd_a_data = ynl;
                    floatadd_a_valid = 1'b1;
                    floatadd_b_data = d1t;
                    floatadd_b_valid = 1'b1;
                    
                    st_next = yn;
                end else
                    st_next = ynleft_t;  // waiting for cleaning up
            end
            yn: begin
                if(floatadd_out_valid == 1'b1) begin
                    data_out = floatadd_out_data;
                    floatadd_a_valid = 1'b0;
                    floatadd_b_valid = 1'b0;
                    
                    ynl = 'b0;
                    d1t = 'b0;
                    
                    yn_2 = yn_1;  // update registers for past 1 and 2 calculations
                    xn_2 = xn_1;
                    
                    data_out_valid = 1'b1;  // data output is ready here
                    
                    st_next = yn_t;
                end else
                    st_next = yn;  // waiting for adder complete this turn
            end
            yn_t: begin
                if(floatadd_out_valid == 1'b0) begin
                    yn_1 = data_out;
                    xn_1 = xn;
                    data_out_valid = 1'b0;  // data out set to not ready, preparing for the next turn
                    
                    st_next = IDLE;
                end else
                    st_next = yn_t; // waiting for cleaning up
            end
        endcase
    end
    
endmodule
