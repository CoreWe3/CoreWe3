library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity bram is
  generic (file_name : string := "init_data.txt");
  port (
    clk : in std_logic;
    di : in std_logic_vector(31 downto 0);
    do : out std_logic_vector(31 downto 0);
    addr : in std_logic_vector(11 downto 0);
    we : in std_logic);
end bram;

architecture arch_bram of bram is

  type ram_t is array (0 to (2**12)-1) of bit_vector(31 downto 0);

  impure function init_ram (file_name : in string) return ram_t is
    file init_file : text open read_mode is file_name;
    variable file_line : line;
    variable RAM : ram_t;
  begin
    for i in ram_t'range loop
      readline(init_file, file_line);
      read(file_line, RAM(i));
    end loop;
    return RAM;
  end function;
  signal RAM : ram_t := init_ram(file_name);

  attribute rom_style : string;
  attribute rom_style of RAM : signal is "block";
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        RAM(conv_integer(addr)) <= to_bitvector(di);
      end if;
      do <= to_stdLogicVector(RAM(conv_integer(addr)));
    end if;
  end process;

end arch_bram;
