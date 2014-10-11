--メモリ、IOに関するエンティティー
--goが立つと読み書きを開始し、busyが立つ。
--load_store=1でstore、load_store=0でloadを行う。
--busyが下りた時には、読み書きは完了していて、
--loadの場合load_wordにデータが入っているものとする。
--インターフェースは以下、実装よろ

--addrが0x0ffffのときio
--load_store=1でstore_wordを出力　rs_txに
--load_store=0でrs_rxをload_wordに
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity memory_io is
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
  component memory_io_u232c
    generic (wtime: std_logic_vector(15 downto 0) := x"1ADB");
    Port ( clk  : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0);
           go   : in  STD_LOGIC;
           busy : out STD_LOGIC;
           tx   : out STD_LOGIC);
  end component;

  component memory_io_r232c
    generic (
      wtime : std_logic_vector(15 downto 0) := x"1ADB");
    port (
      clk  : in  std_logic;
      rx   : in  std_logic;
      owari: out std_logic;
      data : out std_logic_vector(7 downto 0));
  end component;

  signal state : std_logic_vector(4 downto 0) := (others => '0');
  signal rdata : std_logic_vector(7 downto 0);
  signal udata : std_logic_vector(7 downto 0);
  signal uart_go: std_logic := '0';
  signal uart_busy: std_logic := '0';
  signal owari : std_logic;
  signal cansend : std_logic := '0';
  signal temp : std_logic := '1';
  signal load_word_temp : std_logic_vector(31 downto 0) := x"11111111";
begin  -- blackbox
  nr232c : memory_io_r232c generic map (wtime => x"1adb")
    port map (clk,temp,owari,rdata);
  nu232c: memory_io_u232c generic map (wtime=>x"1b16")
    port map (
      clk=>clk,
      data=>udata,
      go=>uart_go,
      busy=>uart_busy,
      tx=>rs_tx);
  mio: process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when "00000"  => 
            if go = '1' then
              if addr = x"0ffff" then     --io
                if load_store = '1' then --store_wordをrs_txに
                  udata <= store_word(31 downto 24);
                  cansend <= '1';
                  state <= "01000";
                else  --rs_rx をload_wordに
                  state <= "10000";
                end if;
              else                      --sram
                if load_store = '1' then  --store
                  ZD <= store_word;
                  XWA <= '0';
                else
                  ZD <= (others => 'Z');
                  XWA <= '1';
                end if;
                ZA <= addr;
                state <= "11110";
              end if;
            end if;
        when "01000" =>
          if cansend = '1' and uart_go = '0' and uart_busy = '0'then
            uart_go <= '1';
            cansend <= '0';
          else
            if cansend = '0' and uart_go = '0' and uart_busy = '0' then
              cansend <= '1';
              udata <= store_word(23 downto 16);
              state <= "01001";
            end if;
            uart_go <= '0';
          end if;
        when "01001" =>
          if cansend = '1' and uart_go = '0' and uart_busy = '0'then
            uart_go <= '1';
            cansend <= '0';
          else
            if cansend = '0' and uart_go = '0' and uart_busy = '0' then
              cansend <= '1';
              udata <= store_word(15 downto 8);
              state <= "01010";
            end if;
            uart_go <= '0';
          end if;
        when "01010" =>
          if cansend = '1' and uart_go = '0' and uart_busy = '0'then
            uart_go <= '1';
            cansend <= '0';
          else
            if cansend = '0' and uart_go = '0' and uart_busy = '0' then
              cansend <= '1';
              udata <= store_word(7 downto 0);
              state <= "01011";
            end if;
            uart_go <= '0';
          end if;
        when "01011" =>
          if cansend = '1' and uart_go = '0' and uart_busy = '0'then
            uart_go <= '1';
            cansend <= '0';
          else
            if cansend = '0' and uart_go = '0' and uart_busy = '0' then
              state <= "11111";         --when others
            end if;
            uart_go <= '0';
          end if;

        when "10000" => 
          temp <= RS_RX;
          if owari = '1' then
            load_word_temp <= x"000000" & rdata;
            state <= "10001";
          end if;
        when "10001" =>
          temp <= RS_RX;
          if owari = '1' then
            load_word_temp <= load_word_temp(23 downto 0) & rdata;
            state <= "10010";
          end if;
        when "10010" =>
          temp <= RS_RX;
          if owari = '1' then
            load_word_temp <= load_word_temp(23 downto 0) & rdata;
            state <= "10011";
          end if;
        when "10011" =>
          temp <= RS_RX;
          if owari = '1' then
            load_word_temp <= load_word_temp(23 downto 0) & rdata;
            state <= "11100";
          end if;
        when "11100" =>
          load_word <= load_word_temp;
          state <= "00000";
        when "11110" =>
          load_word <= ZD;
          state <= "00000";
        when others =>
          state <= "00000";
      end case;
    end if;
  end process;
  busy <= '0' when state = "00000" else '1';
end blackbox;
