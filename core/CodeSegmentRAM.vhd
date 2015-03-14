library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

library work;
use work.Util.all;

entity CodeSegmentRAM is
  port (
    clk     : in  std_logic;
    bus_out : in  bus_out_t;
    bus_in  : out bus_in_t);
end CodeSegmentRAM;

architecture CodeSegmentRAM_arch of CodeSegmentRAM is

  type ram_t is array (0 to (2**ADDR_WIDTH)-1) of bit_vector(31 downto 0);

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
  signal RAM : ram_t := init_ram(BOOTLOADER);

  attribute rom_style : string;
  attribute rom_style of RAM : signal is "block";
begin

  process(clk)
    variable vrep : memory_reply_t;
  begin
    if rising_edge(clk) then
      vrep := ((others => '-'), '0', '0');
      if bus_out.m.go = '1' and
        bus_out.m.a(19 downto ADDR_WIDTH) = ones(19 downto ADDR_WIDTH) and
        bus_out.m.a(19 downto 0) /= ones(19 downto 0) then
        if bus_out.m.we = '1' then
          RAM(to_integer(bus_out.m.a(ADDR_WIDTH-1 downto 0))) <=
            to_bitvector(std_logic_vector(bus_out.m.d));
        else
          vrep.d := unsigned(to_stdLogicVector(
            RAM(to_integer(bus_out.m.a(ADDR_WIDTH-1 downto 0)))));
          vrep.complete := '1';
        end if;
      end if;
      bus_in.i <= to_stdLogicVector(RAM(to_integer(bus_out.pc)));
      bus_in.m <= vrep;
    end if;
  end process;

end CodeSegmentRAM_arch;
