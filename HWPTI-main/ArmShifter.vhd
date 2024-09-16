--------------------------------------------------------------------------------
--	Shifter des HWPR-Prozessors, instanziiert einen Barrelshifter.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ArmTypes.all;
use work.ArmBarrelShifter;
entity ArmShifter is
	port (
		SHIFT_OPERAND	: in	std_logic_vector(31 downto 0);
		SHIFT_AMOUNT	: in	std_logic_vector(7 downto 0);
		SHIFT_TYPE_IN	: in	std_logic_vector(1 downto 0);
		SHIFT_C_IN	: in	std_logic;
		SHIFT_RRX	: in	std_logic;
		SHIFT_RESULT	: out	std_logic_vector(31 downto 0);
		SHIFT_C_OUT		: out	std_logic    		
 	);
end entity ArmShifter;

architecture behave of ArmShifter is

signal  ABS_C_OUT: std_logic;
signal ABS_DATA_OUT : std_logic_vector(31 downto 0);
signal  ABS_MUX_CTRL  : std_logic_vector(1 downto 0);
signal  ABS_ARITH_SHIFT: std_logic; 


begin
ARM_BARREL_SHIFTER : entity work.ArmBarrelShifter(structure)
	generic map (
		OPERAND_WIDTH => 32,
		SHIFTER_DEPTH => 5
	)
	port map (
		OPERAND => SHIFT_OPERAND,
		MUX_CTRL => ABS_MUX_CTRL,
		AMOUNT => SHIFT_AMOUNT(4 downto 0),
		ARITH_SHIFT => ABS_ARITH_SHIFT,
		C_IN => SHIFT_C_IN,
		DATA_OUT => ABS_DATA_OUT,
		C_OUT => ABS_C_OUT
	);

process (SHIFT_TYPE_IN) 
begin
    if SHIFT_TYPE_IN = SH_LSL then
        ABS_MUX_CTRL <= "01";
        ABS_ARITH_SHIFT <= '0';
    elsif SHIFT_TYPE_IN = SH_LSR then
        ABS_MUX_CTRL <= "10";
        ABS_ARITH_SHIFT <= '0';
    elsif SHIFT_TYPE_IN = SH_ASR then
        ABS_MUX_CTRL <= "10";
        ABS_ARITH_SHIFT <= '1';
    elsif SHIFT_TYPE_IN = SH_ROR then
        ABS_MUX_CTRL <= "11";
        ABS_ARITH_SHIFT <= '0';
    else
        ABS_MUX_CTRL <= "00";
        ABS_ARITH_SHIFT <= '0';
    end if;
end process;

process (SHIFT_AMOUNT, SHIFT_RRX, SHIFT_TYPE_IN, ABS_DATA_OUT, SHIFT_OPERAND, SHIFT_C_IN) 
begin
    if (unsigned(SHIFT_AMOUNT) < 32) and (SHIFT_RRX = '0') then
        SHIFT_RESULT <= ABS_DATA_OUT;
    elsif (unsigned(SHIFT_AMOUNT) >= 32) and (SHIFT_TYPE_IN = SH_LSL) and (SHIFT_RRX = '0') then
        SHIFT_RESULT <= (others => '0');
    elsif (unsigned(SHIFT_AMOUNT) >= 32) and (SHIFT_TYPE_IN = SH_LSR) and (SHIFT_RRX = '0') then
        SHIFT_RESULT <= (others => '0');
    elsif (unsigned(SHIFT_AMOUNT) >= 32) and (SHIFT_TYPE_IN = SH_ASR) and (SHIFT_RRX = '0') then
        SHIFT_RESULT <= (others => SHIFT_OPERAND(31));
    elsif (SHIFT_TYPE_IN = SH_ROR) and (SHIFT_RRX = '0') then
        SHIFT_RESULT <= ABS_DATA_OUT;
    elsif (SHIFT_RRX = '1') then
        SHIFT_RESULT <= SHIFT_C_IN & SHIFT_OPERAND(31 downto 1);
    else
        SHIFT_RESULT <= (others => '0');
    end if;
end process;

process (SHIFT_AMOUNT, SHIFT_RRX, SHIFT_TYPE_IN, ABS_C_OUT, SHIFT_OPERAND)
begin
    if (unsigned(SHIFT_AMOUNT) < 32) and (SHIFT_RRX = '0') then
        SHIFT_C_OUT <= ABS_C_OUT;
    elsif (unsigned(SHIFT_AMOUNT) > 32) and (SHIFT_TYPE_IN = SH_LSL) and (SHIFT_RRX = '0') then
        SHIFT_C_OUT <= '0';
    elsif (unsigned(SHIFT_AMOUNT) = 32) and (SHIFT_TYPE_IN = SH_LSL) and (SHIFT_RRX = '0') then
        SHIFT_C_OUT <= SHIFT_OPERAND(0);
    elsif (unsigned(SHIFT_AMOUNT) > 32) and (SHIFT_TYPE_IN = SH_LSR) and (SHIFT_RRX = '0') then
        SHIFT_C_OUT <= '0';
    elsif (unsigned(SHIFT_AMOUNT) = 32) and (SHIFT_TYPE_IN = SH_LSR) and (SHIFT_RRX = '0') then
        SHIFT_C_OUT <= SHIFT_OPERAND(31);
    elsif (unsigned(SHIFT_AMOUNT) >= 32) and (SHIFT_TYPE_IN = SH_ASR) and (SHIFT_RRX = '0') then
        SHIFT_C_OUT <= SHIFT_OPERAND(31);
    elsif (SHIFT_TYPE_IN = SH_ROR) and (SHIFT_RRX = '0') then
        SHIFT_C_OUT <= ABS_C_OUT;
    elsif (SHIFT_RRX = '1') then
        SHIFT_C_OUT <= SHIFT_OPERAND(0);
    else
        SHIFT_C_OUT <= '0';
    end if;
end process;
