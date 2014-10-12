library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity core_main is
  generic (
    CODE : string := "hogehoge");
  port (
    clk   : in    std_logic;
    RS_TX : out   std_logic;
    RS_RX : in    std_logic;
    ZD    : inout std_logic_vector(31 downto 0);
    ZA    : out   std_logic_vector(19 downto 0);
    XWA   : out   std_logic);

end core_main;

architecture arch_core_main of core_main is

  component code_rom
    generic ( CODE : string := CODE);
    port (
      clk : in std_logic;
      en : in std_logic;
      addr : in std_logic_vector(15 downto 0);
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
      addr1 : in std_logic_vector(3 downto 0);
      addr2 : in std_logic_vector(3 downto 0);
      in_word : in std_logic_vector(31 downto 0);
      out_word1 : out std_logic_vector(31 downto 0);
      out_word2 : out std_logic_vector(31 downto 0));
  end component;

  component memory_io
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
  end component;

  signal pc : std_logic_vector(15 downto 0) := x"0000";
  signal next_pc : std_logic_vector(15 downto 0);
  
  signal instr_addr : std_logic_vector(15 downto 0);
  signal sram_addr : std_logic_vector(19 downto 0);
  signal instr : std_logic_vector(31 downto 0);
  signal state : std_logic_vector(3 downto 0) :=
    (others => '0');

  signal alu_iw1 : std_logic_vector(31 downto 0);
  signal alu_iw2 : std_logic_vector(31 downto 0);
  signal alu_ow : std_logic_vector(31 downto 0);
  signal ctrl : std_logic_vector(2 downto 0);
  signal reg_addr1 : std_logic_vector(3 downto 0);
  signal reg_addr2 : std_logic_vector(3 downto 0);
  signal reg_we : std_logic;
  signal reg_iw : std_logic_vector(31 downto 0);
  signal reg_ow1 : std_logic_vector(31 downto 0);
  signal reg_ow2 : std_logic_vector(31 downto 0);
  signal buf : std_logic_vector(31 downto 0);
  signal mem_store : std_logic_vector(31 downto 0);
  signal mem_load : std_logic_vector(31 downto 0);
  signal mem_addr : std_logic_vector(19 downto 0);
  signal mem_we : std_logic;
  signal mem_go : std_logic;
  signal mem_busy : std_logic;
  signal branch_f : std_logic;
    
begin

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when x"0" => --fetch
          instr_addr <= pc;
          state <= state+1;

        when x"1" => --
          state <= state+1;

        when x"2" => --decode 
          
          case instr(31 downto 24) is
            when x"00" => --load
              reg_addr1 <= instr(19 downto 16);
            when x"01" => --store
              reg_addr1 <= instr(19 downto 16);
              reg_addr2 <= instr(23 downto 20);
            when x"02" => --add
              reg_addr1 <= instr(19 downto 16);
              reg_addr2 <= instr(15 downto 12);
            when x"03" => --subtract
              reg_addr1 <= instr(19 downto 16);
              reg_addr2 <= instr(15 downto 12);
            when x"04" => --addi
              reg_addr1 <= instr(19 downto 16);
            when x"09" => -- branch eq
              reg_addr1 <= instr(23 downto 20);
              reg_addr2 <= instr(19 downto 16);
            when others =>
          end case;
          state <= state+1;

        when x"3" => --exec
          case instr(31 downto 24) is
            when x"00" => --load
              ctrl <= "000";
              alu_iw1 <= reg_ow1;
              if instr(15) = '0' then
                alu_iw2 <= x"0000" & instr(15 downto 0);
              else
                alu_iw2 <= x"FFFF" & instr(15 downto 0);
                end if;
              next_pc <= pc+1;
            when x"01" => --store
              ctrl <= "000";
              alu_iw1 <= reg_ow1;
              if instr(15) = '0' then
                alu_iw2 <= x"0000" & instr(15 downto 0);
              else
                alu_iw2 <= x"FFFF" & instr(15 downto 0);
              end if;
              next_pc <= pc+1;
              buf <= reg_ow2;
            when x"02" | x"03" =>
              ctrl <= "000";
              alu_iw1 <= reg_ow1;
              alu_iw2 <= reg_ow2;
              next_pc <= pc+1;
            when x"04" =>
              ctrl <= "000";
              alu_iw1 <= reg_ow1;
              if instr(15) = '0' then
                alu_iw2 <= x"0000" & instr(15 downto 0);
              else
                alu_iw2 <= x"FFFF" & instr(15 downto 0);
              end if;
              next_pc <= pc+1;
            when x"09" =>
              ctrl <= "000";
              alu_iw1 <= x"0000" & pc;
              if instr(15) = '0' then
                alu_iw2 <= x"0000" & instr(15 downto 0);
              else
                alu_iw2 <= x"FFFF" & instr(15 downto 0);
              end if;
              if reg_ow1 = reg_ow2 then
                branch_f <= '1';
              else
                branch_f <= '0';
              end if;
            when others =>  
          end case;
          state <= state+1;

        when x"4" => --memory request
          case instr(31 downto 24) is
            when x"00" =>
              if mem_busy = '0' and mem_go = '0' then
                mem_we <= '0';
                mem_go <= '1';
                mem_addr <= alu_ow(19 downto 0);
                state <= state + 1;
              else
                mem_go <= '0';
              end if;
            when x"01" =>
              if mem_busy = '0' and mem_busy = '0' then
                mem_we <= '1';
                mem_go <= '1';
                mem_addr <= alu_ow(19 downto 0);
                mem_store <= buf;
                state <= state + 1;
              else
                mem_go <= '0';
              end if;
            when others =>
              state <= state+2;
          end case;

        when x"5" => -- memory complete
          case instr(31 downto 24) is
            when x"00" => --load
              if mem_busy = '0' and mem_go = '0' then
                buf <= mem_load;
                state <= state+1;
              else
                mem_go <= '0';
              end if;
            when x"01" =>
              if mem_busy = '0' and mem_go = '0' then
                state <= state+1;
              else
                mem_go <= '0';
              end if;
            when others =>
          end case;
                       
        when x"6" => --write
          case instr(31 downto 24) is
            when x"00" => --load
              reg_addr1 <= instr(23 downto 20);
              reg_iw <= buf;
              reg_we <= '1';
              pc <= next_pc;
            when x"01" =>
              pc <= next_pc;
            when x"02" | x"03" =>
              reg_addr1 <= instr(23 downto 20);
              reg_iw <= alu_ow;
              reg_we <= '1';
              pc <= next_pc;
            when x"04" =>
              reg_addr1 <= instr(23 downto 20);
              reg_iw <= alu_ow;
              reg_we <= '1';
              pc <= next_pc;
            when x"09" =>
              pc <= alu_ow(15 downto 0);
            when others =>
          end case;
          state <= state+1;
        when x"7" =>
          state <= x"0";
          reg_we <= '0';
        when others =>
          state <= x"0";
      end case;
    end if;
  end process;

  rom : code_rom port map (
    clk => clk,
    en => '1',
    addr => instr_addr,
    instr => instr);

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
    RS_RX => RS_RX,
    RS_TX => RS_TX,
    ZD => ZD,
    ZA => ZA,
    XWA => XWA,
    store_word => mem_store,
    load_word => mem_load,
    addr => mem_addr,
    load_store => mem_we,
    go => mem_go,
    busy => mem_busy);

end arch_core_main;
