library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity transmit_buffer_tb is
end transmit_buffer_tb;

architecture tb of transmit_buffer_tb is
  component transmit_buffer is
    generic(
      wtime : std_logic_vector(15 downto 0) := x"0001");
    port (
      clk : in std_logic;
      RS_TX : out std_logic;
      go : in std_logic;
      data : in std_logic_vector(31 downto 0);
      busy : out std_logic);
  end component;

  signal clk : std_logic; 
  signal RS_TX : std_logic; 
  signal go : std_logic := '0'; 
  signal data : std_logic_vector(31 downto 0); 
  signal busy : std_logic; 

  signal state : std_logic_vector(2 downto 0) := "000"; 

begin

  main : transmit_buffer port map (
    clk => clk,
    RS_TX => RS_TX,
    go => go,
    data => data,
    busy => busy);

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when "000" =>
          if busy = '0' and go = '0' then
            go <= '1';
            data <= x"12341234";
            state <= state+1;
          else
            go <= '0';
          end if;
        when "001" =>
          if busy = '0' and go = '0' then
            go <= '1';
            data <= x"0A0B0C0D";
            state <= state+1;
          else
            go <= '0';
          end if;
        when "010" =>
          if busy = '0' and go = '0' then
            go <= '1';
            data <= x"01020304";
            state <= state+1;
          else
            go <= '0';
          end if;
        when others =>
          go <= '0';
          state <= "000";
      end case;
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
