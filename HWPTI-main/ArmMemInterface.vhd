--------------------------------------------------------------------------------
--	Schnittstelle zur Anbindung des RAM an die Busse des HWPR-Prozessors
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmConfiguration.all;
use work.ArmTypes.all;

entity ArmMemInterface is
	generic(
--------------------------------------------------------------------------------
--	Beide Generics sind fuer das HWPR nicht relevant und koennen von
--	Ihnen ignoriert werden.
--------------------------------------------------------------------------------
		SELECT_LINES				: natural range 0 to 2 := 1;
		EXTERNAL_ADDRESS_DECODING_INSTRUCTION : boolean := false);
	port (  RAM_CLK	:  in  std_logic;
		--	Instruction-Interface
       		IDE		:  in std_logic;
			IA		:  in std_logic_vector(31 downto 2); --Adressleitung des Instruktionsbus
			ID		: out std_logic_vector(31 downto 0); 
			IABORT	: out std_logic;
		--	Data-Interface
			DDE		:  in std_logic;
			DnRW	:  in std_logic;
			DMAS	:  in std_logic_vector(1 downto 0);
			DA 		:  in std_logic_vector(31 downto 0);
			DDIN	:  in std_logic_vector(31 downto 0);
			DDOUT	: out std_logic_vector(31 downto 0);
			DABORT	: out std_logic);
end entity ArmMemInterface;

architecture behave of ArmMemInterface is
	signal RamOutPortA:std_logic_vector(31 downto 0);
	signal RamOutPortB:std_logic_vector(31 downto 0);
	signal DnRWMuxOut:std_logic_vector(31 downto 0);
	signal ControlRamB:std_logic_vector(3 downto 0);
	signal ControlWrite:std_logic_vector(3 downto 0);
	signal InonValid:std_logic;
	signal DnonValid:std_logic;
	signal enableD:std_logic;
	signal DnonValidRead:std_logic;
begin
	ram_module : entity work.ArmRAMB_4kx32 port map(
	        RAM_CLK => RAM_CLK,
	        ENA => IDE,    -- in std_logic;
	        ADDRA => IA(13 downto 2), -- in std_logic_vector(11 downto 0);
        	DOA => RamOutPortA,     -- out std_logic_vector(31 downto 0);
        	ENB => enableD,    -- in std_logic;
        	ADDRB => DA(13 downto 2), -- in std_logic_vector(11 downto 0);
        	WEB => ControlRamB,    -- in std_logic_vector(3 downto 0);
        	DIB => DDIN,    -- in std_logic_vector(31 downto 0);
        	DOB => RamOutPortB     -- out std_logic_vector(31 downto 0)
	);
	with IDE select
		ID <= RamOutPortA when '1',
		      (others => 'Z') when others;

	with DnRW select
		DnRWMuxOut <= RamOutPortB when '0',
			      (others => 'Z') when others;

	with DnRW select
		ControlRamB <= (others => '0') when '0',
			       ControlWrite when others;

	ControlWrite <= "0001" when DMAS=DMAS_BYTE AND DA(1 downto 0)="00" else
			"0010" when DMAS=DMAS_BYTE AND DA(1 downto 0)="01" else
			"0100" when DMAS=DMAS_BYTE AND DA(1 downto 0)="10" else
			"1000" when DMAS=DMAS_BYTE AND DA(1 downto 0)="11" else
			"0011" when DMAS=DMAS_HWORD AND DA(1 downto 0)="00"else
			"1100" when DMAS=DMAS_HWORD AND DA(1 downto 0)="10"else
		    "1111" when DMAS=DMAS_WORD else
		    "0000";


	with DDE select
		DDOUT <= DnRWMuxOut when '1',
			 (others => 'Z') when others;

	with IDE select
		IABORT <= 'Z' when '0',
			  InonValid when others;

	InonValid <= '1' when (unsigned(IA(31 downto 2))&"11" > unsigned(INST_HIGH_ADDR)) OR (unsigned(IA(31 downto 2))&"11" < unsigned(INST_LOW_ADDR)) else
		     '0';

	DABORT <= DnonValid when (DDE = '1') else
		  'Z';

	DnonValid <= '0' when ((DMAS=DMAS_BYTE) OR (DMAS=DMAS_HWORD AND (DA(1 downto 0)="10" OR DA(1 downto 0)="00")) OR (DMAS=DMAS_WORD AND DA(1 downto 0)="00")) and DnRW='1' else 
		          DnonValidRead when DnRW='0' else
		          '1';
		          
    enableD <= '0' when DnonValid='1' and DnRW='1' else
               DDE;
    DnonValidRead <= '0' when DA(1 downto 0)= "00" else
                     '1';

end architecture behave;
