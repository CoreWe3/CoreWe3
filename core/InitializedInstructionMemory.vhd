library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;
library work;
use work.Util.all;

entity InitializedInstructionMemory is
  generic(
    CODE  : string := "file/test_with_hazard.b");
  port (
    clk : in std_logic;
    instruction_mem_o : out std_logic_vector(31 downto 0);
    instruction_mem_i : in unsigned(ADDR_WIDTH-1 downto 0));
end InitializedInstructionMemory;

architecture InitializedInstructionMemory_arch of
  InitializedInstructionMemory is
  constant SIZE : integer := 2 ** ADDR_WIDTH;
  type rom_t is array (0 to SIZE-1) of bit_vector(31 downto 0);
  --type rom_t is array (0 to SIZE-1) of std_logic_vector(31 downto 0);
  impure function init_rom (file_name : in string) return rom_t is
    --file rom_file : text is in file_name;
    file rom_file : text open read_mode is file_name;
    variable file_line : line;
    variable ROM : rom_t;
  begin
    for i in rom_t'range loop
      readline (rom_file, file_line);
      read(file_line, ROM(i));
      --hread (file_line, ROM(i));
    end loop;
    return ROM;
  end function;

  --signal ROM : rom_t := init_rom(CODE);
  signal ROM : rom_t := init_rom(CODE);

  attribute rom_style : string;
  attribute rom_style of ROM : signal is "block";
begin

  process(clk)
  begin
    if rising_edge(clk) then
      instruction_mem_o <=
        to_stdLogicVector(ROM(to_integer(instruction_mem_i)));
    end if;
  end process;

end InitializedInstructionMemory_arch;
