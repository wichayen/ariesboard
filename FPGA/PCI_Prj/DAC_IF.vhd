	library		ieee,std;
	use			ieee.std_logic_1164.all	;
	use			ieee.std_logic_unsigned.all;
	use			ieee.std_logic_arith.all;
	use			ieee.std_logic_misc.all;
	
--	use			std.textio.all;
--	use			ieee.std_logic_textio.all;
	
	use			work.MY_PKG.all;
	
--------------------------------------------------------
	entity	DAC_IF	is
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
				
				-- DAC7614 interface
				MISO						:	in	std_logic							;
				MOSI						:	out	std_logic							;
				SCLK						:	out	std_logic							;
				CS_L1						:	out	std_logic							;
				CS_L2						:	out	std_logic							;
				LOADDACS_L					:	out	std_logic							
				
				);
	end	DAC_IF;

	architecture	arcDAC_IF	of	DAC_IF	is
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
	signal			wLOADDACS_L					:	std_logic							:=	'1'	;
	signal			wLOADDACS_L_PosEdge			:	std_logic_vector(1 downto 0)		:=	(others => '1');
	
	begin

--====================================================--
--[Function] Reset
--====================================================--


--====================================================--
--[Port Map] 
--====================================================--
	
	DAC_SPI_IF:SPI_IF
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
			
			
	process( CLK , RST_L )
	begin
		if ( RST_L = '0' ) then
			wLOADDACS_L			<=	'1'				;
			wLOADDACS_L_PosEdge	<=	(others => '1')	;
		elsif ( CLK'event and CLK = '1' ) then
			if(ipTrigClk = '1')then
				wLOADDACS_L_PosEdge	<=	wLOADDACS_L_PosEdge(0) & wCS_L	;
				if(wLOADDACS_L_PosEdge = "01")then
					wLOADDACS_L		<=	'0'		;
				else
					wLOADDACS_L		<=	'1'		;
				end if;
			end if;
		end if;
	end process;
	
	
	LOADDACS_L	<=	wLOADDACS_L		;
	CS_L1		<=	wCS_L	when(iSendingCH = x"00" or iSendingCH = x"01")	else	'1'			;
	CS_L2		<=	wCS_L	when(iSendingCH = x"02" or iSendingCH = x"03")	else	'1'			;
	
	
	end	arcDAC_IF;














