library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity memory_io is
  generic(
    wtime : std_logic_vector(15 downto 0) := x"1ADB");
  port (
    clk        : in    std_logic;
    RS_RX      : in    std_logic;
    RS_TX      : out   std_logic;
    ZD         : inout std_logic_vector(31 downto 0);
    ZA         : out   std_logic_vector(19 downto 0);
    XWA        : out   std_logic;
    store_data : in    std_logic_vector(31 downto 0);
    load_data  : out   std_logic_vector(31 downto 0);
    addr       : in   std_logic_vector(19 downto 0);
    we         : in   std_logic;
    go         : in    std_logic;
    busy       : out   std_logic);
end memory_io;

architecture arch_memory_io of memory_io is

  component bram is
    port (
      clk : in std_logic;
      di : in std_logic_vector(31 downto 0);
      do : out std_logic_vector(31 downto 0);
      addr : in std_logic_vector(11 downto 0);
      we : in std_logic);
  end component;

  component receive_buffer is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk : in std_logic;
      RS_RX : in std_logic;
      go : in std_logic;
      do : out std_logic_vector(7 downto 0);
      busy : out std_logic);
  end component;

  component transmit_buffer is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk : in std_logic;
      RS_TX : out std_logic;
      go : in std_logic;
      di : in std_logic_vector(7 downto 0);
      busy : out std_logic);
  end component;

  signal state : std_logic_vector(7 downto 0) := x"00";

  signal bram_o : std_logic_vector(31 downto 0);
  signal bwe : std_logic := '0';
  signal buf : std_logic_vector(31 downto 0);

  signal rgo : std_logic := '0';
  signal rbusy : std_logic;
  signal receive_data : std_logic_vector(7 downto 0);

  signal tgo : std_logic := '0';
  signal tbusy : std_logic;

begin

  bram_u : bram port map (
    clk => clk,
    di => store_data,
    do => bram_o,
    addr => addr(11 downto 0),
    we => bwe);

  receive : receive_buffer port map (
    clk => clk,
    RS_RX => RS_RX,
    go => rgo,
    do => receive_data,
    busy => rbusy);

  transmit : transmit_buffer port map (
    clk => clk,
    RS_TX => RS_TX,
    go => tgo,
    di => store_data(7 downto 0),
    busy => tbusy);

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when x"00" =>
          if go = '1' then
            if we = '1' then --write
              if addr = x"FFFFF" then -- transmit
                bwe <= '0';
                XWA <= '1';
                tgo <= '1';
                state <= x"50";
              elsif addr(19 downto 12) = x"EF" then --bram
                bwe <= '1';
                XWA <= '1';
                state <= x"10";
              else --sram
                bwe <= '0';
                XWA <= '0';
                buf <= store_data;
                state <= x"20";
              end if;
            else  --read
              XWA <= '1';
              bwe <= '0';
              if addr = x"FFFFF" then
                rgo <= '1';
                state <= x"60";
              elsif addr(19 downto 12) = x"EF" then --bram
                state <= x"30";
              else --sram
                state <= x"40";
              end if;
            end if;
            ZA <= addr;
          else
            bwe <= '0';
            XWA <= '1';
            tgo <= '0';
            rgo <= '0';
          end if;
        when x"10" => --write bram
          bwe <= '0';
          state <= x"00";
        when x"20" => --write sram
          XWA <= '1';
          state <= x"21";
        when x"21" => --write sram
          ZD <= buf;
          state <= x"00";
        when x"30" => --read bram
          load_data <= bram_o;
          state <= x"00";
        when x"40" => --read sram
          state <= x"41";
          ZD <= (others => 'Z');
        when x"41" => --read sram
          state <= x"42";
        when x"42" => --read sram
          load_data <= ZD;
          state <= x"00";
        when x"50" => --transmit
          tgo <= '0';
          if tgo <= '0' and tbusy = '0' then
            state <= x"00";
          end if;
        when x"60" => --receive
          rgo <= '0';
          if rgo = '0' and rbusy = '0' then
            state <= x"00";
            load_data <= x"000000" & receive_data;
          end if;
        when others =>
          state <= x"00";
          XWA <= '1';
          bwe <= '0';
      end case;
    end if;
  end process;
  
  busy <= '0' when state = x"00" else
          '1';


end arch_memory_io;
