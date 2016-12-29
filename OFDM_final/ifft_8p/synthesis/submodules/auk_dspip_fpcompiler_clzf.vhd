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

entity auk_dspip_fpcompiler_clzf is
  port (
    frac : in std_logic_vector (32 downto 1);
    count : out std_logic_vector (5 downto 1)
    );
end auk_dspip_fpcompiler_clzf;

architecture rtl of auk_dspip_fpcompiler_clzf is
  
  type numtype is array (32 downto 1) of std_logic_vector (5 downto 1);
  type muxctltype is array (8 downto 1) of std_logic_vector (4 downto 1);
  type muxtype is array (8 downto 1) of std_logic_vector (5 downto 1);

  signal sec, sel : std_logic_vector (8 downto 1);
  signal num      : numtype;
  signal muxctl   : muxctltype;
  signal mux      : muxtype;
  
begin
  
  sec(1) <= frac(32) or frac(31) or frac(30) or frac(29);
  sec(2) <= frac(28) or frac(27) or frac(26) or frac(25);
  sec(3) <= frac(24) or frac(23) or frac(22) or frac(21);
  sec(4) <= frac(20) or frac(19) or frac(18) or frac(17);
  sec(5) <= frac(16) or frac(15) or frac(14) or frac(13);
  sec(6) <= frac(12) or frac(11) or frac(10) or frac(9);
  sec(7) <= frac(8) or frac(7) or frac(6) or frac(5);
  sec(8) <= frac(4) or frac(3) or frac(2) or frac(1);

  -- sel(1) => [32:29], sel(2) => [28:25], etc
  sel(1) <= sec(1);
  sel(2) <= sec(2) and not(sec(1));
  sel(3) <= sec(3) and not(sec(2)) and not(sec(1));
  sel(4) <= sec(4) and not(sec(3)) and not(sec(2)) and not(sec(1));
  sel(5) <= sec(5) and not(sec(4)) and not(sec(3)) and not(sec(2)) and not(sec(1));
  sel(6) <= sec(6) and not(sec(5)) and not(sec(4)) and not(sec(3)) and not(sec(2)) and not(sec(1));
  sel(7) <= sec(7) and not(sec(6)) and not(sec(5)) and not(sec(4)) and not(sec(3)) and not(sec(2)) and not(sec(1));
  sel(8) <= sec(8) and not(sec(7)) and not(sec(6)) and not(sec(5)) and not(sec(4)) and not(sec(3)) and not(sec(2)) and not(sec(1));

  gna : for k in 1 to 32 generate
    num(k)(5 downto 1) <= conv_std_logic_vector (k-1, 5);
  end generate;

  -- muxctl(1)(1) <= frac32, muxctl(1)(2) <= frac31, etc
  gca : for k in 1 to 8 generate
    muxctl(9-k)(1) <= frac(4*k);
    muxctl(9-k)(2) <= frac(4*k-1) and not(frac(4*k));
    muxctl(9-k)(3) <= frac(4*k-2) and not(frac(4*k)) and not(frac(4*k-1));
    muxctl(9-k)(4) <= frac(4*k-3) and not(frac(4*k)) and not(frac(4*k-1)) and not(frac(4*k-2));
  end generate;

  gma : for k in 1 to 8 generate
    gmb : for j in 1 to 5 generate
      mux(k)(j) <= (num(4*k-3)(j) and muxctl(k)(1)) or
                   (num(4*k-2)(j) and muxctl(k)(2)) or
                   (num(4*k-1)(j) and muxctl(k)(3)) or
                   (num(4*k)(j) and muxctl(k)(4));
    end generate;
  end generate;

  gmc : for k in 1 to 5 generate
    count(k) <= (mux(1)(k) and sel(1)) or
                (mux(2)(k) and sel(2)) or
                (mux(3)(k) and sel(3)) or
                (mux(4)(k) and sel(4)) or
                (mux(5)(k) and sel(5)) or
                (mux(6)(k) and sel(6)) or
                (mux(7)(k) and sel(7)) or
                (mux(8)(k) and sel(8));
  end generate;
  
end rtl;

