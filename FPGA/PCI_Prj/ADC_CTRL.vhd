	library		ieee,std;
	use			ieee.std_logic_1164.all	;
	use			ieee.std_logic_unsigned.all;
	use			ieee.std_logic_arith.all;
	use			ieee.std_logic_misc.all;
	
--	use			std.textio.all;
--	use			ieee.std_logic_textio.all;
	
	use			work.MY_PKG.all;
	
	
--------------------------------------------------------
	entity	ADC_CTRL	is
		port	(
				CLK							:	in	std_logic							;
				RST_L						:	in	std_logic							;
				
				-- system interface
				iADCData					:	out	ADC_DATA							;
				iReadREQ					:	in	std_logic							;
				ipReadFinish				:	out	std_logic							;
				
				-- ADC interface
				MISO						:	in	std_logic							;
				MOSI						:	out	std_logic							;
				SCLK						:	out	std_logic							;
				CS_L						:	out	std_logic							
				
				
				);
	end	ADC_CTRL;

	architecture	arcADC_CTRL	of	ADC_CTRL	is
--====================================================--
--[Component]
--====================================================--
Component	TIMER	is
		port	(
				CLK							:	in	std_logic							;
				RST_L						:	in	std_logic							;
				
				iTIMER_Period				:	in	std_logic_vector(15 downto 0)		;
				iEnable						:	in	std_logic							;		--	timer start
				iClear						:	in	std_logic							;		--	Timeout flag clear
				ipTimeout					:	out	std_logic							
				
				);
end	Component;

Component	ADC_STM	is
		port	(
				CLK							:	in	std_logic							;
				RST_L						:	in	std_logic							;
				iSendingCH					:	out	std_logic_vector(7 downto 0)		;
				
				-- system interface
				iADCData					:	out	ADC_DATA							;
				iReadREQ					:	in	std_logic							;
				ipReadFinish				:	out	std_logic							;
				
				-- ADC_IF interface
				iDataWrite					:	out	std_logic_vector(7 downto 0)		;
				iCount						:	out	std_logic_vector(4 downto 0)		;
				ipDataAck					:	in	std_logic							;
				iDataRead					:	in	std_logic_vector(7 downto 0)		;
				ipReadValid					:	in	std_logic							;
				
				ipFinish					:	in	std_logic							;
				ipStart						:	in	std_logic							
				
				);
end Component;

Component	ADC_IF	is
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
	end	Component;
	
	
--====================================================--
--[Constant]
--====================================================--


--====================================================--
--[Signal]PLL'S
--====================================================--
	signal			wDataWrite					:	std_logic_vector(7 downto 0)		;
	signal			wCount						:	std_logic_vector(4 downto 0)		;
	signal			wpDataAck					:	std_logic							;
	signal			wDataRead					:	std_logic_vector(7 downto 0)		;
	signal			wpReadValid					:	std_logic							;
	
	signal			wpTrigClk					:	std_logic							;
	signal			wTrigWriteREQ				:	std_logic							;
	signal			wTrigWriteREQ_DL			:	std_logic_vector(7 downto 0)		;
	
	signal			wpTrigClk_Boolean			:	boolean								;
	signal			wpFinish					:	std_logic							;
	signal			wpStart						:	std_logic							;
	
	signal			wMISO						:	std_logic							;
	signal			wMOSI						:	std_logic							;
	signal			wSCLK						:	std_logic							;
	signal			wCS_L						:	std_logic							;
	signal			wLOADADCS_L					:	std_logic							;
	
	signal			wSendingCH					:	std_logic_vector(7 downto 0)		;
	
	begin

--====================================================--
--[Function] Reset
--====================================================--


--====================================================--
--[Port Map] 
--====================================================--

	ADC_TIMER:TIMER
	port map	(
				CLK							=>	CLK						,	--:	in	std_logic							;
				RST_L						=>	RST_L					,	--:	in	std_logic							;
				
				iTIMER_Period				=>	x"000A"					,	--:	in	std_logic_vector(15 downto 0)		;
				iEnable						=>	'1'						,	--:	in	std_logic							;		--	timer start
				iClear						=>	'0'						,	--:	in	std_logic							;		--	Timeout flag clear
				ipTimeout					=>	wpTrigClk					--:	out	std_logic							
				
				);
	
	ADC_STM_M:ADC_STM
	port map	(
				CLK							=>	CLK						,	--:	in	std_logic							;
				RST_L						=>	RST_L					,	--:	in	std_logic							;
				iSendingCH					=>	wSendingCH				,	--:	out	std_logic_vector(7 downto 0)		;

				-- system interface         =>			,	--
				iADCData					=>	iADCData				,
				iReadREQ					=>	iReadREQ				,	--:	in	std_logic							;		
				ipReadFinish				=>	ipReadFinish			,	--:	out	std_logic							;		

				-- ADC_IF interface     =>			,	--
				iDataWrite					=>	wDataWrite				,	--:	out	std_logic_vector(7 downto 0)		;
				iCount						=>	wCount					,	--:	out	std_logic_vector(4 downto 0)		;
				ipDataAck					=>	wpDataAck				,	--:	in	std_logic							;
				iDataRead					=>	wDataRead				,	--:	in	std_logic_vector(7 downto 0)		;
				ipReadValid					=>	wpReadValid				,	--:	in	std_logic							;

				ipFinish					=>	wpFinish				,	--:	in	std_logic							;
				ipStart						=>	wpStart						--:	in	std_logic							
			
			);
			
			
			
	ADC_IF_M:ADC_IF
	port map	(
				CLK							=>	CLK						,	--:	in	std_logic							;
				RST_L						=>	RST_L					,	--:	in	std_logic							;
				iSendingCH					=>	wSendingCH				,

				-- system interface         =>			,	--
				iDataWrite					=>	wDataWrite				,	--:	in	std_logic_vector(7 downto 0)		;
				ipDataAck					=>	wpDataAck				,	--:	out	std_logic							;
				iDataRead					=>	wDataRead				,	--:	out	std_logic_vector(7 downto 0)		;
				ipReadValid					=>	wpReadValid				,	--:	out	std_logic							;

				ipTrigClk					=>	wpTrigClk				,	--:	in	std_logic							;
				iCount						=>	wCount					,	--:	in	std_logic_vector(4 downto 0)		;
				ipFinish					=>	wpFinish				,	--:	out	std_logic							;
				ipStart						=>	wpStart					,	--:	out	std_logic							;

				-- ADC interface        =>			,	--
				MISO						=>	wMISO					,	--:	in	std_logic							;
				MOSI						=>	wMOSI					,	--:	out	std_logic							;
				SCLK						=>	wSCLK					,	--:	out	std_logic							;
				CS_L						=>	wCS_L					
			
			);
	
	
	wMISO			<=	MISO			;		--	when(ALL_OR(wTrigWriteREQ_DL) = '1')	else	'Z'	;
	MOSI			<=	wMOSI			;		--	when(ALL_OR(wTrigWriteREQ_DL) = '1')	else	'Z'	;
	SCLK			<=	wSCLK			;		--	when(ALL_OR(wTrigWriteREQ_DL) = '1')	else	'Z'	;
	CS_L			<=	wCS_L			;		--	when(ALL_OR(wTrigWriteREQ_DL) = '1')	else	'Z'	;
	
	
	
	end	arcADC_CTRL;




