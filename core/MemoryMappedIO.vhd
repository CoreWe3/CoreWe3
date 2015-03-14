library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.Util.all;

entity MemoryMappedIO is
  generic(
    wtime : std_logic_vector(15 downto 0) := x"1ADB");
  port (
    clk     : in  std_logic;
    RS_RX   : in  std_logic;
    RS_TX   : out std_logic;
    request : in  memory_request_t;
    reply   : out memory_reply_t);
end MemoryMappedIO;

architecture MemoryMappedIO_arch of MemoryMappedIO is

  component FIFO is
    generic (
      WIDTH : integer := FIFO_WIDTH);
    port (
      clk : in std_logic;
      di : in std_logic_vector(7 downto 0);
      do : out std_logic_vector(7 downto 0);
      enq : in std_logic;
      deq : in std_logic;
      empty : out std_logic;
      full : out std_logic);
  end component;

  component UartReceiver is
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime);
    port (
      clk  : in  std_logic;
      rx   : in  std_logic;
      complete : out std_logic;
      data : out std_logic_vector(7 downto 0));
  end component;

  component UartTransmitter is
    generic (
      wtime: std_logic_vector(15 downto 0) := wtime);
    Port (
      clk  : in  STD_LOGIC;
      data : in  STD_LOGIC_VECTOR (7 downto 0);
      go   : in  STD_LOGIC;
      busy : out STD_LOGIC;
      tx   : out STD_LOGIC);
  end component;

  type mmio_t is record
    state : unsigned(7 downto 0);
    buf  : memory_request_t;
    data : std_logic_vector(31 downto 0);
    rdeq : std_logic;
    tdi  : std_logic_vector(7 downto 0);
    tenq : std_logic;
  end record;

  signal r : mmio_t := (x"00", default_memory_request, (others => '-'),
                        '0', (others => '-'), '0');

  signal rcomplete : std_logic;
  signal rdo : std_logic_vector(7 downto 0);
  signal rdi : std_logic_vector(7 downto 0);
  signal renq : std_logic := '0';
  signal rempty : std_logic;

  signal tgo : std_logic := '0';
  signal tbusy : std_logic;
  signal tdo : std_logic_vector(7 downto 0);
  signal tdeq : std_logic := '0';
  signal tempty : std_logic;
  signal tfull : std_logic;

  signal trans_state : std_logic_vector(2 downto 0) := "000";

begin

  receiver : UartReceiver port map (
    clk => clk,
    rx => RS_RX,
    complete => rcomplete,
    data => rdi);

  receive_fifo : FIFO port map (
    clk => clk,
    di => rdi,
    do => rdo,
    enq => renq,
    deq => r.rdeq,
    empty => rempty,
    full => open);

  transmitter : UartTransmitter port map(
    clk => clk,
    data => tdo,
    go => tgo,
    busy => tbusy,
    tx => RS_TX);

  transmit_fifo : FIFO port map(
    clk => clk,
    di => r.tdi,
    do => tdo,
    enq => r.tenq,
    deq => tdeq,
    empty => tempty,
    full => tfull);

  main : process(clk)
    variable vreq : memory_request_t;
    variable v : mmio_t;
    variable vrep : memory_reply_t;
  begin
    if rising_edge(clk) then
      v := r;
      v.rdeq := '0';
      v.tenq := '0';
      v.tdi := (others => '-');
      vrep := ((others => '-'), '1', '0');
      if r.state = x"00" then
        vreq := request;
      else
        vreq := r.buf;
      end if;

      case r.state is
        when x"00" => -- ready
          v.state := x"00";
          v.data := (others => '-');
          if vreq.go = '1' and vreq.a = x"FFFFF" then
            if vreq.f = '0' then -- byte
              if vreq.we = '1' then -- transmit
                if tfull = '0' then
                  v.tdi := std_logic_vector(vreq.d(7 downto 0));
                  v.tenq := '1';
                  v.state := x"02";
                else
                  v.state := x"01";
                end if;
              else --receive
                if rempty = '0' then
                  v.rdeq := '1';
                  v.state := x"11";
                else
                  v.state := x"10";
                end if;
              end if;
            else -- word
              if vreq.we = '1' then --transmit
                if tfull = '0' then
                  v.tdi := std_logic_vector(vreq.d(7 downto 0));
                  v.tenq := '1';
                  v.state := x"21";
                else
                  v.state := x"20";
                end if;
              else  -- receive
                if rempty = '0' then
                  v.rdeq := '1';
                  v.state := x"31";
                else
                  v.state := x"30";
                end if;
              end if;
            end if;
          else
            vrep.busy := '0';
          end if;
        when x"01" => --wait trasmit byte
          if tfull = '0' then
            v.tdi := std_logic_vector(vreq.d(7 downto 0));
            v.tenq := '1';
            v.state := x"02";
          end if;
        when x"02" => --finish transmit byte
          v.state := x"00";
          vrep.busy := '0';
        when x"10" => --wait receive byte
          if rempty = '0' then
            v.rdeq := '1';
            v.state := x"11";
          end if;
        when x"11" => -- complete receive byte
          v.state := x"12";
        when x"12" => -- finish transmit byte
          v.state := x"00";
          vrep.busy := '0';
          vrep.d := unsigned(x"000000" & rdo);
          vrep.complete := '1';
        when X"20" => --wait transmit word1
          if tfull = '0' then
            v.tdi := std_logic_vector(vreq.d(7 downto 0));
            v.tenq := '1';
            v.state := x"21";
          end if;
        when x"21" => --finish transmit word1
          v.state := x"22";
        when x"22" => --wait transmit word2;
          if tfull = '0' then
            v.tdi := std_logic_vector(vreq.d(15 downto 8));
            v.tenq := '1';
            v.state := x"23";
          end if;
        when x"23" =>
          v.state := x"24";
        when x"24" => --wait transmit word3;
          if tfull = '0' then
            v.tdi := std_logic_vector(vreq.d(23 downto 16));
            v.tenq := '1';
            v.state := x"25";
          end if;
        when x"25" =>
          v.state := x"26";
        when x"26" => --wait transmit word4;
          if tfull = '0' then
            v.tdi := std_logic_vector(vreq.d(31 downto 24));
            v.tenq := '1';
            v.state := x"27";
          end if;
        when x"27" => -- finish transmit word
          v.state := x"00";
          vrep.busy := '0';
        when x"30" => --wait receive word1;
          if rempty = '0' then
            v.rdeq := '1';
            v.state := x"31";
          end if;
        when x"31" => --read receive fifo word1;
          v.state := x"32";
        when x"32" =>
          v.data(7 downto 0) := rdo;
          v.state := x"33";
        when x"33" => --wait receive word2;
          if rempty = '0' then
            v.rdeq := '1';
            v.state := x"34";
          end if;
        when x"34" =>
          v.state := x"35";
        when x"35" => --read receive fifo word2;
          v.data(15 downto 8) := rdo;
          v.state := x"36";
        when x"36" => --wait receive word3;
          if rempty = '0' then
            v.rdeq := '1';
            v.state := x"37";
          end if;
        when x"37" =>
          v.state := x"38";
        when x"38" => --read receive fifo word1;
          v.data(23 downto 16) := rdo;
          v.state := x"39";
        when x"39" => --wait receive word3;
          if rempty = '0' then
            v.rdeq := '1';
            v.state := x"3a";
          end if;
        when x"3a" => -- complete receive word
          v.state := x"3b";
        when x"3b" => -- finish receive word
          v.state := x"00";
          vrep.busy := '0';
          vrep.d := unsigned(rdo & r.data(23 downto 0));
          vrep.complete := '1';
        when others =>
      end case;

      if v.state /= x"00" then
        v.buf := vreq;
      end if;

      r <= v;
      reply <= vrep;

    end if;
  end process;

  trans_deque : process(clk)
  begin
    if rising_edge(clk) then
      case trans_state is
        when "000" => --ready
          tgo <= '0';
          if tempty = '0' then
            tdeq <= '1';
            trans_state <= "001";
          end if;
        when "001" => --read wait
          tdeq <= '0';
          trans_state <= "010";
        when "010" => --transmit
          tgo <= '1';
          trans_state <= "011";
        when "011" => --transmit wait
          tgo <= '0';
          if tgo = '0' and tbusy = '0' then
            trans_state <= "000";
          end if;
        when others =>
          tgo <= '0';
          tdeq <= '0';
          trans_state <= "000";
      end case;
    end if;
  end process;

  recv_enque : process(clk)
  begin
    if rising_edge(clk) then
      if rcomplete = '1' then
        renq <= '1';
      else
        renq <= '0';
      end if;
    end if;
  end process;

end MemoryMappedIO_arch;
