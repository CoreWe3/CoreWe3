--メモリ、IOに関するエンティティー
--goが立つと読み書きを開始し、busyが立つ。
--load_store=1でstore、load_store=0でloadを行う。
--busyが下りた時には、読み書きは完了していて、
--loadの場合load_wordにデータが入っているものとする。

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
    --バーストとか使うならピン追加可
    store_word : in    std_logic_vector(31 downto 0);
    load_word  : out   std_logic_vector(31 downto 0);
    addr       : in   std_logic_vector(19 downto 0);
    load_store : in   std_logic;
    go         : in    std_logic;
    busy       : out   std_logic);

end memory_io;

architecture blackbox of memory_io is

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
      transmit_data : in std_logic_vector(31 downto 0);
      receive_data : out std_logic_vector(31 downto 0);
      busy : out std_logic);
  end component;
  
  signal state : std_logic_vector(3 downto 0) := (others => '0');
  signal store_word_tmp : std_logic_vector(31 downto 0);
  signal iowe : std_logic := '0';
  signal iogo : std_logic := '0';
  signal iotransmit_data : std_logic_vector(31 downto 0);
  signal ioreceive_data : std_logic_vector(31 downto 0);
  signal iobusy : std_logic;
    
begin
  IO : IO_buffer port map (
    clk => clk,
    RS_RX => RS_RX,
    RS_TX => RS_TX,
    we => iowe,
    go => iogo,
    transmit_data => iotransmit_data,
    receive_data => ioreceive_data,
    busy => iobusy);

  --SRAM : SRAM_controller 
    
  main: process(clk)
  begin
    if rising_edge(clk) then
      case state is 
        when x"0" =>
          if go = '1' then
            store_word_tmp <= store_word;
            if addr = x"fffff" then     --io
              XWA <= '1';
              if iobusy = '0' and iogo = '0' then
                --available
                iogo <= '1';
                if load_store = '1' then --store
                  iowe <= '1';
                  iotransmit_data <= store_word;
                  state <= x"1";
                else  --load
                  iowe <= '0';
                  state <= x"2";
                end if;
              else
                -- busy
                iogo <= '0';
                if load_store = '1' then
                  state <= x"3";
                else
                  state <= x"4";
                end if;
              end if;
            else                      --sram
              if load_store = '1' then  --store
                XWA <= '0';
                ZA <= addr;
                state <= x"3";
              else --load
                ZD <= (others => 'Z');
                XWA <= '1';
                ZA <= addr;
                state <= x"4";
              end if;
            end if;
          end if;

        when x"1" =>  --io store
          if iobusy = '0' and iogo = '0' then
            state <= x"0";
          else
            iogo <= '0';
          end if;
        when x"2" => --io load
          if iobusy = '0' and iogo = '0' then
            load_word <= ioreceive_data;
            state <= x"0";
          else
            iogo <= '0';
          end if;

        when x"3" => --sram store
          XWA <= '1';
          state <= x"A";
        when x"A" => --sram store
          XWA <= '1';
          ZD <= store_word_tmp;
          state <= x"0";

        when x"4" => --sram load
          state <= x"B";
        when x"B" => --sram load
          state <= x"C";
        when x"C" => --sram load
          load_word <= ZD;
          state <= x"0";
        when others =>
          state <= x"0";
      end case;
    end if;
  end process;

  busy <= '0' when state = x"0" else '1';
end blackbox;
