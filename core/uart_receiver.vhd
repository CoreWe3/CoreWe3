library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity uart_receiver is
  generic (
    wtime : std_logic_vector(15 downto 0) := x"1ADB");
  port (
    clk  : in  std_logic;
    rx   : in  std_logic;
    complete : out std_logic;
    data : out std_logic_vector(7 downto 0));
end uart_receiver;

architecture arch_uart_receiver of uart_receiver is
  signal countdown : std_logic_vector(15 downto 0) := wtime;
  signal receivebuf : std_logic_vector(7 downto 0) := (others=>'1');
  signal state : std_logic_vector(3 downto 0) := x"9";
  signal start : std_logic_vector(3 downto 0) := x"F";
begin  -- structure
  process(clk)
  begin
    if rising_edge(clk) then
      case state  is
        when x"9" =>
          complete <= '0';
          start <= rx&start(3 downto 1);
          if start = x"0" then
            receivebuf<=(others => '1');
            state<=state-1;
            countdown<=wtime+("0"&wtime(15 downto 1)); --debugging
          end if;
        when x"0" =>
          if countdown=0 then
            if rx = '1' then
              data<=receivebuf;
            else
              data<=x"58";
            end if;
            complete<='1';
            state<=x"9";
            start<=x"F";
          else
            countdown<=countdown-1;
          end if;
        when others =>
          complete <= '0';
          if countdown=0 then
            receivebuf<=rx&receivebuf(7 downto 1);
            countdown<=wtime;
            state<=state-1;
          else
            countdown<=countdown-1;
          end if;
      end case;
    end if;
  end process;
end arch_uart_receiver;
