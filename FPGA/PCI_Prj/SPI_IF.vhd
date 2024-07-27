	library		ieee,std;
	use			ieee.std_logic_1164.all	;
	use			ieee.std_logic_unsigned.all;
	use			ieee.std_logic_arith.all;
	use			ieee.std_logic_misc.all;
	
--	use			std.textio.all;
--	use			ieee.std_logic_textio.all;
	
	
--------------------------------------------------------
	entity	SPI_IF	is
		port	(
				CLK							:	in	std_logic							;
				RST_L						:	in	std_logic							;
				
				-- system interface
				iDataWrite					:	in	std_logic_vector(7 downto 0)		;		
				ipDataAck					:	out	std_logic							;		
				iDataRead					:	out	std_logic_vector(7 downto 0)		;		
				ipReadValid					:	out	std_logic							;		
				
				ipTrigClk					:	in	std_logic							;		
				iCount						:	in	std_logic_vector(4 downto 0)		;		
				ipFinish					:	out	std_logic							;		
				ipStart						:	out	std_logic							;		
				
				-- SPI interface
				MISO						:	in	std_logic							;
				MOSI						:	out	std_logic							;
				SCLK						:	out	std_logic							;
				CS_L						:	out	std_logic							
				
				);
	end	SPI_IF;

	architecture	arcSPI_IF	of	SPI_IF	is
--====================================================--
--[Component]
--====================================================--


--====================================================--
--[Constant]
--====================================================--


--====================================================--
--[Signal]PLL'S
--====================================================--
	signal		wCount						:	std_logic_vector(4 downto 0)			:=	( others => '0' )	;
	signal		wSCLK						:	std_logic								:=	'0'					;
	signal		wCS_L						:	std_logic								:=	'1'					;
	
	signal		wCS_L_PosEdge				:	std_logic_vector(1 downto 0)			:=	( others => '1' )	;
	signal		wpTrigClk_DL1				:	std_logic								:=	'0'					;
	
	signal		w16BitCount					:	integer range 0 to 20					:=	0					;
	
	signal		wDataWrite					:	std_logic_vector(7 downto 0)			:=	( others => '0' )	;
	signal		wDataWriteShift				:	std_logic_vector(7 downto 0)			:=	( others => '0' )	;
	signal		wDataRead					:	std_logic_vector(7 downto 0)			:=	( others => '0' )	;
	signal		wDataReadShift				:	std_logic_vector(7 downto 0)			:=	( others => '0' )	;
	
	signal		wStart						:	std_logic								:=	'0'					;
	signal		wStart_DL1					:	std_logic								:=	'0'					;
	signal		wStartPosEdge				:	std_logic_vector(1 downto 0)			:=	( others => '0' )	;
	signal		wpTrigStart					:	std_logic								:=	'0'					;
	signal		wpStart						:	std_logic								:=	'0'					;
	signal		wpTrigStart_DL1				:	std_logic								:=	'0'					;
	
	signal		wpDataAck					:	std_logic								:=	'0'					;
	signal		wpTrigDataAck				:	std_logic								:=	'0'					;
	signal		wpTrigDataAck_DL1			:	std_logic								:=	'0'					;
	signal		wDataAckPosEdge				:	std_logic_vector(1 downto 0)			:=	( others => '0' )	;
	
	signal		wReadValid					:	std_logic								:=	'0'					;
	signal		wpReadValid					:	std_logic								:=	'0'					;
	signal		wpTrigReadValid				:	std_logic								:=	'0'					;
	signal		wTrigReadValidPosEdge		:	std_logic_vector(1 downto 0)			:=	( others => '0' )	;
	
	signal		wpGetNextData				:	std_logic								:=	'0'					;
	
	signal		wpFinish					:	std_logic								:=	'0'					;
	
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
			wCount		<=	(others => '0')	;
			wpTrigStart	<=	'0'				;
			wStart		<=	'0'				;
		elsif ( CLK'event and CLK = '1' ) then
			if(ipTrigClk = '1')then
				if(wCount /= "00000")then
					wStart			<=	'1'			;
					if(w16BitCount = 0 and wStart = '0')then
						wpTrigStart			<=	'1'			;
					else
						wpTrigStart			<=	'0'		;
					end if;
					
					if(w16BitCount = 0 and wCS_L = '0')then
						wCount		<=	wCount - 1	;
					end if;
				else
					if(wStart = '0')then
						wCount		<=	iCount			;	
					end if;
					wStart		<=	'0'			;
				end if;
			else
				
			end if;
		end if;
	end process;
	
	process( CLK , RST_L )
	begin
		if ( RST_L = '0' ) then
			wStart_DL1		<=	'0'		;
		elsif ( CLK'event and CLK = '1' ) then
			if(ipTrigClk = '1')then
				wStart_DL1		<=	wStart			;
			end if;
		end if;
	end process;
	
	
	process( CLK , RST_L )
	begin
		if ( RST_L = '0' ) then
			wCS_L				<=	'1'				;
			MOSI				<=	'0'				;
			wSCLK				<=	'0'				;
			w16BitCount			<=	0				;
			wDataWrite			<=	(others => '0')	;
			wDataWriteShift		<=	(others => '0')	;
			wDataRead			<=	(others => '0')	;
			wReadValid			<=	'0'				;
		elsif ( CLK'event and CLK = '1' ) then
			if(ipTrigClk = '1')then
				
				if(wpTrigDataAck_DL1 = '1')then
					wDataWrite		<=	iDataWrite		;
				end if;
				
				if(wpTrigStart = '1')then
					wDataWriteShift	<=	iDataWrite		;
				elsif(wpGetNextData = '1')then
					wDataWriteShift	<=	wDataWrite		;
				elsif(wCS_L = '0' and conv_std_logic_vector(w16BitCount,4)(0) = '1')then
					wDataWriteShift	<=	wDataWriteShift(6 downto 0) & '0'		;
				end if;
				
				if(wStart_DL1 = '1')then
					if(wCount = "00000")then
						wCS_L		<=	'1'		;
						wSCLK		<=	'0'		;
						MOSI		<=	'0'		;
						w16BitCount	<=	0		;
					else
						wCS_L			<=	'0'			;
						if(w16BitCount = 15)then
							w16BitCount		<=	0					;
						else
							w16BitCount		<=	w16BitCount + 1		;
						end if;
						
						if(conv_std_logic_vector(w16BitCount,4)(0) = '0')then
							wSCLK			<=	'0'									;
							MOSI			<=	wDataWriteShift(7)					;
						else
							wSCLK			<=	'1'									;
							wDataRead		<=	wDataRead(6 downto 0) & MISO		;
						end if;
					end if;
				else
					w16BitCount		<=	0	;
				end if;
			end if;
			
		end if;
	end process;
	
	process( CLK , RST_L )
	begin
		if ( RST_L = '0' ) then
			wpTrigDataAck		<=	'0'		;
			wpGetNextData		<=	'0'		;
		elsif ( CLK'event and CLK = '1' ) then
			if(ipTrigClk = '1')then
				if(w16BitCount = 8)then
					wpTrigDataAck	<=	'1'		;
				else
					wpTrigDataAck	<=	'0'		;
				end if;
				wpTrigDataAck_DL1	<=	wpTrigDataAck	;
				
				if(w16BitCount = 14)then
					wpGetNextData	<=	'1'		;
				else
					wpGetNextData	<=	'0'		;
				end if;
			end if;
		end if;
	end process;
	
	process( CLK , RST_L )
	begin
		if ( RST_L = '0' ) then
			wpTrigReadValid		<=	'0'					;
		elsif ( CLK'event and CLK = '1' ) then
			if(ipTrigClk = '1')then
				if(w16BitCount = 15)then
					wpTrigReadValid	<=	'1'				;
				else
					wpTrigReadValid	<=	'0'				;
				end if;
			end if;
		end if;
	end process;
	
	
	process( CLK , RST_L )
	begin
		if ( RST_L = '0' ) then
			wpFinish		<=	'0'					;
			wCS_L_PosEdge	<=	( others => '1' )	;
		elsif ( CLK'event and CLK = '1' ) then
			wCS_L_PosEdge	<=	wCS_L_PosEdge(0) & wCS_L	;
			if(wCS_L_PosEdge = "01")then
				wpFinish		<=	'1'	;
			else
				wpFinish		<=	'0'	;
			end if;
		end if;
	end process;
	
	
	process( CLK , RST_L )
	begin
		if ( RST_L = '0' ) then
			wStartPosEdge		<=	( others => '0' )	;
			wDataAckPosEdge		<=	( others => '0' )	;
			wpDataAck			<=	'0'					;
			wpStart				<=	'0'					;
		elsif ( CLK'event and CLK = '1' ) then
			wDataAckPosEdge	<=	wDataAckPosEdge(0) & wpTrigDataAck;
			if(wDataAckPosEdge = "01")then
				wpDataAck	<=	'1'		;
			else
				wpDataAck	<=	'0'		;
			end if;
			
			wStartPosEdge	<=	wStartPosEdge(0) & wpTrigStart;
			if(wStartPosEdge = "01")then
				wpStart		<=	'1'		;
			else
				wpStart		<=	'0'		;
			end if;
		end if;
	end process;
	
	process( CLK , RST_L )
	begin
		if ( RST_L = '0' ) then
			wTrigReadValidPosEdge	<=	( others => '0' )	;
			wpReadValid				<=	'0'					;
		elsif ( CLK'event and CLK = '1' ) then
			wTrigReadValidPosEdge	<=	wTrigReadValidPosEdge(0) & wpTrigReadValid	;
			if(wTrigReadValidPosEdge = "01")then
				wpReadValid	<=	'1'		;
			else
				wpReadValid	<=	'0'		;
			end if;
		end if;
	end process;
	
	ipFinish		<=	wpFinish											;
	ipReadValid		<=	wpReadValid		when(wCS_L = '0')	else 	'0'		;
	ipDataAck		<=	wpDataAck											;
	ipStart			<=	wpStart												;
	
	CS_L			<=	wCS_L												;
	SCLK			<=	wSCLK			when(wCS_L = '0')	else 	'0'		;
	iDataRead		<=	wDataRead											;
	
	
	end	arcSPI_IF;



















