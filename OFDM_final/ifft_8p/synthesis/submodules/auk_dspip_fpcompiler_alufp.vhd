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

-- add/sub float
entity auk_dspip_fpcompiler_alufp is
  port (
    sysclk       : in std_logic;
    reset        : in std_logic;
    enable       : in  std_logic;
    addsub       : in std_logic;
    aa           : in std_logic_vector (42 downto 1);
    aasat, aazip : in std_logic;
    bb           : in std_logic_vector (42 downto 1);
    bbsat, bbzip : in std_logic;
    cc           : out std_logic_vector (42 downto 1);
    ccsat, cczip : out std_logic
    );
end auk_dspip_fpcompiler_alufp;

architecture rtl of auk_dspip_fpcompiler_alufp is
  
  type expbasefftype is array (3 downto 1) of std_logic_vector (10 downto 1);

  signal manleftff, manrightff, delmanleftff           : std_logic_vector (32 downto 1);
  signal shiftbus, shiftbusnode, shiftbusff            : std_logic_vector (32 downto 1);
  signal aluleft, aluright, aluff                      : std_logic_vector (32 downto 1);
  signal carryvec                                      : std_logic_vector (32 downto 1);
  signal zerovec                                       : std_logic_vector (31 downto 1);
  signal expbaseff                                     : expbasefftype;
  signal expshiftff                                    : std_logic_vector (10 downto 1);
  signal addsubff                                      : std_logic_vector (2 downto 1);
  signal ccsatff, cczipff                              : std_logic_vector (3 downto 1);
  signal switch, switchff, invertleftff, invertrightff : std_logic;
  signal subexpone, subexptwo                          : std_logic_vector (10 downto 1);
  signal expzerochk                                    : std_logic_vector (10 downto 1);

  component auk_dspip_fpcompiler_asrf
    port (
      inbus : in std_logic_vector (32 downto 1);
      shift : in std_logic_vector (5 downto 1);
      outbus : out std_logic_vector (32 downto 1)
      );
  end component;
  
begin
  
  zerovec <= conv_std_logic_vector (0, 31);

  paa : process (sysclk, reset)
  begin
    
    if (reset = '1') then
      
      for k in 1 to 32 loop
        manleftff(k)    <= '0';
        delmanleftff(k) <= '0';
        manrightff(k)   <= '0';
        shiftbusff(k)   <= '0';
        aluff(k)        <= '0';
      end loop;
      for k in 1 to 10 loop
        expbaseff(1)(k) <= '0';
        expbaseff(2)(k) <= '0';
        expbaseff(3)(k) <= '0';
        expshiftff(k)   <= '0';
      end loop;
      addsubff      <= "00";
      switchff      <= '0';
      ccsatff       <= "000";
      cczipff       <= "000";
      invertleftff  <= '0';
      invertrightff <= '0';
      
    elsif (rising_edge(sysclk)) then
      if enable = '1' then
      -- level 1
      for k in 1 to 32 loop
        manleftff(k)  <= (aa(k+10) and not(switch)) or (bb(k+10) and switch);
        manrightff(k) <= (bb(k+10) and not(switch)) or (aa(k+10) and switch);
      end loop;
      for k in 1 to 10 loop
        expbaseff(1)(k) <= (aa(k) and not(switch)) or (bb(k) and switch);
      end loop;
      expbaseff(2)(10 downto 1) <= expbaseff(1)(10 downto 1);
      expbaseff(3)(10 downto 1) <= expbaseff(2)(10 downto 1);
      for k in 1 to 10 loop
        expshiftff(k) <= (subexpone(k) and not(switch)) or (subexptwo(k) and switch);
      end loop;

      addsubff(1) <= addsub;
      addsubff(2) <= addsubff(1);

      switchff <= switch;

      ccsatff(1) <= aasat or bbsat;
      ccsatff(2) <= ccsatff(1);
      ccsatff(3) <= ccsatff(2);
      -- once through add/sub, output can only be ieee754"0" if both inputs are ieee754"0"
      cczipff(1) <= aazip and bbzip;
      cczipff(2) <= cczipff(1);
      cczipff(3) <= cczipff(2);

      -- level 2
      delmanleftff  <= manleftff;
      shiftbusff    <= shiftbus;
      --invertleftff <= addsubff(2) AND switch;  
      --invertrightff <= addsubff(2) AND NOT(switch);   
      invertleftff  <= addsubff(1) and switchff;
      invertrightff <= addsubff(1) and not(switchff);

      -- level 3
      aluff <= aluleft + aluright + carryvec;
      end if;
      
    end if;
    
  end process;

  subexpone <= aa(10 downto 1) - bb(10 downto 1);
  subexptwo <= bb(10 downto 1) - aa(10 downto 1);

  switch <= subexpone(10);

  expzerochk <= expshiftff - "0000100000"; 

  shift : auk_dspip_fpcompiler_asrf port map (inbus => manrightff, shift => expshiftff(5 downto 1), outbus => shiftbusnode);

  gsba : for k in 1 to 32 generate
    shiftbus(k) <= shiftbusnode(k) and expzerochk(10);
  end generate;

  gaa : for k in 1 to 32 generate
    aluleft(k)  <= delmanleftff(k) xor invertleftff;
    aluright(k) <= shiftbusff(k) xor invertrightff;
  end generate;
  carryvec <= zerovec & addsubff(2);

  cc    <= aluff & expbaseff(3)(10 downto 1);
  ccsat <= ccsatff(3);
  cczip <= cczipff(3);
  
end rtl;

