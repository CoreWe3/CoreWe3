library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

entity code_rom is
  generic(ADDR_WIDTH : integer := 16;
          SIZE : integer := 65536;
          CODE : string := "code.foo");
  
  port (clk : in std_logic;
        en : in std_logic;
        addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        instr : out std_logic_vector(31 downto 0));
end code_rom;

architecture arch_code_rom of code_rom is
  type rom_t is array (0 to SIZE-1) of bit_vector(31 downto 0);

  impure function init_rom (file_name : in string) return rom_t is
    file rom_file : text is in file_name;
    variable file_line : line;
    variable ROM : rom_t;
  begin
    for i in rom_t'range loop
      readline (rom_file, file_line);
      read (file_line, ROM(i));
    end loop;
    return ROM;
  end function;

  signal ROM : rom_t := init_rom(CODE);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if en = '1' then
        instr <= to_stdLogicVector(ROM(conv_integer(addr)));
      end if;
    end if;
  end process;

end arch_code_rom;
      
  
