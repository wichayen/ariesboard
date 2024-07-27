	library		ieee,std;
	use			ieee.std_logic_1164.all	;
	use			ieee.std_logic_unsigned.all;
	use			ieee.std_logic_arith.all;
	use			ieee.std_logic_misc.all;
	
--	use			std.textio.all;
--	use			ieee.std_logic_textio.all;
	
	use			work.MY_PKG.all;
	
	
--------------------------------------------------------
	entity	PIO_CTRL	is
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
	end	PIO_CTRL;

	architecture	arcPIO_CTRL	of	PIO_CTRL	is
	
	signal			wPIOCtrl						:	std_logic_vector(15 downto 0)		;
	signal			wPIOBufferIn					:	std_logic_vector(15 downto 0)		;
	signal			wPIOBufferOut					:	std_logic_vector(15 downto 0)		;
	
	begin
	
	
	process( CLK , RST_L )
	begin
		if ( RST_L = '0' ) then
			iPIOBufferIn	<=	(others => '0')	;
			wPIOCtrl		<=	(others => '0')	;
			wPIOBufferOut	<=	(others => '0')	;
		elsif ( CLK'event and CLK = '1' ) then
			iPIOBufferIn	<=	wPIOBufferIn	;
			wPIOCtrl		<=	iPIOCtrl		;
			wPIOBufferOut	<=	iPIOBufferOut	;
		end if;
	end process;
	
	
	G1:	for i in 0 to 15 generate
		PIO(i)	<=	'Z'	when(wPIOCtrl(i) = '0')	else	wPIOBufferOut(i)	;
	end generate G1;
	
	wPIOBufferIn	<=	PIO		;
	
	
	end	arcPIO_CTRL;


































