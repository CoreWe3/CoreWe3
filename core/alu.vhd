library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity alu is
  port (
    clk : in std_logic;
    in_word1 : in std_logic_vector(31 downto 0);
    in_word2 : in std_logic_vector(31 downto 0);
    out_word : out std_logic_vector(31 downto 0);
    ctrl : in std_logic_vector(2 downto 0));
end alu;

architecture arch_alu of alu is
  constant zero : std_logic_vector(31 downto 0) := (others => '0');

  component lshifter is
    port (
      DI : in unsigned(31 downto 0);
      SEL : in unsigned(4 downto 0);
      SO : out unsigned(31 downto 0));
  end component;

  component rshifter is
    port (
      DI : in unsigned(31 downto 0);
      SEL : in unsigned(4 downto 0);
      SO : out unsigned(31 downto 0));
  end component;

  signal out_word_d : std_logic_vector(31 downto 0);  
  signal shiftl : unsigned(31 downto 0);
  signal shiftr : unsigned(31 downto 0);
  signal shift_di : unsigned(31 downto 0);
  signal shift_sel : unsigned(4 downto 0);
  
begin

  lshift : lshifter port map (
    di => shift_di,
    sel => shift_sel,
    so => shiftl);

  rshift : rshifter port map (
    di => shift_di,
    sel => shift_sel,
    so => shiftr);

  shift_di <= unsigned(in_word1);
  shift_sel <= unsigned(in_word2(4 downto 0));

  out_word_d <= in_word1 + in_word2 when ctrl = "000" else
                in_word1 - in_word2 when ctrl = "001" else
                in_word1 and in_word2 when ctrl = "010" else
                in_word1 or in_word2 when ctrl = "011" else
                in_word1 xor in_word2 when ctrl = "100" else
                std_logic_vector(shiftl)
                when ctrl = "101" and in_word2(31 downto 5) = 0 else
                std_logic_vector(shiftr)
                when ctrl = "110" and in_word2(31 downto 5) = 0 else
                zero;

  process(clk)
  begin
    if rising_edge(clk) then
      out_word <= out_word_d;
    end if;
  end process;

end arch_alu;
