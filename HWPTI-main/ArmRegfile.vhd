------------------------------------------------------------------------------
--	Registerspeichers des ARM-SoC
------------------------------------------------------------------------------
--	Datum:		16.05.2022
--	Version:	0.2
------------------------------------------------------------------------------

library work;
use work.ArmTypes.all;
use work.ArmRegAddressTranslation.all;
use work.ArmConfiguration.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ArmRegfile is
	Port ( REF_CLK 		: in std_logic;
	       REF_RST 		: in  std_logic;

	       REF_W_PORT_A_ENABLE	: in std_logic;
	       REF_W_PORT_B_ENABLE	: in std_logic;
	       REF_W_PORT_PC_ENABLE	: in std_logic;

	       REF_W_PORT_A_ADDR 	: in std_logic_vector(4 downto 0);
	       REF_W_PORT_B_ADDR 	: in std_logic_vector(4 downto 0);

	       REF_R_PORT_A_ADDR 	: in std_logic_vector(4 downto 0);
	       REF_R_PORT_B_ADDR 	: in std_logic_vector(4 downto 0);
	       REF_R_PORT_C_ADDR 	: in std_logic_vector(4 downto 0);

	       REF_W_PORT_A_DATA 	: in std_logic_vector(31 downto 0);
	       REF_W_PORT_B_DATA 	: in std_logic_vector(31 downto 0);
	       REF_W_PORT_PC_DATA 	: in std_logic_vector(31 downto 0);

	       REF_R_PORT_A_DATA 	: out std_logic_vector(31 downto 0);
	       REF_R_PORT_B_DATA 	: out std_logic_vector(31 downto 0);
	       REF_R_PORT_C_DATA 	: out std_logic_vector(31 downto 0)
       );
end entity ArmRegfile;

architecture behavioral of ArmRegfile is
    subtype two_bit is std_logic_vector(1 downto 0);
    type two_bit_vector is array(natural range <>) of two_bit;
    subtype vector_of_two is two_bit_vector(31 downto 0);
    signal last_write:vector_of_two;
    
	--output signals 
	signal Data_A0:std_logic_vector(31 downto 0);
	signal Data_B0:std_logic_vector(31 downto 0);
	signal Data_C0:std_logic_vector(31 downto 0);
	signal Data_A1:std_logic_vector(31 downto 0);
	signal Data_B1:std_logic_vector(31 downto 0);
	signal Data_C1:std_logic_vector(31 downto 0);
	signal Data_A2:std_logic_vector(31 downto 0);
	signal Data_B2:std_logic_vector(31 downto 0);
	signal Data_C2:std_logic_vector(31 downto 0);
begin
--------------------------------------------------------------------------------
--	Auswahl und Einstellung der Registerspeicher-Implementierung
--	Version 2 des Registerspeichers nutzt Distributed RAM
--	Im HWPTI wird Version 2 implementiert, die ARM_SIM_LIB stellt
--	zu Debugging-Zwecken auch Version 1 zur Verfügung
--------------------------------------------------------------------------------
	REGFILE_VERSION : if USE_REGFILE_V2 generate
		-- Registerspeicher auf Basis von Distributed RAM
		GEN_SATZ_A: --'00'
   		for I in 15 downto 0 generate
			REGX : entity work.DistRAM32M port map
        			(WCLK => REF_CLK,
			        WED => REF_W_PORT_A_ENABLE,
				ADDRA => REF_R_PORT_A_ADDR,
				ADDRB => REF_R_PORT_B_ADDR,
				ADDRC => REF_R_PORT_C_ADDR,
				ADDRD => REF_W_PORT_A_ADDR,
				DID => REF_W_PORT_A_DATA( 2*I+1 downto 2*I),
				DOA => Data_A0(2*I+1 downto 2*I),
				DOB => Data_B0(2*I+1 downto 2*I),
				DOC => Data_C0(2*I+1 downto 2*I),
				DOD => open);
   		end generate GEN_SATZ_A;

		GEN_SATZ_B: --"01"
   		for I in 15 downto 0 generate
			REGX : entity work.DistRAM32M port map
        			(WCLK => REF_CLK,
			        WED => REF_W_PORT_B_ENABLE,
				ADDRA => REF_R_PORT_A_ADDR,
				ADDRB => REF_R_PORT_B_ADDR,
				ADDRC => REF_R_PORT_C_ADDR,
				ADDRD => REF_W_PORT_B_ADDR,
				DID => REF_W_PORT_B_DATA( 2*I+1 downto 2*I),
				DOA => Data_A1(2*I+1 downto 2*I),
				DOB => Data_B1(2*I+1 downto 2*I),
				DOC => Data_C1(2*I+1 downto 2*I),
				DOD => open);
   		end generate GEN_SATZ_B;

		GEN_SATZ_C: --"10"
   		for I in 15 downto 0 generate
			REGX : entity work.DistRAM32M port map
        			(WCLK => REF_CLK,
			        WED => REF_W_PORT_PC_ENABLE,
				ADDRA => REF_R_PORT_A_ADDR,
				ADDRB => REF_R_PORT_B_ADDR,
				ADDRC => REF_R_PORT_C_ADDR,
				ADDRD => get_internal_address("1111",USER,'0'),
				DID => REF_W_PORT_PC_DATA(2*I+1 downto 2*I),
			    DOA => Data_A2(2*I+1 downto 2*I),
				DOB => Data_B2(2*I+1 downto 2*I),
				DOC => Data_C2(2*I+1 downto 2*I),
				DOD => open);
   		end generate GEN_SATZ_C;

		--output mux
		with last_write(to_integer(unsigned (REF_R_PORT_A_ADDR))) select 
			REF_R_PORT_A_DATA <= Data_A0 when "00",
					     Data_A1 when "01",
					     Data_A2 when "10",
					     (others => '0') when others;

		with last_write(to_integer(unsigned (REF_R_PORT_B_ADDR))) select 
			REF_R_PORT_B_DATA <= Data_B0 when "00",
					     Data_B1 when "01",
					     Data_B2 when "10",
					     (others => '0') when others;

		with last_write(to_integer(unsigned (REF_R_PORT_C_ADDR))) select 
			REF_R_PORT_C_DATA <= Data_C0 when "00",
					     Data_C1 when "01",
					     Data_C2 when "10",
					     (others => '0') when others;

		--track last write:
		process(REF_CLK) is
			begin
				if rising_edge(REF_CLK)then
					if(REF_W_PORT_PC_ENABLE = '1')then
						last_write(to_integer(unsigned (get_internal_address("1111",USER,'0')))) <= "10";
					end if;
					if(REF_W_PORT_B_ENABLE = '1')then
						last_write(to_integer(unsigned (REF_W_PORT_B_ADDR))) <= "01";
					end if;
					if(REF_W_PORT_A_ENABLE = '1')then
						last_write(to_integer(unsigned (REF_W_PORT_A_ADDR))) <= "00";
					end if;
				end if;
		end process;

	end generate;
end architecture;
