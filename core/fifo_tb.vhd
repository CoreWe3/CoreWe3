library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fifo_tb is
end fifo_tb;

architecture tb of fifo_tb is
  component FIFO is
    generic (
      SIZE : integer := 4;
      WIDTH : integer := 2);
    port (
      clk : in std_logic;
      idata : in std_logic_vector(31 downto 0);
      odata : out std_logic_vector(31 downto 0);
      igo : in std_logic;
      ogo : in std_logic;
      empty : out std_logic;
      full : out std_logic);
  end component;

  signal clk : std_logic;
  signal idata : std_logic_vector(31 downto 0);
  signal odata : std_logic_vector(31 downto 0);  
  signal igo : std_logic := '0';
  signal ogo : std_logic := '0';
  signal empty : std_logic;
  signal full : std_logic;

  signal state : std_logic_vector(2 downto 0) := "000";
begin

  main : fifo port map (
    clk => clk,
    idata => idata,
    odata => odata,
    igo => igo,
    ogo => ogo,
    empty => empty,
    full => full);

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when "000" =>
          ogo <= '1';
          igo <= '0';
        when "001" =>
          igo <= '1';
          ogo <= '0';
          idata <= x"00000001";
        when "010" =>
          igo <= '1';
          ogo <= '0';
          idata <= x"00000002";
        when others =>
          ogo <= '0';
          igo <= '0';
      end case;
      state <= state+1;
    end if;
  end process;

  process
  begin
    clk <= '1';
    wait for 1 ns;
    clk <= '0';
    wait for 1 ns;
  end process;

end tb;
