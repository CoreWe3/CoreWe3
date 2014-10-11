library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity core_main is
  
  port (
    clk   : in    std_logic;
    RS_TX : out   std_logic;
    RS_RX : in    std_logic;
    ZD    : inout std_logic_vector(31 downto 0);
    ZA    : out   std_logic_vector(19 downto 0);
    XWA   : out   std_logic);

end core_main;

architecture arch_core_main of core_main is
  component code_rom
    generic ( ADDR_WIDTH : integer := 2;
              SIZE : integer := 4;
              FILE_NAME : string := "hogehoge");
    port (
      clk : in std_logic;
      en : in std_logic;
      addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      instr : out std_logic_vector(31 downto 0));
  end component;

  component alu
    port ( in_word1 : in std_logic_vector(31 downto 0);
           in_word2 : in std_logic_vector(31 downto 0);
           out_word : out std_logic_vector(31 downto 0);
           ctrl : in std_logic_vector(2 downto 0));
  end component;

  signal instr_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal sram_addr : std_logic_vector(19 downto 0);
  signal instr : std_logic_vector(31 downto 0);
  signal state : std_logic_vector(3 downto 0) := (others => '0');

begin  

  process(clk)
  begin
    case state is
      when "0000" => --fetch

      when "0001" => --decode read

      when "0010" => --exec memory write
    end case;
    
  

end arch_core_main;
