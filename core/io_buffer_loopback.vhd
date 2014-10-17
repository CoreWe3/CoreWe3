library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity IO_buffer_loopback is
  generic(
    wtime : std_logic_vector(15 downto 0) := x"1ADB";
    debug : boolean := false);
  port (
    clk : in std_logic;
    RS_RX : in std_logic;
    RS_TX : out std_logic);
end IO_buffer_loopback;

architecture arch_loopback of IO_buffer_loopback is
  component IO_buffer is
    generic(
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

  signal we : std_logic;
  signal go : std_logic := '0';
  signal send_data : std_logic_vector(31 downto 0);
  signal receive_data : std_logic_vector(31 downto 0);
  signal busy : std_logic;
  signal state : std_logic_vector(1 downto 0) := "00";
  signal buf : std_logic_vector(31 downto 0);
begin

  iobuf : IO_buffer
    port map (
      clk => clk,
      RS_RX => RS_RX,
      RS_TX => RS_TX,
      we => we,
      go => go,
      send_data => send_data,
      receive_data => receive_data,
      busy => busy);

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when "00" => --read request
          if busy = '0' and go = '0' then
            we <= '0';
            go <= '1';
            state <= "01";
          else
            go <= '0';
          end if;
        when "01" => --read
          go <= '0';
          if busy = '0' and go = '0' then
            buf <= receive_data;
            state <= "10";
          end if;
        when "10" => --write
          if busy = '0' and go = '0' then
            we <= '1';
            go <= '1';
            send_data <= buf;
            state <= "00";
          else
            go <= '0';
          end if;
        when others =>
          state <= "00";
          go <= '0';
      end case;

      --if busy = '0' and go = '0' then
      --  go <= '1';
      --  we <= '1';
      --  send_data <= x"41424344";
      --else
      --  go <= '0';
      --end if;
    end if;
  end process;

end arch_loopback;
