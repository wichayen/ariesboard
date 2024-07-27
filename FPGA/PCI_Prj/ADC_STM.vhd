	library		ieee,std;
	use			ieee.std_logic_1164.all	;
	use			ieee.std_logic_unsigned.all;
	use			ieee.std_logic_arith.all;
	use			ieee.std_logic_misc.all;
	
--	use			std.textio.all;
--	use			ieee.std_logic_textio.all;
	
	use			work.MY_PKG.all;
	
	
--------------------------------------------------------
	entity	ADC_STM	is
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
	end	ADC_STM;

	architecture	arcADC_STM	of	ADC_STM	is
--====================================================--
--[Component]
--====================================================--


--====================================================--
--[Constant]
--====================================================--


--====================================================--
--[Signal]PLL'S
--====================================================--
	constant		kADC_CH1					:	std_logic_vector(7 downto 0)		:=	"11000000";
	constant		kADC_CH2					:	std_logic_vector(7 downto 0)		:=	"11001000";
	constant		kADC_CH3					:	std_logic_vector(7 downto 0)		:=	"11010000";
	constant		kADC_CH4					:	std_logic_vector(7 downto 0)		:=	"11011000";
	constant		kADC_CH5					:	std_logic_vector(7 downto 0)		:=	"11100000";
	constant		kADC_CH6					:	std_logic_vector(7 downto 0)		:=	"11101000";
	constant		kADC_CH7					:	std_logic_vector(7 downto 0)		:=	"11110000";
	constant		kADC_CH8					:	std_logic_vector(7 downto 0)		:=	"11111000";
	
	signal			wDataCount					:	integer range 0 to 31				:=	0	;
	signal			iReadREQ_PosEdge			:	std_logic_vector(1 downto 0)		:=	(others => '0');
	signal			wpReadREQ					:	std_logic							:=	'0'	;
	signal			wSendingCH					:	std_logic_vector(7 downto 0)		:=	(others => '0');
	
	
	signal			wADC_CHCount				:	integer range 0 to 31				:=	0	;
	signal			wADC_RecvStart				:	std_logic							:=	'0'	;
	signal			wADC_RecvStart_NegEdge		:	std_logic_vector(1 downto 0)		:=	(others => '0');
	
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
			wpReadREQ			<=	'0'					;
			iReadREQ_PosEdge	<=	(others => '0')		;
			wDataCount			<=	0					;
			wSendingCH			<=	(others => '0')		;
		elsif ( CLK'event and CLK = '1' ) then
			iReadREQ_PosEdge		<=	iReadREQ_PosEdge(0) & iReadREQ	;
			if(iReadREQ_PosEdge = "01")then
				wpReadREQ	<=	'1'		;
			else
				wpReadREQ	<=	'0'		;
			end if;
			
			if(wpReadREQ = '1')then
				wDataCount		<=	wDataCount + 1	;
				iDataWrite		<=	kADC_CH1(7 downto 0)	;
				iCount			<=	conv_std_logic_vector(3,5)			;
			elsif(ipDataAck = '1')then
				wDataCount		<=	wDataCount + 1	;
				if(wDataCount = 1)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 2)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 3)then
					iDataWrite		<=	kADC_CH2(7 downto 0)	;
					iCount			<=	conv_std_logic_vector(3,5)	;
				elsif(wDataCount = 4)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 5)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 6)then
					iDataWrite		<=	kADC_CH3(7 downto 0)	;
					iCount			<=	conv_std_logic_vector(3,5)	;
				elsif(wDataCount = 7)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 8)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 9)then
					iDataWrite		<=	kADC_CH4(7 downto 0)	;
					iCount			<=	conv_std_logic_vector(3,5)	;
				elsif(wDataCount = 10)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 11)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 12)then
					iDataWrite		<=	kADC_CH5(7 downto 0)	;
					iCount			<=	conv_std_logic_vector(3,5)	;
				elsif(wDataCount = 13)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 14)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 15)then
					iDataWrite		<=	kADC_CH6(7 downto 0)	;
					iCount			<=	conv_std_logic_vector(3,5)	;
				elsif(wDataCount = 16)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 17)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 18)then
					iDataWrite		<=	kADC_CH7(7 downto 0)	;
					iCount			<=	conv_std_logic_vector(3,5)	;
				elsif(wDataCount = 19)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 20)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 21)then
					iDataWrite		<=	kADC_CH8(7 downto 0)	;
					iCount			<=	conv_std_logic_vector(3,5)	;
				elsif(wDataCount = 22)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				elsif(wDataCount = 23)then
					iDataWrite		<=	(others => '0')	;
					iCount			<=	conv_std_logic_vector(0,5)	;
				else
					iDataWrite		<=	(others => '0')				;
					iCount			<=	conv_std_logic_vector(0,5)	;
				end if;
			elsif(ipFinish = '1')then
				wSendingCH		<=	wSendingCH + '1'		;
				if(wDataCount = 25)then
					wDataCount		<=	0			;
					wSendingCH		<=	(others => '0')	;
				end if;
			end if;
			
			
		end if;
	end process;
	
	
	process( CLK , RST_L )
	begin
		if ( RST_L = '0' ) then
			wADC_CHCount			<=	0				;
			wADC_RecvStart			<=	'0'				;
			wADC_RecvStart_NegEdge	<=	(others => '0')	;
			ipReadFinish			<=	'0'				;
			iADCData				<=	(others => x"000")	;
		elsif ( CLK'event and CLK = '1' ) then
			if(iReadREQ_PosEdge = "01")then
				wADC_RecvStart	<=	'1'	;
			elsif(wADC_CHCount = 24)then
				wADC_RecvStart	<=	'0'	;
			end if;
			
			wADC_RecvStart_NegEdge	<=	wADC_RecvStart_NegEdge(0) & wADC_RecvStart	;
			
			if(wADC_RecvStart = '1')then
				if(ipReadValid = '1')then
					wADC_CHCount	<=	wADC_CHCount + 1	;
					if(wADC_CHCount = 0)then
						iADCData.CH1(11)			<=	iDataRead(0)	;
					elsif(wADC_CHCount = 1)then
						iADCData.CH1(10 downto 3)	<=	iDataRead	;
					elsif(wADC_CHCount = 2)then
						iADCData.CH1(2 downto 0)	<=	iDataRead(7 downto 5)	;
					elsif(wADC_CHCount = 3)then
						iADCData.CH2(11)			<=	iDataRead(0)	;
					elsif(wADC_CHCount = 4)then
						iADCData.CH2(10 downto 3)	<=	iDataRead	;
					elsif(wADC_CHCount = 5)then
						iADCData.CH2(2 downto 0)	<=	iDataRead(7 downto 5)	;
					elsif(wADC_CHCount = 6)then
						iADCData.CH3(11)			<=	iDataRead(0)	;
					elsif(wADC_CHCount = 7)then
						iADCData.CH3(10 downto 3)	<=	iDataRead	;
					elsif(wADC_CHCount = 8)then
						iADCData.CH3(2 downto 0)	<=	iDataRead(7 downto 5)	;
					elsif(wADC_CHCount = 9)then
						iADCData.CH4(11)			<=	iDataRead(0)	;
					elsif(wADC_CHCount = 10)then
						iADCData.CH4(10 downto 3)	<=	iDataRead	;
					elsif(wADC_CHCount = 11)then
						iADCData.CH4(2 downto 0)	<=	iDataRead(7 downto 5)	;
					elsif(wADC_CHCount = 12)then
						iADCData.CH5(11)			<=	iDataRead(0)	;
					elsif(wADC_CHCount = 13)then
						iADCData.CH5(10 downto 3)	<=	iDataRead	;
					elsif(wADC_CHCount = 14)then
						iADCData.CH5(2 downto 0)	<=	iDataRead(7 downto 5)	;
					elsif(wADC_CHCount = 15)then
						iADCData.CH6(11)			<=	iDataRead(0)	;
					elsif(wADC_CHCount = 16)then
						iADCData.CH6(10 downto 3)	<=	iDataRead	;
					elsif(wADC_CHCount = 17)then
						iADCData.CH6(2 downto 0)	<=	iDataRead(7 downto 5)	;
					elsif(wADC_CHCount = 18)then
						iADCData.CH7(11)			<=	iDataRead(0)	;
					elsif(wADC_CHCount = 19)then
						iADCData.CH7(10 downto 3)	<=	iDataRead	;
					elsif(wADC_CHCount = 20)then
						iADCData.CH7(2 downto 0)	<=	iDataRead(7 downto 5)	;
					elsif(wADC_CHCount = 21)then
						iADCData.CH8(11)			<=	iDataRead(0)	;
					elsif(wADC_CHCount = 22)then
						iADCData.CH8(10 downto 3)	<=	iDataRead	;
					elsif(wADC_CHCount = 23)then
						iADCData.CH8(2 downto 0)	<=	iDataRead(7 downto 5)	;
					end if;
				end if;
			else
				wADC_CHCount	<=	0	;
			end if;
			
			
			if(wADC_RecvStart_NegEdge = "10")then
				ipReadFinish	<=	'1'		;
			else
				ipReadFinish	<=	'0'		;
			end if;
			
		end if;
	end process;
	
	
	iSendingCH	<=	wSendingCH	;
	
	
	end	arcADC_STM;








