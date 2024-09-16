--------------------------------------------------------------------------------
--	ALU des ARM-Datenpfades
--------------------------------------------------------------------------------
--	Datum:		??.??.14
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.ArmTypes.all;

entity ArmALU is
    Port ( ALU_OP1 		: in	std_logic_vector(31 downto 0);
           ALU_OP2 		: in 	std_logic_vector(31 downto 0);           
    	   ALU_CTRL 	: in	std_logic_vector(3 downto 0);
    	   ALU_CC_IN 	: in	std_logic_vector(1 downto 0);
		   ALU_RES 		: out	std_logic_vector(31 downto 0);
		   ALU_CC_OUT	: out	std_logic_vector(3 downto 0)
   	);
end entity ArmALU;

architecture behave of ArmALU is
	signal temp_res: std_logic_vector(32 downto 0);  -- Extra Bit für Carry
    signal carry: std_logic;
    signal overflow: std_logic;
	signal negative: std_logic;
    signal zero: std_logic;
begin
	process(ALU_OP1, ALU_OP2, ALU_CTRL, ALU_CC_IN)
    begin
        case ALU_CTRL is
            when "0000" or "1000" =>  -- AND
                temp_res <= ('0' & ALU_OP1) and ('0' & ALU_OP2);
				
            when "0001" or "1001" =>  -- XOR
                temp_res <= ('0' & ALU_OP1) xor ('0' & ALU_OP2);
				
            when "0100" or "1011" =>  -- ADD
                temp_res <= ('0' & ALU_OP1) + ('0' & ALU_OP2);
				
            when "0010" or "1010" =>  -- SUB
                temp_res <= ('0' & ALU_OP1) - ('0' & ALU_OP2);
				
			when "0011" =>	--Reverse Subtract
				temp_res <= ('0' & ALU_OP2) - ('0' & ALU_OP1);
				
			when "1100" =>	--OR
				temp_res <= ('0' & ALU_OP1) or ('0' & ALU_OP2);
			
			when "1101" =>	--MOVE
				temp_res <= '0' & ALU_OP2;
				
			when "1110" =>	--Bit Clear
				temp_res <= ('0' & ALU_OP1) and not ('0' & ALU_OP2);
				
			when "1111" =>	--Move not
				temp_res <= not ALU_OP2;
				
			when "0101" =>  --Add with Carry
                temp_res <= ('0' & ALU_OP1) + ('0' & ALU_OP2) + ('0' & std_logic_vector(to_unsigned(to_integer(unsigned(ALU_CC_IN(1))), 1)));
				
			when "0110" =>  --Subtract with Carry
                temp_res <= ('0' & ALU_OP1) - ('0' & ALU_OP2) - ('0' & std_logic_vector(to_unsigned(to_integer(not unsigned(ALU_CC_IN(1))), 1)));
				
			when "0111" =>  --Reverse Subtract with Carry
                temp_res <= ('0' & ALU_OP2) - ('0' & ALU_OP1) - ('0' & std_logic_vector(to_unsigned(to_integer(not unsigned(ALU_CC_IN(1))), 1)));
				
            when others =>  -- Default to zero
                temp_res <= (others => '0');
        end case;
        
        -- ALU Result
        ALU_RES <= temp_res(31 downto 0);
		
		-- Negative Bit
        negative <= ALU_RES(31);

        -- Zero Bit
        if ALU_RES = "00000000000000000000000000000000" then
            zero <= '1';
        else
            zero <= '0';
        end if;
        
        -- Carry und Overflow Bits
        carry <= temp_res(32);
        overflow <= (ALU_OP1(31) xor ALU_OP2(31)) and (ALU_OP1(31) xor temp_res(31));
        
        -- ALU_CC_OUT setzen
        ALU_CC_OUT <= negative & zero & ALU_CC_IN & overflow & carry;
    end process;

end architecture behave;
