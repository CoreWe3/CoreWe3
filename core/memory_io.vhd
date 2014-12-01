library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity memory_io is
  generic(
    wtime : std_logic_vector(15 downto 0) := x"1ADB";
    debug : boolean := false);
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

  component IO_buffer is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime;
      debug : boolean := debug);
    port (
      clk : in std_logic;
      RS_RX : in std_logic;
      RS_TX : out std_logic;
      we : in std_logic;
      go : in std_logic;
      transmit_data : in std_logic_vector(7 downto 0);
      receive_data : out std_logic_vector(7 downto 0);
      busy : out std_logic);
  end component;

  component ram_controller is
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
  end component;

  signal state : std_logic := '0';
  signal iogo : std_logic := '0';
  signal ioload_data : std_logic_vector(7 downto 0);
  signal iobusy : std_logic;

  signal ramgo : std_logic := '0';
  signal ramload_data : std_logic_vector(31 downto 0);
  signal rambusy : std_logic;
    
begin

  IO : IO_buffer port map (
    clk => clk,
    RS_RX => RS_RX,
    RS_TX => RS_TX,
    we => we,
    go => iogo,
    transmit_data => store_data(7 downto 0),
    receive_data => ioload_data,
    busy => iobusy);

  ram : ram_controller port map (
    clk => clk,
    ZD => ZD,
    ZA => ZA,
    XWA => XWA,
    input => store_data,
    output => ramload_data,
    addr => addr,
    we => we,
    go => ramgo,
    busy => rambusy);

  iogo <= go when addr = x"FFFFF" else
          '0';
  ramgo <= go when addr /= x"FFFFF" else
           '0';
  load_data <= x"000000" & ioload_data when state = '0' else
               ramload_data;
  busy <= iobusy or rambusy;

  process(clk)
  begin
    if rising_edge(clk) then
      if we = '0' and go = '1' then
        if addr = x"FFFFF" then --io
          state <= '0';
        else --ram
          state <= '1';
        end if;
      end if;
    end if;
  end process;
  
  --main: process(clk)
  --begin
  --  if rising_edge(clk) then
  --    case state is 
  --      when x"0" =>
  --        if go = '1' then
  --          store_word_tmp <= store_word;
  --          if addr = x"fffff" then     --io
  --            XWA <= '1';
  --            iogo <= '1';
  --            if load_store = '1' then --store
  --              iowe <= '1';
  --              iotransmit_data <= store_word(7 downto 0);
  --              state <= x"1";
  --            else  --load
  --              iowe <= '0';
  --              state <= x"2";
  --            end if;
  --          else     --ram
  --            iogo <= '0';              
  --            if load_store = '1' then  --store
  --              XWA <= '0';
  --              ZA <= addr;
  --              state <= x"3";
  --            else --load
  --              ZD <= (others => 'Z');
  --              XWA <= '1';
  --              ZA <= addr;
  --              state <= x"4";
  --            end if;
  --          end if;
  --        else
  --          iogo <= '0';
  --        end if;

  --      when x"1" =>  --io storing
  --        iogo <= '0';
  --        if iobusy = '0' and iogo = '0' then
  --          state <= x"0";
  --        end if;
  --      when x"2" => --io loading
  --        iogo <= '0';
  --        if iobusy = '0' and iogo = '0' then
  --          load_word <= x"000000" & ioreceive_data;
  --          state <= x"0";
  --        end if;

  --      when  x"3" => --sram store
  --        XWA <= '1';
  --        state <= x"A";
  --      when  x"A" => --sram store
  --        ZD <= store_word_tmp;
  --        state <= x"0";

  --      when x"4" => --sram load
  --        state <= x"B";
  --      when x"B" => --sram load
  --        state <= x"C";
  --      when x"C" => --sram load
  --        state <= x"D";
  --      when x"D" =>
  --        state <= x"0";
  --        load_word <= ZD;
  --      when others =>
  --        state <= x"0";
  --    end case;
  --  end if;
  --end process;

end arch_memory_io;
