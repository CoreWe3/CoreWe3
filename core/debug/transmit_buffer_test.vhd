library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity transmit_buffer_test is
  port (
    clk : in std_logic;
    RS_TX : out std_logic);
end transmit_buffer_test;

architecture test_arch of transmit_buffer_test is
  component transmit_buffer is
    port (
      clk : in std_logic;
      RS_TX : out std_logic;
      go : in std_logic;
      data : in std_logic_vector(31 downto 0);
      busy : out std_logic);
  end component;

  signal go : std_logic := '0';
  signal busy : std_logic;

begin

  main : transmit_buffer port map (
    clk => clk,
    RS_TX => RS_TX,
    go => go,
    data => x"6161610A",
    busy => busy);

  process(clk)
  begin
    if rising_edge(clk) then
      if busy = '0' and go = '0' then
        go <= '1';
      else
        go <= '0';
      end if;
    end if;
  end process;

end test_arch;
