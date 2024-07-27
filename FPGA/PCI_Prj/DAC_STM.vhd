	library		ieee,std;
	use			ieee.std_logic_1164.all	;
	use			ieee.std_logic_unsigned.all;
	use			ieee.std_logic_arith.all;
	use			ieee.std_logic_misc.all;
	
--	use			std.textio.all;
--	use			ieee.std_logic_textio.all;
	
	use			work.MY_PKG.all;
	
	
--------------------------------------------------------
	entity	DAC_STM	is
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
	end	DAC_STM;

	architecture	arcDAC_STM	of	DAC_STM	is
--====================================================--
--[Component]
--====================================================--


--====================================================--
--[Constant]
--====================================================--


--====================================================--
--[Signal]PLL'S
--====================================================--
	
	signal			wDataCount					:	integer range 0 to 10				:=	0	;
	signal			iWriteREQ_PosEdge			:	std_logic_vector(1 downto 0)		:=	(others => '0');
	signal			wpWriteREQ					:	std_logic							:=	'0'	;
	signal			wSendingCH					:	std_logic_vector(7 downto 0)		:=	(others => '0');
	
	begin

--====================================================--
--[Function] Reset
--====================================================--


--====================================================--
--[Port Map] 
--====================================================--
	
	process( CLK , RST_L )
	begin
		if ( RST_L = '0' ) then
			iDataWrite			<=	(others => '0')		;
			iCount				<=	(others => '0')		;
			ipWriteFinish		<=	'0'					;
			wpWriteREQ			<=	'0'					;
			iWriteREQ_PosEdge	<=	(others => '0')		;
			wDataCount			<=	0					;
			wSendingCH			<=	(others => '0')		;
		elsif ( CLK'event and CLK = '1' ) then
			iWriteREQ_PosEdge		<=	iWriteREQ_PosEdge(0) & iWriteREQ	;
			if(iWriteREQ_PosEdge = "01")then
				wpWriteREQ	<=	'1'		;
			else
				wpWriteREQ	<=	'0'		;
			end if;
			
			if(wpWriteREQ = '1')then
				wDataCount		<=	wDataCount + 1	;
				iDataWrite		<=	"0111" & iDACData.CH1(11 downto 8)	;
				iCount			<=	conv_std_logic_vector(2,5)			;
			elsif(ipDataAck = '1')then
				wDataCount		<=	wDataCount + 1	;
				if(wDataCount = 1)then
					iDataWrite		<=	iDACData.CH1(7 downto 0)		;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 2)then
					iDataWrite		<=	"1111" & iDACData.CH2(11 downto 8)	;
					iCount			<=	conv_std_logic_vector(2,5)	;
				elsif(wDataCount = 3)then
					iDataWrite		<=	iDACData.CH2(7 downto 0)		;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 4)then
					iDataWrite		<=	"0111" & iDACData.CH3(11 downto 8)	;
					iCount			<=	conv_std_logic_vector(2,5)	;
				elsif(wDataCount = 5)then
					iDataWrite		<=	iDACData.CH3(7 downto 0)		;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 6)then
					iDataWrite		<=	"1111" & iDACData.CH4(11 downto 8)	;
					iCount			<=	conv_std_logic_vector(2,5)	;
				elsif(wDataCount = 7)then
					iDataWrite		<=	iDACData.CH4(7 downto 0)		;
					iCount			<=	conv_std_logic_vector(0,5)	;
				else
					iDataWrite		<=	(others => '0')				;
					iCount			<=	conv_std_logic_vector(0,5)	;
				end if;
			elsif(ipFinish = '1')then
				wSendingCH		<=	wSendingCH + '1'		;
				if(wDataCount = 9)then
					wDataCount		<=	0			;
					ipWriteFinish	<=	'1'			;
					wSendingCH		<=	(others => '0')	;
				end if;
			else
				ipWriteFinish	<=	'0'		;
			end if;
			
			
		end if;
	end process;
	
	
	iSendingCH	<=	wSendingCH	;
	
	
	end	arcDAC_STM;








