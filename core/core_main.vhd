library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity core_main is
  generic (
    CODE  : string := "code.bin";
    ADDR_WIDTH : integer := 8;
    wtime : std_logic_vector(15 downto 0) := x"023D";
    debug : boolean := false);
  port (
    clk   : in    std_logic;
    RS_TX : out   std_logic;
    RS_RX : in    std_logic;
    ZD    : inout std_logic_vector(31 downto 0);
    ZA    : out   std_logic_vector(19 downto 0);
    XWA   : out   std_logic);
end core_main;

architecture arch_core_main of core_main is
  constant zero : std_logic_vector(31 downto 0) := (others => '0');

  component init_code_rom
    generic ( CODE  : string := CODE;
              WIDTH : integer := ADDR_WIDTH);
    port (
      clk   : in  std_logic;
      en    : in  std_logic;
      addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      instr : out std_logic_vector(31 downto 0));
  end component;

  component bootload_code_rom
    generic ( wtime : std_logic_vector(15 downto 0) := wtime;
              WIDTH : integer := ADDR_WIDTH);
    port (
      clk   : in std_logic;
      RS_RX : in std_logic;
      ready : out std_logic;
      addr  : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      instr : out std_logic_vector(31 downto 0));
  end component;

  component alu
    port ( in_word1 : in std_logic_vector(31 downto 0);
           in_word2 : in std_logic_vector(31 downto 0);
           out_word : out std_logic_vector(31 downto 0);
           ctrl : in std_logic_vector(2 downto 0));
  end component;

  component registers
    port (
      clk : in std_logic;
      we : in std_logic;
      addr1 : in std_logic_vector(5 downto 0);
      addr2 : in std_logic_vector(5 downto 0);
      in_word : in std_logic_vector(31 downto 0);
      out_word1 : out std_logic_vector(31 downto 0);
      out_word2 : out std_logic_vector(31 downto 0));
  end component;

  component memory_io
    generic (
      wtime : std_logic_vector(15 downto 0) := wtime;
      debug : boolean := debug);
    port (
      clk        : in    std_logic;
      RS_RX      : in    std_logic;
      RS_TX      : out   std_logic;
      ZD         : inout std_logic_vector(31 downto 0);
      ZA         : out   std_logic_vector(19 downto 0);
      XWA        : out   std_logic;
      store_data : in    std_logic_vector(31 downto 0);
      load_data  : out   std_logic_vector(31 downto 0);
      addr       : in   std_logic_vector(19 downto 0);
      we         : in   std_logic;
      go         : in    std_logic;
      busy       : out   std_logic);
  end component;


  signal pc : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal next_pc : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal sp : std_logic_vector(19 downto 0) := x"F7FFF";
  
  signal instr : std_logic_vector(31 downto 0);
  signal state : std_logic_vector(3 downto 0) := x"F";

  signal alu_iw1 : std_logic_vector(31 downto 0) := (others => '0');
  signal alu_iw2 : std_logic_vector(31 downto 0) := (others => '0');
  signal alu_ow : std_logic_vector(31 downto 0);
  signal ctrl : std_logic_vector(2 downto 0) := (others => '0');

  signal reg_addr1 : std_logic_vector(5 downto 0):= (others => '0');
  signal reg_addr2 : std_logic_vector(5 downto 0) := (others => '0');
  signal reg_we : std_logic := '0';
  signal reg_iw : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_ow1 : std_logic_vector(31 downto 0);
  signal reg_ow2 : std_logic_vector(31 downto 0);

  signal buf : std_logic_vector(31 downto 0);
  signal mem_store : std_logic_vector(31 downto 0) := (others => '0');
  signal mem_load : std_logic_vector(31 downto 0);
  signal mem_addr : std_logic_vector(19 downto 0) := (others => '0');
  signal mem_we : std_logic := '0';
  signal mem_go : std_logic := '0';
  signal mem_busy : std_logic;

  signal branch_f : std_logic;

  signal ready : std_logic;
  signal RS_RX_exec : std_logic;
  signal RS_RX_load : std_logic;

  
begin

  file_initialize : if (CODE /= "bootload") generate
    rom : init_code_rom port map (
      clk => clk,
      en => '1',
      addr => pc,
      instr => instr);
    ready <= '1';
  end generate;
  
  bootload : if (CODE = "bootload") generate
    rom : bootload_code_rom port map (
      clk => clk,
      RS_RX => RS_RX_load,
      ready => ready,
      addr => pc,
      instr => instr);
  end generate;

  alu0 : alu port map (
    in_word1 => alu_iw1,
    in_word2 => alu_iw2,
    out_word => alu_ow,
    ctrl => ctrl);

  reg : registers port map (
    clk => clk,
    we => reg_we,
    addr1 => reg_addr1,
    addr2 => reg_addr2,
    in_word => reg_iw,
    out_word1 => reg_ow1,
    out_word2 => reg_ow2);

  mem : memory_io port map (
    clk => clk,
    RS_RX => RS_RX_exec,
    RS_TX => RS_TX,
    ZD => ZD,
    ZA => ZA,
    XWA => XWA,
    store_data => mem_store,
    load_data => mem_load,
    addr => mem_addr,
    we => mem_we,
    go => mem_go,
    busy => mem_busy);

  RS_RX_exec <= RS_RX when state /= x"F" else
                '1';
  RS_RX_load <= RS_RX when state = x"F" else
                '1';

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when x"0" => --fetch
          state <= x"2";
          reg_we <= '0';

        when x"2" => --decode 
          case instr(31 downto 26) is
            when "000000" => --load
              reg_addr1 <= instr(19 downto 14);
            when "000001" => --store
              reg_addr1 <= instr(19 downto 14);
              reg_addr2 <= instr(25 downto 20);
            when "000010" => --load abs
            when "000011" => --store abs
              reg_addr1 <= instr(25 downto 20);
            when "000100" => --load immediate high
              reg_addr1 <= instr(25 downto 20);
            when "000110" | "000111" => --add sub
              reg_addr1 <= instr(19 downto 14);
              reg_addr2 <= instr(13 downto 8);
            when "001000" => --fneg
              reg_addr1 <= instr(19 downto 14);
            when "001001" => --addi
              reg_addr1 <= instr(19 downto 14);
            when "001010" | "001011" | "001100" | "001101" | "001110" =>
              --and or shl shr xor
              reg_addr1 <= instr(19 downto 14);
              reg_addr2 <= instr(13 downto 8);
            when "001111" | "010000" => --shri shli
              reg_addr1 <= instr(19 downto 14);
            when "010001" | "010010" | "010011" | "010100" =>
              -- branch
              reg_addr1 <= instr(25 downto 20);
              reg_addr2 <= instr(19 downto 14);
            when "010111" => --push
              reg_addr1 <= instr(25 downto 20);
            when others =>
          end case;
          state <= state+1;

        when x"3" => --exec
          case instr(31 downto 26) is
            when "000000" => --load
              ctrl <= "000";
              alu_iw1 <= reg_ow1;
              if instr(13) = '0' then
                alu_iw2 <= "00" & x"0000" & instr(13 downto 0);
              else
                alu_iw2 <= "11" & x"FFFF" & instr(13 downto 0);
              end if;
            when "000001" => --store
              ctrl <= "000";
              alu_iw1 <= reg_ow1;
              buf <= reg_ow2;
              if instr(13) = '0' then
                alu_iw2 <= "00" & x"0000" & instr(13 downto 0);
              else
                alu_iw2 <= "11" & x"FFFF" & instr(13 downto 0);
              end if;
            when "000110" => --add
              ctrl <= "000";
              alu_iw1 <= reg_ow1;
              alu_iw2 <= reg_ow2;
            when "000111" => --sub
              ctrl <= "001";
              alu_iw1 <= reg_ow1;
              alu_iw2 <= reg_ow2;
            when "001000" => --fneg
              buf <= reg_ow1;
            when "001001" => --addi
              ctrl <= "000";
              alu_iw1 <= reg_ow1;
              if instr(13) = '0' then
                alu_iw2 <= "00" & x"0000" & instr(13 downto 0);
              else
                alu_iw2 <= "11" & x"FFFF" & instr(13 downto 0);
              end if;
            when "001010" => --and
              ctrl <= "010";
              alu_iw1 <= reg_ow1;
              alu_iw2 <= reg_ow2;
            when "001011" => --or
              ctrl <= "011";
              alu_iw1 <= reg_ow1;
              alu_iw2 <= reg_ow2;
            when "001100" => --xor
              ctrl <= "100";
              alu_iw1 <= reg_ow1;
              alu_iw2 <= reg_ow2;
            when "001101" => --shl
              ctrl <= "101";
              alu_iw1 <= reg_ow1;
              alu_iw2 <= reg_ow2;
            when "001110" => --shr
              ctrl <= "110";
              alu_iw1 <= reg_ow1;
              alu_iw2 <= reg_ow2;
            when "001111" => --shl imm
              ctrl <= "101";
              alu_iw1 <= reg_ow1;
              alu_iw2 <= "00" & x"0000" & instr(13 downto 0);
            when "010000" => --shr imm
              ctrl <= "110";
              alu_iw1 <= reg_ow1;
              alu_iw2 <= "00" & x"0000" & instr(13 downto 0);
            when "010001" => --branch eq
              ctrl <= "000";
              alu_iw1 <= zero(31 downto ADDR_WIDTH) & pc;
              if instr(13) = '0' then
                alu_iw2 <= "00" & x"0000" & instr(13 downto 0);
              else
                alu_iw2 <= "11" & x"FFFF" & instr(13 downto 0);
              end if;
              if reg_ow1 = reg_ow2 then
                branch_f <= '1';
              else
                branch_f <= '0';
              end if;
            when "010010" => --ble
              ctrl <= "000";
              alu_iw1 <= zero(31 downto ADDR_WIDTH) & pc;
              if instr(13) = '0' then
                alu_iw2 <= "00" & x"0000" & instr(13 downto 0);
              else
                alu_iw2 <= "11" & x"FFFF" & instr(13 downto 0);
              end if;
              if reg_ow1 <= reg_ow2 then
                branch_f <= '1';
              else
                branch_f <= '0';
              end if;
            when "010011" => --blt
              ctrl <= "000";
              alu_iw1 <= zero(31 downto ADDR_WIDTH) & pc;
              if instr(13) = '0' then
                alu_iw2 <= "00" & x"0000" & instr(13 downto 0);
              else
                alu_iw2 <= "11" & x"FFFF" & instr(13 downto 0);
              end if;
              if reg_ow1 < reg_ow2 then
                branch_f <= '1';
              else
                branch_f <= '0';
              end if;
            when "010100" => --bfle
              ctrl <= "000";
              alu_iw1 <= zero(31 downto ADDR_WIDTH) & pc;
              if instr(13) = '0' then
                alu_iw2 <= "00" & x"0000" & instr(13 downto 0);
              else
                alu_iw2 <= "11" & x"FFFF" & instr(13 downto 0);
              end if;
              if reg_ow1(31) = '1' and reg_ow2(31) = '0' then
                branch_f <= '1';
              elsif reg_ow1(30 downto 0) <= reg_ow2(30 downto 0) then
                branch_f <= '1';
              else
                branch_f <= '0';
              end if;
            when "010101" => --jump subroutine
              ctrl <= "000";
              alu_iw1 <= zero(31 downto ADDR_WIDTH) & pc;
              if instr(25) = '0' then
                alu_iw2 <= "00" & x"0" & instr(25 downto 0);
              else
                alu_iw2 <= "11" & x"F" & instr(25 downto 0);
              end if;
              sp <= sp-1;
            when "010110" => --ret
              ctrl <= "000";
              alu_iw1 <= x"000" & sp;
              alu_iw2 <= x"00000001";
            when "010111" => --push
              ctrl <= "001";
              alu_iw1 <= x"000" & sp;
              alu_iw2 <= x"00000001";
              buf <= reg_ow1;
            when "011000" => --pop
              ctrl <= "000";
              alu_iw1 <= x"000" & sp;
              alu_iw2 <= x"00000001";
            when others =>
          end case;
          next_pc <= pc+1;
          state <= state+1;

        when x"4" => --memory request
          case instr(31 downto 26) is
            when "000000" => --load
              if mem_busy = '0' and mem_go = '0' then
                mem_we <= '0';
                mem_go <= '1';
                mem_addr <= alu_ow(19 downto 0);
                state <= state + 1;
              end if;
            when "000001" => --store
              if mem_busy = '0' and mem_go = '0' then
                mem_we <= '1';
                mem_go <= '1';
                mem_addr <= alu_ow(19 downto 0);
                mem_store <= buf;
                state <= state+1;
              end if;
            when "000010" => --load abs
              if mem_busy = '0' and mem_go = '0' then
                mem_we <= '0';
                mem_go <= '1';
                mem_addr <= instr(19 downto 0);
                state <= state+1;
              end if;
            when "000011" => --store abs
              if mem_busy = '0' and mem_go = '0' then
                mem_we <= '1';
                mem_go <= '1';
                mem_addr <= instr(19 downto 0);
                state <= state+1;
              end if;
            when "010101" => --jsub
              if mem_busy = '0' and mem_go = '0' then
                mem_we <= '1';
                mem_go <= '1';
                mem_addr <= sp;
                mem_store <= zero(31 downto ADDR_WIDTH) & next_pc;
                state <= state+1;
              end if;
            when "010110" => --return
              if mem_busy = '0' and mem_go = '0' then
                mem_we <= '0';
                mem_go <= '1';
                mem_addr <= sp;
                state <= state+1;
              end if;
            when "010111" => --push
              if mem_busy = '0' and mem_go = '0' then
                mem_we <= '1';
                mem_go <= '1';
                mem_addr <= alu_ow(19 downto 0);
                sp <= alu_ow(19 downto 0);
                mem_store <= buf;
                state <= state+1;
              end if;
            when "011000" => --pop
              if mem_busy = '0' and mem_go = '0' then
                mem_we <= '0';
                mem_go <= '1';
                mem_addr <= sp;
                state <= state+1;
              end if;
            when others =>
              state <= state+2;
          end case;

        when x"5" => -- memory complete
          mem_we <= '0';
          mem_go <= '0';
          case instr(31 downto 26) is
            when "000000" => --load
              if mem_busy = '0' and mem_go = '0' then
                buf <= mem_load;
                state <= state+1;
              end if;
            when "000001" => --store
              if mem_busy = '0' and mem_go = '0' then
                state <= state+1;
              end if;
            when "000010" => --load abs
              if mem_busy = '0' and mem_go = '0' then
                buf <= mem_load;
                state <= state+1;
              end if;
            when "000011" => --load abs
              if mem_busy = '0' and mem_go = '0' then
                state <= state+1;
              end if;
            when "010101" => --jsub
              if mem_busy = '0' and mem_go = '0' then
                state <= state+1;
              end if;
            when "010110" => --ret
              if mem_busy = '0' and mem_go = '0' then
                pc <= mem_load(ADDR_WIDTH-1 downto 0);
                state <= state+1;
              end if;
            when "010111" => --push
              if mem_busy = '0' and mem_go = '0' then
                state <= state+1;
              end if;
            when "011000" => --pop
              if mem_busy = '0' and mem_go = '0' then
                buf <= mem_load;
                state <= state+1;
              end if;
            when others =>
          end case;
                       
        when x"6" => --write
          case instr(31 downto 26) is
            when "000000" => --load
              reg_addr1 <= instr(25 downto 20);
              reg_iw <= buf;
              reg_we <= '1';
              pc <= next_pc;
            when "000001" => --store
              pc <= next_pc;
            when "000100" => --load immediate high
              reg_addr1 <= instr(25 downto 20);
              reg_iw <= instr(15 downto 0) & reg_ow1(15 downto 0);
              reg_we <= '1';
              pc <= next_pc;
            when "000101" => --load immediate low
              reg_addr1 <= instr(25 downto 20);
              reg_iw <= x"0000" & instr(15 downto 0);
              reg_we <= '1';
              pc <= next_pc;
            when "000110" | "000111" => --add sub
              reg_addr1 <= instr(25 downto 20);
              reg_iw <= alu_ow;
              reg_we <= '1';
              pc <= next_pc;
            when "001000" => --fneg
              reg_addr1 <= instr(25 downto 20);
              reg_iw <= (not buf(31)) & buf(30 downto 0);
              reg_we <= '1';
              pc <= next_pc;
            when "001001" => --addi
              reg_addr1 <= instr(25 downto 20);
              reg_iw <= alu_ow;
              reg_we <= '1';
              pc <= next_pc;
            when "001010" | "001011" | "001100" |
              "001101" | "001110" | "001111" | "010000" =>
              --and ~ shr imm
              reg_addr1 <= instr(25 downto 20);
              reg_iw <= alu_ow;
              reg_we <= '1';
              pc <= next_pc;
            when "010001" | "010010" | "010011" | "010100" =>
              --branch
              if branch_f = '1' then
                pc <= alu_ow(ADDR_WIDTH-1 downto 0);
              else
                pc <= next_pc;
              end if;
            when "010101" => --jsub
              pc <= alu_ow(ADDR_WIDTH-1 downto 0);
            when "010110" => --ret
              sp <= alu_ow(19 downto 0);
            when "010111" => --push
              pc <= next_pc;
            when "011000" => --pop
              reg_we <= '1';
              reg_addr1 <= instr(25 downto 20);
              reg_iw <= buf;
              sp <= alu_ow(19 downto 0);
              pc <= next_pc;
            when others =>
          end case;
          state <= x"0";

        when x"F" => --setupping 
          if ready = '1' then
            state <= x"0";
            pc <= (others => '0');
          end if;
        when others =>
          state <= x"0";
          pc <= (others => '0');
      end case;
    end if;
  end process;

end arch_core_main;
