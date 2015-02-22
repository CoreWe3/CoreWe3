library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

library work;
use work.Util.all;

entity CodeSegmentRAM is
  generic (
    file_name : string := "code");
  port (
    clk : in std_logic;
    mem_i : in mem_in_t;
    mem_o : out mem_out_t);
end CodeSegmentRAM;

architecture CodeSegmentRAM_arch of CodeSegmentRAM is

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
      if mem_i.m.go = '1' and mem_i.m.a(19 downto 12) = x"FF" then
        if mem_i.m.we = '1' then
          RAM(to_integer(mem_i.m.a(11 downto 0))) <=
            to_bitvector(std_logic_vector(mem_i.m.d));
        end if;
      end if;
      mem_o.d <= unsigned(to_stdLogicVector(RAM(to_integer(mem_i.m.a(11 downto 0)))));
      mem_o.i <= to_stdLogicVector(RAM(to_integer(mem_i.pc)));
    end if;
  end process;

  mem_o.stall <= '0';

end CodeSegmentRAM_arch;
