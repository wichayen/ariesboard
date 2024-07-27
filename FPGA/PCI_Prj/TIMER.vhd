	library		ieee,std;
	use			ieee.std_logic_1164.all	;
	use			ieee.std_logic_unsigned.all;
	use			ieee.std_logic_arith.all;
	use			ieee.std_logic_misc.all;
	
--	use			std.textio.all;
--	use			ieee.std_logic_textio.all;
		
	entity	TIMER	is
		port	(
				CLK							:	in	std_logic							;
				RST_L						:	in	std_logic							;
				
				iTIMER_Period				:	in	std_logic_vector(15 downto 0)		;
				iEnable						:	in	std_logic							;		--	timer start
				iClear						:	in	std_logic							;		--	Timeout flag clear
				ipTimeout					:	out	std_logic							
				
				);
	end	TIMER;
	
	architecture	arcTIMER	of	TIMER	is
	
	
	signal			wCount					:	std_logic_vector(15 downto 0)			:=	(others => '0')	;
	
	
	begin
	
	process( CLK , RST_L )
	begin
		if ( RST_L = '0' ) then
			wCount		<=	(others => '0')	;
			ipTimeout	<=	'0'				;
		elsif ( CLK'event and CLK = '1' ) then
			if(iEnable = '1')then
				if(iClear = '0')then
					if(wCount = x"0000")then
						wCount		<=	iTIMER_Period	;
						ipTimeout	<=	'1'				;
					else
						wCount		<=	wCount - 1		;
						ipTimeout	<=	'0'				;
					end if;
				else
					wCount		<=	(others => '0')	;
					ipTimeout	<=	'0'				;
				end if;
			else
				wCount		<=	(others => '0')	;
				ipTimeout	<=	'0'				;
			end if;
		end if;
	end process;
	
	
	
	
	end	arcTIMER;
