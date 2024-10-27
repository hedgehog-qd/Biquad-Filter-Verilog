-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Thu Oct 24 22:57:43 2024
-- Host        : DESKTOP-4982S5B running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/ASUS/Documents/VivadoProjects/iir_design_waveSim/iir_design_waveSim.srcs/sources_1/ip/floating_point_3/floating_point_3_stub.vhdl
-- Design      : floating_point_3
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7s25csga225-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity floating_point_3 is
  Port ( 
    aclk : in STD_LOGIC;
    s_axis_a_tvalid : in STD_LOGIC;
    s_axis_a_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_result_tvalid : out STD_LOGIC;
    m_axis_result_tdata : out STD_LOGIC_VECTOR ( 23 downto 0 )
  );

end floating_point_3;

architecture stub of floating_point_3 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "aclk,s_axis_a_tvalid,s_axis_a_tdata[63:0],m_axis_result_tvalid,m_axis_result_tdata[23:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "floating_point_v7_1_7,Vivado 2018.3";
begin
end;
