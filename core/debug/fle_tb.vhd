library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

entity fle_tb is
end fle_tb;

architecture tb of fle_tb is
  component fle is
    port (
      a : in std_logic_vector(31 downto 0);
      b : in std_logic_vector(31 downto 0);
      cmp : out std_logic);
  end component;

  signal a : std_logic_vector(31 downto 0);
  signal b : std_logic_vector(31 downto 0);
  signal cmp : std_logic;

  signal clk : std_logic := '0';

  file f_in : text open read_mode is "in.dat";
  file f_out : text open write_mode is "vhdl.dat";

begin

  test : fle port map (
    a => a,
    b => b,
    cmp => cmp);
  
  process(clk)
    variable li : line;
    variable va : std_logic_vector(31 downto 0);
    variable vb : std_logic_vector(31 downto 0);
  begin
    if rising_edge(clk) then
      if endfile(f_in) = false then
        readline(f_in, li);
        read(li, va);
        read(li, vb);
        a <= va;
        b <= vb;
      end if;
    elsif falling_edge(clk) then
      write(li, cmp, right, 1);
      writeline(f_out, li);
    end if;
  end process;

  process
  begin
    clk <= '0';
    wait for 1 ns;
    clk <= '1';
    wait for 1 ns;
  end process;
      
end tb;
      
