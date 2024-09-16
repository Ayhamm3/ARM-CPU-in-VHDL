------------------------------------------------------------------------------
--	Paket fuer die Funktionen zur die Abbildung von ARM-Registeradressen
-- 	auf Adressen des physischen Registerspeichers (5-Bit-Adressen)
------------------------------------------------------------------------------
--	Datum:		05.11.2013
--	Version:	0.1
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ArmTypes.all;
use IEEE.numeric_std.all;

package ArmRegaddressTranslation is
  
	function get_internal_address(
		EXT_ADDRESS: std_logic_vector(3 downto 0); 
		THIS_MODE: std_logic_vector(4 downto 0); 
		USER_BIT : std_logic) 
	return std_logic_vector;

end package ArmRegaddressTranslation;

package body ArmRegAddressTranslation is

function get_internal_address(
	EXT_ADDRESS: std_logic_vector(3 downto 0);
	THIS_MODE: std_logic_vector(4 downto 0); 
	USER_BIT : std_logic) 
	return std_logic_vector 
is

--------------------------------------------------------------------------------		
--	Raum fuer lokale Variablen innerhalb der Funktion
--------------------------------------------------------------------------------
variable output:std_logic_vector(4 downto 0);
variable oldBit:std_logic;
	begin
--------------------------------------------------------------------------------		
--	Functionscode
--------------------------------------------------------------------------------		 
		output:="00000";
		oldBit :='0';
		if EXT_ADDRESS="XXXX" OR EXT_ADDRESS="UUUU" then
		  return "01111";
		end if;
		if USER_BIT = '1' then
		  oldBit := '1';
		  output:= '0' & EXT_ADDRESS;
		elsif((EXT_ADDRESS < "1000") OR (EXT_ADDRESS = "1111")) then
			output := '0' & EXT_ADDRESS;
		elsif THIS_MODE = FIQ then		          
				output := '1' & std_logic_vector(unsigned(EXT_ADDRESS) + 8);
		elsif (EXT_ADDRESS < "1101") then
				output := '0' & EXT_ADDRESS;
		else
			case THIS_MODE is
				when USER | SYSTEM =>
					output := '0' & EXT_ADDRESS;
				when IRQ =>
					output := '1' & std_logic_vector(unsigned(EXT_ADDRESS) +10);
				when SUPERVISOR =>
					output := '1' & std_logic_vector(unsigned(EXT_ADDRESS) +12);
				when ABORT =>
					output:= '1' & std_logic_vector(unsigned(EXT_ADDRESS) +14);
				when UNDEFINED =>
					output :=  '1' & std_logic_vector(unsigned(EXT_ADDRESS) +16);
				when others =>
					output:= "01111";
			end case;	
		end if;	
		if (oldBit = '1' OR oldBit = USER_BIT) then
		  return output;
		else
		  return '0' & EXT_ADDRESS;
		end if;
end function get_internal_address;	
	 
end package body ArmRegAddressTranslation;
