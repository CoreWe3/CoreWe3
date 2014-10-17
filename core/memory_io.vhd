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
      send_data : in std_logic_vector(31 downto 0);
      receive_data : out std_logic_vector(31 downto 0);
      busy : out std_logic);
  end component;
  
  signal state : std_logic_vector(4 downto 0) := (others => '0');
  signal store_word_tmp : std_logic_vector(31 downto 0);
  signal iowe : std_logic;
  signal iogo : std_logic := '0';
  signal iosend_data : std_logic_vector(31 downto 0);
  signal ioreceive_data : std_logic_vector(31 downto 0);
  signal iobusy : std_logic;
    
begin
  IO : IO_buffer port map (
    clk => clk,
    RS_RX => RS_RX,
    RS_TX => RS_TX,
    we => iowe,
    go => iogo,
    send_data => iosend_data,
    receive_data => ioreceive_data,
    busy => iobusy);
  
    
  mio: process(clk)
  begin
    if rising_edge(clk) then
      case state is 
        when "00000" =>
          iogo <= '0';
          XWA <= '1';
          if go = '1' then
            store_word_tmp <= store_word;
            if addr = x"fffff" then     --io
              if load_store = '1' then --store
                state <= "01000";
              else  --load
                state <= "10000";
              end if;
            else                      --sram
              if load_store = '1' then  --store
                ZD <= store_word;
                XWA <= '0';
                ZA <= addr;
                state <= "11100";
              else --load
                ZD <= (others => 'Z');
                XWA <= '1';
                ZA <= addr;
                state <= "11101";
              end if;
            end if;
          end if;

        when "01000" =>  --io store
          if iobusy = '0' and iogo = '0' then
            iowe <= '1';
            iogo <= '1';
            iosend_data <= store_word_tmp;
            state <= "00000";
          else
            iogo <= '0';
          end if;

        when "10000" => --io load
          if iobusy = '0' and iogo = '0' then
            iowe <= '1';
            iogo <= '0';
            state <= "10001";
          else
            iogo <= '0';
          end if;
        when "10001" => --io load
          if iobusy = '0' and iogo = '0' then
            load_word <= ioreceive_data;
            state <= "00000";
          end if;

        when "11100" => --sram store
          XWA <= '1';
          state <= "00000";

        when "11101" => --sram load
          state <= "11110";
        when "11110" =>
          state <= "11111";
        when "11111" => --sram load
          load_word <= ZD;
          state <= "00000";

        when others =>
          state <= "00000";
      end case;
    end if;
  end process;
  busy <= '0' when state = "00000" else '1';
end blackbox;
