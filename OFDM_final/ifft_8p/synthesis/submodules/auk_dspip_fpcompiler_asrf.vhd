-- (C) 2001-2015 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions and other 
-- software and tools, and its AMPP partner logic functions, and any output 
-- files any of the foregoing (including device programming or simulation 
-- files), and any associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License Subscription 
-- Agreement, Altera MegaCore Function License Agreement, or other applicable 
-- license agreement, including, without limitation, that your use is for the 
-- sole purpose of programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the applicable 
-- agreement for further details.



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- asr 32 bits
entity auk_dspip_fpcompiler_asrf is
  port (
    inbus : in std_logic_vector (32 downto 1);
    shift : in std_logic_vector (5 downto 1);

    outbus : out std_logic_vector (32 downto 1)
    );
end auk_dspip_fpcompiler_asrf;

architecture rtl of auk_dspip_fpcompiler_asrf is
  
  signal levzip, levone, levtwo, levthr, levfor, levfiv : std_logic_vector (32 downto 1);
  
begin
  
  levzip <= inbus;

  gaa : for k in 1 to 31 generate
    levone(k) <= (levzip(k) and not(shift(1))) or (levzip(k+1) and shift(1));
  end generate;
  levone(32) <= inbus(32);

  gba : for k in 1 to 30 generate
    levtwo(k) <= (levone(k) and not(shift(2))) or (levone(k+2) and shift(2));
  end generate;
  levtwo(31) <= (levone(31) and not(shift(2))) or (levone(32) and shift(2));
  levtwo(32) <= levone(32);

  gca : for k in 1 to 28 generate
    levthr(k) <= (levtwo(k) and not(shift(3))) or (levtwo(k+4) and shift(3));
  end generate;
  gcb : for k in 29 to 32 generate
    levthr(k) <= (levtwo(k) and not(shift(3))) or (levtwo(32) and shift(3));
  end generate;

  gda : for k in 1 to 24 generate
    levfor(k) <= (levthr(k) and not(shift(4))) or (levthr(k+8) and shift(4));
  end generate;
  gdb : for k in 25 to 32 generate
    levfor(k) <= (levthr(k) and not(shift(4))) or (levthr(32) and shift(4));
  end generate;

  gea : for k in 1 to 16 generate
    levfiv(k) <= (levfor(k) and not(shift(5))) or (levfor(k+16) and shift(5));
  end generate;
  geb : for k in 17 to 32 generate
    levfiv(k) <= (levfor(k) and not(shift(5))) or (levfor(32) and shift(5));
  end generate;

  outbus <= levfiv;
  
end rtl;

