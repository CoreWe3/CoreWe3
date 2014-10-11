library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity code_rom_test is
  port (
    clk : in std_logic;
    RS_TX : out std_logic);
end code_rom_test;

architecture arch of code_rom_test is
  component code_rom
    generic (ADDR_WIDTH : integer := 2;
             SIZE : integer := 4;
             CODE : string := "sample.txt");
    port (
      clk : in std_logic;
      en : in std_logic;
      addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      instr : out std_logic_vector(31 downto 0));
  end component;

  component u232c is
    generic (wtime : std_logic_vector(15 downto 0));
    port ( clk  : in std_logic;
           data : in std_logic_vector(7 downto 0);
           go   : in std_logic;
           busy : out std_logic;
           tx   : out std_logic);
  end component;

  signal state : std_logic_vector(1 downto 0) := (others => '0');
  signal go : std_logic := '0';
  signal busy : std_logic := '0';
  signal addr : std_logic_vector(1 downto 0) := (others => '0');
  signal data : std_logic_vector(7 downto 0);
  signal instr : std_logic_vector(31 downto 0);
begin

  rom : code_rom port map
    (clk => clk,
     en => '1',
     addr => addr,
     instr => instr);

  send : u232c
    generic map (wtime => x"1C06")
    port map
    (clk => clk,
     data => data,
     go => go,
     busy => busy,
     tx => RS_TX);
  
  test : process(clk)
  begin
    if rising_edge(clk) then
      --if busy = '0' and go = '0' then
      --  go <= '1';
      --  data <= data + 1;
      --else
      --  go <= '0';
      --end if;

      if busy = '0' and go <= '0' then
        go <= '1';
        case state is
          when "00" =>
            data <= instr(31 downto 24); 
          when "01" =>
            data <= instr(23 downto 16); 
          when "10" =>
            data <= instr(15 downto 8); 
          when "11" =>
            data <= instr(7  downto 0); addr <= addr+1;
          when others =>
        end case;
        state <= state + 1;
      else
        go <= '0';
      end if;

    end if;
  end process;
  
end arch;
