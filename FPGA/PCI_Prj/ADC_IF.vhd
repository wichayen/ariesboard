	library		ieee,std;
	use			ieee.std_logic_1164.all	;
	use			ieee.std_logic_unsigned.all;
	use			ieee.std_logic_arith.all;
	use			ieee.std_logic_misc.all;
	
--	use			std.textio.all;
--	use			ieee.std_logic_textio.all;
	
	use			work.MY_PKG.all;
	
--------------------------------------------------------
	entity	ADC_IF	is
		port	(
				CLK							:	in	std_logic							;
				RST_L						:	in	std_logic							;
				iSendingCH					:	in	std_logic_vector(7 downto 0)		;
				
				-- system interface
				iDataWrite					:	in	std_logic_vector(7 downto 0)		;
				iCount						:	in	std_logic_vector(4 downto 0)		;
				ipDataAck					:	out	std_logic							;
				iDataRead					:	out	std_logic_vector(7 downto 0)		;
				ipReadValid					:	out	std_logic							;
				
				ipTrigClk					:	in	std_logic							;
				ipFinish					:	out	std_logic							;
				ipStart						:	out	std_logic							;
				
				-- ADC interface
				MISO						:	in	std_logic							;
				MOSI						:	out	std_logic							;
				SCLK						:	out	std_logic							;
				CS_L						:	out	std_logic							
				
				);
	end	ADC_IF;

	architecture	arcADC_IF	of	ADC_IF	is
--====================================================--
--[Component]
--====================================================--
Component	SPI_IF	is
	port	(
				CLK							:	in	std_logic							;
				RST_L						:	in	std_logic							;
				
				-- system interface
				iDataWrite					:	in	std_logic_vector(7 downto 0)		;
				iCount						:	in	std_logic_vector(4 downto 0)		;
				ipDataAck					:	out	std_logic							;
				iDataRead					:	out	std_logic_vector(7 downto 0)		;
				ipReadValid					:	out	std_logic							;
				
				ipTrigClk					:	in	std_logic							;
				ipFinish					:	out	std_logic							;
				ipStart						:	out	std_logic							;
				
				-- SPI interface
				MISO						:	in	std_logic							;
				MOSI						:	out	std_logic							;
				SCLK						:	out	std_logic							;
				CS_L						:	out	std_logic							
				
			);
end Component;

--====================================================--
--[Constant]
--====================================================--


--====================================================--
--[Signal]PLL'S
--====================================================--
	
	signal			wCS_L						:	std_logic							:=	'1'	;
	
	
	begin

--====================================================--
--[Function] Reset
--====================================================--


--====================================================--
--[Port Map] 
--====================================================--
	
	ADC_SPI_IF:SPI_IF
	port map	(
			CLK						=>	CLK							,	--	:	in	std_logic							;
			RST_L					=>	RST_L						,	--	:	in	std_logic							;

			-- system interface     =>	-- system interface		,	--
			iDataWrite				=>	iDataWrite					,	--	:	in	std_logic_vector(7 downto 0)		;
			ipDataAck				=>	ipDataAck					,	--	:	out	std_logic							;
			iDataRead				=>	iDataRead					,	--	:	out	std_logic_vector(7 downto 0)		;
			ipReadValid				=>	ipReadValid					,	--	:	out	std_logic							;

			ipTrigClk				=>	ipTrigClk					,	--	:	in	std_logic							;
			iCount					=>	iCount						,	--	:	in	std_logic_vector(4 downto 0)		;
			ipFinish				=>	ipFinish					,	--	:	out	std_logic							;
			ipStart					=>	ipStart						,	--	:	out	std_logic							;

			-- SPI interface        =>	-- SPI interface		,	--
			MISO					=>	MISO						,	--	:	in	std_logic							;
			MOSI					=>	MOSI						,	--	:	out	std_logic							;
			SCLK					=>	SCLK						,	--	:	out	std_logic							;
			CS_L					=>	wCS_L							--	:	out	std_logic							

			);
			
			
	
	CS_L		<=	wCS_L			;
	
	
	end	arcADC_IF;
