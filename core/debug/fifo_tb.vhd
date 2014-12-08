library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fifo_tb is
end fifo_tb;

architecture tb of fifo_tb is
  component FIFO is
    generic (
      WIDTH : integer := 8);
    port (
      clk : in std_logic;
      di : in std_logic_vector(7 downto 0);
      do : out std_logic_vector(7 downto 0);
      enq : in std_logic;
      deq : in std_logic;
      empty : out std_logic;
      full : out std_logic);
  end component;

  signal clk : std_logic;
  signal di : std_logic_vector(7 downto 0);
  signal do : std_logic_vector(7 downto 0);  
  signal enq : std_logic := '0';
  signal deq : std_logic := '0';
  signal empty : std_logic;
  signal full : std_logic;

  signal state : std_logic_vector(2 downto 0) := "000";
begin

  main : fifo port map (
    clk => clk,
    di => di,
    do => do,
    enq => enq,
    deq => deq,
    empty => empty,
    full => full);

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when "000" =>
          deq <= '1';
          enq <= '0';
        when "001" =>
          enq <= '1';
          deq <= '0';
          di <= x"01";
        when "010" =>
          enq <= '1';
          deq <= '0';
          di <= x"02";
        when others =>
          enq <= '0';
          deq <= '0';
      end case;
      state <= state+1;
    end if;
  end process;

  process
  begin
    clk <= '1';
    wait for 1 ps;
    clk <= '0';
    wait for 1 ps;
  end process;

end tb;
