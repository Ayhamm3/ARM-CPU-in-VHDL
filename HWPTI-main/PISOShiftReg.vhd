--------------------------------------------------------------------------------
-- PISO-Schieberegister als mögliche Grundlage für die Implementierung der RS232-
-- Schnittstelle im Hardwarepraktikum
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity PISOShiftReg is
	generic(
		WIDTH	 : integer := 5
	);
	port(
		CLK	     : in std_logic;
		CLK_EN	 : in std_logic;
		LOAD	 : in std_logic;
		D_IN	 : in std_logic_vector(WIDTH-1 downto 0);
		D_OUT	 : out std_logic;
		LAST_BIT : out std_logic
	);
end entity PISOShiftReg;

architecture behavioral of PISOShiftReg is  

signal shift_reg : std_logic_vector(WIDTH-1 downto 0);
signal count : integer;

begin

process(CLK)
begin
    if rising_edge(CLK) then
        if CLK_EN = '1' then
            if LOAD = '1' then
                shift_reg <= D_IN;
                D_OUT <= shift_reg(0);
                count <= 0;
            else
                shift_reg <= '0' & shift_reg(WIDTH-1 downto 1);
                D_OUT <= shift_reg(0);
                count <= count + 1;
            end if;
            
            if count = WIDTH-1 then
                LAST_BIT <= '1';
            else
                LAST_BIT <= '0';
            end if;
        end if;
    end if;
end process;

end architecture behavioral;
