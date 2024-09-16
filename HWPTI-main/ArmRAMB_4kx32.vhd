--------------------------------------------------------------------------------
--	Wrapper um Basys3-Blockram fuer den RAM des HWPR-Prozessors.
--------------------------------------------------------------------------------
--	Datum:		23.05.2022
--	Version:	1.1
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ArmRAMB_4kx32 is
    generic (
        SELECT_LINES : natural range 0 to 2 := 1
    );
    port (
        RAM_CLK : in std_logic;
        ENA     : in std_logic;
        ADDRA   : in std_logic_vector(11 downto 0);
        DOA     : out std_logic_vector(31 downto 0);
        ENB     : in std_logic;
        ADDRB   : in std_logic_vector(11 downto 0);
        WEB     : in std_logic_vector(3 downto 0);
        DIB     : in std_logic_vector(31 downto 0);
        DOB     : out std_logic_vector(31 downto 0)
    );
end entity ArmRAMB_4kx32;

architecture behavioral of ArmRAMB_4kx32 is
    type ram_type is array (4095 downto 0) of std_logic_vector(31 downto 0);
    signal RAM : ram_type; 
begin
    process (RAM_CLK)
    begin
        if rising_edge(RAM_CLK) then
            if ENA = '1' then
                DOA <= RAM(to_integer(unsigned(ADDRA)));
            end if;
			
		if (ENB = '1') AND (WEB = "0000") then
                	DOB <= RAM(to_integer(unsigned(ADDRB)));
		elsif (ENB = '1')then
		if WEB(0) = '1' then
                    RAM(to_integer(unsigned(ADDRB)))(7 downto 0) <= DIB(7 downto 0);
                end if;
		if WEB(1) = '1' then
                    RAM(to_integer(unsigned(ADDRB)))(15 downto 8) <= DIB(15 downto 8);
            	end if;
		if WEB(2) = '1' then
                    RAM(to_integer(unsigned(ADDRB)))(23 downto 16) <= DIB(23 downto 16);
		end if;
		if WEB(3) = '1' then
                    RAM(to_integer(unsigned(ADDRB)))(31 downto 24) <= DIB(31 downto 24);
		end if;
	end if;
        end if;
    end process;

end architecture behavioral;

