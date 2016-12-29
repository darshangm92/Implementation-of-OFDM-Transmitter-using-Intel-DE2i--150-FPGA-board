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

entity auk_dspip_fpcompiler_castftox is
  port (
    aa : in std_logic_vector (32 downto 1);
    cc           : out std_logic_vector (42 downto 1);
    ccsat, cczip : out std_logic
    );
end auk_dspip_fpcompiler_castftox;

architecture rtl of auk_dspip_fpcompiler_castftox is
  
  signal fractional : std_logic_vector (32 downto 1);
  signal exponent   : std_logic_vector (10 downto 1);
  signal satf, zipf : std_logic;
  
begin

  -- aa: sign (32), 8 exponent (31:24), 23 mantissa (23:1)
  -- fractional : (signx4,!sign,mantissa XOR sign, signx4)
  -- cc: fractional(42:11), exponent (10:1)

  -- if exponent = 255 => saturate, if 0 => 0
  satf <= aa(31) and aa(30) and aa(29) and aa(28) and
          aa(27) and aa(26) and aa(25) and aa(24);
  zipf <= not(aa(31) or aa(30) or aa(29) or aa(28) or
              aa(27) or aa(26) or aa(25) or aa(24));

  gxa : for k in 1 to 8 generate
    exponent(k) <= (aa(k+23) or satf) and not(zipf);
  end generate;
  exponent(9)  <= satf;
  exponent(10) <= '0';

  fractional(32) <= aa(32);
  fractional(31) <= aa(32);
  fractional(30) <= aa(32);
  fractional(29) <= aa(32);
  fractional(28) <= not(aa(32));        -- '1' XOR sign
  gfa : for k in 1 to 23 generate
    fractional(k+4) <= (aa(k) xor aa(32));
  end generate;
  gfb : for k in 1 to 4 generate
    fractional(k) <= aa(32);            -- '0' XOR sign
  end generate;

  cc    <= (fractional & exponent);
  ccsat <= satf;
  cczip <= zipf;

end rtl;

