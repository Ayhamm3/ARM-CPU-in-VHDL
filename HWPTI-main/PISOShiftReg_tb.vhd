library ieee;
use ieee.std_logic_1164.all;

entity PISOShiftReg_tb is
end PISOShiftReg_tb;

architecture testbench of PISOShiftReg_tb is
    constant test_width : integer := 5 ; --STUDENT: SET TO ARBITRARY VALUE THAT FITS YOUR TESTDATA

    signal tb_in       : std_logic_vector(test_width-1 downto 0);
    signal tb_out      : std_logic;
    signal tb_load     : std_logic;
    signal tb_last_bit : std_logic;

    signal clk : std_logic;
    signal ce  : std_logic;

    component PISOShiftReg
        generic ( WIDTH : integer);
        port(
            CLK      : in std_logic;
            CLK_EN   : in std_logic;
            LOAD     : in std_logic;
            D_IN     : in std_logic_vector(WIDTH-1 downto 0);
            D_OUT    : out std_logic;
            LAST_BIT : out std_logic
        );
   
    end component;

    begin

    --generate basic clock
    clk_gen : process
    begin
        clk <= '1';
        wait for 1 ns;
        clk <= '0';
        wait for 1 ns;
    end process clk_gen;

    --generate clock enable signal
    clk_en_gen : process
    begin
        ce <= '1';
        wait for 1 ns;
        ce <= '0';
        wait for 9 ns;
    end process clk_en_gen;

    uut : PISOShiftReg
    generic map (WIDTH => test_width)
    port map (
        CLK => clk,
        CLK_EN => ce,
        LOAD => tb_load,
        D_IN => tb_in,
        D_OUT => tb_out,
        LAST_BIT => tb_last_bit
    );

    --STUDENT: INSERT TESTBENCH CODE HERE (SIGNAL ASSIGNMENTS ETC.)
    
    test_process : process
    begin
        report "start the test";
	
	for i in 2 downto 0 loop
    
    --Eingangsdaten setzen
	case i is
		when 2 =>
    			tb_in <= "11010";
		when 1 =>
			tb_in <= "00000";
		when 0 =>
			tb_in <= "11111";
	end case;

    --Daten in das Schieberegister laden
    tb_load <= '1';
    wait for 20 ns;
    tb_load <= '0';
    
    --Ausgabe nach dem Verschieben überprüfen
    wait for 10 ns;
    assert tb_out = tb_in(0)
        report "Fehler: Erstes Bit wurde nicht korrekt übertragen!";
    assert tb_last_bit = '0'
        report "shiften Fehlerhaft und LAST_BIT ist 1";
    
    wait for 10 ns;
    assert tb_out = tb_in(1)
        report "Fehler: Zweites Bit wurde nicht korrekt übertragen!";
    assert tb_last_bit = '0'
        report "shiften Fehlerhaft und LAST_BIT ist 1";
    
    wait for 10 ns;
    assert tb_out = tb_in(2)
        report "Fehler: Drittes Bit wurde nicht korrekt übertragen!";
    assert tb_last_bit = '0'
        report "shiften Fehlerhaft und LAST_BIT ist 1";
    
    wait for 10 ns;
    assert tb_out = tb_in(3)
        report "Fehler: Viertes Bit wurde nicht korrekt übertragen!";
    assert tb_last_bit = '0'
        report "shiften Fehlerhaft und LAST_BIT ist 1";
    
    wait for 10 ns;
    assert tb_out = tb_in(4)
        report "Fehler: Fünftes Bit wurde nicht korrekt übertragen!";
    assert tb_last_bit = '1'
        report "Shiften ist abgeschlossen, LAST_BIT ist 0";
	
end loop;
    
    report "Testprozess abgeschlossen.";
    
    report "Ende" severity failure;
end process test_process;

end testbench;
