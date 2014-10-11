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
  signal pc : std_logic_vector(15 downto 0) := x"0000";
  signal next_pc : std_logic_vector(15 downto 0);
  
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
            when x"01" => --store
            when x"02" => --add
              ctrl <= "000";
              reg_addr1 <= instr(19 downto 16);
              reg_addr2 <= instr(15 downto 12);
            when x"03" => --subtract
              ctrl <= "001";
              reg_addr1 <= instr(19 downto 16);
              reg_addr2 <= instr(15 downto 12);
            when x"04" => --addi
              ctrl <= "000";
              reg_addr1 <= instr(19 downto 16);
            when others =>
          end case;
          state <= state+1;

        when x"3" => --exec
          case instr(31 downto 24) is
            when x"02" | x"03" =>
              alu_iw1 <= reg_ow1;
              alu_iw2 <= reg_ow2;
              next_pc <= pc+1;
            when x"04" =>
              alu_iw1 <= reg_ow1;
              alu_iw2 <= x"0000" & instr(15 downto 0);
              next_pc <= pc+1;
            when others =>  
          end case;
          state <= state+1;

        when x"4" => --memory
          state <= state+1;
          
        when x"5" => --write
          case instr(31 downto 24) is
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
            when others =>
          end case;
          state <= state+1;
        when x"6" =>
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

end arch_core_main;
