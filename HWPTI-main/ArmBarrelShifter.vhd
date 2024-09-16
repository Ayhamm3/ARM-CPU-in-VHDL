--------------------------------------------------------------------------------
-- 	Barrelshifter fuer LSL, LSR, ASR, ROR mit Shiftweiten von 0 bis 3 (oder 
--	generisch n-1) Bit. 
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
library work;
use work.MUX;
use ieee.numeric_std.all;
entity ArmBarrelShifter is
--------------------------------------------------------------------------------
--	Breite der Operanden (n) und die Zahl der notwendigen
--	Multiplexerstufen (m) um Shifts von 0 bis n-1 Stellen realisieren zu
--	koennen. Es muss gelten: ???
--------------------------------------------------------------------------------
	generic (OPERAND_WIDTH : integer := 32;	
		 SHIFTER_DEPTH : integer := 5
	 );
	port (  OPERAND 	: in std_logic_vector(OPERAND_WIDTH-1 downto 0);	
    		MUX_CTRL 	: in std_logic_vector(1 downto 0);
    		AMOUNT 	: in std_logic_vector(SHIFTER_DEPTH-1 downto 0);	
    		ARITH_SHIFT    : in std_logic; 
    		C_IN 		: in std_logic;
           	daten_OUT 	: out std_logic_vector(OPERAND_WIDTH-1 downto 0);	
    		C_OUT 		: out std_logic
	);
end entity ArmBarrelShifter;


architecture structure of ArmBarrelShifter is

signal rightshift: std_logic;
type daten_array is array(SHIFTER_DEPTH downto 0) of std_logic_vector(OPERAND_WIDTH-1 downto 0);
signal daten: daten_array;
type ctrl_array is array(SHIFTER_DEPTH-1 downto 0) of std_logic_vector(1 downto 0);
signal ctrl : ctrl_array;


begin
	daten(0) <= OPERAND;
	rightshift <= '1' when ARITH_SHIFT ='1' and daten(0)(OPERAND_WIDTH-1 ) = '1' else '0';
	SHIFT_LAYER:for i in 0 to SHIFTER_DEPTH-1 generate
			ctrl(i) <= MUX_CTRL when AMOUNT(i) = '1' else "00";
			MUX:for j in 0 to OPERAND_WIDTH - 1 generate
				LSBs:if j < 2**i  generate
					MUX1:entity work.Mux port map (
						A => daten(i)(j),
						B => '0',
						C => daten(i)(j+2**i),
						D => daten(i)(j+2**i),
						S => ctrl(i),
						MUX_OUT => daten(i+1)(j)
					);
				end generate LSBs;
				
				MITTE:if j >= 2**i and j <= OPERAND_WIDTH-1-(2**i) generate
					MUX2:entity work.Mux port map (
						A => daten(i)(j),
						B => daten(i)(j-2**i),
						C => daten(i)(j+2**i),
						D => daten(i)(j+2**i),
						S => ctrl(i),
						MUX_OUT => daten(i+1)(j)
					);
				end generate MITTE;

				MSBs: if j > OPERAND_WIDTH-1-(2**i) generate
					MUX3:entity work.Mux port map (
						A => daten(i)(j),
						B => daten(i)(j-2**i),
						C => rightshift,
						D => daten(i)((j+(2**i)) mod OPERAND_WIDTH),
						S => ctrl(i),
						MUX_OUT => daten(i+1)(j)
					);
				end generate MSBs;
			end generate MUX;
	end generate SHIFT_LAYER;
	daten_OUT <= daten(SHIFTER_DEPTH);
	
	process (AMOUNT, MUX_CTRL, OPERAND, C_IN)
	begin
		if to_integer(unsigned(AMOUNT)) = 0 then
			C_OUT <= C_IN;
		elsif MUX_CTRL = "00" then
			C_OUT <= C_IN;
		elsif MUX_CTRL = "10" then
			C_OUT <= OPERAND(to_integer(unsigned(AMOUNT))-1);
		elsif MUX_CTRL = "11" then
			C_OUT <= OPERAND(to_integer(unsigned(AMOUNT))-1);
		elsif MUX_CTRL = "01" then
			C_OUT <= OPERAND((OPERAND_WIDTH) - to_integer(unsigned(AMOUNT)));
		else
			C_OUT <= '0';
		end if;
	end process;

		
end architecture structure;

