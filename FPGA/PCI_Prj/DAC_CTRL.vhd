	library		ieee,std;
	use			ieee.std_logic_1164.all	;
	use			ieee.std_logic_unsigned.all;
	use			ieee.std_logic_arith.all;
	use			ieee.std_logic_misc.all;
	
--	use			std.textio.all;
--	use			ieee.std_logic_textio.all;
	
	use			work.MY_PKG.all;
	
				
--	type		ODAC_DATA	is
--		RECORD
--			CH1					:	std_logic_vector( 11 downto 0 )	;		-- CH1
--			CH2					:	std_logic_vector( 11 downto 0 )	;		-- CH2
--			CH3					:	std_logic_vector( 11 downto 0 )	;		-- CH3
--			CH4					:	std_logic_vector( 11 downto 0 )	;		-- CH4
--		end RECORD	;
	
--------------------------------------------------------
	entity	DAC_CTRL	is
		port	(
				CLK							:	in	std_logic							;
				RST_L						:	in	std_logic							;
				
				-- system interface
				iDACData					:	in	ODAC_DATA							;
				iWriteREQ					:	in	std_logic							;
				ipWriteFinish				:	out	std_logic							;
				
				-- DAC interface
--				GATE_L						:	out	std_logic							;
				MOSI						:	out	std_logic							;
				SCLK						:	out	std_logic							;
				CS_L1						:	out	std_logic							;
				CS_L2						:	out	std_logic							;
				LOADDACS_L					:	out	std_logic							
				
				);
	end	DAC_CTRL;

	architecture	arcDAC_CTRL	of	DAC_CTRL	is
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
	
Component	DAC_STM	is
		port	(
				CLK							:	in	std_logic							;
				RST_L						:	in	std_logic							;
				iSendingCH					:	out	std_logic_vector(7 downto 0)		;
				
				-- system interface
				iDACData					:	in	ODAC_DATA							;
				iWriteREQ					:	in	std_logic							;
				ipWriteFinish				:	out	std_logic							;
				
				-- DAC_IF interface
				iDataWrite					:	out	std_logic_vector(7 downto 0)		;
				iCount						:	out	std_logic_vector(4 downto 0)		;
				ipDataAck					:	in	std_logic							;
				iDataRead					:	in	std_logic_vector(7 downto 0)		;
				ipReadValid					:	in	std_logic							;
				
				ipFinish					:	in	std_logic							;
				ipStart						:	in	std_logic							
				
				);
end Component;

Component	DAC_IF	is
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
				
				-- DAC interface
				MISO						:	in	std_logic							;
				MOSI						:	out	std_logic							;
				SCLK						:	out	std_logic							;
				CS_L1						:	out	std_logic							;
				CS_L2						:	out	std_logic							;
				LOADDACS_L					:	out	std_logic							
				
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
	signal			wCS_L1						:	std_logic							;
	signal			wCS_L2						:	std_logic							;
	signal			wLOADDACS_L					:	std_logic							;
	
	signal			wSendingCH					:	std_logic_vector(7 downto 0)		;
	
	begin

--====================================================--
--[Function] Reset
--====================================================--


--====================================================--
--[Port Map] 
--====================================================--
	DAC_TIMER:TIMER
	port map	(
				CLK							=>	CLK						,	--:	in	std_logic							;
				RST_L						=>	RST_L					,	--:	in	std_logic							;
				
				iTIMER_Period				=>	x"000A"					,	--:	in	std_logic_vector(15 downto 0)		;
				iEnable						=>	'1'						,	--:	in	std_logic							;		--	timer start
				iClear						=>	'0'						,	--:	in	std_logic							;		--	Timeout flag clear
				ipTimeout					=>	wpTrigClk					--:	out	std_logic							
				
				);
	
	DAC_STM_M:DAC_STM
	port map	(
				CLK							=>	CLK						,	--:	in	std_logic							;
				RST_L						=>	RST_L					,	--:	in	std_logic							;
				iSendingCH					=>	wSendingCH				,	--:	out	std_logic_vector(7 downto 0)		;

				-- system interface         =>			,	--
				iDACData					=>	iDACData				,
				iWriteREQ					=>	iWriteREQ				,	--:	in	std_logic							;		
				ipWriteFinish				=>	ipWriteFinish			,	--:	out	std_logic							;		

				-- DAC_IF interface     =>			,	--
				iDataWrite					=>	wDataWrite				,	--:	out	std_logic_vector(7 downto 0)		;
				iCount						=>	wCount					,	--:	out	std_logic_vector(4 downto 0)		;
				ipDataAck					=>	wpDataAck				,	--:	in	std_logic							;
				iDataRead					=>	wDataRead				,	--:	in	std_logic_vector(7 downto 0)		;
				ipReadValid					=>	wpReadValid				,	--:	in	std_logic							;

				ipFinish					=>	wpFinish				,	--:	in	std_logic							;
				ipStart						=>	wpStart						--:	in	std_logic							
			
			);
			
			
			
	DAC_IF_M:DAC_IF
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

				-- DAC interface        =>			,	--
				MISO						=>	wMISO					,	--:	in	std_logic							;
				MOSI						=>	wMOSI					,	--:	out	std_logic							;
				SCLK						=>	wSCLK					,	--:	out	std_logic							;
				CS_L1						=>	wCS_L1					,	--:	out	std_logic							;
				CS_L2						=>	wCS_L2					,	--:	out	std_logic							;
				LOADDACS_L					=>	wLOADDACS_L					--:	out	std_logic							
			
			);
			
			
			
	process( CLK , RST_L )
	begin
		if ( RST_L = '0' ) then
			wTrigWriteREQ_DL	<=	(others => '0')		;
			--GATE_L				<=	'1'					;
		elsif ( CLK'event and CLK = '1' ) then
			if(wpTrigClk = '1')then
				wTrigWriteREQ_DL	<=	wTrigWriteREQ_DL(6 downto 0) & iWriteREQ	;
			end if;
			
			--GATE_L		<=	not (iWriteREQ or or_reduce(wTrigWriteREQ_DL))	;
			
		end if;
	end process;
	
	
	
	
	
	--wMISO			<=	MISO		when(ALL_OR(wTrigWriteREQ_DL) = '1')	else	'Z'	;
	MOSI			<=	wMOSI			;		--	when(ALL_OR(wTrigWriteREQ_DL) = '1')	else	'Z'	;
	SCLK			<=	wSCLK			;		--	when(ALL_OR(wTrigWriteREQ_DL) = '1')	else	'Z'	;
	CS_L1			<=	wCS_L1			;		--	when(ALL_OR(wTrigWriteREQ_DL) = '1')	else	'Z'	;
	CS_L2			<=	wCS_L2			;		--	when(ALL_OR(wTrigWriteREQ_DL) = '1')	else	'Z'	;
	LOADDACS_L		<=	wLOADDACS_L		;		--	when(ALL_OR(wTrigWriteREQ_DL) = '1')	else	'Z'	;
	
	
	
	end	arcDAC_CTRL;





























