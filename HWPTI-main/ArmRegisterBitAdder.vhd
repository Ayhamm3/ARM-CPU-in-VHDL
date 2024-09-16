--------------------------------------------------------------------------------
--	Schaltung fuer das Zaehlen von Einsen in einem 16-Bit-Vektor, realisiert
-- 	als Baum von Addierern.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ArmRegisterBitAdder is
	Port (
		RBA_REGLIST 	: in  std_logic_vector(15 downto 0);
		RBA_NR_OF_REGS 	: out  std_logic_vector(4 downto 0)
	);
end entity ArmRegisterBitAdder;

architecture structure of ArmRegisterBitAdder is
	type vectorL1 is array (7 downto 0) of std_logic_vector(1 downto 0);
	type vectorL2 is array (3 downto 0) of std_logic_vector(2 downto 0);
	type vectorL3 is array (1 downto 0) of std_logic_vector(3 downto 0);
	signal resL1 : vectorL1 := (others => "00");
	signal resL2 : vectorL2 := (others => "000");
	signal resL3 : vectorL3 := (others => "0000");

begin
	genL1: for i1 in 7 downto 0 generate
		resL1(i1)(1) <= RBA_REGLIST(i1) and RBA_REGLIST(i1+8); 
		resL1(i1)(0) <= RBA_REGLIST(i1) xor RBA_REGLIST(i1+8);	
	end generate;
	genL2: for i2 in 3 downto 0 generate
		resL2(i2)(1 downto 0) <= std_logic_vector(unsigned(resL1(i2)) + unsigned(resL1(i2+4)));	
		resL2(i2)(2) <= resL1(i2)(1) and resL1(i2+4)(1);
	end generate;
	genL3: for i3 in 1 downto 0 generate
		resL3(i3)(2 downto 0) <=  std_logic_vector(unsigned(resL2(i3)) + unsigned(resL2(i3+2)));
		resL3(i3)(3) <= resL2(i3)(2) and resL2(i3+2)(2);
	end generate;
	RBA_NR_OF_REGS(3 downto 0) <= std_logic_vector(unsigned(resL3(0)) + unsigned(resL3(1)));
    RBA_NR_OF_REGS(4) <= resL3(0)(3) and resL3(1)(3);
end architecture structure;
