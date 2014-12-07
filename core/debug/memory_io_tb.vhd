library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity memory_io_tb is
end memory_io_tb;

architecture arch of memory_io_tb is
  component memory_io is
    generic(
      wtime : std_logic_vector(15 downto 0) := x"1ADB";
      debug : boolean := false);
    port (
      clk        : in    std_logic;
      RS_RX      : in    std_logic;
      RS_TX      : out   std_logic;
      ZD         : inout std_logic_vector(31 downto 0);
      ZA         : out   std_logic_vector(19 downto 0);
      XWA        : out   std_logic;
      store_data : in    std_logic_vector(31 downto 0);
      load_data  : out   std_logic_vector(31 downto 0);
      addr       : in   std_logic_vector(19 downto 0);
      we         : in   std_logic;
      go         : in    std_logic;
      busy       : out   std_logic);
  end component;

  component SRAM is
    port (
      clk : in std_logic;
      ZD : inout std_logic_vector(31 downto 0);
      ZA : in std_logic_vector(19 downto 0);
      XWA : in std_logic);
  end component;

  signal clk : std_logic;
  signal ZD : std_logic_vector(31 downto 0);
  signal ZA : std_logic_vector(19 downto 0);
  signal XWA : std_logic;

  signal store_data : std_logic_vector(31 downto 0);
  signal load_data : std_logic_vector(31 downto 0);  
  signal addr : std_logic_vector(19 downto 0) := x"EF003";
  signal we : std_logic;
  signal go : std_logic;
  signal busy : std_logic;

begin

  main : memory_io port map(
    clk => clk,
    RS_RX => '0',
    RS_TX => open,
    ZD => ZD,
    ZA => ZA,
    XWA => XWA,
    store_data => store_data,
    load_data => load_data,
    addr => addr,
    we => we,
    go => go,
    busy => busy);

  pseudo : SRAM port map(
    clk => clk,
    ZD => ZD,
    ZA => ZA,
    XWA => XWA);

  clkgen : process
  begin
    clk <= '1';
    wait for 1 ps;
    clk <= '0';
    wait for 1 ps;
  end process;

  ctrl : process(clk)
  begin
    if rising_edge(clk) then
      if go = '0' and busy = '0' then
        go <= '1';
        addr <= addr-1;
        if addr > x"EF000" then
          we <= '0';
        elsif addr = x"EEFFA" then
          we <= '0';
          addr <= x"EEFFC";
        else
          we <= '1';
          store_data <= x"000" & addr;
        end if;
      else
        go <= '0';
      end if;
    end if;
  end process;

end arch;
