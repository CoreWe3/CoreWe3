library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

entity read_file is
  generic (
    wtime : std_logic_vector(15 downto 0) := x"0003";
    file_name : string := "data.hex");
  port (
    clk : in std_logic;
    complete : out std_logic;
    data : out std_logic_vector(7 downto 0));
end read_file;

architecture arch_read_file of read_file is
  file data_file : text open read_mode is file_name;
  signal state : std_logic_vector(15 downto 0) := wtime;
begin
  process(clk)
    variable data_line : line;
    variable data_v : std_logic_vector(7 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when x"0000" =>
          if(not endfile(data_file)) then
            readline(data_file, data_line);
            hread(data_line, data_v);
            data <= data_v;
            complete <= '1';
          end if;
          state <= wtime;
        when others =>
          complete <= '0';
          state <= state-1;
      end case;
    end if;
  end process;
end arch_read_file;
          
    
