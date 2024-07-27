library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use			work.MY_PKG.all;

entity MYIP is
	port (
		
		clk					:	in			std_logic			:= '0';
		reset_N				:	in			std_logic			:= '0';
		MEM_ADRS			:	in			std_logic_vector(23 downto 0);
		MEM_DATA			:	inout		std_logic_vector(31 downto 0);
		MEM_CEn				:	in			std_logic;			-- SRAM /CE
		MEM_OEn				:	in			std_logic;			-- SRAM /OE
		MEM_WE0n			:	in			std_logic;			-- SRAM0 /WE
		MEM_WE1n			:	in			std_logic;			-- SRAM1 /WE
		MEM_WE2n			:	in			std_logic;			-- SRAM2 /WE
		MEM_WE3n			:	in			std_logic;			-- SRAM3 /WE
	
		-- external interface
		-- Analog out
		DAC_DATA					:	out	std_logic							;
		DAC_LDAC					:	out	std_logic							;
		DAC_CLK						:	out	std_logic							;
		DAC_CS1						:	out	std_logic							;
		DAC_CS2						:	out	std_logic							;
		
		-- Analog in
		ADC_CLK						:	out	std_logic							;
		ADC_DOUT					:	out	std_logic							;
		ADC_DIN						:	in	std_logic							;
		ADC_CS						:	out	std_logic							;
		
		-- LED
		LED							:	out	std_logic_vector(7 downto 0)		;
		
		-- Digital IO
		DIGITAL_IO					:	inout	std_logic_vector(15 downto 0)		
				
		
	);
end entity MYIP;

architecture rtl of MYIP is


component	PIO_CTRL	is
	port	(
			CLK							:	in	std_logic							;
			RST_L						:	in	std_logic							;
			
			-- system interface
			iPIOCtrl					:	in	std_logic_vector(15 downto 0)		;
			iPIOBufferIn				:	out	std_logic_vector(15 downto 0)		;
			iPIOBufferOut				:	in	std_logic_vector(15 downto 0)		;
			
			-- PIO interface
			PIO							:	inout	std_logic_vector(15 downto 0)	
			
			);
end	component;
	
component	DAC_CTRL	is
	port	(
			CLK							:	in	std_logic							;
			RST_L						:	in	std_logic							;
			
			-- system interface
			iDACData					:	in	ODAC_DATA							;
			iWriteREQ					:	in	std_logic							;
			ipWriteFinish				:	out	std_logic							;
			
			-- DAC interface
			MOSI						:	out	std_logic							;
			SCLK						:	out	std_logic							;
			CS_L1						:	out	std_logic							;
			CS_L2						:	out	std_logic							;
			LOADDACS_L					:	out	std_logic							
			
			);
end	component;
	
	
component	ADC_CTRL	is
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
end	component;
	
	signal		RST_L						:	std_logic							:=	'0';
	
	signal		wDACData					:	ODAC_DATA							;
	signal		wDACWriteREQ				:	std_logic							:=	'0';
	signal		wDACWriteREQReg				:	std_logic							:=	'0';
	signal		wpWriteFinish				:	std_logic							:=	'0';
	
	signal		wADCData					:	ADC_DATA							;
	signal		wADCReadREQ					:	std_logic							:=	'0';
	signal		wADCReadREQReg				:	std_logic							:=	'0';
	signal		wADCReadNonStop				:	std_logic							:=	'0';
	signal		wpReadFinish				:	std_logic							:=	'0';
	signal		wCS_L						:	std_logic							:=	'1';
	
	signal		wPIOCtrl					:	std_logic_vector(15 downto 0)		:=	(others => '0')	;
	signal		wPIOBufferIn				:	std_logic_vector(15 downto 0)		:=	(others => '0')	;
	signal		wPIOBufferOut				:	std_logic_vector(15 downto 0)		:=	(others => '0')	;
	
	signal		wREAD_DATA					: 	std_logic_vector(31 downto 0)		:=	(others => '0')	;
	signal		wWRITE_DATA					: 	std_logic_vector(31 downto 0)		:=	(others => '0')	;
	signal		wDATA_HiZ					:	std_logic							:=	'0';
	signal		wMEM_WEn					:	std_logic							:=	'0';
	signal		wMEM_WE						:	std_logic							:=	'0';
	signal		wpMEM_WE					:	std_logic							:=	'0';
	signal		wMemEnEdge					:	std_logic_vector(1 downto 0)		:=	(others => '0')	;
	
	signal		wLED						:	std_logic_vector(7 downto 0)		:=	(others => '0')	;
	
	-- test register
	type		tTestReg	is array (0 to 7) of std_logic_vector(31 downto 0)	;
	signal		wTestReg					:	tTestReg							:=	(others => (others => '0'))	;	--:=	(others => others => '0')	;
	
begin

PIO_CTRL_M:PIO_CTRL
	port map	(
			CLK							=>	clk				,	--:	in	std_logic							;
			RST_L						=>	RST_L			,	--:	in	std_logic							;
			
			-- system interface         =>			,	--
			iPIOCtrl					=>	wPIOCtrl		,	--:	in	std_logic_vector(15 downto 0)		;
			iPIOBufferIn				=>	wPIOBufferIn	,	--:	out	std_logic_vector(15 downto 0)		;
			iPIOBufferOut				=>	wPIOBufferOut	,	--:	in	std_logic_vector(15 downto 0)		;
			
			-- PIO interface            =>			,	--
			PIO							=>	DIGITAL_IO			--:	inout	std_logic_vector(15 downto 0)	
			
			);
			
	
DAC_CTRL_M:DAC_CTRL
	port map	(
			CLK							=>	clk				,	--:	in	std_logic							;
			RST_L						=>	RST_L			,	--:	in	std_logic							;
			
			-- system interface         =>			,	--
			iDACData					=>	wDACData		,	--:	in	ODAC_DATA							;
			iWriteREQ					=>	wDACWriteREQ	,	--:	in	std_logic							;
			ipWriteFinish				=>	wpWriteFinish	,	--:	out	std_logic							;
			
			-- DAC interface            =>			,	--
			MOSI						=>	DAC_DATA		,	--:	out	std_logic							;
			SCLK						=>	DAC_CLK			,	--:	out	std_logic							;
			CS_L1						=>	DAC_CS1			,	--:	out	std_logic							;
			CS_L2						=>	DAC_CS2			,	--:	out	std_logic							;
			LOADDACS_L					=>	DAC_LDAC			--:	out	std_logic							
			
			);
			
			
ADC_CTRL_M:ADC_CTRL
	port map	(
			CLK							=>	clk				,	--:	in	std_logic							;
			RST_L						=>	RST_L			,	--:	in	std_logic							;
			
			-- system interface         =>			,	--
			iADCData					=>	wADCData		,	--:	out	ADC_DATA							;
			iReadREQ					=>	wADCReadREQ		,	--:	in	std_logic							;
			ipReadFinish				=>	wpReadFinish	,	--:	out	std_logic							;
			
			-- ADC interface            =>			,	--
			MISO						=>	ADC_DIN			,	--:	in	std_logic							;
			MOSI						=>	ADC_DOUT		,	--:	out	std_logic							;
			SCLK						=>	ADC_CLK			,	--:	out	std_logic							;
			CS_L						=>	wCS_L				--:	out	std_logic							
			
			);
			
	ADC_CS			<=	wCS_L											;
	RST_L			<=	reset_N											;
	wMEM_WEn		<=	MEM_WE0n or MEM_WE1n or MEM_WE2n or MEM_WE3n	;
	wMEM_WE			<=	not wMEM_WEn									;
	MEM_DATA		<=	wREAD_DATA	when(MEM_OEn = '0' and MEM_CEn = '0' and wMEM_WEn='1' )	else
						(others => 'Z')								;
	wWRITE_DATA		<=	MEM_DATA										;
	
	process( clk , reset_N )
	begin
		if ( reset_N = '0' ) then
			wMemEnEdge		<=	(others => '0')	;
			wpMEM_WE		<=	'0'					;
		elsif ( clk'event and clk = '1' ) then
			wMemEnEdge		<=	wMemEnEdge(0) & wMEM_WE	;
			if(wMemEnEdge = "01")then
				wpMEM_WE		<=	'1'			;
			else
				wpMEM_WE		<=	'0'			;
			end if;
			
		end if;
	end process;
	
	
	-- read
	process( clk , reset_N )
	begin
		if ( reset_N = '0' ) then
			wREAD_DATA				<= x"00000000";
		elsif ( clk'event and clk = '1' ) then
			if(MEM_OEn = '0' and MEM_CEn = '0' and wMEM_WEn='1')then
				if(MEM_ADRS(11 downto 8) = x"0")then
					if(MEM_ADRS(7 downto 0) = x"00")then
						wREAD_DATA	<=	x"0000" & wPIOBufferIn	;
					end if;
					
				elsif(MEM_ADRS(11 downto 8) = x"1")then
					if(MEM_ADRS(7 downto 0) = x"00")then
						wREAD_DATA	<=	x"0000" & x"0" & wADCData.CH1	;
					elsif(MEM_ADRS(7 downto 0) = x"04")then
						wREAD_DATA	<=	x"0000" & x"0" & wADCData.CH2	;
					elsif(MEM_ADRS(7 downto 0) = x"08")then
						wREAD_DATA	<=	x"0000" & x"0" & wADCData.CH3	;
					elsif(MEM_ADRS(7 downto 0) = x"0c")then
						wREAD_DATA	<=	x"0000" & x"0" & wADCData.CH4	;
					elsif(MEM_ADRS(7 downto 0) = x"10")then
						wREAD_DATA	<=	x"0000" & x"0" & wADCData.CH5	;
					elsif(MEM_ADRS(7 downto 0) = x"14")then
						wREAD_DATA	<=	x"0000" & x"0" & wADCData.CH6	;
					elsif(MEM_ADRS(7 downto 0) = x"18")then
						wREAD_DATA	<=	x"0000" & x"0" & wADCData.CH7	;
					elsif(MEM_ADRS(7 downto 0) = x"1c")then
						wREAD_DATA	<=	x"0000" & x"0" & wADCData.CH8	;
					else
						wREAD_DATA	<=	(others => '0')	;
					end if;
					
				elsif(MEM_ADRS(11 downto 8) = x"2")then
					wREAD_DATA		<=	x"00000000"	;
				elsif(MEM_ADRS(11 downto 8) = x"3")then
					wREAD_DATA		<=	x"000000" & wLED	;
					
				elsif(MEM_ADRS(11 downto 8) = x"4")then
					wREAD_DATA		<=	x"20111102"	;
					
				elsif(MEM_ADRS(11 downto 8) = x"5")then
					if(MEM_ADRS(7 downto 0) = x"00")then
						wREAD_DATA	<=	wTestReg(0)	;
					elsif(MEM_ADRS(7 downto 0) = x"04")then
						wREAD_DATA	<=	wTestReg(1)	;
					elsif(MEM_ADRS(7 downto 0) = x"08")then
						wREAD_DATA	<=	wTestReg(2)	;
					elsif(MEM_ADRS(7 downto 0) = x"0c")then
						wREAD_DATA	<=	wTestReg(3)	;
					elsif(MEM_ADRS(7 downto 0) = x"10")then
						wREAD_DATA	<=	wTestReg(4)	;
					elsif(MEM_ADRS(7 downto 0) = x"14")then
						wREAD_DATA	<=	wTestReg(5)	;
					elsif(MEM_ADRS(7 downto 0) = x"18")then
						wREAD_DATA	<=	wTestReg(6)	;
					elsif(MEM_ADRS(7 downto 0) = x"1c")then
						wREAD_DATA	<=	wTestReg(7)	;
					else
						wREAD_DATA	<=	(others => '0')	;
					end if;
					
				else
					wREAD_DATA 	<= x"BABABABA";
				end if;
				
				
				
			end if;
			
		end if;
	end process;
	
	
	
	-- write
	process( clk , reset_N )
	begin
		if ( reset_N = '0' ) then
			wDACData		<=	(others => x"000")	;
			wDACWriteREQ	<=	'0'						;
			wADCReadREQ		<=	'0'						;
			wADCReadNonStop	<=	'0'						;
			wDACWriteREQReg	<=	'0'						;
			wADCReadREQReg	<=	'0'						;
			wLED			<=	(others => '0')		;
			wTestReg		<=	(others => (others => '0'))		;
		elsif ( clk'event and clk = '1' ) then
			if(MEM_OEn = '1' and MEM_CEn = '0' and wpMEM_WE='1' )then
				if(MEM_ADRS(11 downto 8) = x"0")then
					if(MEM_ADRS(7 downto 0) = x"00")then
						wPIOBufferOut		<=	wWRITE_DATA(15 downto 0)	;
					elsif(MEM_ADRS(7 downto 0) = x"04")then
						wPIOCtrl			<=	wWRITE_DATA(15 downto 0)	;
					end if;
				elsif(MEM_ADRS(11 downto 8) = x"1")then
					wADCReadREQReg		<=	'1'		;
					if(MEM_ADRS(3 downto 0) = x"0")then
						if(wWRITE_DATA(1) = '1')then
							wADCReadNonStop	<=	'1'	;
						else
							wADCReadNonStop	<=	'0'	;
						end if;
					end if;
				elsif(MEM_ADRS(11 downto 8) = x"2")then
					if(MEM_ADRS(7 downto 0) = x"00")then
						wDACData.CH1	<=	wWRITE_DATA(11 downto 0)	;
					elsif(MEM_ADRS(7 downto 0) = x"04")then
						wDACData.CH2	<=	wWRITE_DATA(11 downto 0)	;
					elsif(MEM_ADRS(7 downto 0) = x"08")then
						wDACData.CH3	<=	wWRITE_DATA(11 downto 0)	;
					elsif(MEM_ADRS(7 downto 0) = x"0c")then
						wDACData.CH4	<=	wWRITE_DATA(11 downto 0)	;
					elsif(MEM_ADRS(7 downto 0) = x"10")then
						wDACWriteREQReg	<=	'1'								;
					end if;
				elsif(MEM_ADRS(11 downto 8) = x"3")then
					if(MEM_ADRS(7 downto 0) = x"00")then
						wLED		<=	wWRITE_DATA(7 downto 0)	;
					end if;
					
				elsif(MEM_ADRS(11 downto 8) = x"5")then
					if(MEM_ADRS(7 downto 0) = x"00")then
						wTestReg(0)		<=	wWRITE_DATA		;
					elsif(MEM_ADRS(7 downto 0) = x"04")then
						wTestReg(1)		<=	wWRITE_DATA		;
					elsif(MEM_ADRS(7 downto 0) = x"08")then
						wTestReg(2)		<=	wWRITE_DATA		;
					elsif(MEM_ADRS(7 downto 0) = x"0c")then
						wTestReg(3)		<=	wWRITE_DATA		;
					elsif(MEM_ADRS(7 downto 0) = x"10")then
						wTestReg(4)		<=	wWRITE_DATA		;
					elsif(MEM_ADRS(7 downto 0) = x"14")then
						wTestReg(5)		<=	wWRITE_DATA		;
					elsif(MEM_ADRS(7 downto 0) = x"18")then
						wTestReg(6)		<=	wWRITE_DATA		;
					elsif(MEM_ADRS(7 downto 0) = x"1c")then
						wTestReg(7)		<=	wWRITE_DATA		;
					end if;
					
				else
				
				end if;
			else
				wDACWriteREQReg	<=	'0'	;
				wADCReadREQReg	<=	'0'	;
			end if;
			
			if(wpWriteFinish = '1')then
				wDACWriteREQ	<=	'0'		;
			elsif(wDACWriteREQReg = '1')then
				wDACWriteREQ	<=	'1'		;
			end if;
			
			if(wADCReadNonStop = '1')then
				if(wpReadFinish = '1')then
					wADCReadREQ		<=	'0'		;
				else
					if(wCS_L = '1')then
						wADCReadREQ		<=	'1'		;
					end if;
				end if;
			else
				if(wpReadFinish = '1')then
					wADCReadREQ		<=	'0'		;
				elsif(wADCReadREQReg = '1')then
					wADCReadREQ		<=	'1'		;
				end if;
			end if;
			
		end if;
		
	end process;
	
	
	LED		<=	wLED		;
	
	
end architecture rtl; -- of MYIP
