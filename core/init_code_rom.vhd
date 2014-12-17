library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;
library work;
use work.util.all;

entity init_code_rom is
  generic(CODE  : string := "code.bin");
  port (clk   : in  std_logic;
        insti : in inst_in_t;
        insto : out inst_out_t);
end init_code_rom;

architecture arch_code_rom of init_code_rom is
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
      --instr <= ROM(conv_integer(addr));
      insto.d <= to_stdLogicVector(ROM(to_integer(insti.a)));
    end if;
  end process;

end arch_code_rom;
