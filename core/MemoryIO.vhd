-- bram write 1 clk
--      read  1 clk
-- sram write 2 clk
--      read  3 clk
-- io   write 0 clk (best)
--      read  2 clk (best)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.Util.all;

entity MemoryIO is
  generic(
    wtime : std_logic_vector(15 downto 0) := x"1ADB");
  port (
    clk   : in    std_logic;
    RS_RX : in    std_logic;
    RS_TX : out   std_logic;
    ZD    : inout std_logic_vector(31 downto 0);
    ZA    : out   std_logic_vector(19 downto 0);
    XWA   : out   std_logic;
    data_mem_i : in    mem_in_t;
    data_mem_o : out   mem_out_t);
end MemoryIO;

architecture MemoryIO_arch of MemoryIO is

  component BlockRAM is
    port (
      clk : in std_logic;
      di : in std_logic_vector(31 downto 0);
      do : out std_logic_vector(31 downto 0);
      addr : in std_logic_vector(11 downto 0);
      we : in std_logic);
  end component;

  component FIFO is
    generic (
      WIDTH : integer := 5);
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

  signal state : std_logic_vector(7 downto 0) := x"00";

  signal bram_i : std_logic_vector(31 downto 0);
  signal bram_o : std_logic_vector(31 downto 0);
  signal bram_a : std_logic_vector(11 downto 0);
  signal bwe : std_logic := '0';
  signal buf : std_logic_vector(31 downto 0);

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

  bram_unit : BlockRAM port map (
    clk => clk,
    di => bram_i,
    do => bram_o,
    addr => bram_a,
    we => bwe);

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

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when x"00" =>
          if data_mem_i.go = '1' then
            if data_mem_i.we = '1' then -- write
              rdeq <= '0';
              if data_mem_i.a = x"FFFFF" then  -- transmit
                bwe <= '0';
                XWA <= '1';
                tdi <= std_logic_vector(data_mem_i.d(7 downto 0));
                if tfull = '0' then -- not full
                  tenq <= '1';
                  state <= x"00";
                else -- full
                  tenq <= '0';
                  state <= x"50";
                end if;
              elsif data_mem_i.a(19 downto 12) = x"EF" then -- bram
                bwe <= '1';
                XWA <= '1';
                tenq <= '0';
                state <= x"00";
                bram_i <= std_logic_vector(data_mem_i.d);
                bram_a <= std_logic_vector(data_mem_i.a(11 downto 0));
              else -- sram
                bwe <= '0';
                XWA <= '0';
                tenq <= '0';
                buf <= std_logic_vector(data_mem_i.d);
                state <= x"20";
              end if;
            else  -- read
              XWA <= '1';
              bwe <= '0';
              tenq <= '0';
              if data_mem_i.a = x"FFFFF" then -- receive
                if rempty = '0' then
                  rdeq <= '1';
                  state <= x"61";
                else
                  rdeq <= '0';
                  state <= x"60";
                end if;
              elsif data_mem_i.a(19 downto 12) = x"EF" then -- bram
                rdeq <= '0';
                bram_a <= std_logic_vector(data_mem_i.a(11 downto 0));
                state <= x"30";
              else -- sram
                rdeq <= '0';
                state <= x"40";
              end if;
            end if;
            ZA <= std_logic_vector(data_mem_i.a);
          else
            bwe <= '0';
            XWA <= '1';
            tenq <= '0';
          end if;
        when x"20" => --write sram
          XWA <= '1';
          state <= x"21";
        when x"21" => --write sram
          ZD <= buf;
          state <= x"00";
        when x"30" => --read bram
          state <= x"31";
        when x"31" => --read bram
          data_mem_o.d <= unsigned(bram_o);
          state <= x"00";
        when x"40" => --read sram
          state <= x"41";
          ZD <= (others => 'Z');
        when x"41" => --read sram
          state <= x"42";
        when x"42" => --read sram
          data_mem_o.d <= unsigned(ZD);
          state <= x"00";
        when x"50" => --transmit
          if tfull = '0' then
            state <= x"00";
            tenq <= '1';
          end if;
        when x"60" => --wait receive
          if rempty = '0' then
            rdeq <= '1';
            state <= x"61";
          end if;
        when x"61" => --receiving
          rdeq <= '0';
          state <= x"62";
        when x"62" => --received
          data_mem_o.d <= unsigned(x"000000" & rdo);
          state <= x"00";
        when others =>
          state <= x"00";
          XWA <= '1';
          bwe <= '0';
      end case;
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

  data_mem_o.busy <= '0' when state = x"00" else
          '1';

end MemoryIO_arch;
