-- ************************************************************************* --
-- PCIターゲット8 (バースト転送対応)
-- ************************************************************************* --
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PCI_TGT8 is
	port(

	-- PCIバス信号ピン(ターゲット8で使用する信号) --
		PCICLK		: in	std_logic;			-- PCIバスクロック
		RST_n		: in	std_logic;			-- 非同期リセット
		PCIAD		: inout	std_logic_vector(31 downto 0);	-- アドレス/データバス
		C_BE_n		: in	std_logic_vector(3 downto 0);	-- PCIバスコマンド/バイトイネーブル
		FRAME_n		: in	std_logic;			-- フレーム
		IRDY_n		: in	std_logic;			-- イニシエータレディ
		DEVSEL_n	: out	std_logic;			-- デバイスセレクション
		TRDY_n		: out	std_logic;			-- ターゲットレディ
		STOP_n		: out	std_logic;			-- 転送ストップ要求
		PAR			: inout	std_logic;			-- パリティビット
		IDSEL		: in	std_logic;			-- コンフィグレーションデバイスセレクト
		INTA_n		: out	std_logic;			-- 割り込み出力 INTA#

	-- PCIバス信号ピン(ターゲット8で未使用な信号) --
		PERR_n		: out	std_logic;			-- パリティエラー
		SERR_n		: out	std_logic;			-- システムエラー
		REQ_n		: out	std_logic;			-- バス使用要求信号
		GNT_n		: in	std_logic;			-- バス使用許諾信号
		INTB_n		: out	std_logic;			-- 割り込み出力 INTB#
		INTC_n		: out	std_logic;			-- 割り込み出力 INTC#
		INTD_n		: out	std_logic;			-- 割り込み出力 INTD#

	-- ローカルバス信号ピン
		MEM_ADRS	: out	std_logic_vector(23 downto 0);	-- メモリアドレスバス
		MEM_DATA	: inout	std_logic_vector(31 downto 0);	-- メモリデータバス
		MEM_CEn		: out	std_logic;			-- SRAM0～3 /CE
		MEM_OEn		: out	std_logic;			-- SRAM0～3 /OE
		MEM_WE0n	: out	std_logic;			-- SRAM0 /WE
		MEM_WE1n	: out	std_logic;			-- SRAM1 /WE
		MEM_WE2n	: out	std_logic;			-- SRAM2 /WE
		MEM_WE3n	: out	std_logic;			-- SRAM3 /WE

	-- 外部割り込み入力ピン
		INT_IN3		: in	std_logic;			-- 割り込み入力3
		INT_IN2		: in	std_logic;			-- 割り込み入力2
		INT_IN1		: in	std_logic;			-- 割り込み入力1
		INT_IN0		: in	std_logic			-- 割り込み入力0

	);
end entity PCI_TGT8;

architecture RTL of PCI_TGT8 is


-- ************************************************************************* --
-- **********	レジスタ/定数 定義部分
-- ************************************************************************* --

-- PCIバスコマンド/アドレス/IDSELホールドレジスタ --
	signal PCI_BusCommand	: std_logic_vector(3 downto 0)		:=	(others => '0');	-- PCIバスコマンドレジスタ
	signal PCI_Address	: std_logic_vector(31 downto 0)		:=	(others => '0');	-- PCIアドレスレジスタ
	signal PCI_IDSEL	: std_logic								:=	'0'				;						-- IDSELレジスタ

-- ローカルバスシーケンサ スタートフラグ
	signal LOCAL_Bus_Start : std_logic							:=	'0';
-- ローカルバスシーケンサ データ転送完了フラグ
	signal LOCAL_DTACK     : std_logic							:=	'0';

-- トライステートバッファ制御用のフリップフロップ定義 --
	-- PCIバス信号線
	signal PCIAD_HiZ  : std_logic								:=	'1';						-- ADポート出力ドライブ制御
	signal PCIAD_Port : std_logic_vector(31 downto 0)			:=	(others => '0');	-- ADポート出力レジスタ
	signal DEVSEL_HiZ, DEVSEL_Port : std_logic					:=	'1';	-- DEVSEL#出力ドライブ制御/出力レジスタ
	signal TRDY_HiZ, TRDY_Port     : std_logic					:=	'1';	-- TRDY#出力ドライブ制御/出力レジスタ
	signal INTA_HiZ                : std_logic					:=	'1';	-- INTA#出力ドライブ制御/出力レジスタ
	signal INTA_Port               : std_logic					:=	'0';	-- INTA#出力ドライブ制御/出力レジスタ
	signal PAR_HiZ                 : std_logic					:=	'1';	-- PAR出力ドライブ制御/出力レジスタ
	signal PAR_Port                : std_logic					:=	'0';	-- PAR出力ドライブ制御/出力レジスタ
	signal STOP_HiZ, STOP_Port     : std_logic					:=	'1';	-- STOP出力ドライブ制御/出力レジスタ
		
		
	--	signal PERR_HiZ, PERR_Port     : std_logic;	-- ダミーノード(ターゲット8未使用)
	--	signal SERR_HiZ, SERR_Port     : std_logic;
	--	signal REQ_HiZ,  REQ_Port      : std_logic;
	--	signal INTB_HiZ, INTB_Port     : std_logic;
	--	signal INTC_HiZ, INTC_Port     : std_logic;
	--	signal INTD_HiZ, INTD_Port     : std_logic;

--  PCIバスコマンド(ビットパターン定義) --
	-- コンフィギュレーションサイクル
	constant PCI_CfgCycle      : std_logic_vector(3 downto 1) := ("101");
	constant PCI_CfgReadCycle  : std_logic_vector(3 downto 0) := ("1010");
	constant PCI_CfgWriteCycle : std_logic_vector(3 downto 0) := ("1011");
	-- メモリサイクル
	constant PCI_MemCycle      : std_logic_vector(3 downto 1) := ("011");
	constant PCI_MemReadCycle  : std_logic_vector(3 downto 0) := ("0110");
	constant PCI_MemWriteCycle : std_logic_vector(3 downto 0) := ("0111");
	-- I/Oサイクル
	constant PCI_IoCycle       : std_logic_vector(3 downto 1) := ("001");
	constant PCI_IoReadCycle   : std_logic_vector(3 downto 0) := ("0010");
	constant PCI_IoWriteCycle  : std_logic_vector(3 downto 0) := ("0011");

-- コンフィギュレーションレジスタ群(読み出し専用レジスタ) --
--	constant CFG_VendorID   : std_logic_vector(15 downto 0) := (X"6809");	-- ベンダID   6809h
--	constant CFG_DeviceID   : std_logic_vector(15 downto 0) := (X"8000");	-- デバイスID 8000h
--	constant CFG_Command    : std_logic_vector(15 downto 0) := (X"0000");
--	constant CFG_Status     : std_logic_vector(15 downto 0) := (X"0200");	-- DEVSEL# 中速応答
--	constant CFG_BaseClass  : std_logic_vector(7  downto 0) := (X"05");		-- 05h RAM
--	--constant CFG_BaseClass  : std_logic_vector(7  downto 0) := (X"FF");		-- 05h RAM
--	constant CFG_SubClass   : std_logic_vector(7  downto 0) := (X"00");
--	constant CFG_ProgramIF  : std_logic_vector(7  downto 0) := (X"00");
--	constant CFG_RevisionID : std_logic_vector(7  downto 0) := (X"01");		-- レビジョン 1
--	constant CFG_HeaderType : std_logic_vector(7  downto 0) := (X"00");		-- ヘッダタイプ0
--	constant CFG_Int_Pin    : std_logic_vector(7  downto 0) := (X"01");		-- INTA#のみ使用
	
	-- コンフィギュレーションレジスタ群(読み出し専用レジスタ) -- hong pci
	constant CFG_VendorID   : std_logic_vector(15 downto 0) := (X"1172");	-- ベンダID	
	constant CFG_DeviceID   : std_logic_vector(15 downto 0) := (X"0004");	-- デバイスID
	constant CFG_Command    : std_logic_vector(15 downto 0) := (X"0000");
	constant CFG_Status     : std_logic_vector(15 downto 0) := (X"0200");	-- DEVSEL# 中速応答
	constant CFG_BaseClass  : std_logic_vector(7  downto 0) := (X"FF");		-- 05h RAM
	constant CFG_SubClass   : std_logic_vector(7  downto 0) := (X"00");
	constant CFG_ProgramIF  : std_logic_vector(7  downto 0) := (X"00");
	constant CFG_RevisionID : std_logic_vector(7  downto 0) := (X"01");		-- レビジョン 1
	constant CFG_HeaderType : std_logic_vector(7  downto 0) := (X"00");		-- ヘッダタイプ0
	constant CFG_Int_Pin    : std_logic_vector(7  downto 0) := (X"01");		-- INTA#のみ使用
	
	

-- コンフィギュレーションレジスタ群(読み書きレジスタ) --
	-- コマンドレジスタ メモリイネーブルビット
	signal CFG_Cmd_Mem : std_logic						:=	'0';
	-- コマンドレジスタ I/Oイネーブルビット
	signal CFG_Cmd_Io : std_logic						:=	'0';
	-- コマンドレジスタ 割り込みディセーブルビット
	signal CFG_Cmd_IntDis : std_logic					:=	'0';
	-- ステータスレジスタ 割り込みステータスビット
	signal CFG_Sta_IntSta : std_logic					:=	'0';
	-- ベースアドレスレジスタ(メモリ空間)
	signal CFG_Base_Addr0 : std_logic_vector(31 downto 24)	:=	(others => '0');
	-- ベースアドレスレジスタ(I/O空間)
	signal CFG_Base_Addr1 : std_logic_vector(15 downto 2)		:=	(others => '0');
	-- インタラプトラインレジスタ
	signal CFG_Int_Line : std_logic_vector(7 downto 0)	:=	(others => '0');
	
		
		
-- アドレスデコードフラグ
	signal Hit_Device : std_logic			:=	'0'	;	-- デバイスヒット
	signal Hit_Memory : std_logic			:=	'0'	;	-- メモリサイクルヒット
	signal Hit_Io : std_logic				:=	'0'	;		-- I/Oサイクルヒット
	signal Hit_Config : std_logic			:=	'0'	;	-- コンフィグレーションサイクルヒット

-- PCIADバスドライブ時パリティ計算
	signal TGT_PAR    : std_logic			:=	'0'	;

-- ローカルバス トライステート制御
	signal MEM_DATA_HiZ  : std_logic		:=	'0'	;	-- メモリデータバストライステート制御
	signal MEM_DATA_Port : std_logic_vector(31 downto 0)	:=	(others => '0');	-- メモリデータバス

	
		
--  割り込み制御レジスタ群
	-- 割り込みステータス/フラグレジスタ
	signal INT_STAT3 : std_logic			:=	'0'	;
	signal INT_STAT2 : std_logic			:=	'0'	;
	signal INT_STAT1 : std_logic			:=	'0'	;
	signal INT_STAT0 : std_logic			:=	'0'	;
	-- 割り込みマスク(許可)レジスタ
	signal INT_MSK3 : std_logic			:=	'0'	;
	signal INT_MSK2 : std_logic			:=	'0'	;
	signal INT_MSK1 : std_logic			:=	'0'	;
	signal INT_MSK0 : std_logic			:=	'0'	;
	-- 割り込みステータスクリア指示レジスタ
	signal INT_CLR3 : std_logic			:=	'0'	;
	signal INT_CLR2 : std_logic			:=	'0'	;
	signal INT_CLR1 : std_logic			:=	'0'	;
	signal INT_CLR0 : std_logic			:=	'0'	;
	
	signal wPCI_CURRENT_STATE	: std_logic_vector (2 downto 0)	:=	(others => '0');	-- 現在のステート
	
		
begin


-- ************************************************************************* --
-- **********	同時処理文
-- ************************************************************************* --

-- トライステートバッファ動作
	MEM_DATA <= (others => 'Z') when MEM_DATA_HiZ = '1' else MEM_DATA_Port;
	PCIAD    <= (others => 'Z') when PCIAD_HiZ = '1'    else PCIAD_Port;
	DEVSEL_n <= 'Z'	when DEVSEL_HiZ = '1'	else DEVSEL_Port;
	TRDY_n   <= 'Z'	when TRDY_HiZ = '1'	else TRDY_Port;
	INTA_n <= 'Z'	when INTA_HiZ = '1'	else INTA_Port; INTA_Port <= '0';
	PAR    <= 'Z'	when PAR_HiZ  = '1'	else PAR_Port;
	STOP_n <= 'Z'	when STOP_HiZ = '1'	else STOP_Port;

-- 未使用ピンの状態設定(ハイインピーダンス状態に固定)
	PERR_n <= 'Z'		;	--	when PERR_HiZ = '1'	else PERR_Port; PERR_HiZ <= '1'; PERR_Port <= '0';
	SERR_n <= 'Z'		;	--	when SERR_HiZ = '1'	else SERR_Port; SERR_HiZ <= '1'; SERR_Port <= '0';
	REQ_n  <= 'Z'		;	--	when REQ_HiZ  = '1'	else REQ_Port;	REQ_HiZ  <= '0'; REQ_Port  <= '1';
	INTB_n <= 'Z'		;	--	when INTB_HiZ = '1'	else INTB_Port; INTB_HiZ <= '1'; INTB_Port <= '0';
	INTC_n <= 'Z'		;	--	when INTC_HiZ = '1'	else INTC_Port; INTC_HiZ <= '1'; INTC_Port <= '0';
	INTD_n <= 'Z'		;	--	when INTD_HiZ = '1'	else INTD_Port; INTD_HiZ <= '1'; INTD_Port <= '0';
	
-- ************************************************************************* --
-- **********	PCIターゲットシーケンサ
-- ************************************************************************* --

PCI_TGT_Seq : process( PCICLK, RST_n )

-- PCIターゲットシーケンサ ステートバリューレジスタ --
	variable PCI_CURRENT_STATE	: std_logic_vector (2 downto 0)		:=	(others => '0')	;	-- 現在のステート
	variable PCI_NEXT_STATE		: std_logic_vector (2 downto 0)	:=	(others => '0')	;	-- 次のステート

-- PCIターゲットシーケンサ ステートマシン定義
	constant BUS_IDLE		: std_logic_vector (2 downto 0) :="000";
	constant ADRS_COMPARE	: std_logic_vector (2 downto 0) :="001";
	constant BUS_BUSY		: std_logic_vector (2 downto 0) :="010";
	constant WAIT_IRDY		: std_logic_vector (2 downto 0) :="011";
	constant WAIT_LOCAL_ACK : std_logic_vector (2 downto 0) :="100";
	constant ACC_COMPLETE	: std_logic_vector (2 downto 0) :="101";
	constant DIS_CONNECT	: std_logic_vector (2 downto 0) :="110";
	constant TURN_AROUND	: std_logic_vector (2 downto 0) :="111";

begin

-- ********** リセット時動作 ********** --
	if (RST_n = '0') then	-- PCIバスリセット時(非同期リセット)

		PCI_CURRENT_STATE	:= BUS_IDLE;	-- ステートマシン IDLE状態 リセット
		PCI_NEXT_STATE		:= BUS_IDLE;	-- ステートマシン IDLE状態 リセット

		LOCAL_Bus_Start <= '0';		-- ローカルバスシーケンサ スタートフラグ クリア

		PCI_BusCommand <= (others => '0');	-- PCIバスコマンドレジスタ クリア
		PCI_Address <= (others => '0');		-- PCIバスアドレスレジスタ クリア
		PCI_IDSEL <= '0';					-- IDSELレジスタ クリア

	-- 制御出力端子をハイインピーダンス
		PCIAD_HiZ <= '1';
		DEVSEL_HiZ <= '1'; DEVSEL_Port <= '1';	-- DEVSEL#="H"
		TRDY_HiZ   <= '1'; TRDY_Port   <= '1';	-- TRDY#="H"
		STOP_HiZ   <= '1'; STOP_Port   <= '1';	-- STOP#="H"


-- ********** PCIターゲットシーケンサ ステートマシン ********** --
	elsif (PCICLK'event and PCICLK = '1') then

		PCI_CURRENT_STATE := PCI_NEXT_STATE;	-- ステートマシン制御
		case PCI_CURRENT_STATE is

	-- ********** BUS_IDLE時の動作 ********** --
		when BUS_IDLE =>	-- トランザクションの開始待ち

			if (FRAME_n = '0' and IRDY_n /= '0') then	-- トランザクション開始
				PCI_BusCommand <= C_BE_n;	-- PCIバスコマンド取得
				PCI_Address <= PCIAD;		-- アドレス取得
				PCI_IDSEL <= IDSEL;			-- IDSEL取得
				PCI_NEXT_STATE := ADRS_COMPARE;

			else	-- バスアイドル時このステートにとどまる
				PCI_NEXT_STATE := BUS_IDLE;
			end if;


	-- ********** ADRS_COMPARE時の動作 ********** --
		when ADRS_COMPARE =>	-- アドレスデコード結果を調べる

			if (Hit_Device = '1') then	-- 自分が選択された
				DEVSEL_Port <= '0'; DEVSEL_HiZ <= '0';	-- DEVLSEL#アサート
				TRDY_HiZ <= '0';	-- TRDY# を "H"にドライブ
				STOP_HiZ <= '0';	-- STOP# を "H"にドライブ
				PCI_NEXT_STATE := WAIT_IRDY;	-- イニシエータレディを待つステートへ

			else	-- 自分が選択されていない
				PCI_NEXT_STATE := BUS_BUSY;	-- トランザクションの終了を待つステートへ
			end if;


	-- ********** BUS_BUSY時の動作 ********** --
		when BUS_BUSY =>	-- トランザクション終了待ち

			if (FRAME_n = '1' and IRDY_n = '1') then	-- トランザクション終了(アイドル)
				PCI_NEXT_STATE := BUS_IDLE;	-- トランザクション開始待ちステートへ

			else	-- トランザクション中ならこのステートにとどまる
				PCI_NEXT_STATE := BUS_BUSY;
			end if;


	-- ********** WAIT_IRDY時の動作 ********** --
		when WAIT_IRDY =>	-- イニシエータレディ待ち

			if (IRDY_n = '0') then	-- イニシエータの準備完了
				if (PCI_BusCommand(0) = '0') then	-- リードサイクルのとき
					PCIAD_HiZ <= '0' ;				-- PCIAD[31:0]バスドライブ
				end if;
				LOCAL_Bus_Start <= '1';	-- ローカルバスシーケンサ スタート!
				PCI_NEXT_STATE := WAIT_LOCAL_ACK;	-- ローカルバスシーケンサ終了待ちステートへ

			else	-- イニシエータの準備がまだならこのステートにとどまる
				PCI_NEXT_STATE := WAIT_IRDY;
			end if;


	-- ********** WAIT_LOCAL_ACK時の動作 ********** --
		when WAIT_LOCAL_ACK =>	-- ローカルバスシーケンサ終了待ち

			LOCAL_Bus_Start <= '0';	-- ローカルバスシーケンサ スタートフラグ クリア

			if (LOCAL_DTACK = '1') then	-- ローカルバスシーケンサ データ転送完了
				TRDY_Port <= '0';	-- TRDY# アサート
				PCI_NEXT_STATE := ACC_COMPLETE;	-- アクセス完了ステートへ

			else	-- ローカルバスシーケンサの準備がまだならこのステートにとどまる
				PCI_NEXT_STATE := WAIT_LOCAL_ACK;
			end if;


	-- ********** ACC_COMPLETE時の動作 ********** --
		when ACC_COMPLETE =>	-- アクセス完了ステート

			TRDY_Port <= '1';		-- TRDY# ディアサート
			PCIAD_HiZ <= '1' ;		-- PCIAD[31:0]バスドライブ解放

			if (FRAME_n = '0') then			-- FRAME# = 'L'ならバースト転送要求

				if ( Hit_Memory = '1' and PCI_Address(1 downto 0) = "00"
						-- メモリ空間&アドレスインクリメントモード=リニアバースト
						-- バースト転送アドレスが最上位以外なら
						and PCI_Address(23 downto 2) /= "1111111111111111111111") then
									-- アドレスが最終アドレスではない
					PCI_Address(23 downto 2) <= PCI_Address(23 downto 2) + '1';
					PCI_NEXT_STATE := WAIT_IRDY;	-- イニシエータレディを待つステートへ

				else
					STOP_Port <= '0';	-- STOP# アサート
					PCI_NEXT_STATE := DIS_CONNECT;	-- ディスコネクトステートへ
				end if;

			else	-- 単一データフェーズのトランザクションの時
				DEVSEL_Port <= '1';		-- DEVSEL#ディアサート
				PCI_NEXT_STATE := TURN_AROUND;	--  ターンアラウンドステートへ
			end if;


	-- ********** DIS_CONNECT時の動作 ********** --
		when DIS_CONNECT =>		-- ディスコネクト処理

			if (FRAME_n = '1') then	-- イニシエータがSTOP#を認識
				DEVSEL_Port <= '1';	-- DEVSEL# ディアサート
				STOP_Port <= '1';	-- STOP# ディアサート
				PCI_NEXT_STATE := TURN_AROUND;	-- 次はTURN_AROUNDステートへ

			else	-- イニシエータがSTOP#を認識していなければこのステートにとどまる
				PCI_NEXT_STATE := DIS_CONNECT;
			end if;


	-- ********** TURN_AROUND時の動作 ********** --
		when TURN_AROUND =>		-- ターンアラウンドステート

			DEVSEL_HiZ <= '1';			-- DEVSEL#ドライブ解放
			TRDY_HiZ <= '1';			-- TRDY#ドライブ解放
			STOP_HiZ <= '1';			-- STOP#ドライブ解放
			PCI_NEXT_STATE := BUS_IDLE;	-- トランザクション開始待ちステートへ


	-- ****************************************** --
		when others => null;	-- これ以外の値では何もしない場合でも必ず入れる

	end case;

	end if;

	wPCI_CURRENT_STATE	<=	PCI_CURRENT_STATE	;
	
end process PCI_TGT_Seq;



-- ************************************************************************* --
-- **********	ローカルバスシーケンサ
-- ************************************************************************* --
MEM_ADRS(23 downto 2) <= PCI_Address(23 downto 2);
MEM_ADRS(1 downto 0) <=	"00";
LOCAL_BUS_Seq : process(PCICLK, RST_n)

-- ローカルバスシーケンサ ステートバリューレジスタ --
	variable LOCAL_CURRENT_STATE : std_logic_vector (2 downto 0)	:= (others => '0')	;	-- 現在のステート
	variable LOCAL_NEXT_STATE : std_logic_vector (2 downto 0)	:= (others => '0')	;		-- 次のステート

-- ローカルバスシーケンサ ステートマシン定義
	constant LOCAL_IDLE			: std_logic_vector(2 downto 0) := "000";
	constant LOCAL_MEM_ACCESS	: std_logic_vector(2 downto 0) := "001";
	constant LOCAL_IO_ACCESS	: std_logic_vector(2 downto 0) := "010";
	constant LOCAL_CFG_ACCESS	: std_logic_vector(2 downto 0) := "011";
	constant LOCAL_STATE_COMP	: std_logic_vector(2 downto 0) := "100";

-- メモリアクセス ウェイトカウンタ
	variable WAIT_Count : std_logic_vector(3 downto 0)		:=	(others => '0');

begin

-- ********** リセット時動作 ********** --
	if (RST_n = '0') then	-- PCIバスリセットがアサートされたとき

		-- ステートバリューレジスタクリア
		LOCAL_CURRENT_STATE := (others => '0');	-- ローカルバスシーケンサ リセット
		LOCAL_NEXT_STATE := (others => '0');	-- ローカルバスシーケンサ リセット

		-- コンフィグレーションレジスタ リード/ライトレジスタ インタラプトライン クリア
		CFG_Cmd_Mem <= '0';
		CFG_Cmd_Io  <= '0';
		CFG_Cmd_IntDis <= '0';
		CFG_Base_Addr0 <= (others => '0');
		CFG_Base_Addr1 <= (others => '0');
		CFG_Int_Line <= (others => '0');

		-- ローカルバス制御線ディセーブル
		MEM_CEn  <= '1';	-- SRAM0～3 /CE
		MEM_OEn  <= '1';	-- SRAM0～3 /OE
		MEM_WE0n <= '1';	-- SRAM0 /WE
		MEM_WE1n <= '1';	-- SRAM1 /WE
		MEM_WE2n <= '1';	-- SRAM2 /WE
		MEM_WE3n <= '1';	-- SRAM3 /WE
		MEM_DATA_HiZ  <= '0';	-- データバス出力方向

		PCIAD_Port <= (others => '0');		-- AD出力レジスタ クリア
		MEM_DATA_Port <= (others => '0');	-- MEM_DATA出力レジスタ クリア

		-- メモリアクセス ウェイトカウンタ クリア
		WAIT_Count := (others => '0');

		-- ローカルバスシーケンサ データ転送完了フラグ クリア
		LOCAL_DTACK <= '0';

		-- 割り込み制御レジスタ --
		INT_MSK3 <= '0';	-- 割り込みマスクレジスタ クリア
		INT_MSK2 <= '0';
		INT_MSK1 <= '0';
		INT_MSK0 <= '0';
		INT_CLR3 <= '0';	-- 割り込みステータスクリア指示信号 クリア
		INT_CLR2 <= '0';
		INT_CLR1 <= '0';
		INT_CLR0 <= '0';


-- ********** ローカルバスシーケンサ ステートマシン ********** --
	elsif (PCICLK'event and PCICLK = '1') then

		LOCAL_CURRENT_STATE := LOCAL_NEXT_STATE;
		case LOCAL_CURRENT_STATE is

	-- ********** LOCAL_IDLE時の動作 ********** --
		when LOCAL_IDLE =>	-- ローカルバスシーケンサ スタート指示待ち

			if (LOCAL_Bus_Start = '1' ) then	-- ローカルバスシーケンサ スタート!

				if (Hit_Config = '1') then	-- コンフィグレーションサイクルヒット
					LOCAL_NEXT_STATE := LOCAL_CFG_ACCESS;	-- コンフィグレーションステートへ
				end if;
				if (Hit_Memory = '1') then	-- メモリサイクルヒット
					LOCAL_NEXT_STATE := LOCAL_MEM_ACCESS;	-- メモリアクセスステートへ
				end if;
				if (Hit_Io = '1') then		-- I/Oサイクルヒット
					LOCAL_NEXT_STATE := LOCAL_IO_ACCESS;	-- I/Oアクセスステートへ
				end if;

			else	-- ローカルバスシーケンサ スタートフラグがまだならこのステートにとどまる

				LOCAL_NEXT_STATE := LOCAL_IDLE;
			end if;


	-- ********** LOCAL_MEM_ACCESS時の動作 ********** --
		when LOCAL_MEM_ACCESS =>

			case WAIT_Count is
			when X"0" =>	-- ウェイトカウンタ0クロック目
				MEM_CEn <= '0';		-- SRAM /CE アサート
				if (PCI_BusCommand(0) = '1') then	-- メモリライトサイクル
					MEM_DATA_Port(31 downto 0) <= PCIAD(31 downto 0); -- ライトデータ
				else						-- メモリリードサイクル
					MEM_DATA_HiZ <= '1';	-- ローカルデータバス入力方向
				end if;
				LOCAL_NEXT_STATE := LOCAL_MEM_ACCESS;	-- メモリアクセスはまだ終わらない

			when X"1" =>	-- ウェイトカウンタ1クロック目
				if (PCI_BusCommand(0) = '1') then	-- メモリライトサイクル
					MEM_WE3n <= C_BE_n(3);	-- バイトイネーブルを/WEに出力
					MEM_WE2n <= C_BE_n(2);
					MEM_WE1n <= C_BE_n(1);
					MEM_WE0n <= C_BE_n(0);
				else						-- メモリリードサイクル
					MEM_OEn <= '0';			-- SRAM /OE アサート
				end if;
				LOCAL_NEXT_STATE := LOCAL_MEM_ACCESS;	-- メモリアクセスはまだ終わらない

			when X"4" =>	-- ウェイトカウンタ4クロック目
				if (PCI_BusCommand(0) = '1') then	-- メモリライトサイクル
					MEM_WE3n <= '1';	-- SRAM /WE ディセーブル
					MEM_WE2n <= '1';
					MEM_WE1n <= '1';
					MEM_WE0n <= '1';
				else									-- メモリリードサイクル
					PCIAD_Port(31 downto 0) <= MEM_DATA;-- SRAMデータをADバスに出力
					MEM_OEn <= '1';						-- SRAM /OE ディアサート
				end if;
				LOCAL_DTACK <= '1';		-- ローカルバスシーケンサ データ転送完了フラグ セット
				LOCAL_NEXT_STATE := LOCAL_STATE_COMP;	-- メモリアクセス完了

			when others =>	-- そのままの状態でウェイト時間が経過するのを待つ
				LOCAL_NEXT_STATE := LOCAL_MEM_ACCESS;	-- メモリアクセスはまだ終わらない

			end case;

			WAIT_Count := WAIT_Count + '1';	-- ウェイトカウント + 1


		-- ********** LOCAL_IO_ACCESS時の動作 ********** --
		when LOCAL_IO_ACCESS =>

			if (PCI_BusCommand(0) = '1') then	-- ライトサイクル

				case PCI_Address(1 downto 0) is
					when "00" =>				-- 割り込みステータスレジスタへのアクセス
						INT_CLR3 <= PCIAD(3);		-- ステータスクリア #3
						INT_CLR2 <= PCIAD(2);		-- ステータスクリア #2
						INT_CLR1 <= PCIAD(1);		-- ステータスクリア #1
						INT_CLR0 <= PCIAD(0);		-- ステータスクリア #0

					when "10" =>				-- 割り込みマスクレジスタへのアクセス
						INT_MSK3 <= PCIAD(19);		-- 割り込みマスク #3
						INT_MSK2 <= PCIAD(18);		-- 割り込みマスク #2
						INT_MSK1 <= PCIAD(17);		-- 割り込みマスク #1
						INT_MSK0 <= PCIAD(16);		-- 割り込みマスク #0

					when others => null;		-- それ以外のアクセスは無視
				end case;

			else	-- リードサイクル

				case PCI_Address(1 downto 0) is
					when "00" =>				-- 割り込みステータスレジスタへのアクセス
						PCIAD_Port(31 downto  4) <= (others => '0');
						PCIAD_Port(3)  <= INT_STAT3;-- 割り込み3ステータス
						PCIAD_Port(2)  <= INT_STAT2;-- 割り込み2ステータス
						PCIAD_Port(1)  <= INT_STAT1;-- 割り込み1ステータス
						PCIAD_Port(0)  <= INT_STAT0;-- 割り込み0ステータス

					when "10" =>				-- 割り込みマスクレジスタへのアクセス
						PCIAD_Port(31 downto 20) <= (others => '0');
						PCIAD_Port(19) <= INT_MSK3;	-- 割り込み3マスク
						PCIAD_Port(18) <= INT_MSK2;	-- 割り込み2マスク
						PCIAD_Port(17) <= INT_MSK1;	-- 割り込み1マスク
						PCIAD_Port(16) <= INT_MSK0;	-- 割り込み0マスク
						PCIAD_Port(15 downto  4) <= (others => '0');

					when others =>				-- それ以外のアクセスは0を返す
						PCIAD_Port(31 downto 0) <= (others => '0');
				end case;

			end if;

			LOCAL_DTACK <= '1';
			LOCAL_NEXT_STATE := LOCAL_STATE_COMP;


	-- ********** LOCAL_CFG_ACCESS時の動作 ********** --
		when LOCAL_CFG_ACCESS =>	-- コンフィグレーションサイクル

			if (PCI_BusCommand(0) = '1' ) then	-- コンフィグレーションライトサイクル

				case PCI_Address(7 downto 2) is

				when "000001" =>	-- コマンドレジスタ
					if (C_BE_n(1) = '0') then
						CFG_Cmd_IntDis <= PCIAD(10);-- 割り込みディセーブル
					end if;
					if (C_BE_n(0) = '0') then
						CFG_Cmd_Mem <= PCIAD(1);	-- メモリイネーブル
						CFG_Cmd_Io  <= PCIAD(0);	-- I/Oイネーブル
					end if;

				when "000100" =>	-- ベースアドレスレジスタ0
					if (C_BE_n(3) = '0') then
						CFG_Base_Addr0(31 downto 24) <= PCIAD(31 downto 24);
					end if;

				when "000101" =>	-- ベースアドレスレジスタ1
					if (C_BE_n(1) = '0') then
						CFG_Base_Addr1(15 downto  8) <= PCIAD(15 downto  8);
					end if;
					if (C_BE_n(0) = '0') then
						CFG_Base_Addr1( 7 downto  2) <= PCIAD( 7 downto  2);
					end if;

				when "001111" =>	-- 割り込みラインレジスタ
					if (C_BE_n(0) = '0') then
						CFG_Int_Line(7 downto 0) <= PCIAD(7 downto 0);
					end if;

				when others => null;	-- これ以外の値では何もしない場合でも必ず入れる

				end case;


			else	-- コンフィグレーションリードサイクル

				case PCI_Address(7 downto 2) is

				when "000000" =>	-- ベンダID/デバイスID
					PCIAD_Port(31 downto 16) <= CFG_DeviceID;
					PCIAD_Port(15 downto  0) <= CFG_VendorID;

				when "000001" =>	-- コマンド/ステータスレジスタ
					PCIAD_Port(31 downto 20) <= CFG_Status(15 downto  4);
					PCIAD_Port(19)           <= CFG_Sta_IntSta;
					PCIAD_Port(18 downto 16) <= CFG_Status( 2 downto  0);
					PCIAD_Port(15 downto 11) <= CFG_Command(15 downto 11);
					PCIAD_Port(10)           <= CFG_Cmd_IntDis;
					PCIAD_Port( 9 downto  2) <= CFG_Command( 9 downto  2);
					PCIAD_Port(1)            <= CFG_Cmd_Mem;
					PCIAD_Port(0)            <= CFG_Cmd_Io;

				when "000010" =>	-- クラスコード
					PCIAD_Port(31 downto 24) <= CFG_BaseClass;
					PCIAD_Port(23 downto 16) <= CFG_SubClass;
					PCIAD_Port(15 downto  8) <= CFG_ProgramIF;
					PCIAD_Port( 7 downto  0) <= CFG_RevisionID;

				when "000011" =>	-- ヘッダタイプほか
					PCIAD_Port(31 downto 24) <= (others => '0');
					PCIAD_Port(23 downto 16) <= CFG_HeaderType;
					PCIAD_Port(15 downto  0) <= (others => '0');

				when "000100" =>	-- ベースアドレスレジスタ0
					PCIAD_Port(31 downto 24) <= CFG_Base_Addr0;
					PCIAD_Port(23 downto  0) <= (others => '0');

				when "000101" =>	-- ベースアドレスレジスタ1
					PCIAD_Port(31 downto 16) <= (others => '0');
					PCIAD_Port(15 downto  2) <= CFG_Base_Addr1;
					PCIAD_Port( 1 downto  0) <= "01";

				when "001011" =>	-- サブシステムベンダID/サブシステムID
					PCIAD_Port(31 downto 16) <= CFG_DeviceID;
					PCIAD_Port(15 downto  0) <= CFG_VendorID;

				when "001111" =>	-- 割り込み関連レジスタ
					PCIAD_Port(31 downto 16) <= (others => '0');
					PCIAD_Port(15 downto  8) <= CFG_Int_Pin;
					PCIAD_Port( 7 downto  0) <= CFG_Int_Line;

				when others => -- その他のレジスタ
					PCIAD_Port <= (others => '0');	-- すべて0を返す

				end case;

			end if;

			LOCAL_DTACK <= '1';		-- ローカルバスシーケンサ データ転送完了フラグ セット
			LOCAL_NEXT_STATE := LOCAL_STATE_COMP;


	-- ********** LOCAL_STATE_COMP時の動作 ********** --
		when LOCAL_STATE_COMP =>	-- ローカルバスアクセス完了

			INT_CLR3 <= '0';		-- 割り込みクリア指示信号クリア
			INT_CLR2 <= '0';
			INT_CLR1 <= '0';
			INT_CLR0 <= '0';

			MEM_CEn <= '1';			-- SRAM /CE ディアサート
			MEM_DATA_HiZ <= '0';	-- ローカルデータバス出力方向
			WAIT_Count := (others => '0');
			LOCAL_DTACK <= '0';		-- ローカルバスシーケンサ データ転送完了フラグ クリア
			LOCAL_NEXT_STATE := LOCAL_IDLE;


	-- ********************************************** --
		when others => null;	-- これ以外の値では何もしない場合でも必ず入れる

		end case;

	end if;

end process LOCAL_BUS_Seq;



-- ************************************************************************* --
-- **********	割り込みコントローラ
-- ************************************************************************* --

INT_Ctrl : process(PCICLK, RST_n)
	variable INT_IN3_flg1 : std_logic		:=	'0'	;	-- 割り込み入力状態保存フラグ
	variable INT_IN2_flg1 : std_logic		:=	'0'	;
	variable INT_IN1_flg1 : std_logic		:=	'0'	;
	variable INT_IN0_flg1 : std_logic		:=	'0'	;
	variable INT_IN3_flg0 : std_logic		:=	'0'	;	-- 割り込み入力状態保存フラグ
	variable INT_IN2_flg0 : std_logic		:=	'0'	;
	variable INT_IN1_flg0 : std_logic		:=	'0'	;
	variable INT_IN0_flg0 : std_logic		:=	'0'	;
begin
	if (RST_n = '0') then	-- PCIバスリセットがアサートされたとき

		INTA_HiZ  <='1';	-- INTA# ハイインピーダンス
		CFG_Sta_IntSta <= '0';

		INT_STAT3 <= '0';	-- 割り込み要求レジスタ クリア
		INT_STAT2 <= '0';
		INT_STAT1 <= '0';
		INT_STAT0 <= '0';
		INT_IN3_flg1 := '0';	-- 割り込み入力フラグ クリア
		INT_IN2_flg1 := '0';
		INT_IN1_flg1 := '0';
		INT_IN0_flg1 := '0';
		INT_IN3_flg0 := '0';
		INT_IN2_flg0 := '0';
		INT_IN1_flg0 := '0';
		INT_IN0_flg0 := '0';

	elsif (PCICLK'event and PCICLK = '1') then

	-- **********	割り込みコントローラ	 ********** --
		if (INT_CLR3 = '1') then
			INT_STAT3  <= '0';	-- 割り込みステータスレジスタ3クリア
		elsif (INT_IN3_flg1 = '1' and INT_IN3_flg0 = '0') then	-- 外部割り込み入力3 立ち下りエッジ
			INT_STAT3  <= '1';	-- 割り込みステータスレジスタ3
		end if;
		if (INT_CLR2 = '1') then
			INT_STAT2  <= '0';	-- 割り込みステータスレジスタ2クリア
		elsif (INT_IN2_flg1 = '1' and INT_IN2_flg0 = '0') then	-- 外部割り込み入力2 立ち下りエッジ
			INT_STAT2  <= '1';	-- 割り込みステータスレジスタ2
		end if;
		if (INT_CLR1 = '1') then
			INT_STAT1  <= '0';	-- 割り込みステータスレジスタ1クリア
		elsif (INT_IN1_flg1 = '1' and INT_IN1_flg0 = '0') then	-- 外部割り込み入力1 立ち下りエッジ
			INT_STAT1  <= '1';	-- 割り込みステータスレジスタ1
		end if;
		if (INT_CLR0 = '1') then
			INT_STAT0  <= '0';	-- 割り込みステータスレジスタ0クリア
		elsif (INT_IN0_flg1 = '1' and INT_IN0_flg0 = '0') then	-- 外部割り込み入力0 立ち下りエッジ
			INT_STAT0  <= '1';	-- 割り込みステータスレジスタ0
		end if;

		if (
			(CFG_Cmd_IntDis = '0')	-- 割り込みディセーブルビットがセットされていない
		) and (
			(INT_STAT3 = '1' and INT_MSK3 = '1') -- チャネル3割り込み発生&割り込み可
			or
			(INT_STAT2 = '1' and INT_MSK2 = '1') -- チャネル2割り込み発生&割り込み可
			or
			(INT_STAT1 = '1' and INT_MSK1 = '1') -- チャネル1割り込み発生&割り込み可
			or
			(INT_STAT0 = '1' and INT_MSK0 = '1') -- チャネル0割り込み発生&割り込み可
		) then
			INTA_HiZ <= '0';	-- INTA#ドライブ開始(アサート)
			CFG_Sta_IntSta <= '1';	-- 割り込み出力中
		else
			INTA_HiZ <= '1';	-- ハイインピーダンス状態
			CFG_Sta_IntSta <= '0';
		end if;

		INT_IN3_flg1 := INT_IN3_flg0;
		INT_IN2_flg1 := INT_IN2_flg0;
		INT_IN1_flg1 := INT_IN1_flg0;
		INT_IN0_flg1 := INT_IN0_flg0;
		INT_IN3_flg0 := INT_IN3;	-- 現在の割り込み入力状態の保存
		INT_IN2_flg0 := INT_IN2;
		INT_IN1_flg0 := INT_IN1;
		INT_IN0_flg0 := INT_IN0;

	end if;

end process INT_Ctrl;





-- ************************************************************************* --
-- **********	アドレスデコーダ
-- ************************************************************************* --

-- メモリサイクルorコンフィグレーションサイクルヒット = 自分が選択されている
Hit_Device <= Hit_Memory or Hit_Config or Hit_Io;

Address_Decoder : process (
				PCI_IDSEL,		-- コンフィグレーションデバイスセレクト
				PCI_Address,	-- PCIバスアドレス
				PCI_BusCommand,	-- バスコマンド
				CFG_Base_Addr0,	-- ベースアドレスレジスタ0
				CFG_Base_Addr1,	-- ベースアドレスレジスタ1
				CFG_Cmd_Mem,	-- コンフィグレーションレジスタ メモリイネーブルビット
				CFG_Cmd_Io		-- コンフィグレーションレジスタ I/Oイネーブルビット
				)
begin

	-- メモリ空間へのアクセスアドレスとベースアドレス0が一致したか
	if (
			PCI_BusCommand(3 downto 1) = PCI_MemCycle	-- メモリサイクル
		) and (
			PCI_Address(31 downto 24) = CFG_Base_Addr0	-- ベースアドレス0と比較
		) and (
			CFG_Cmd_Mem = '1'	-- コンフィグレーション コマンドレジスタ メモリイネーブルビット
		)
	then
		Hit_Memory <= '1';	-- メモリサイクルヒット
	else
		Hit_Memory <= '0';
	end if;

	-- I/O空間へのアクセスアドレスとベースアドレス1が一致したか
	if (
			PCI_BusCommand(3 downto 1) = PCI_IoCycle	-- I/Oサイクル
		) and (
			CFG_Cmd_Io = '1' -- コンフィグレーション コマンドレジスタ I/Oイネーブルビット
		) and (
			PCI_Address(31 downto 16) = X"0000"		-- 上位16ビットが0か
		) and (
			PCI_Address(15 downto 2 ) = CFG_Base_Addr1(15 downto 2)
		)
	then
		Hit_Io <= '1';	-- I/Oサイクルヒット
	else
		Hit_Io <= '0';
	end if;

	-- コンフィグレーション空間へのアクセスかどうかを認識
	if (
			PCI_BusCommand(3 downto 1) = PCI_CfgCycle	-- コンフィグレーションサイクル
		) and (
			PCI_IDSEL = '1'		-- 自分が選択されているか
		) and (
			PCI_Address(10 downto 8) = "000"	-- ファンクション番号0のみ
		) and (
			PCI_Address(1 downto 0) = "00"		-- タイプ0のみ
		)
	then
		Hit_Config <= '1';	-- コンフィグレーションサイクルヒット
	else
		Hit_Config <= '0';
	end if;

end process Address_Decoder;



-- ************************************************************************* --
-- **********	パリティジェネレータ
-- ************************************************************************* --

-- ***** パリティ生成 ***** --
PCI_Parity_Gen : process (PCIAD_Port, C_BE_n)
	variable temp : std_logic		:=	'0';	-- テンポラリ
begin
	-- ターゲット パリティ生成 --
	temp := '0';
	for I in 0 to 31 loop
		temp := temp xor PCIAD_Port(I);
	end loop;
	TGT_PAR <= temp xor C_BE_n(3) xor C_BE_n(2) xor C_BE_n(1) xor C_BE_n(0);
end process PCI_Parity_Gen;

-- ***** パリティ出力制御 ***** --
PCI_Parity_Ctrl : process(PCICLK, RST_n)
begin
	if (RST_n = '0') then
		PAR_HiZ  <= '1';
		PAR_Port <= '0';
	elsif (PCICLK'event and PCICLK = '1') then
		if (PCIAD_HiZ = '0') then
			PAR_HiZ  <= '0';
			PAR_Port <= TGT_PAR;
		else
			PAR_HiZ  <= '1';
		end if;
		-- ↑ADバスのドライブから1クロック遅れてPARを制御
	end if;
end process PCI_Parity_Ctrl;


end RTL;







