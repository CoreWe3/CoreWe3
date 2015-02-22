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
      WIDTH : integer := 8);
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

  signal stall : std_logic := '0';
  signal buf : memory_request_t := default_memory_request;

  signal rcomplete : std_logic;
  signal rdo : std_logic_vector(7 downto 0);
  signal rdi : std_logic_vector(7 downto 0);
  signal renq : std_logic := '0';
  signal rdeq : std_logic := '0';
  signal rempty : std_logic;

  signal tgo : std_logic := '0';
  signal tbusy : std_logic;
  signal tdo : std_logic_vector(7 downto 0);
  signal tdi : std_logic_vector(7 downto 0);
  signal tenq : std_logic := '0';
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
    deq => rdeq,
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
    di => tdi,
    do => tdo,
    enq => tenq,
    deq => tdeq,
    empty => tempty,
    full => tfull);

  reply.d <= unsigned(x"000000" & rdo);
  reply.stall <= stall or rdeq;

  main : process(clk)
    variable vreq : memory_request_t;
    variable vstall : std_logic;
  begin
    if rising_edge(clk) then
      if stall = '0' then
        vreq := request;
      else
        vreq := buf;
      end if;
      vstall := '0';

      if vreq.go = '1' and vreq.a = x"FFFFF" then
        if vreq.we = '1' then -- transmit
          rdeq <= '0';
          if tfull = '0' then
            tdi <= std_logic_vector(vreq.d(7 downto 0));
            tenq <= '1';
          else
            tenq <= '0';
            vstall := '1';
          end if;
        else --receive
          tenq <= '0';
          if rempty = '0' then
            rdeq <= '1';
          else
            rdeq <= '0';
            vstall := '1';
          end if;
        end if;
      else
        rdeq <= '0';
        tenq <= '0';
      end if;

      if vstall = '1' then
        buf <= vreq;
      end if;
      stall <= vstall;

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
