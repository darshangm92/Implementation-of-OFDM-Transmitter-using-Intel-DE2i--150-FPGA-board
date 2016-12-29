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
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

-- multiply x format
-- coarse adjust to avoid overflow
entity auk_dspip_fpcompiler_mulfp is
  port (
    sysclk       : in std_logic;
    reset        : in std_logic;
    enable       : in  std_logic;
    aa           : in std_logic_vector (42 downto 1);
    aasat, aazip : in std_logic;
    bb           : in std_logic_vector (42 downto 1);
    bbsat, bbzip : in std_logic;
    cc           : out std_logic_vector (42 downto 1);
    ccsat, cczip : out std_logic
    );
end auk_dspip_fpcompiler_mulfp;

architecture rtl of auk_dspip_fpcompiler_mulfp is
  
  
  signal shiftaa, shiftbb : std_logic;
  signal aaman, bbman     : std_logic_vector (32 downto 1);
  signal aaexp, bbexp     : std_logic_vector (10 downto 1);

  signal aamanff, bbmanff                   : std_logic_vector (32 downto 1);
  signal mulff                              : std_logic_vector (64 downto 1);
  signal aaexpff, bbexpff, expff            : std_logic_vector (10 downto 1);
  signal expnode                            : std_logic_vector (10 downto 1);
  signal aasatff, aazipff, bbsatff, bbzipff : std_logic;
  signal ccsatff, cczipff                   : std_logic;
  
begin
  
  shiftaa <= (aa(42) and (not(aa(41)) or not(aa(40)) or not(aa(39)))) or
             (not(aa(42)) and (aa(41) or aa(40) or aa(39)));
  shiftbb <= (bb(42) and (not(bb(41)) or not(bb(40)) or not(bb(39)))) or
             (not(bb(42)) and (bb(41) or bb(40) or bb(39)));
  
  gma : for k in 1 to 29 generate
    aaman(k) <= (aa(k+10) and not(shiftaa)) or (aa(k+13) and shiftaa);
    bbman(k) <= (bb(k+10) and not(shiftbb)) or (bb(k+13) and shiftbb);
  end generate;
  gmb : for k in 30 to 32 generate
    aaman(k) <= (aa(k+10) and not(shiftaa)) or (aa(42) and shiftaa);
    bbman(k) <= (bb(k+10) and not(shiftbb)) or (bb(42) and shiftbb);
  end generate;

  aaexp <= aa(10 downto 1) + ("00000000" & shiftaa & shiftaa);
  bbexp <= bb(10 downto 1) + ("00000000" & shiftbb & shiftbb);

  pma : process (sysclk, reset)
  begin
    
    if (reset = '1') then
      
      aaexpff <= "0000000000";
      bbexpff <= "0000000000";
      expff   <= "0000000000";
      aasatff <= '0';
      aazipff <= '0';
      bbsatff <= '0';
      bbzipff <= '0';
      
    elsif (rising_edge(sysclk)) then
      if enable = '1' then
      -- don't bother resetting DSP block
      aamanff <= aaman;
      bbmanff <= bbman;
      mulff   <= aamanff * bbmanff;

      aasatff <= aasat;
      aazipff <= aazip;
      bbsatff <= bbsat;
      bbzipff <= bbzip;

      aaexpff <= aaexp;
      bbexpff <= bbexp;
      -- 
      for k in 1 to 10 loop
        expff(k) <= (expnode(k) or aasatff or bbsatff) and not(aazipff) and not(bbzipff);
      end loop;

      ccsatff <= aasatff or bbsatff;
      cczipff <= aazipff or bbzipff;
      
      end if;
    end if;
    
  end process;

  expnode <= aaexpff + bbexpff - "0001111111"; 

  -- shift left by 3 to maintain position of '1.0'
  -- shift left by 5 - no multx2 on input
  cc    <= mulff(59 downto 28) & expff;
  ccsat <= ccsatff;
  cczip <= cczipff;
  
end rtl;

