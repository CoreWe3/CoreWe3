library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ram_controller_tb is
end ram_controller_tb;

architecture test_arch of ram_controller_tb is
  component ram_controller is
    port (
      clk : in std_logic;
      ZD : inout std_logic_vector(31 downto 0);
      ZA : out std_logic_vector(19 downto 0);
      XWA : out std_logic;
      input : in std_logic_vector(31 downto 0);
      output : out std_logic_vector(31 downto 0);
      addr : in std_logic_vector(19 downto 0);
      we : in std_logic;
      go : in std_logic;
      busy : out std_logic);
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
  signal input : std_logic_vector(31 downto 0);
  signal output : std_logic_vector(31 downto 0);
  signal addr : std_logic_vector(19 downto 0);
  signal we : std_logic := '0';
  signal go : std_logic := '0';
  signal busy : std_logic;

  signal state : std_logic_vector(2 downto 0) := (others => '0');

begin

  SRAM_u : SRAM port map (
    clk => clk,
    ZD => ZD,
    ZA => ZA,
    XWA => XWA);

  main : ram_controller port map (
    clk => clk,
    ZD => ZD,
    ZA => ZA,
    XWA => XWA,
    input => input,
    output => output,
    addr => addr,
    we => we,
    go => go,
    busy => busy);

  process
  begin
    clk <= '1';
    wait for 1 ns;
    clk <= '0';
    wait for 1 ns;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when "000" =>
          if busy = '0' and go = '0' then
            go <= '1';
            we <= '1';
            input <= x"abcd0000";
            addr <= x"aaaaa";
            state <= "001";
          else
            go <= '0';
          end if;
        when "001" =>
          if busy = '0' and go = '0' then
            go <= '1';
            we <= '0';
            state <= "010";
          else
            go <= '0';
          end if;
        when "010" =>
          if busy = '0' and go = '0' then
            go <= '1';
            we <= '1';
            input <= x"12345678";
            addr <= x"11111";
            state <= "011";
          else
            go <= '0';
          end if;
        when "011" =>
          if busy = '0' and go = '0' then
            go <= '1';
            we <= '0';
            state <= "000";
          else
            go <= '0';
          end if;
        when others =>
          go <= '0';
          state <= "000";
      end case;
    end if;
  end process;
    
end test_arch;
