--メモリ、IOに関するエンティティー
--goが立つと読み書きを開始し、busyが立つ。
--load_store=1でstore、load_store=0でloadを行う。
--busyが下りた時には、読み書きは完了していて、
--loadの場合load_wordにデータが入っているものとする。
--インターフェースは以下、実装よろ

--addrが0x0ffffのときio ->0xfffffに変更
--load_store=1でstore_wordを出力　rs_txに
--load_store=0でrs_rxをload_wordに

--receive用bufferは0xf8000から0xf9fffまで(仮)
--send用bufferは0xfa000から0xfafffまで(仮)
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

  component memory_io_unit
    port (
      clk          : in    std_logic;
      rs_rx        : in    std_logic;
      rs_tx        : out   std_logic;
      ZD           : inout std_logic_vector(31 downto 0);
      ZA           : out   std_logic_vector(19 downto 0);
      XWA          : out   std_logic;
      --cpu_raddr    : in    std_logic_vector(19 downto 0);
      raddr        : out   std_logic_vector(19 downto 0);
      cpu_uaddr    : in    std_logic_vector(19 downto 0);
      uaddr        : out   std_logic_vector(19 downto 0);
      rumemory_busy : out   std_logic;
      memory_busy  : in    std_logic);
      --umemory_size : in    std_logic_vector(19 downto 0);
      --rflag        : out   std_logic);
  end component;
  
  signal state : std_logic_vector(4 downto 0) := (others => '0');
  --signal rdata : std_logic_vector(7 downto 0);
  --signal udata : std_logic_vector(7 downto 0);
  --signal uart_go: std_logic := '0';
  --signal uart_busy: std_logic := '0';
  --signal owari : std_logic;
  --signal cansend : std_logic := '0';
  --signal temp : std_logic := '1';
  --signal load_word_temp : std_logic_vector(31 downto 0) := x"11111111";
  signal cpu_raddr : std_logic_vector(19 downto 0) := x"f8000";
  signal raddr : std_logic_vector(19 downto 0);
  signal cpu_uaddr : std_logic_vector(19 downto 0) := x"fa000";
  signal uaddr : std_logic_vector(19 downto 0);
  signal umemory_size : std_logic_vector(19 downto 0) := (others => '0');
  signal rumemory_busy : std_logic := '0';
  signal uflag : std_logic := '0';      -- cpu_uaddr と uaddr の位置が逆転しているかどうか
  signal rsize : std_logic_vector(19 downto 0) := x"1ffff";
  signal usize : std_logic_vector(19 downto 0) := x"1ffff";
  signal rhead : std_logic_vector(19 downto 0) := x"f8000";
  signal uhead : std_logic_vector(19 downto 0) := x"fa000";
  signal rflag : std_logic;
  signal memory_busy : std_logic := '0';
begin  -- blackbox
  io_unit : memory_io_unit
    port map(clk,rs_rx,rs_tx,ZD,ZA,XWA,raddr,cpu_uaddr,uaddr,rumemory_busy,memory_busy);
  mio: process(clk)
  begin
    if rising_edge(clk) then
      case state is 
        when "00000" =>
          memory_busy <= '0';
            if go = '1' then
              if addr = x"fffff" then     --io
                if load_store = '1' then --store_wordをrs_txに
                  state <= "01000";
                else  --rs_rx をload_wordに
                  state <= "10000";
                end if;
              else                      --sram
                state <= "00001";
              end if;
            end if;
        when "00001" =>
          if load_store = '1' and rumemory_busy = '0' then  --store
            ZD <= store_word;
            XWA <= '0';
            ZA <=addr;
            state <= "11111";           --others
          else
            if rumemory_busy = '0' then
            ZD <= (others => 'Z');
            XWA <= '1';
            ZA <= addr;
            state <= "11110";
            end if;
          end if;
        when "01000" => 
          if rumemory_busy = '0' then
            ZD <= store_word;
            XWA <= '0';
            ZA <= cpu_uaddr;
            if cpu_uaddr = uhead + usize then
              cpu_uaddr <= uhead;
              uflag <= '1';
            else
              cpu_uaddr <= cpu_uaddr + 1;
            end if;
          end if;
          state <= "00000";
        when "10000" =>
          if raddr = cpu_raddr then
            state <= "10000";           --loop
          end if;
          if rumemory_busy = '0' then
            ZD <= (others => 'Z');
            XWA <= '1';
            memory_busy <= '1';
            ZA <= cpu_raddr;
            if cpu_raddr = rhead + rsize then
              cpu_raddr <= rhead;
            else
              cpu_raddr <= cpu_raddr + 1;
            end if;
            state <= "11110";
          end if;
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
