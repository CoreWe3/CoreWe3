--メモリ、IOに関するエンティティー
--goが立つと読み書きを開始し、busyが立つ。
--load_store=1でstore、load_store=0でloadを行う。
--busyが下りた時には、読み書きは完了していて、
--loadの場合load_wordにデータが入っているものとする。
--インターフェースは以下、実装よろ

--addrが0x0ffffのときio ->0xfffffに変更
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

  component memory_io_unit
    port (
      clk          : in    std_logic;
      rs_rx        : in    std_logic;
      rs_tx        : out   std_logic;
      --ZD           : inout std_logic_vector(31 downto 0);
      --ZA           : out   std_logic_vector(19 downto 0);
      --XWA          : out   std_logic;
      cpu_raddr    : in    std_logic_vector(15 downto 0);
      raddr        : out   std_logic_vector(15 downto 0);
      cpu_uaddr    : in    std_logic_vector(15 downto 0);
      --uaddr        : out   std_logic_vector(19 downto 0);
      flag         : in    std_logic_vector(1 downto 0);
      data_from_r  : out   std_logic_vector(31 downto 0);  --flag "01"
      data_to_u    : in   std_logic_vector(31 downto 0));  --flag "11"
      --rumemory_busy : out   std_logic;
      --memory_busy  : in    std_logic);
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
  signal cpu_raddr : std_logic_vector(15 downto 0) := x"0000";
  signal rsize : std_logic_vector(19 downto 0);
  signal raddr : std_logic_vector(15 downto 0);
  signal cpu_uaddr : std_logic_vector(15 downto 0) := x"0000";
  signal usize : std_logic_vector(19 downto 0);
  --signal uaddr : std_logic_vector(19 downto 0);
  signal umemory_size : std_logic_vector(19 downto 0) := (others => '0');
  signal rumemory_busy : std_logic := '0';
  signal flag : std_logic_vector(1 downto 0) := "00";
  signal data_from_r : std_logic_vector(31 downto 0);
  signal data_to_u : std_logic_vector(31 downto 0);
  signal load_store_tmp : std_logic;
  signal store_word_tmp : std_logic_vector(31 downto 0);
begin  -- blackbox
  io_unit : memory_io_unit port map(
    clk => clk,
    rs_rx => rs_rx,
    rs_tx => rs_tx,
    cpu_raddr => cpu_raddr,
    raddr => raddr,
    cpu_uaddr => cpu_uaddr,
    flag => flag,
    data_to_r => data_from_r,
    data_from_r => data_to_u);

  mio: process(clk)
  begin
    if rising_edge(clk) then
      case state is 
        when "00000" =>
          XWA <= '1';
          flag <= "00";
          if go = '1' then
            load_store_tmp <= load_store;
            store_word_tmp <= store_word;
            if addr = x"fffff" then     --io
              if load_store = '1' then -- store
                state <= "01000";
              else  --load
                state <= "10000";
              end if;
            else                      --sram
              state <= "00001";
            end if;
          end if;

        when "00001" => --sram
          if load_store_tmp = '1' then  --store
            ZD <= store_word_tmp;
            XWA <= '0';
            ZA <=addr;
            state <= "11100";
          else --load
            ZD <= (others => 'Z');
            XWA <= '1';
            ZA <= addr;
            state <= "11101";
          end if;

        when "01000" =>  --io store 
          data_to_u <= store_word_tmp;
          flag <= "11";  
          state <= "01001";
        when "01001" => --io store
          flag <= "00";
          cpu_uaddr <= cpu_uaddr + 1;
          state <= "00000";

        when "10000" => --io load
          if raddr = cpu_raddr then
            state <= "10000";
          else
            flag <= "01";
            state <= "10001";
          end if;
        when "10001" => --io load
          flag <= "00";
          load_word <= data_from_r;
          cpu_raddr <= cpu_raddr + 1;
          state <= "00000";

        when "11100" => --sram store
          XWA <= '1';
          state <= "11111";
        when "11101" => --sram load
          state <= "11110";
        when "11110" => --sram load
          load_word <= ZD;
          state <= "00000";

        when others =>
          state <= "00000";
      end case;
    end if;
  end process;
  busy <= '0' when state = "00000" else '1';
end blackbox;
