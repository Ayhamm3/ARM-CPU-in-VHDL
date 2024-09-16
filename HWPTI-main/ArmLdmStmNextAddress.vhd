--------------------------------------------------------------------------------
--	16-Bit-Register zur Steuerung der Auswahl des naechsten Registers
--	bei der Ausfuehrung von STM/LDM-Instruktionen. Das Register wird
--	mit der Bitmaske der Instruktion geladen. Ein Prioritaetsencoder
--	(Modul ArmPriorityVectorFilter) bestimmt das Bit mit der hochsten 
--	Prioritaet. Zu diesem Bit wird eine 4-Bit-Registeradresse erzeugt und
--	das Bit im Register geloescht. Bis zum Laden eines neuen Datums wird
--	mit jedem Takt ein Bit geloescht bis das Register leer ist.	
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ArmLdmStmNextAddress is
	port(
		SYS_RST			: in std_logic;
		SYS_CLK			: in std_logic;	
		LNA_LOAD_REGLIST 	: in std_logic;
		LNA_HOLD_VALUE 		: in std_logic;
		LNA_REGLIST 		: in std_logic_vector(15 downto 0);
		LNA_ADDRESS 		: out std_logic_vector(3 downto 0);
		LNA_CURRENT_REGLIST_REG : out std_logic_vector(15 downto 0)
	    );
end entity ArmLdmStmNextAddress;

architecture behave of ArmLdmStmNextAddress is

	component ArmPriorityVectorFilter
		port(
			PVF_VECTOR_UNFILTERED	: in std_logic_vector(15 downto 0);
			PVF_VECTOR_FILTERED	: out std_logic_vector(15 downto 0)
		);
	end component ArmPriorityVectorFilter;
	signal reg : std_logic_vector(15 downto 0);
	signal filtered_reg: std_logic_vector(15 downto 0);

begin
	CURRENT_REGLIST_FILTER : ArmPriorityVectorFilter
		port map(
			PVF_VECTOR_UNFILTERED => reg,
			PVF_VECTOR_FILTERED => filtered_reg
		);
		process(SYS_CLK)
		begin
			if rising_edge(SYS_CLK) then
				if(SYS_RST = '1')then
					reg <= (others => '0');
				else
					if(LNA_LOAD_REGLIST = '1')then
						reg <= LNA_REGLIST;
					else
						if LNA_HOLD_VALUE = '0' then
							reg <= reg xor filtered_reg;
						end if;
					end if;
				end if;
			end if;  --endif clk
		end process;
		process(reg)
		begin
		   if(unsigned(reg)=0)then --if 1
			     LNA_ADDRESS <= "0000";
              else
				   for i in 0 to 15 loop
					   if reg(i) = '1' then --if 0
						  LNA_ADDRESS <= std_logic_vector(to_unsigned(i,LNA_ADDRESS'length));
						  exit;
					   end if; --endif 0
				  end loop;
			end if;	 --endif 1
		end process;
		LNA_CURRENT_REGLIST_REG <= reg;
end architecture behave;
