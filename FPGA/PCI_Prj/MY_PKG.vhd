library		ieee;
use			ieee.std_logic_1164.all	;
use			ieee.std_logic_unsigned.all;
use			ieee.std_logic_arith.all;



	package	MY_PKG	is

	type		ODAC_DATA	is
		RECORD
			CH1					:	std_logic_vector( 11 downto 0 )	;		-- CH1
			CH2					:	std_logic_vector( 11 downto 0 )	;		-- CH2
			CH3					:	std_logic_vector( 11 downto 0 )	;		-- CH3
			CH4					:	std_logic_vector( 11 downto 0 )	;		-- CH4
		end RECORD	;
		
	type		ADC_DATA	is
		RECORD
			CH1					:	std_logic_vector( 11 downto 0 )	;		-- CH1
			CH2					:	std_logic_vector( 11 downto 0 )	;		-- CH2
			CH3					:	std_logic_vector( 11 downto 0 )	;		-- CH3
			CH4					:	std_logic_vector( 11 downto 0 )	;		-- CH4
			CH5					:	std_logic_vector( 11 downto 0 )	;		-- CH5
			CH6					:	std_logic_vector( 11 downto 0 )	;		-- CH6
			CH7					:	std_logic_vector( 11 downto 0 )	;		-- CH7
			CH8					:	std_logic_vector( 11 downto 0 )	;		-- CH8
		end RECORD	;
	
	end	MY_PKG;
	
	
	package body  MY_PKG  is
	
	
	
	
	end;
	


