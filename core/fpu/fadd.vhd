library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fadd is
  port(
    clk : in std_logic;
    A : in std_logic_vector(31 downto 0);
    B : in std_logic_vector(31 downto 0);
    C : out std_logic_vector(31 downto 0));
end fadd;

architecture arch_fadd of fadd is

  signal uA, uB, uC : unsigned(31 downto 0);
  signal largeE : unsigned(7 downto 0);
  signal smallE : unsigned(7 downto 0);
  signal largeF : unsigned(25 downto 0);
  signal smallF : unsigned(25 downto 0);
  signal diff : unsigned(7 downto 0);

begin

  uA <= unsigned(A);
  uB <= unsigned(B);
  
  process(uA,uB)
  begin
    if uA(31) = uB(31) then
      uC(31) <= A(31);
      if uA(30 downto 0) > uB(30 downto 0) then
        largeE <= uA(30 downto 23);
        smallE <= uB(30 downto 23);
        largeF <= "01" & uA(22 downto 0);
        smallE <= "01" & uB(22 downto 0);
        diff <= uA(30 downto 23) - uB(30 downto 23);
      else
        largeE <= uB(30 downto 23);
        smallE <= uA(30 downto 23);
        largeF <= "01" & uB(22 downto 0);
        smallF <= "01" & uA(22 downto 0);
        diff <= uA(30 downto 23) - uB(30 downto 23);
      end if;
    else
      if uA(30 downto 0) >= uB(30 downto 0) then
        C(31) <= uA(31);
        largeE <= uA(30 downto 23);
        smallE <= uB(30 downto 23);
        largeF <= "01" & uA(22 downto 0);
        smallF <= "01" & uB(22 downto 0);
        diff <= uA(30 downto 23) - uB(30 downto 23);
      else
        C(31) <= uB(31);
        largeE <= uB(30 downto 23);
        smallE <= uA(30 downto 23);
        largeF <= "01" & uB(22 downto 0);
        smallF <= "01" & uA(22 downto 0);
        diff <= uB(30 downto 23) - uA(30 downto 23);
      end if;
    end if;

    process(A(31), B(31), largeE, smallE)
    begin
      if A(31) = B(31) then
        C(30 downto 23) <= largeE;
        
