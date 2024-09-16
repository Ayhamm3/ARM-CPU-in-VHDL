--------------------------------------------------------------------------------
--	Testbench-Vorlage des HWPR-Bitaddierers.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------
--	In TB_TOOLS kann, wenn gewuenscht die Funktion SLV_TO_STRING() zur
--	Ermittlung der Stringrepraesentation eines std_logic_vektor verwendet
--	werden und SEPARATOR_LINE fuer eine horizontale Trennlinie in Ausgaben.
--------------------------------------------------------------------------------
library work;
use work.TB_TOOLS.all;

entity ArmRegisterBitAdder_TB is
end ArmRegisterBitAdder_TB;

architecture testbench of ArmRegisterBitAdder_tb is 

	component ArmRegisterBitAdder
	port(
		RBA_REGLIST	: in std_logic_vector(15 downto 0);          
		RBA_NR_OF_REGS	: out std_logic_vector(4 downto 0)
		);
	end component ArmRegisterBitAdder;
	signal REGLIST : std_logic_vector(15 downto 0);
	signal NR_OF_REGS : std_logic_vector (4 downto 0);
	type testArray_t is array (15 downto 0) of std_logic_vector(15 downto 0);
	type resArray_t is array (15 downto 0) of std_logic_vector(4 downto 0);
	signal testArray : testArray_t := (
    		"0000000000000000", -- All zeros
    		"1111111111111111", -- All ones
    		"1010101010101010", -- Alternating bits (pattern 1)
    		"0101010101010101", -- Alternating bits (pattern 2)
   		    "0000111100001111", -- Nibble pattern (low and high nibbles)
    		"1111000011110000", -- Nibble pattern (high and low nibbles)
    		"0000000011111111", -- Lower half zeros, upper half ones
    		"1111111100000000", -- Lower half ones, upper half zeros
    		"1000000000000001", -- First and last bits set
    		"0111111111111110", -- All bits set except first and last
    		"0011111100000001", -- Some intermediate pattern
    		"1100000011111110", -- Some intermediate pattern
    		"0000000000000001", -- Single bit set (LSB)
    		"1000000000000000", -- Single bit set (MSB)
    		"0000000000000010", -- Single bit set (near LSB)
    		"0100000000000000"  -- Single bit set (near MSB)
	);
	signal resArray : resArray_t := (
    		"00000", -- 0 ones in "0000000000000000"
    		"10000", -- 16 ones in "1111111111111111"
    		"01000", -- 8 ones in "1010101010101010"
    		"01000", -- 8 ones in "0101010101010101"
    		"01000", -- 8 ones in "0000111100001111"
    		"01000", -- 8 ones in "1111000011110000"
    		"01000", -- 8 ones in "0000000011111111"
    		"01000", -- 8 ones in "1111111100000000"
    		"00010", -- 2 ones in "1000000000000001"
    		"01110", -- 14 ones in "0111111111111110"
    		"00111", -- 7 ones in "0011111100000001"
    		"01001", -- 9 ones in "1100000011111110"
    		"00001", -- 1 one in "0000000000000001"
    		"00001", -- 1 one in "1000000000000000"
    		"00001", -- 1 one in "0000000000000010"
		"00001"  -- 1 one in "0100000000000000"
	);
	signal errors:std_logic := '0';
	function to_string ( a: std_logic_vector) return string is
variable b : string (1 to a'length) := (others => NUL);
variable stri : integer := 1; 
begin
    for i in a'range loop
        b(stri) := std_logic'image(a((i)))(2);
    stri := stri+1;
    end loop;
return b;
end function;





begin
--	Unit Under Test
	UUT: ArmRegisterBitAdder port map(
		RBA_REGLIST	=> REGLIST,
		RBA_NR_OF_REGS	=> NR_OF_REGS
	);


--	Testprozess
	tb : process is
	begin
	    report "start of test" severity note;
		wait for 100 ns;
		for i in 15 downto 0 loop
			REGLIST <= testArray(i);
			wait for 11 ns;
			if(resArray(i)/=NR_OF_REGS)then
				report "Fehler Testcase " & integer'image(i) & " Input: " & to_string(testArray(i)) & " Expected: " & to_string(resArray(i)) & " Recieved: " & to_string(NR_OF_REGS);
				errors <= '1';
			end if;

		end loop;
		if errors = '0' then
			report "Test finished, all good" severity note;
		else
			report "Test finished with errors" severity note;
		end if;


		
--		...


		report SEPARATOR_LINE;	
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
--	Unbegrenztes Anhalten des Testbench Prozess
		wait;
	end process tb;
end architecture testbench;
