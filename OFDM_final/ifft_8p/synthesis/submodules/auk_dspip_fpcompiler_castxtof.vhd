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
library work;
use work.auk_dspip_math_pkg.all;

entity auk_dspip_fpcompiler_castxtof is
  port (
    sysclk       : in  std_logic;
    reset        : in  std_logic;
    enable       : in  std_logic;
    aa           : in  std_logic_vector (42 downto 1);
    aasat, aazip : in  std_logic;
    cc           : out std_logic_vector (32 downto 1)
    );
end auk_dspip_fpcompiler_castxtof;

architecture rtl of auk_dspip_fpcompiler_castxtof is
  
  type abstype is array (2 downto 1) of std_logic_vector (32 downto 1);
  type exptype is array (3 downto 1) of std_logic_vector (10 downto 1);

  signal absff          : abstype;
  signal signff         : std_logic_vector (3 downto 1);
  signal count, countff : std_logic_vector (5 downto 1);
  signal expff          : exptype;
  signal expnode        : std_logic_vector (10 downto 1);
  signal satff, zipff   : std_logic_vector (2 downto 1);
  signal satexp, zipexp : std_logic;
  signal mannode, manff : std_logic_vector (32 downto 1);
  signal absnode        : std_logic_vector (32 downto 1);

  signal abszerocheck : std_logic;
  signal abszerocheckff : std_logic;
  component auk_dspip_fpcompiler_clzf
    port (
      frac : in std_logic_vector (32 downto 1);

      count : out std_logic_vector (5 downto 1)
      );
  end component;

  component auk_dspip_fpcompiler_aslf
    port (
      inbus : in std_logic_vector (32 downto 1);
      shift : in std_logic_vector (5 downto 1);

      outbus : out std_logic_vector (32 downto 1)
      );
  end component;

begin
  
  pma : process (sysclk, reset)
  begin
    
    if (reset = '1') then
      
      for k in 1 to 32 loop
        absff(1)(k) <= '0';
        absff(2)(k) <= '0';
      end loop;
      signff                <= "000";
      countff               <= "00000";
      expff(1)(10 downto 1) <= "0000000000";
      expff(2)(10 downto 1) <= "0000000000";
      expff(3)(10 downto 1) <= "0000000000";
      satff                 <= "00";
      zipff                 <= "00";
      for k in 1 to 32 loop
        manff(k) <= '0';
      end loop;
      
    elsif (rising_edge(sysclk)) then
      if enable = '1' then
      absff(1)(32 downto 1) <= absnode;
      abszerocheck <= not(or_reduce(absnode));
      absff(2)(32 downto 1) <= absff(1)(32 downto 1);
      abszerocheckff <= abszerocheck;

      signff(1) <= aa(42);
      signff(2) <= signff(1);
      signff(3) <= signff(2);

      countff <= count;

      expff(1)(10 downto 1) <= aa(10 downto 1);
      expff(2)(10 downto 1) <= expff(1)(10 downto 1) + "0000000100";
      for k in 1 to 10 loop
        expff(3)(k) <= (expnode(k) or satff(2) or satexp) and not(zipff(2)) and not(zipexp);
      end loop;

      satff(1) <= aasat;
      satff(2) <= satff(1);

      zipff(1) <= aazip;
      zipff(2) <= zipff(1);
	  
		if zipff(2) ='1' then  -- SPR 250285:   the mantissa is also zeroed when azip is asserted
			manff(31 downto 9) <= (others=>'0');			
		else
			manff <= mannode;                 
		end if;
      
      end if;
      
    end if;
    
  end process;

  gaa : for k in 1 to 32 generate
    absnode(k) <= aa(k+10) xor aa(42);
  end generate;

  expnode <= expff(2)(10 downto 1) - ("00000" & countff);

  -- both '1' when condition true
  satexp <= expnode(9) or (expnode(8) and expnode(7) and expnode(6) and expnode(5) and
                           expnode(4) and expnode(3) and expnode(2) and expnode(1));
  zipexp <= expnode(10) or not(expnode(8) or expnode(7) or expnode(6) or expnode(5) or
                               expnode(4) or expnode(3) or expnode(2) or expnode(1)) or abszerocheckff;

  -- '1' expected in position 28 - if count = 0 => exponent +4
  clz : auk_dspip_fpcompiler_clzf port map (frac => absff(1)(32 downto 1), count => count);

  sft : auk_dspip_fpcompiler_aslf port map (inbus => absff(2)(32 downto 1), shift => countff, outbus => mannode);

  -- OUTPUT
  cc(32)           <= signff(3);
  cc(31 downto 24) <= expff(3)(8 downto 1);
  cc(23 downto 1)  <= manff(31 downto 9);

end rtl;

