--------------------------------------------------------------------------------
--	Multiplizierer fuer den Datenpfad des ARM-SoC
--	Einzige Operation OP1 x OP2 => RES; 32Bit x 32Bit => 32Bit(!) 
--------------------------------------------------------------------------------
--	Datum:		??.??.14
--	Version:	0.01
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ArmTypes.all;


entity ArmMultiplier is
	Port (
		MUL_OP1 	: in  STD_LOGIC_VECTOR (31 downto 0);	-- Rm
		MUL_OP2 	: in  STD_LOGIC_VECTOR (31 downto 0);	-- Rs
		MUL_RES 	: out  STD_LOGIC_VECTOR (31 downto 0)	-- Rd bzw. RdLo         	
	);
end entity ArmMultiplier;

architecture behavioral of ArmMultiplier is

begin
	MUL_RES <= STD_LOGIC_VECTOR(signed(MUL_OP1)*signed(MUL_OP2));

end architecture behavioral;