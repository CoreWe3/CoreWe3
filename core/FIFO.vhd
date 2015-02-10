--when clk rises, if igo is active, enqueue idata to fifo,
--and if ogo if active, dequeue to odata.
--if quque is empty, empty bit rises.
--if queue is full, full bit rises.
--when queue is empty and try to deq,
--the value of odata is undef but queue is consistent
--when queue is full and try to enque, enque fails
--but queue is consistent.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity FIFO is
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
end FIFO;

architecture arch_fifo of FIFO is
  constant SIZE : integer := 2 ** WIDTH;
  type ram_t is array(0 to SIZE-1) of std_logic_vector(7 downto 0);
  signal QUE : ram_t;
  signal enq_addr : std_logic_vector(WIDTH-1 downto 0)
    := (others => '0'); --enque addr
  signal deq_addr : std_logic_vector(WIDTH-1 downto 0)
    := (others => '0'); --deque addr
  
begin
  
  process(clk)
  begin
    if rising_edge(clk) then
      if enq = '1' and enq_addr+1 /= deq_addr then
        --when queue is not full
        enq_addr <= enq_addr+1;
        QUE(conv_integer(enq_addr)) <= di;
      end if;
      if deq = '1' and enq_addr /= deq_addr then
        -- when queue is not empty
        deq_addr <= deq_addr+1;
        do <= QUE(conv_integer(deq_addr));
      end if;
    end if;
  end process;
  
  empty <= '1' when enq_addr = deq_addr else
           '0';
  full <= '1' when enq_addr+1 = deq_addr else
          '0';
end arch_fifo;
    
    
