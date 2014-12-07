library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity transmit_buffer is
  generic(
    wtime : std_logic_vector(15 downto 0) := x"1ADB");
  port (
    clk : in std_logic;
    RS_TX : out std_logic;
    go : in std_logic;
    di : in std_logic_vector(7 downto 0);
    busy : out std_logic);
end transmit_buffer;

architecture arch_transmit_buffer of transmit_buffer is
  component FIFO is
    generic (
      WIDTH : integer := 10);
    port (
      clk : in std_logic;
      di : in std_logic_vector(7 downto 0);
      do : out std_logic_vector(7 downto 0);
      enq : in std_logic;
      deq : in std_logic;
      empty : out std_logic;
      full : out std_logic);
  end component;

  component uart_transmitter is
    generic (wtime: std_logic_vector(15 downto 0) := wtime);
    Port ( clk  : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0);
           go   : in  STD_LOGIC;
           busy : out STD_LOGIC;
           tx   : out STD_LOGIC);
  end component;

  signal fdi : std_logic_vector(7 downto 0);
  signal fdo : std_logic_vector(7 downto 0);
  signal enq : std_logic := '0';
  signal deq : std_logic := '0';
  signal empty : std_logic;
  signal full : std_logic;
  signal io_go : std_logic := '0';
  signal inbuf : std_logic_vector(7 downto 0);
  signal outbuf : std_logic_vector(7 downto 0);
  signal byte : std_logic_vector(7 downto 0);
  signal io_busy : std_logic;
  signal enq_state : std_logic_vector(1 downto 0) := "00";
  signal deq_state : std_logic_vector(2 downto 0) := "000";
begin
  
  transmit_fifo : fifo port map (
    clk => clk,
    di => fdi,
    do => fdo,
    enq => enq,
    deq => deq,
    empty => empty,
    full => full);

  transmitter : uart_transmitter port map (
    clk => clk,
    data => byte,
    go => io_go,
    busy => io_busy,
    tx => RS_TX);

  enque : process(clk)
  begin
    if rising_edge(clk) then
      case enq_state is
        when "00" => --ready
          if go = '1' then
            if full = '0' then --not full
              fdi <= di;
              enq <= '1';
              enq_state <= "10";
            else --full
              inbuf <= di;
              enq <= '0';
              enq_state <= "01";
            end if;
          else
            enq <= '0';
          end if;
        when "01" => --wait for queue
          if full = '0' then
            fdi <= inbuf;
            enq <= '1';
            enq_state <= "10";
          else
            enq <= '0';
          end if;
        when "10" => --complete
          enq <= '0';
          enq_state <= "00";
        when others =>
          enq <= '0';
          enq_state <= "00";
      end case;
    end if;
  end process;

  busy <= '0' when enq_state = "00" else
          '1';

  deque : process(clk)
  begin
    if rising_edge(clk) then
      case deq_state is
        when "000" => --ready
          io_go <= '0';
          if empty = '0' then
            deq <= '1';
            deq_state <= "001";
          end if;
        when "001" => --read wait
          deq <= '0';
          deq_state <= "010";
        when "010" =>
          outbuf <= fdo;
          if io_go = '0' and io_busy = '0' then
            io_go <= '1';
            byte <= fdo;
            deq_state <= "000";
          else
            deq_state <= "011";
          end if;
        when "011" =>
          if io_go = '0' and io_busy = '0' then
            io_go <= '1';
            byte <= outbuf;
            deq_state <= "000";
          end if;
        when others =>
          io_go <= '0';
          deq <= '0';
          deq_state <= "000";
      end case;
    end if;
  end process;
end arch_transmit_buffer;
                   
