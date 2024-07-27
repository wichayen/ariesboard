	library		ieee;
	use			ieee.std_logic_1164.all	;
	use			ieee.std_logic_unsigned.all;
	use			ieee.std_logic_arith.all;
	

	entity	PRJ_TOP	is
		port	(
				CLK							:	in	std_logic							;
				RST_L						:	in	std_logic							;
				
				-- Analog out
				DAC_DATA					:	out	std_logic							;
				DAC_LDAC					:	out	std_logic							;
				DAC_CLK						:	out	std_logic							;
				DAC_CS1						:	out	std_logic							;
				DAC_CS2						:	out	std_logic							;
				
				-- Analog in
				ADC_CLK						:	out	std_logic							;
				ADC_DOUT					:	in	std_logic							;
				ADC_DIN						:	out	std_logic							;
				ADC_CS						:	out	std_logic							;
				
				-- Digital IO
				DIGITAL_IO					:	inout	std_logic_vector(15 downto 0)		;
				
				-- SDRAM
				SDRAM_DQ					:	inout	std_logic_vector(15 downto 0)	;
				SDRAM_ADDR					:	out	std_logic_vector(12 downto 0)		;
				SDRAM_LDQM					:	out	std_logic							;
				SDRAM_UDQM					:	out	std_logic							;
				SDRAM_WE_N					:	out	std_logic							;
				SDRAM_CAS_N					:	out	std_logic							;
				SDRAM_RAS_N					:	out	std_logic							;
				SDRAM_CS_N					:	out	std_logic							;
				SDRAM_BA_0					:	out	std_logic							;
				SDRAM_BA_1					:	out	std_logic							;
				SDRAM_CLK					:	out	std_logic							;
				SDRAM_CKE					:	out	std_logic							;
				
				-- serial Flash
				FLASH_DCLK					:	out	std_logic							;
				FLASH_ASDI					:	out	std_logic							;
				FLASH_DATA					:	in	std_logic							;
				FLASH_nCS					:	out	std_logic							;
				
				-- UART
				UART_TXD					:	out	std_logic							;
				UART_RXD					:	in	std_logic							;
				
				-- VGA (LED)
				VGA_VSYNC					:	out	std_logic							;
				VGA_HSYNC					:	out	std_logic							;
				VGA_R						:	out	std_logic_vector(1 downto 0)		;
				VGA_G						:	out	std_logic_vector(1 downto 0)		;
				VGA_B						:	out	std_logic_vector(1 downto 0)		;
				
				-- switch
				SW_SLIDE					:	in	std_logic_vector(3 downto 0)		;
				SW_TACT						:	in	std_logic_vector(2 downto 0)		;
				
				-- PCI master
				REQN		: OUT STD_LOGIC;
				GNTN		: in STD_LOGIC;
				
				-- PCI interface
				idsel	: IN STD_LOGIC;
				
				cben	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
				clk_pci: IN STD_LOGIC;
				framen	: IN STD_LOGIC;
				irdyn	: IN STD_LOGIC;
				intan	: OUT STD_LOGIC;
				--serrn	: OUT STD_LOGIC;
				serrn	: INOUT STD_LOGIC;
				
				perrn	: OUT STD_LOGIC;
				rstn	: IN STD_LOGIC;
				devseln	: OUT STD_LOGIC;
				trdyn	: OUT STD_LOGIC;
				stopn	: OUT STD_LOGIC;
				ad	: INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
				par	: INOUT STD_LOGIC
				
				);
	end	PRJ_TOP;

	architecture	arcPRJ_TOP	of	PRJ_TOP	is
--------------------------------------------------------
--Component
--------------------------------------------------------

-- BAR0	:	MMIO
-- BAR1	:	IO port
component PCI_TGT8 is
	port(

	-- PCI(8) --
		PCICLK		: in	std_logic;			-- PCI
		RST_n		: in	std_logic;			-- 
		PCIAD		: inout	std_logic_vector(31 downto 0);	-- /
		C_BE_n		: in	std_logic_vector(3 downto 0);	-- PCI/
		FRAME_n		: in	std_logic;			-- 
		IRDY_n		: in	std_logic;			-- 
		DEVSEL_n	: out	std_logic;			-- 
		TRDY_n		: out	std_logic;			-- 
		STOP_n		: out	std_logic;			-- 
		PAR			: inout	std_logic;			-- 
		IDSEL		: in	std_logic;			-- 
		INTA_n		: out	std_logic;			--  INTA#

	-- PCI(8) --
		PERR_n		: out	std_logic;			-- 
		SERR_n		: out	std_logic;			-- 
		REQ_n		: out	std_logic;			-- 
		GNT_n		: in	std_logic;			-- 
		INTB_n		: out	std_logic;			--  INTB#
		INTC_n		: out	std_logic;			--  INTC#
		INTD_n		: out	std_logic;			--  INTD#

	-- 
		MEM_ADRS	: out	std_logic_vector(23 downto 0);	-- 
		MEM_DATA	: inout	std_logic_vector(31 downto 0);	-- 
		MEM_CEn		: out	std_logic;			-- SRAM03 /CE
		MEM_OEn		: out	std_logic;			-- SRAM03 /OE
		MEM_WE0n	: out	std_logic;			-- SRAM0 /WE
		MEM_WE1n	: out	std_logic;			-- SRAM1 /WE
		MEM_WE2n	: out	std_logic;			-- SRAM2 /WE
		MEM_WE3n	: out	std_logic;			-- SRAM3 /WE

	-- 
		INT_IN3		: in	std_logic;			-- 3
		INT_IN2		: in	std_logic;			-- 2
		INT_IN1		: in	std_logic;			-- 1
		INT_IN0		: in	std_logic			-- 0

	);
end component PCI_TGT8;


--component AVALON_SDRAM is 
--           port (
--                 -- 1) global signals:
--                    signal clk_0 : IN STD_LOGIC;
--                    signal reset_n : IN STD_LOGIC;
--
--                 -- the_MyAvalonM_0
--                    signal iaddress_to_the_MyAvalonM_0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
--                    signal iread_to_the_MyAvalonM_0 : IN STD_LOGIC;
--                    signal ireaddata_from_the_MyAvalonM_0 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
--                    signal ireaddatavalid_from_the_MyAvalonM_0 : OUT STD_LOGIC;
--                    signal iwaitrequest_from_the_MyAvalonM_0 : OUT STD_LOGIC;
--                    signal iwrite_to_the_MyAvalonM_0 : IN STD_LOGIC;
--                    signal iwritedata_to_the_MyAvalonM_0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
--
--                 -- the_sdram_0
--                    signal zs_addr_from_the_sdram_0 : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
--                    signal zs_ba_from_the_sdram_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
--                    signal zs_cas_n_from_the_sdram_0 : OUT STD_LOGIC;
--                    signal zs_cke_from_the_sdram_0 : OUT STD_LOGIC;
--                    signal zs_cs_n_from_the_sdram_0 : OUT STD_LOGIC;
--                    signal zs_dq_to_and_from_the_sdram_0 : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
--                    signal zs_dqm_from_the_sdram_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
--                    signal zs_ras_n_from_the_sdram_0 : OUT STD_LOGIC;
--                    signal zs_we_n_from_the_sdram_0 : OUT STD_LOGIC
--                 );
--end component AVALON_SDRAM;



component MYIP is
	port (
		
		clk					: in  std_logic                     := '0';
		reset_N				: in  std_logic                     := '0';
		MEM_ADRS			: in	std_logic_vector(23 downto 0);	-- 
		MEM_DATA			: inout	std_logic_vector(31 downto 0);	-- 
		MEM_CEn				: in	std_logic;			-- SRAM03 /CE
		MEM_OEn				: in	std_logic;			-- SRAM03 /OE
		MEM_WE0n			: in	std_logic;			-- SRAM0 /WE
		MEM_WE1n			: in	std_logic;			-- SRAM1 /WE
		MEM_WE2n			: in	std_logic;			-- SRAM2 /WE
		MEM_WE3n			: in	std_logic	;		-- SRAM3 /WE
	
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
end component MYIP;
	

--------------------------------------------------------
--Constant
--------------------------------------------------------
--	constant	kCOUNT_END				:	integer range 0 to 10000		:=	127					;
--------------------------------------------------------
--Signal
--------------------------------------------------------
	signal		wAddress					:		STD_LOGIC_VECTOR (23 DOWNTO 0);
	signal		wCLK						:		STD_LOGIC;
	signal		wReadData					:		STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal		wReadValid					:		STD_LOGIC;
	signal		wRead						:		STD_LOGIC;
	signal		wReset_L					:		STD_LOGIC;
	signal		wWaitReq					:		STD_LOGIC;
	signal		wWriteData					:		STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal		wWrite						:		STD_LOGIC;

	signal		wLED						:	std_logic_vector(7 downto 0)		:=	(others => '0')	;
	
	signal		wSDRAM_BA					:	std_logic_vector(1 downto 0)		:=	(others => '0')	;
	signal		wSDRAM_DQM					:	std_logic_vector(1 downto 0)		:=	(others => '0')	;
	
	
	signal		wMEM_ADRS			: 	std_logic_vector(23 downto 0);	-- 
	signal		wMEM_DATA			: 	std_logic_vector(31 downto 0);	-- 
	signal		wMEM_CEn			: 	std_logic;			-- SRAM03 /CE
	signal		wMEM_OEn			: 	std_logic;			-- SRAM03 /OE
	signal		wMEM_WE0n			: 	std_logic;			-- SRAM0 /WE
	signal		wMEM_WE1n			: 	std_logic;			-- SRAM1 /WE
	signal		wMEM_WE2n			: 	std_logic;			-- SRAM2 /WE
	signal		wMEM_WE3n			: 	std_logic;			-- SRAM3 /WE
		
		
	
--------------------------------------------------------
--Function
--------------------------------------------------------
	
--------------------------------------------------------
	begin
--------------------------------------------------------
	
--------------------------------------------------------
--Port Map
--------------------------------------------------------

--AVALON_SDRAM_M:AVALON_SDRAM
--	port map(
--			-- 1) global signals:
--			clk_0 									=>	CLK					,	--: IN STD_LOGIC;
--			reset_n 								=>	RST_L				,	--: IN STD_LOGIC;
--
--			-- the_MyAvalonM_0	=                    >				,	--
--			iaddress_to_the_MyAvalonM_0				=>	(others => '0')		,	-- : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
--			iread_to_the_MyAvalonM_0				=>	'0'					,	-- : IN STD_LOGIC;
--			ireaddata_from_the_MyAvalonM_0			=>	open				,	-- : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
--			ireaddatavalid_from_the_MyAvalonM_0 	=>	open				,	--: OUT STD_LOGIC;
--			iwaitrequest_from_the_MyAvalonM_0 		=>	open				,	--	: OUT STD_LOGIC;
--			iwrite_to_the_MyAvalonM_0 				=>	'0'					,	--: IN STD_LOGIC;
--			iwritedata_to_the_MyAvalonM_0 			=>	(others => '0')		,	--: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
--
--			-- the_sdram_0	=                        >				,	--
--			zs_addr_from_the_sdram_0 				=>	SDRAM_ADDR			,	--: OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
--			zs_ba_from_the_sdram_0 					=>	wSDRAM_BA			,	--: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
--			zs_cas_n_from_the_sdram_0 				=>	SDRAM_CAS_N			,	--: OUT STD_LOGIC;
--			zs_cke_from_the_sdram_0 				=>	SDRAM_CKE			,	--: OUT STD_LOGIC;
--			zs_cs_n_from_the_sdram_0 				=>	SDRAM_CS_N			,	--: OUT STD_LOGIC;
--			zs_dq_to_and_from_the_sdram_0 			=>	SDRAM_DQ			,	--	: INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
--			zs_dqm_from_the_sdram_0 				=>	wSDRAM_DQM			,	--: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
--			zs_ras_n_from_the_sdram_0 				=>	SDRAM_RAS_N			,	--: OUT STD_LOGIC;
--			zs_we_n_from_the_sdram_0 				=>	SDRAM_WE_N				--: OUT STD_LOGIC
--                 );


-- BAR0	:	MMIO
-- BAR1	:	IO port

PCI_TGT8_M:PCI_TGT8
	port map(
		-- PCI(8) --
			PCICLK				=>	clk_pci				,	--: in	std_logic;			-- PCI
			RST_n				=>	rstn				,	--: in	std_logic;			-- 
			PCIAD				=>	ad				,	--: inout	std_logic_vector(31 downto 0);	-- /
			C_BE_n				=>	cben				,	--: in	std_logic_vector(3 downto 0);	-- PCI/
			FRAME_n				=>	framen				,	--: in	std_logic;			-- 
			IRDY_n				=>	irdyn				,	--: in	std_logic;			-- 
			DEVSEL_n			=>	devseln				,	--: out	std_logic;			-- 
			TRDY_n				=>	trdyn				,	--: out	std_logic;			-- 
			STOP_n				=>	stopn				,	--: out	std_logic;			-- 
			PAR					=>	par				,	--: inout	std_logic;			-- 
			IDSEL				=>	idsel				,	--: in	std_logic;			-- 
			INTA_n				=>	intan				,	--: out	std_logic;			--  INTA#
		
		-- PCI		=>					,	--(8) --
			PERR_n				=>	perrn				,	--: out	std_logic;			-- 
			SERR_n				=>	serrn				,	--: out	std_logic;			-- 
			REQ_n				=>	REQN				,	--: out	std_logic;			-- 
			GNT_n				=>	GNTN				,	--: in	std_logic;			-- 
			INTB_n				=>	open				,	--: out	std_logic;			--  INTB#
			INTC_n				=>	open				,	--: out	std_logic;			--  INTC#
			INTD_n				=>	open				,	--: out	std_logic;			--  INTD#
		
		-- 		=>					,	--
			MEM_ADRS			=>	wMEM_ADRS					,	--: out	std_logic_vector(23 downto 0);	-- 
			MEM_DATA			=>	wMEM_DATA					,	--: inout	std_logic_vector(31 downto 0);	-- 
			MEM_CEn				=>	wMEM_CEn					,	--: out	std_logic;			-- SRAM03 /CE
			MEM_OEn				=>	wMEM_OEn					,	--: out	std_logic;			-- SRAM03 /OE
			MEM_WE0n			=>	wMEM_WE0n					,	--: out	std_logic;			-- SRAM0 /WE
			MEM_WE1n			=>	wMEM_WE1n					,	--: out	std_logic;			-- SRAM1 /WE
			MEM_WE2n			=>	wMEM_WE2n					,	--: out	std_logic;			-- SRAM2 /WE
			MEM_WE3n			=>	wMEM_WE3n					,	--: out	std_logic;			-- SRAM3 /WE
		
		-- 		=>					,	--
			INT_IN3				=>	'0'				,	--: in	std_logic;			-- 3
			INT_IN2				=>	'0'				,	--: in	std_logic;			-- 2
			INT_IN1				=>	'0'				,	--: in	std_logic;			-- 1
			INT_IN0				=>	'0'					--: in	std_logic			-- 0

	);


MYIP_M : MYIP
	port map(
		
		clk						=>	clk_pci					,	--	    : in  std_logic                     := '0';             -- clock.clk
		reset_N					=>	rstn					,	--    : in  std_logic                     := '0';             --      .reset
		MEM_ADRS				=>	wMEM_ADRS				,	--	: in	std_logic_vector(23 downto 0);	-- 
		MEM_DATA				=>	wMEM_DATA				,	--	: inout	std_logic_vector(31 downto 0);	-- 
		MEM_CEn					=>	wMEM_CEn				,	--	: in	std_logic;			-- SRAM03 /CE
		MEM_OEn					=>	wMEM_OEn				,	--	: in	std_logic;			-- SRAM03 /OE
		MEM_WE0n				=>	wMEM_WE0n				,	--	: in	std_logic;			-- SRAM0 /WE
		MEM_WE1n				=>	wMEM_WE1n				,	--	: in	std_logic;			-- SRAM1 /WE
		MEM_WE2n				=>	wMEM_WE2n				,	--	: in	std_logic;			-- SRAM2 /WE
		MEM_WE3n				=>	wMEM_WE3n				,	--	: in	std_logic			-- SRAM3 /WE
			
		-- external interfa		=>				,	--ce
		-- Analog out		=        >				,	--
		DAC_DATA				=>	DAC_DATA				,	--			:	out	std_logic							;
		DAC_LDAC					=>	DAC_LDAC					,	--			:	out	std_logic							;
		DAC_CLK					=>	DAC_CLK					,	--			:	out	std_logic							;
		DAC_CS1					=>	DAC_CS1					,	--			:	out	std_logic							;
		DAC_CS2					=>	DAC_CS2					,	--			:	out	std_logic							;
		
		-- Analog in		=        >	-- Analog in				,	--
		ADC_CLK					=>	ADC_CLK					,	--			:	out	std_logic							;
		ADC_DOUT				=>	ADC_DIN					,	--			:	out	std_logic							;
		ADC_DIN					=>	ADC_DOUT					,	--			:	in	std_logic							;
		ADC_CS					=>	ADC_CS						,	--			:	out	std_logic							;
		
		-- LED		=                >	-- LED		=  			,	--
		LED						=>	wLED							,	--			:	out	std_logic_vector(7 downto 0)		;
		
		-- Digital IO		=            >	-- Digital IO					,	--
		DIGITAL_IO				=>	DIGITAL_IO					--			:	inout	std_logic_vector(15 downto 0)		
		
		
	);

				 
	
	-- SDRAM
	----.zs_ba_from_the_sdram_0({DRAM_BA_1,DRAM_BA_0}),
	SDRAM_BA_1		<=	wSDRAM_BA(1)		;
	SDRAM_BA_0		<=	wSDRAM_BA(0)		;
	----.zs_dqm_from_the_sdram_0({DRAM_UDQM,DRAM_LDQM}),
	SDRAM_UDQM		<=	wSDRAM_DQM(1)		;
	SDRAM_LDQM		<=	wSDRAM_DQM(0)		;
	
	SDRAM_CLK		<=	CLK					;
	
	-- PCI interrupt
	REQN			<=	'Z'					;
	
	VGA_VSYNC		<=	wLED(0)		;
	VGA_HSYNC		<=	wLED(1)		;
	VGA_B(1)		<=	wLED(2)		;
	VGA_B(0)		<=	wLED(3)		;
	VGA_G(1)		<=	wLED(4)		;
	VGA_G(0)		<=	wLED(5)		;
	VGA_R(1)		<=	wLED(6)		;
	VGA_R(0)		<=	wLED(7)		;	
	
	
	
end	arcPRJ_TOP;










--synthesis translate_off

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your libraries here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>

entity test_bench is 
end entity test_bench;


architecture europa of test_bench is

component	PRJ_TOP	is
		port	(
				CLK							:	in	std_logic							;
				RST_L						:	in	std_logic							;
				
				-- Analog out
				DAC_DATA					:	out	std_logic							;
				DAC_LDAC					:	out	std_logic							;
				DAC_CLK						:	out	std_logic							;
				DAC_CS1						:	out	std_logic							;
				DAC_CS2						:	out	std_logic							;
				
				-- Analog in
				ADC_CLK						:	out	std_logic							;
				ADC_DOUT					:	in	std_logic							;
				ADC_DIN						:	out	std_logic							;
				ADC_CS						:	out	std_logic							;
				
				-- Digital IO
				DIGITAL_IO					:	inout	std_logic_vector(15 downto 0)		;
				
				-- SDRAM
				SDRAM_DQ					:	inout	std_logic_vector(15 downto 0)	;
				SDRAM_ADDR					:	out	std_logic_vector(12 downto 0)		;
				SDRAM_LDQM					:	out	std_logic							;
				SDRAM_UDQM					:	out	std_logic							;
				SDRAM_WE_N					:	out	std_logic							;
				SDRAM_CAS_N					:	out	std_logic							;
				SDRAM_RAS_N					:	out	std_logic							;
				SDRAM_CS_N					:	out	std_logic							;
				SDRAM_BA_0					:	out	std_logic							;
				SDRAM_BA_1					:	out	std_logic							;
				SDRAM_CLK					:	out	std_logic							;
				SDRAM_CKE					:	out	std_logic							;
				
				-- serial Flash
				FLASH_DCLK					:	out	std_logic							;
				FLASH_ASDI					:	out	std_logic							;
				FLASH_DATA					:	in	std_logic							;
				FLASH_nCS					:	out	std_logic							;
				
				-- UART
				UART_TXD					:	out	std_logic							;
				UART_RXD					:	in	std_logic							;
				
				-- VGA (LED)
				VGA_VSYNC					:	out	std_logic							;
				VGA_HSYNC					:	out	std_logic							;
				VGA_R						:	out	std_logic_vector(1 downto 0)		;
				VGA_G						:	out	std_logic_vector(1 downto 0)		;
				VGA_B						:	out	std_logic_vector(1 downto 0)		;
				
				-- switch
				SW_SLIDE					:	in	std_logic_vector(3 downto 0)		;
				SW_TACT						:	in	std_logic_vector(2 downto 0)		;
				
				-- PCI master
				REQN		: OUT STD_LOGIC;
				GNTN		: in STD_LOGIC;
				
				-- PCI interface
				idsel	: IN STD_LOGIC;
				
				cben	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
				clk_pci: IN STD_LOGIC;
				framen	: IN STD_LOGIC;
				irdyn	: IN STD_LOGIC;
				intan	: OUT STD_LOGIC;
				--serrn	: OUT STD_LOGIC;
				serrn	: INOUT STD_LOGIC;
				
				perrn	: OUT STD_LOGIC;
				rstn	: IN STD_LOGIC;
				devseln	: OUT STD_LOGIC;
				trdyn	: OUT STD_LOGIC;
				stopn	: OUT STD_LOGIC;
				ad	: INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
				par	: INOUT STD_LOGIC
				
				);
	end component	PRJ_TOP;
	
	
component pci_tb is 
           port (
                 -- inputs:
                    signal clk_0 : IN STD_LOGIC;

                 -- outputs:
                    signal ad : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cben : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal clk_pci_compiler_0 : OUT STD_LOGIC;
                    signal devseln : INOUT STD_LOGIC;
                    signal framen : INOUT STD_LOGIC;
                    signal idsel : OUT STD_LOGIC;
                    signal intan : INOUT STD_LOGIC;
                    signal irdyn : INOUT STD_LOGIC;
                    signal par : INOUT STD_LOGIC;
                    signal perrn : INOUT STD_LOGIC;
                    signal rstn : OUT STD_LOGIC;
                    signal serrn : INOUT STD_LOGIC;
                    signal stopn : INOUT STD_LOGIC;
                    signal trdyn : INOUT STD_LOGIC
                 );
end component pci_tb;

	signal ADC_CLK  :  STD_LOGIC;
	signal ADC_CS  :  STD_LOGIC;
	signal ADC_DIN  :  STD_LOGIC;
	signal ADC_DOUT  :  STD_LOGIC;
	signal DAC_CLK  :  STD_LOGIC;
	signal DAC_CS1  :  STD_LOGIC;
	signal DAC_CS2  :  STD_LOGIC;
	signal DAC_DATA  :  STD_LOGIC;
	signal DAC_LDAC  :  STD_LOGIC;
	signal DIGITAL_IO  :  STD_LOGIC_VECTOR (15 DOWNTO 0);
	signal LED  :  STD_LOGIC_VECTOR (7 DOWNTO 0);
	signal NpmBeginTransfer_o_pci_compiler_0 :  STD_LOGIC;
	signal ad_pci_compiler_0 :  STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal cben_pci_compiler_0 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
	signal clk :  STD_LOGIC;
	signal clk_0 :  STD_LOGIC;
	signal clk_pci_compiler_0 :  STD_LOGIC;
	signal devseln_pci_compiler_0 :  STD_LOGIC;
	signal framen_pci_compiler_0 :  STD_LOGIC;
	signal idsel_pci_compiler_0 :  STD_LOGIC;
	signal intan_pci_compiler_0 :  STD_LOGIC;
	signal irdyn_pci_compiler_0 :  STD_LOGIC;
	signal par_pci_compiler_0 :  STD_LOGIC;
	signal perrn_pci_compiler_0 :  STD_LOGIC;
	signal reset_n :  STD_LOGIC;
	signal rstn_pci_compiler_0 :  STD_LOGIC;
	signal serrn_pci_compiler_0 :  STD_LOGIC;
	signal stopn_pci_compiler_0 :  STD_LOGIC;
	signal trdyn_pci_compiler_0 :  STD_LOGIC;
	
	
	signal		RST_L						:	 	std_logic							;
	signal		SDRAM_DQ					:		std_logic_vector(15 downto 0)	;
	signal		SDRAM_ADDR					:	 	std_logic_vector(12 downto 0)		;
	signal		SDRAM_LDQM					:	 	std_logic							;
	signal		SDRAM_UDQM					:	 	std_logic							;
	signal		SDRAM_WE_N					:	 	std_logic							;
	signal		SDRAM_CAS_N					:	 	std_logic							;
	signal		SDRAM_RAS_N					:	 	std_logic							;
	signal		SDRAM_CS_N					:	 	std_logic							;
	signal		SDRAM_BA_0					:	 	std_logic							;
	signal		SDRAM_BA_1					:	 	std_logic							;
	signal		SDRAM_CLK					:	 	std_logic							;
	signal		SDRAM_CKE					:	 	std_logic							;
	
	signal		FLASH_DCLK					:	 	std_logic							;
	signal		FLASH_ASDI					:	 	std_logic							;
	signal		FLASH_DATA					:	 	std_logic							;
	signal		FLASH_nCS					:	 	std_logic							;
	
	signal		UART_TXD					:	 	std_logic							;
	signal		UART_RXD					:	 	std_logic							;
	
	signal		VGA_VSYNC					:	 	std_logic							;
	signal		VGA_HSYNC					:	 	std_logic							;
	signal		VGA_R						:	 	std_logic_vector(1 downto 0)		;
	signal		VGA_G						:	 	std_logic_vector(1 downto 0)		;
	signal		VGA_B						:	 	std_logic_vector(1 downto 0)		;
	
	signal		SW_SLIDE					:		std_logic_vector(3 downto 0)		;
	signal		SW_TACT						:		std_logic_vector(2 downto 0)		;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your component and signal declaration here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


begin

  --Set us up the Dut
  DUT : PRJ_TOP
    port map(
	
				CLK						=>	CLK								,		--:	in	std_logic							;
				RST_L					=>	RST_L							,		--:	in	std_logic							;

				-- Analog out	^           =>	-- Analog out	^  				,		--
				DAC_DATA				=>	DAC_DATA						,		--	:	out	std_logic							;
				DAC_LDAC				=>	DAC_LDAC						,		--	:	out	std_logic							;
				DAC_CLK					=>	DAC_CLK							,		--	:	out	std_logic							;
				DAC_CS1					=>	DAC_CS1							,		--	:	out	std_logic							;
				DAC_CS2					=>	DAC_CS2							,		--	:	out	std_logic							;

				-- Analog in	^           =>	-- Analog in	^  				,		--
				ADC_CLK					=>	ADC_CLK							,		--	:	out	std_logic							;
				ADC_DOUT				=>	ADC_DOUT						,		--	:	out	std_logic							;
				ADC_DIN					=>	ADC_DIN							,		--	:	in	std_logic							;
				ADC_CS					=>	ADC_CS							,		--	:	out	std_logic							;

				-- Digital IO	^           =>	-- Digital IO	^  				,		--
				DIGITAL_IO				=>	DIGITAL_IO						,		--	:	inout	std_logic_vector(15 downto 0)		;

				-- SDRAM	^               =>	-- SDRAM	^      				,		--
				SDRAM_DQ				=>	SDRAM_DQ						,		--	:	inout	std_logic_vector(15 downto 0)	;
				SDRAM_ADDR				=>	SDRAM_ADDR						,		--		:	out	std_logic_vector(12 downto 0)		;
				SDRAM_LDQM				=>	SDRAM_LDQM						,		--		:	out	std_logic							;
				SDRAM_UDQM				=>	SDRAM_UDQM						,		--		:	out	std_logic							;
				SDRAM_WE_N				=>	SDRAM_WE_N						,		--		:	out	std_logic							;
				SDRAM_CAS_N				=>	SDRAM_CAS_N						,		--		:	out	std_logic							;
				SDRAM_RAS_N				=>	SDRAM_RAS_N						,		--		:	out	std_logic							;
				SDRAM_CS_N				=>	SDRAM_CS_N						,		--		:	out	std_logic							;
				SDRAM_BA_0				=>	SDRAM_BA_0						,		--		:	out	std_logic							;
				SDRAM_BA_1				=>	SDRAM_BA_1						,		--		:	out	std_logic							;
				SDRAM_CLK				=>	SDRAM_CLK						,		--	:	out	std_logic							;
				SDRAM_CKE				=>	SDRAM_CKE						,		--	:	out	std_logic							;

				-- serial Flash	^       =>	-- serial Flash					,		--
				FLASH_DCLK				=>	FLASH_DCLK						,		--	:	out	std_logic							;
				FLASH_ASDI				=>	FLASH_ASDI						,		--	:	in	std_logic							;
				FLASH_DATA				=>	FLASH_DATA						,		--	:	out	std_logic							;
				FLASH_nCS				=>	FLASH_nCS						,		--	:	out	std_logic							;

				-- UART	^               =>	-- UART	^      				,		--
				UART_TXD				=>	UART_TXD						,		--	:	out	std_logic							;
				UART_RXD				=>	UART_RXD						,		--	:	in	std_logic							;

				-- VGA (LED)	^           =>	-- VGA (LED)	^  				,		--
				VGA_VSYNC				=>	VGA_VSYNC						,		--	:	out	std_logic							;
				VGA_HSYNC				=>	VGA_HSYNC						,		--	:	out	std_logic							;
				VGA_R					=>	VGA_R							,		--:	out	std_logic_vector(1 downto 0)		;
				VGA_G					=>	VGA_G							,		--:	out	std_logic_vector(1 downto 0)		;
				VGA_B					=>	VGA_B							,		--:	out	std_logic_vector(1 downto 0)		;
				
				SW_SLIDE				=>	SW_SLIDE						,
				SW_TACT					=>	SW_TACT							,
				
				
				-- PCI master
				REQN					=>	open							,		--	: OUT STD_LOGIC;
				GNTN					=>	'1'								,		--	: in STD_LOGIC;

				-- PCI interface
				idsel					=>	idsel_pci_compiler_0			,		--: IN STD_LOGIC;

				cben					=>	cben_pci_compiler_0				,		--: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
				clk_pci					=>	clk_pci_compiler_0				,		-- IN STD_LOGIC;
				framen					=>	framen_pci_compiler_0			,		--: IN STD_LOGIC;
				irdyn					=>	irdyn_pci_compiler_0			,		--: IN STD_LOGIC;
				intan					=>	intan_pci_compiler_0			,		--: OUT STD_LOGIC;
				--serrn	: OUT STD_LOGIC;
				serrn					=>		serrn_pci_compiler_0		,		--: INOUT STD_LOGIC;

				perrn					=>	perrn_pci_compiler_0			,		--: OUT STD_LOGIC;
				rstn					=>	rstn_pci_compiler_0				,		--: IN STD_LOGIC;
				devseln					=>	devseln_pci_compiler_0			,		--: OUT STD_LOGIC;
				trdyn					=>	trdyn_pci_compiler_0			,		--: OUT STD_LOGIC;
				stopn					=>	stopn_pci_compiler_0			,		--: OUT STD_LOGIC;
				ad						=>	ad_pci_compiler_0				,		--: INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
				par						=>	par_pci_compiler_0						--	: INOUT STD_LOGIC
				
				);

  --the_pci_tb, which is an e_instance
  the_pci_tb : pci_tb
    port map(
      ad => ad_pci_compiler_0,
      cben => cben_pci_compiler_0,
      clk_pci_compiler_0 => clk_pci_compiler_0,
      devseln => devseln_pci_compiler_0,
      framen => framen_pci_compiler_0,
      idsel => idsel_pci_compiler_0,
      intan => intan_pci_compiler_0,
      irdyn => irdyn_pci_compiler_0,
      par => par_pci_compiler_0,
      perrn => perrn_pci_compiler_0,
      rstn => rstn_pci_compiler_0,
      serrn => serrn_pci_compiler_0,
      stopn => stopn_pci_compiler_0,
      trdyn => trdyn_pci_compiler_0,
      clk_0 => clk_0
    );
	
	process
	begin
		ADC_DOUT <= '0';
		loop
		   wait for 200 ns;
		   ADC_DOUT <= not ADC_DOUT;
		end loop;
	end process;
	
	
		
	process
	begin
		clk_0 <= '0';
		loop
		   wait for 15 ns;
		   clk_0 <= not clk_0;
		end loop;
	end process;
	PROCESS
		BEGIN
		reset_n <= '0';
		wait for 305 ns;
		reset_n <= '1'; 
		WAIT;
	END PROCESS;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add additional architecture here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


end europa;



--synthesis translate_on
