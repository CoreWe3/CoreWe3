library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

entity ram_controller is
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
end ram_controller;

architecture arch_ram_controller of ram_controller is

  component bram is
    port (
      clk : in std_logic;
      input : in std_logic_vector(31 downto 0);
      output : out std_logic_vector(31 downto 0);
      addr : in std_logic_vector(11 downto 0);
      we : in std_logic);
  end component;

  signal state : std_logic_vector(3 downto 0) := (others => '0');
  signal buf : std_logic_vector(31 downto 0);
  signal boutput : std_logic_vector(31 downto 0);
  signal bwe : std_logic;
  
begin

  bram_u : bram port map (
    clk => clk,
    input => input,
    output => boutput,
    addr => addr(11 downto 0),
    we => bwe);
    
  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when "0000" =>
          if go = '1' then
            if we = '1' then --write
              if addr(19 downto 12) = x"EF" then
                bwe <= '1';
                XWA <= '1';
                state <= "0001";
              else
                bwe <= '0';
                XWA <= '0';
                buf <= input;
                state <= "0010";
              end if;
            else  --read
              XWA <= '1';
              bwe <= '0';
              if addr(19 downto 12) = x"EF" then
                state <= "0011";
              else
                state <= "0100";
              end if;
            end if;
            ZA <= addr;
          else
            bwe <= '0';
            XWA <= '1';
          end if;
        when "0001" => --write bram
          bwe <= '0';
          state <= "0000";
        when "0010" => --write sram
          XWA <= '1';
          state <= "0101";
        when "0101" => --write sram
          ZD <= buf;
          state <= "0000";
        when "0011" => --read bram
          output <= boutput;
          state <= "0000";
        when "0100" => --read sram
          state <= "0110";
          ZD <= (others => 'Z');
        when "0110" => --read sram
          state <= "0111";
        when "0111" => --read sram
          output <= ZD;
          state <= "0000";
        when others =>
          state <= "0000";
          XWA <= '1';
          bwe <= '0';
      end case;
    end if;
  end process;
  
  busy <= '0' when state = "0000" else
          '1';

end arch_ram_controller;
