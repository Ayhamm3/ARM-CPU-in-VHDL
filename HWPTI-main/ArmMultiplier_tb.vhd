library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.TB_TOOLS.all;

entity ArmMultiplier_tb is
end ArmMultiplier_tb;

architecture testbench of ArmMultiplier_tb is
	component ArmMultiplier
	port(	
            MUL_OP1  : in  STD_LOGIC_VECTOR (31 downto 0);
            MUL_OP2  : in  STD_LOGIC_VECTOR (31 downto 0);
            MUL_RES  : out STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;

    --Eingänge
    signal MUL_OP1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal MUL_OP2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    --Ausgänge
    signal MUL_RES : STD_LOGIC_VECTOR(31 downto 0);
    signal tb_finished : boolean := false;

    constant clk_period : time := 10 ns;

    function to_integer(slv : STD_LOGIC_VECTOR) return integer is
        variable unsigned_val : unsigned(slv'range);
    begin
        unsigned_val := unsigned(slv);
        return to_integer(unsigned_val);
    end function;

begin
    uut: ArmMultiplier port map (
        MUL_OP1 => MUL_OP1,
        MUL_OP2 => MUL_OP2,
        MUL_RES => MUL_RES
    );

    stim_proc: process
        variable all_tests_passed : boolean := true;
    begin        
        MUL_OP1 <= x"00000003"; -- 3
        MUL_OP2 <= x"00000004"; -- 4
        wait for clk_period;
        if MUL_RES /= x"0000000C" then -- 12
            report "Testfall 1 fehlgeschlagen: " & integer'image(to_integer(MUL_RES));
            all_tests_passed := false;
        end if;

        MUL_OP1 <= x"0000000A"; -- 10
        MUL_OP2 <= x"0000000B"; -- 11
        wait for clk_period;
        if MUL_RES /= x"0000006E" then -- 110
            report "Testfall 2 fehlgeschlagen: " & integer'image(to_integer(MUL_RES));
            all_tests_passed := false;
        end if;

        MUL_OP1 <= x"FFFFFFFF";
        MUL_OP2 <= x"00000002";
        wait for clk_period;
        if MUL_RES /= x"FFFFFFFE" then
            report "Testfall 3 fehlgeschlagen: " & integer'image(to_integer(MUL_RES));
            all_tests_passed := false;
        end if;

        MUL_OP1 <= x"00000010";
        MUL_OP2 <= x"00000010";
        wait for clk_period;
        if MUL_RES /= x"00000100" then
            report "Testfall 4 fehlgeschlagen: " & integer'image(to_integer(MUL_RES));
            all_tests_passed := false;
        end if;

        MUL_OP1 <= x"80000000";
        MUL_OP2 <= x"00000002";
        wait for clk_period;
        if MUL_RES /= x"00000000" then
            report "Testfall 5 fehlgeschlagen: " & integer'image(to_integer(MUL_RES));
            all_tests_passed := false;
        end if;

        MUL_OP1 <= x"0000FFFF";
        MUL_OP2 <= x"0000FFFF";
        wait for clk_period;
        if MUL_RES /= x"FFFE0001" then
            report "Testfall 6 fehlgeschlagen: " & integer'image(to_integer(MUL_RES));
            all_tests_passed := false;
        end if;

        if all_tests_passed then
            report "Alle Tests bestanden";
        else
            report "Einige Tests fehlgeschlagen";
        end if;

        tb_finished <= true;
        wait;
    end process;
end architecture behavior;
