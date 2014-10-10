library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity registers_tb is
end registers_tb;

architecture arch_registers_tb of registers_tb is
  component registers
    port (
      clk : in std_logic;
      we : in std_logic;
      addr1 : in std_logic_vector(3 downto 0);
      addr2 : in std_logic_vector(3 downto 0);
      wi : in std_logic_vector(31 downto 0);
      wo1 : out std_logic_vector(31 downto 0);
      wo2 : out std_logic_vector(31 downto 0));
  end component;

  signal clk : std_logic;
  signal input : std_logic_vector(31 downto 0);
  signal output1 : std_logic_vector(31 downto 0);  
  signal output2 : std_logic_vector(31 downto 0);
  signal state : std_logic_vector(3 downto 0) := (others => '1');
  signal a1 : std_logic_vector(3 downto 0) := (others => '0');
  signal a2 : std_logic_vector(3 downto 0) := (others => '0');

begin

  reg : registers port map (
    clk => clk,
    we => '1',
    addr1 => a1,
    addr2 => a2,
    wi => input,
    wo1 => output1,
    wo2 => output2);

  process(clk)
  begin
    if rising_edge(clk) then
      input <= state &
               state & 
               state & 
               state & 
               state & 
               state & 
               state & 
               state ;
      a1 <= state;
      a2 <= state+1;
      state <= state+1;
    end if;
  end process;
    
  process
  begin
    clk <= '0';
    wait for 1 ns;
    clk <= '1';
    wait for 1 ns;
  end process;

end arch_registers_tb;
