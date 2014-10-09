--メモリ、IOに関するエンティティー
--goが立つと読み書きを開始し、busyが立つ。
--load_store=1でstore、load_store=0でloadを行う。
--busyが下りた時には、読み書きは完了していて、
--loadの場合load_wordにデータが入っているものとする。
--インターフェースは以下、実装よろ

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
