library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity registers is
  port (
    sysclk    : in  std_logic;
    we        : in  std_logic;
    addr1     : in  std_logic_vector(5 downto 0);
    addr2     : in  std_logic_vector(5 downto 0);
    in_word   : in  std_logic_vector(31 downto 0);
    out_word1 : out std_logic_vector(31 downto 0);
    out_word2 : out std_logic_vector(31 downto 0));
  
end registers;

architecture arch_registers of registers is
  type ram_t is array(63 downto 0) of std_logic_vector(31 downto 0);
  signal RAM : ram_t := (
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000", 
    x"00000000", x"00000000", x"00000000", x"00000000");

  attribute ram_style : string;
  attribute ram_style of RAM : signal is "distributed";
       
begin
  process(sysclk)
  begin
    if rising_edge(sysclk) then
      if we = '1' and addr1 /= "000000" then
        RAM(conv_integer(addr1)) <= in_word;
      end if;
      out_word1 <= RAM(conv_integer(addr1));
      out_word2 <= RAM(conv_integer(addr2));
    end if;
  end process;

end arch_registers;
  
