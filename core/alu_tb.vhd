library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu_tb is
end alu_tb;

architecture arch_alu_tb of alu_tb is
  component alu
    port (
      in_word1 : in std_logic_vector(31 downto 0);
      in_word2 : in std_logic_vector(31 downto 0);
      out_word : out std_logic_vector(31 downto 0);
      ctrl : in std_logic_vector(2 downto 0));
  end component;

  signal a : std_logic_vector(31 downto 0);
  signal b : std_logic_vector(31 downto 0);
  signal c : std_logic_vector(31 downto 0);
  signal clk : std_logic;
  signal state : std_logic_vector(3 downto 0) := (others => '1');
begin

  alu0 : alu port map (
    in_word1 => a,
    in_word2 => b,
    out_word => c,
    ctrl => state(2 downto 0));

  tb : process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when "1111" =>
          a <= x"00002342";
          b <= x"00000AF4";
        when "0111" =>
          a <= x"23498439";
          b <= x"00000012";
        when others =>
      end case;
      state <= state + 1;
    end if;
  end process;

  clkgen : process
  begin
    clk <= '0';
    wait for 1 ns;
    clk <= '1';
    wait for 1 ns;
  end process;
end arch_alu_tb;
  
      
