	component soc_system is
		port (
			avalon_clk_clk                       : in    std_logic                     := 'X';             -- clk
			avalon_reset_reset_n                 : in    std_logic                     := 'X';             -- reset_n
			avalon_clk_lw_clk                    : in    std_logic                     := 'X';             -- clk
			avalon_reset_lw_reset_n              : in    std_logic                     := 'X';             -- reset_n
			memory_mem_a                         : out   std_logic_vector(14 downto 0);                    -- mem_a
			memory_mem_ba                        : out   std_logic_vector(2 downto 0);                     -- mem_ba
			memory_mem_ck                        : out   std_logic;                                        -- mem_ck
			memory_mem_ck_n                      : out   std_logic;                                        -- mem_ck_n
			memory_mem_cke                       : out   std_logic;                                        -- mem_cke
			memory_mem_cs_n                      : out   std_logic;                                        -- mem_cs_n
			memory_mem_ras_n                     : out   std_logic;                                        -- mem_ras_n
			memory_mem_cas_n                     : out   std_logic;                                        -- mem_cas_n
			memory_mem_we_n                      : out   std_logic;                                        -- mem_we_n
			memory_mem_reset_n                   : out   std_logic;                                        -- mem_reset_n
			memory_mem_dq                        : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
			memory_mem_dqs                       : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
			memory_mem_dqs_n                     : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
			memory_mem_odt                       : out   std_logic;                                        -- mem_odt
			memory_mem_dm                        : out   std_logic_vector(3 downto 0);                     -- mem_dm
			memory_oct_rzqin                     : in    std_logic                     := 'X';             -- oct_rzqin
			hps_io_hps_io_emac1_inst_TX_CLK      : out   std_logic;                                        -- hps_io_emac1_inst_TX_CLK
			hps_io_hps_io_emac1_inst_TXD0        : out   std_logic;                                        -- hps_io_emac1_inst_TXD0
			hps_io_hps_io_emac1_inst_TXD1        : out   std_logic;                                        -- hps_io_emac1_inst_TXD1
			hps_io_hps_io_emac1_inst_TXD2        : out   std_logic;                                        -- hps_io_emac1_inst_TXD2
			hps_io_hps_io_emac1_inst_TXD3        : out   std_logic;                                        -- hps_io_emac1_inst_TXD3
			hps_io_hps_io_emac1_inst_RXD0        : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD0
			hps_io_hps_io_emac1_inst_MDIO        : inout std_logic                     := 'X';             -- hps_io_emac1_inst_MDIO
			hps_io_hps_io_emac1_inst_MDC         : out   std_logic;                                        -- hps_io_emac1_inst_MDC
			hps_io_hps_io_emac1_inst_RX_CTL      : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CTL
			hps_io_hps_io_emac1_inst_TX_CTL      : out   std_logic;                                        -- hps_io_emac1_inst_TX_CTL
			hps_io_hps_io_emac1_inst_RX_CLK      : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CLK
			hps_io_hps_io_emac1_inst_RXD1        : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD1
			hps_io_hps_io_emac1_inst_RXD2        : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD2
			hps_io_hps_io_emac1_inst_RXD3        : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD3
			hps_io_hps_io_sdio_inst_CMD          : inout std_logic                     := 'X';             -- hps_io_sdio_inst_CMD
			hps_io_hps_io_sdio_inst_D0           : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D0
			hps_io_hps_io_sdio_inst_D1           : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D1
			hps_io_hps_io_sdio_inst_CLK          : out   std_logic;                                        -- hps_io_sdio_inst_CLK
			hps_io_hps_io_sdio_inst_D2           : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D2
			hps_io_hps_io_sdio_inst_D3           : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D3
			hps_io_hps_io_usb1_inst_D0           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D0
			hps_io_hps_io_usb1_inst_D1           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D1
			hps_io_hps_io_usb1_inst_D2           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D2
			hps_io_hps_io_usb1_inst_D3           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D3
			hps_io_hps_io_usb1_inst_D4           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D4
			hps_io_hps_io_usb1_inst_D5           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D5
			hps_io_hps_io_usb1_inst_D6           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D6
			hps_io_hps_io_usb1_inst_D7           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D7
			hps_io_hps_io_usb1_inst_CLK          : in    std_logic                     := 'X';             -- hps_io_usb1_inst_CLK
			hps_io_hps_io_usb1_inst_STP          : out   std_logic;                                        -- hps_io_usb1_inst_STP
			hps_io_hps_io_usb1_inst_DIR          : in    std_logic                     := 'X';             -- hps_io_usb1_inst_DIR
			hps_io_hps_io_usb1_inst_NXT          : in    std_logic                     := 'X';             -- hps_io_usb1_inst_NXT
			hps_io_hps_io_spim1_inst_CLK         : out   std_logic;                                        -- hps_io_spim1_inst_CLK
			hps_io_hps_io_spim1_inst_MOSI        : out   std_logic;                                        -- hps_io_spim1_inst_MOSI
			hps_io_hps_io_spim1_inst_MISO        : in    std_logic                     := 'X';             -- hps_io_spim1_inst_MISO
			hps_io_hps_io_spim1_inst_SS0         : out   std_logic;                                        -- hps_io_spim1_inst_SS0
			hps_io_hps_io_uart0_inst_RX          : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
			hps_io_hps_io_uart0_inst_TX          : out   std_logic;                                        -- hps_io_uart0_inst_TX
			hps_io_hps_io_i2c0_inst_SDA          : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SDA
			hps_io_hps_io_i2c0_inst_SCL          : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SCL
			hps_io_hps_io_i2c1_inst_SDA          : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SDA
			hps_io_hps_io_i2c1_inst_SCL          : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SCL
			hps_io_hps_io_gpio_inst_GPIO09       : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO09
			hps_io_hps_io_gpio_inst_GPIO35       : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO35
			hps_io_hps_io_gpio_inst_GPIO40       : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO40
			hps_io_hps_io_gpio_inst_GPIO53       : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO53
			hps_io_hps_io_gpio_inst_GPIO54       : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO54
			hps_io_hps_io_gpio_inst_GPIO61       : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO61
			hps_0_f2h_cold_reset_req_reset_n     : in    std_logic                     := 'X';             -- reset_n
			hps_0_f2h_debug_reset_req_reset_n    : in    std_logic                     := 'X';             -- reset_n
			hps_0_f2h_stm_hw_events_stm_hwevents : in    std_logic_vector(27 downto 0) := (others => 'X'); -- stm_hwevents
			hps_0_f2h_warm_reset_req_reset_n     : in    std_logic                     := 'X';             -- reset_n
			hps_0_h2f_reset_reset_n              : out   std_logic;                                        -- reset_n
			avalon_f2s0_address                  : in    std_logic_vector(29 downto 0) := (others => 'X'); -- address
			avalon_f2s0_burstcount               : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- burstcount
			avalon_f2s0_waitrequest              : out   std_logic;                                        -- waitrequest
			avalon_f2s0_readdata                 : out   std_logic_vector(31 downto 0);                    -- readdata
			avalon_f2s0_readdatavalid            : out   std_logic;                                        -- readdatavalid
			avalon_f2s0_read                     : in    std_logic                     := 'X';             -- read
			avalon_f2s0_writedata                : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			avalon_f2s0_byteenable               : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			avalon_f2s0_write                    : in    std_logic                     := 'X';             -- write
			led_pio_external_connection_export   : out   std_logic_vector(7 downto 0);                     -- export
			avalon_f2h_address                   : in    std_logic_vector(31 downto 0) := (others => 'X'); -- address
			avalon_f2h_waitrequest               : out   std_logic;                                        -- waitrequest
			avalon_f2h_burstcount                : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- burstcount
			avalon_f2h_byteenable                : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			avalon_f2h_beginbursttransfer        : in    std_logic                     := 'X';             -- beginbursttransfer
			avalon_f2h_begintransfer             : in    std_logic                     := 'X';             -- begintransfer
			avalon_f2h_read                      : in    std_logic                     := 'X';             -- read
			avalon_f2h_readdata                  : out   std_logic_vector(31 downto 0);                    -- readdata
			avalon_f2h_readdatavalid             : out   std_logic;                                        -- readdatavalid
			avalon_f2h_write                     : in    std_logic                     := 'X';             -- write
			avalon_f2h_writedata                 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			avalon_h2f_address                   : out   std_logic_vector(21 downto 0);                    -- address
			avalon_h2f_write                     : out   std_logic;                                        -- write
			avalon_h2f_read                      : out   std_logic;                                        -- read
			avalon_h2f_readdata                  : in    std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			avalon_h2f_writedata                 : out   std_logic_vector(31 downto 0);                    -- writedata
			avalon_h2f_begintransfer             : out   std_logic;                                        -- begintransfer
			avalon_h2f_beginbursttransfer        : out   std_logic;                                        -- beginbursttransfer
			avalon_h2f_burstcount                : out   std_logic_vector(3 downto 0);                     -- burstcount
			avalon_h2f_byteenable                : out   std_logic_vector(3 downto 0);                     -- byteenable
			avalon_h2f_readdatavalid             : in    std_logic                     := 'X';             -- readdatavalid
			avalon_h2f_waitrequest               : in    std_logic                     := 'X';             -- waitrequest
			avalon_h2f_lw_address                : out   std_logic_vector(15 downto 0);                    -- address
			avalon_h2f_lw_write                  : out   std_logic;                                        -- write
			avalon_h2f_lw_read                   : out   std_logic;                                        -- read
			avalon_h2f_lw_readdata               : in    std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			avalon_h2f_lw_writedata              : out   std_logic_vector(31 downto 0);                    -- writedata
			avalon_h2f_lw_begintransfer          : out   std_logic;                                        -- begintransfer
			avalon_h2f_lw_beginbursttransfer     : out   std_logic;                                        -- beginbursttransfer
			avalon_h2f_lw_burstcount             : out   std_logic_vector(3 downto 0);                     -- burstcount
			avalon_h2f_lw_byteenable             : out   std_logic_vector(3 downto 0);                     -- byteenable
			avalon_h2f_lw_readdatavalid          : in    std_logic                     := 'X';             -- readdatavalid
			avalon_h2f_lw_waitrequest            : in    std_logic                     := 'X';             -- waitrequest
			cnn_inst_info_export                 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
			video_block_number_export            : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
			avalon_f2s1_address                  : in    std_logic_vector(29 downto 0) := (others => 'X'); -- address
			avalon_f2s1_burstcount               : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- burstcount
			avalon_f2s1_waitrequest              : out   std_logic;                                        -- waitrequest
			avalon_f2s1_readdata                 : out   std_logic_vector(31 downto 0);                    -- readdata
			avalon_f2s1_readdatavalid            : out   std_logic;                                        -- readdatavalid
			avalon_f2s1_read                     : in    std_logic                     := 'X';             -- read
			avalon_f2s1_writedata                : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			avalon_f2s1_byteenable               : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			avalon_f2s1_write                    : in    std_logic                     := 'X';             -- write
			pd_bbox_frame_export                 : out   std_logic_vector(7 downto 0);                     -- export
			pd_bbox_h2f_lw_address               : out   std_logic_vector(11 downto 0);                    -- address
			pd_bbox_h2f_lw_write                 : out   std_logic;                                        -- write
			pd_bbox_h2f_lw_read                  : out   std_logic;                                        -- read
			pd_bbox_h2f_lw_readdata              : in    std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			pd_bbox_h2f_lw_writedata             : out   std_logic_vector(31 downto 0);                    -- writedata
			pd_bbox_h2f_lw_begintransfer         : out   std_logic;                                        -- begintransfer
			pd_bbox_h2f_lw_beginbursttransfer    : out   std_logic;                                        -- beginbursttransfer
			pd_bbox_h2f_lw_burstcount            : out   std_logic_vector(3 downto 0);                     -- burstcount
			pd_bbox_h2f_lw_byteenable            : out   std_logic_vector(3 downto 0);                     -- byteenable
			pd_bbox_h2f_lw_readdatavalid         : in    std_logic                     := 'X';             -- readdatavalid
			pd_bbox_h2f_lw_waitrequest           : in    std_logic                     := 'X';             -- waitrequest
			avalon_f2s2_address                  : in    std_logic_vector(29 downto 0) := (others => 'X'); -- address
			avalon_f2s2_burstcount               : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- burstcount
			avalon_f2s2_waitrequest              : out   std_logic;                                        -- waitrequest
			avalon_f2s2_readdata                 : out   std_logic_vector(31 downto 0);                    -- readdata
			avalon_f2s2_readdatavalid            : out   std_logic;                                        -- readdatavalid
			avalon_f2s2_read                     : in    std_logic                     := 'X';             -- read
			avalon_f2s2_writedata                : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			avalon_f2s2_byteenable               : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			avalon_f2s2_write                    : in    std_logic                     := 'X'              -- write
		);
	end component soc_system;

	u0 : component soc_system
		port map (
			avalon_clk_clk                       => CONNECTED_TO_avalon_clk_clk,                       --                  avalon_clk.clk
			avalon_reset_reset_n                 => CONNECTED_TO_avalon_reset_reset_n,                 --                avalon_reset.reset_n
			avalon_clk_lw_clk                    => CONNECTED_TO_avalon_clk_lw_clk,                    --               avalon_clk_lw.clk
			avalon_reset_lw_reset_n              => CONNECTED_TO_avalon_reset_lw_reset_n,              --             avalon_reset_lw.reset_n
			memory_mem_a                         => CONNECTED_TO_memory_mem_a,                         --                      memory.mem_a
			memory_mem_ba                        => CONNECTED_TO_memory_mem_ba,                        --                            .mem_ba
			memory_mem_ck                        => CONNECTED_TO_memory_mem_ck,                        --                            .mem_ck
			memory_mem_ck_n                      => CONNECTED_TO_memory_mem_ck_n,                      --                            .mem_ck_n
			memory_mem_cke                       => CONNECTED_TO_memory_mem_cke,                       --                            .mem_cke
			memory_mem_cs_n                      => CONNECTED_TO_memory_mem_cs_n,                      --                            .mem_cs_n
			memory_mem_ras_n                     => CONNECTED_TO_memory_mem_ras_n,                     --                            .mem_ras_n
			memory_mem_cas_n                     => CONNECTED_TO_memory_mem_cas_n,                     --                            .mem_cas_n
			memory_mem_we_n                      => CONNECTED_TO_memory_mem_we_n,                      --                            .mem_we_n
			memory_mem_reset_n                   => CONNECTED_TO_memory_mem_reset_n,                   --                            .mem_reset_n
			memory_mem_dq                        => CONNECTED_TO_memory_mem_dq,                        --                            .mem_dq
			memory_mem_dqs                       => CONNECTED_TO_memory_mem_dqs,                       --                            .mem_dqs
			memory_mem_dqs_n                     => CONNECTED_TO_memory_mem_dqs_n,                     --                            .mem_dqs_n
			memory_mem_odt                       => CONNECTED_TO_memory_mem_odt,                       --                            .mem_odt
			memory_mem_dm                        => CONNECTED_TO_memory_mem_dm,                        --                            .mem_dm
			memory_oct_rzqin                     => CONNECTED_TO_memory_oct_rzqin,                     --                            .oct_rzqin
			hps_io_hps_io_emac1_inst_TX_CLK      => CONNECTED_TO_hps_io_hps_io_emac1_inst_TX_CLK,      --                      hps_io.hps_io_emac1_inst_TX_CLK
			hps_io_hps_io_emac1_inst_TXD0        => CONNECTED_TO_hps_io_hps_io_emac1_inst_TXD0,        --                            .hps_io_emac1_inst_TXD0
			hps_io_hps_io_emac1_inst_TXD1        => CONNECTED_TO_hps_io_hps_io_emac1_inst_TXD1,        --                            .hps_io_emac1_inst_TXD1
			hps_io_hps_io_emac1_inst_TXD2        => CONNECTED_TO_hps_io_hps_io_emac1_inst_TXD2,        --                            .hps_io_emac1_inst_TXD2
			hps_io_hps_io_emac1_inst_TXD3        => CONNECTED_TO_hps_io_hps_io_emac1_inst_TXD3,        --                            .hps_io_emac1_inst_TXD3
			hps_io_hps_io_emac1_inst_RXD0        => CONNECTED_TO_hps_io_hps_io_emac1_inst_RXD0,        --                            .hps_io_emac1_inst_RXD0
			hps_io_hps_io_emac1_inst_MDIO        => CONNECTED_TO_hps_io_hps_io_emac1_inst_MDIO,        --                            .hps_io_emac1_inst_MDIO
			hps_io_hps_io_emac1_inst_MDC         => CONNECTED_TO_hps_io_hps_io_emac1_inst_MDC,         --                            .hps_io_emac1_inst_MDC
			hps_io_hps_io_emac1_inst_RX_CTL      => CONNECTED_TO_hps_io_hps_io_emac1_inst_RX_CTL,      --                            .hps_io_emac1_inst_RX_CTL
			hps_io_hps_io_emac1_inst_TX_CTL      => CONNECTED_TO_hps_io_hps_io_emac1_inst_TX_CTL,      --                            .hps_io_emac1_inst_TX_CTL
			hps_io_hps_io_emac1_inst_RX_CLK      => CONNECTED_TO_hps_io_hps_io_emac1_inst_RX_CLK,      --                            .hps_io_emac1_inst_RX_CLK
			hps_io_hps_io_emac1_inst_RXD1        => CONNECTED_TO_hps_io_hps_io_emac1_inst_RXD1,        --                            .hps_io_emac1_inst_RXD1
			hps_io_hps_io_emac1_inst_RXD2        => CONNECTED_TO_hps_io_hps_io_emac1_inst_RXD2,        --                            .hps_io_emac1_inst_RXD2
			hps_io_hps_io_emac1_inst_RXD3        => CONNECTED_TO_hps_io_hps_io_emac1_inst_RXD3,        --                            .hps_io_emac1_inst_RXD3
			hps_io_hps_io_sdio_inst_CMD          => CONNECTED_TO_hps_io_hps_io_sdio_inst_CMD,          --                            .hps_io_sdio_inst_CMD
			hps_io_hps_io_sdio_inst_D0           => CONNECTED_TO_hps_io_hps_io_sdio_inst_D0,           --                            .hps_io_sdio_inst_D0
			hps_io_hps_io_sdio_inst_D1           => CONNECTED_TO_hps_io_hps_io_sdio_inst_D1,           --                            .hps_io_sdio_inst_D1
			hps_io_hps_io_sdio_inst_CLK          => CONNECTED_TO_hps_io_hps_io_sdio_inst_CLK,          --                            .hps_io_sdio_inst_CLK
			hps_io_hps_io_sdio_inst_D2           => CONNECTED_TO_hps_io_hps_io_sdio_inst_D2,           --                            .hps_io_sdio_inst_D2
			hps_io_hps_io_sdio_inst_D3           => CONNECTED_TO_hps_io_hps_io_sdio_inst_D3,           --                            .hps_io_sdio_inst_D3
			hps_io_hps_io_usb1_inst_D0           => CONNECTED_TO_hps_io_hps_io_usb1_inst_D0,           --                            .hps_io_usb1_inst_D0
			hps_io_hps_io_usb1_inst_D1           => CONNECTED_TO_hps_io_hps_io_usb1_inst_D1,           --                            .hps_io_usb1_inst_D1
			hps_io_hps_io_usb1_inst_D2           => CONNECTED_TO_hps_io_hps_io_usb1_inst_D2,           --                            .hps_io_usb1_inst_D2
			hps_io_hps_io_usb1_inst_D3           => CONNECTED_TO_hps_io_hps_io_usb1_inst_D3,           --                            .hps_io_usb1_inst_D3
			hps_io_hps_io_usb1_inst_D4           => CONNECTED_TO_hps_io_hps_io_usb1_inst_D4,           --                            .hps_io_usb1_inst_D4
			hps_io_hps_io_usb1_inst_D5           => CONNECTED_TO_hps_io_hps_io_usb1_inst_D5,           --                            .hps_io_usb1_inst_D5
			hps_io_hps_io_usb1_inst_D6           => CONNECTED_TO_hps_io_hps_io_usb1_inst_D6,           --                            .hps_io_usb1_inst_D6
			hps_io_hps_io_usb1_inst_D7           => CONNECTED_TO_hps_io_hps_io_usb1_inst_D7,           --                            .hps_io_usb1_inst_D7
			hps_io_hps_io_usb1_inst_CLK          => CONNECTED_TO_hps_io_hps_io_usb1_inst_CLK,          --                            .hps_io_usb1_inst_CLK
			hps_io_hps_io_usb1_inst_STP          => CONNECTED_TO_hps_io_hps_io_usb1_inst_STP,          --                            .hps_io_usb1_inst_STP
			hps_io_hps_io_usb1_inst_DIR          => CONNECTED_TO_hps_io_hps_io_usb1_inst_DIR,          --                            .hps_io_usb1_inst_DIR
			hps_io_hps_io_usb1_inst_NXT          => CONNECTED_TO_hps_io_hps_io_usb1_inst_NXT,          --                            .hps_io_usb1_inst_NXT
			hps_io_hps_io_spim1_inst_CLK         => CONNECTED_TO_hps_io_hps_io_spim1_inst_CLK,         --                            .hps_io_spim1_inst_CLK
			hps_io_hps_io_spim1_inst_MOSI        => CONNECTED_TO_hps_io_hps_io_spim1_inst_MOSI,        --                            .hps_io_spim1_inst_MOSI
			hps_io_hps_io_spim1_inst_MISO        => CONNECTED_TO_hps_io_hps_io_spim1_inst_MISO,        --                            .hps_io_spim1_inst_MISO
			hps_io_hps_io_spim1_inst_SS0         => CONNECTED_TO_hps_io_hps_io_spim1_inst_SS0,         --                            .hps_io_spim1_inst_SS0
			hps_io_hps_io_uart0_inst_RX          => CONNECTED_TO_hps_io_hps_io_uart0_inst_RX,          --                            .hps_io_uart0_inst_RX
			hps_io_hps_io_uart0_inst_TX          => CONNECTED_TO_hps_io_hps_io_uart0_inst_TX,          --                            .hps_io_uart0_inst_TX
			hps_io_hps_io_i2c0_inst_SDA          => CONNECTED_TO_hps_io_hps_io_i2c0_inst_SDA,          --                            .hps_io_i2c0_inst_SDA
			hps_io_hps_io_i2c0_inst_SCL          => CONNECTED_TO_hps_io_hps_io_i2c0_inst_SCL,          --                            .hps_io_i2c0_inst_SCL
			hps_io_hps_io_i2c1_inst_SDA          => CONNECTED_TO_hps_io_hps_io_i2c1_inst_SDA,          --                            .hps_io_i2c1_inst_SDA
			hps_io_hps_io_i2c1_inst_SCL          => CONNECTED_TO_hps_io_hps_io_i2c1_inst_SCL,          --                            .hps_io_i2c1_inst_SCL
			hps_io_hps_io_gpio_inst_GPIO09       => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO09,       --                            .hps_io_gpio_inst_GPIO09
			hps_io_hps_io_gpio_inst_GPIO35       => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO35,       --                            .hps_io_gpio_inst_GPIO35
			hps_io_hps_io_gpio_inst_GPIO40       => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO40,       --                            .hps_io_gpio_inst_GPIO40
			hps_io_hps_io_gpio_inst_GPIO53       => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO53,       --                            .hps_io_gpio_inst_GPIO53
			hps_io_hps_io_gpio_inst_GPIO54       => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO54,       --                            .hps_io_gpio_inst_GPIO54
			hps_io_hps_io_gpio_inst_GPIO61       => CONNECTED_TO_hps_io_hps_io_gpio_inst_GPIO61,       --                            .hps_io_gpio_inst_GPIO61
			hps_0_f2h_cold_reset_req_reset_n     => CONNECTED_TO_hps_0_f2h_cold_reset_req_reset_n,     --    hps_0_f2h_cold_reset_req.reset_n
			hps_0_f2h_debug_reset_req_reset_n    => CONNECTED_TO_hps_0_f2h_debug_reset_req_reset_n,    --   hps_0_f2h_debug_reset_req.reset_n
			hps_0_f2h_stm_hw_events_stm_hwevents => CONNECTED_TO_hps_0_f2h_stm_hw_events_stm_hwevents, --     hps_0_f2h_stm_hw_events.stm_hwevents
			hps_0_f2h_warm_reset_req_reset_n     => CONNECTED_TO_hps_0_f2h_warm_reset_req_reset_n,     --    hps_0_f2h_warm_reset_req.reset_n
			hps_0_h2f_reset_reset_n              => CONNECTED_TO_hps_0_h2f_reset_reset_n,              --             hps_0_h2f_reset.reset_n
			avalon_f2s0_address                  => CONNECTED_TO_avalon_f2s0_address,                  --                 avalon_f2s0.address
			avalon_f2s0_burstcount               => CONNECTED_TO_avalon_f2s0_burstcount,               --                            .burstcount
			avalon_f2s0_waitrequest              => CONNECTED_TO_avalon_f2s0_waitrequest,              --                            .waitrequest
			avalon_f2s0_readdata                 => CONNECTED_TO_avalon_f2s0_readdata,                 --                            .readdata
			avalon_f2s0_readdatavalid            => CONNECTED_TO_avalon_f2s0_readdatavalid,            --                            .readdatavalid
			avalon_f2s0_read                     => CONNECTED_TO_avalon_f2s0_read,                     --                            .read
			avalon_f2s0_writedata                => CONNECTED_TO_avalon_f2s0_writedata,                --                            .writedata
			avalon_f2s0_byteenable               => CONNECTED_TO_avalon_f2s0_byteenable,               --                            .byteenable
			avalon_f2s0_write                    => CONNECTED_TO_avalon_f2s0_write,                    --                            .write
			led_pio_external_connection_export   => CONNECTED_TO_led_pio_external_connection_export,   -- led_pio_external_connection.export
			avalon_f2h_address                   => CONNECTED_TO_avalon_f2h_address,                   --                  avalon_f2h.address
			avalon_f2h_waitrequest               => CONNECTED_TO_avalon_f2h_waitrequest,               --                            .waitrequest
			avalon_f2h_burstcount                => CONNECTED_TO_avalon_f2h_burstcount,                --                            .burstcount
			avalon_f2h_byteenable                => CONNECTED_TO_avalon_f2h_byteenable,                --                            .byteenable
			avalon_f2h_beginbursttransfer        => CONNECTED_TO_avalon_f2h_beginbursttransfer,        --                            .beginbursttransfer
			avalon_f2h_begintransfer             => CONNECTED_TO_avalon_f2h_begintransfer,             --                            .begintransfer
			avalon_f2h_read                      => CONNECTED_TO_avalon_f2h_read,                      --                            .read
			avalon_f2h_readdata                  => CONNECTED_TO_avalon_f2h_readdata,                  --                            .readdata
			avalon_f2h_readdatavalid             => CONNECTED_TO_avalon_f2h_readdatavalid,             --                            .readdatavalid
			avalon_f2h_write                     => CONNECTED_TO_avalon_f2h_write,                     --                            .write
			avalon_f2h_writedata                 => CONNECTED_TO_avalon_f2h_writedata,                 --                            .writedata
			avalon_h2f_address                   => CONNECTED_TO_avalon_h2f_address,                   --                  avalon_h2f.address
			avalon_h2f_write                     => CONNECTED_TO_avalon_h2f_write,                     --                            .write
			avalon_h2f_read                      => CONNECTED_TO_avalon_h2f_read,                      --                            .read
			avalon_h2f_readdata                  => CONNECTED_TO_avalon_h2f_readdata,                  --                            .readdata
			avalon_h2f_writedata                 => CONNECTED_TO_avalon_h2f_writedata,                 --                            .writedata
			avalon_h2f_begintransfer             => CONNECTED_TO_avalon_h2f_begintransfer,             --                            .begintransfer
			avalon_h2f_beginbursttransfer        => CONNECTED_TO_avalon_h2f_beginbursttransfer,        --                            .beginbursttransfer
			avalon_h2f_burstcount                => CONNECTED_TO_avalon_h2f_burstcount,                --                            .burstcount
			avalon_h2f_byteenable                => CONNECTED_TO_avalon_h2f_byteenable,                --                            .byteenable
			avalon_h2f_readdatavalid             => CONNECTED_TO_avalon_h2f_readdatavalid,             --                            .readdatavalid
			avalon_h2f_waitrequest               => CONNECTED_TO_avalon_h2f_waitrequest,               --                            .waitrequest
			avalon_h2f_lw_address                => CONNECTED_TO_avalon_h2f_lw_address,                --               avalon_h2f_lw.address
			avalon_h2f_lw_write                  => CONNECTED_TO_avalon_h2f_lw_write,                  --                            .write
			avalon_h2f_lw_read                   => CONNECTED_TO_avalon_h2f_lw_read,                   --                            .read
			avalon_h2f_lw_readdata               => CONNECTED_TO_avalon_h2f_lw_readdata,               --                            .readdata
			avalon_h2f_lw_writedata              => CONNECTED_TO_avalon_h2f_lw_writedata,              --                            .writedata
			avalon_h2f_lw_begintransfer          => CONNECTED_TO_avalon_h2f_lw_begintransfer,          --                            .begintransfer
			avalon_h2f_lw_beginbursttransfer     => CONNECTED_TO_avalon_h2f_lw_beginbursttransfer,     --                            .beginbursttransfer
			avalon_h2f_lw_burstcount             => CONNECTED_TO_avalon_h2f_lw_burstcount,             --                            .burstcount
			avalon_h2f_lw_byteenable             => CONNECTED_TO_avalon_h2f_lw_byteenable,             --                            .byteenable
			avalon_h2f_lw_readdatavalid          => CONNECTED_TO_avalon_h2f_lw_readdatavalid,          --                            .readdatavalid
			avalon_h2f_lw_waitrequest            => CONNECTED_TO_avalon_h2f_lw_waitrequest,            --                            .waitrequest
			cnn_inst_info_export                 => CONNECTED_TO_cnn_inst_info_export,                 --               cnn_inst_info.export
			video_block_number_export            => CONNECTED_TO_video_block_number_export,            --          video_block_number.export
			avalon_f2s1_address                  => CONNECTED_TO_avalon_f2s1_address,                  --                 avalon_f2s1.address
			avalon_f2s1_burstcount               => CONNECTED_TO_avalon_f2s1_burstcount,               --                            .burstcount
			avalon_f2s1_waitrequest              => CONNECTED_TO_avalon_f2s1_waitrequest,              --                            .waitrequest
			avalon_f2s1_readdata                 => CONNECTED_TO_avalon_f2s1_readdata,                 --                            .readdata
			avalon_f2s1_readdatavalid            => CONNECTED_TO_avalon_f2s1_readdatavalid,            --                            .readdatavalid
			avalon_f2s1_read                     => CONNECTED_TO_avalon_f2s1_read,                     --                            .read
			avalon_f2s1_writedata                => CONNECTED_TO_avalon_f2s1_writedata,                --                            .writedata
			avalon_f2s1_byteenable               => CONNECTED_TO_avalon_f2s1_byteenable,               --                            .byteenable
			avalon_f2s1_write                    => CONNECTED_TO_avalon_f2s1_write,                    --                            .write
			pd_bbox_frame_export                 => CONNECTED_TO_pd_bbox_frame_export,                 --               pd_bbox_frame.export
			pd_bbox_h2f_lw_address               => CONNECTED_TO_pd_bbox_h2f_lw_address,               --              pd_bbox_h2f_lw.address
			pd_bbox_h2f_lw_write                 => CONNECTED_TO_pd_bbox_h2f_lw_write,                 --                            .write
			pd_bbox_h2f_lw_read                  => CONNECTED_TO_pd_bbox_h2f_lw_read,                  --                            .read
			pd_bbox_h2f_lw_readdata              => CONNECTED_TO_pd_bbox_h2f_lw_readdata,              --                            .readdata
			pd_bbox_h2f_lw_writedata             => CONNECTED_TO_pd_bbox_h2f_lw_writedata,             --                            .writedata
			pd_bbox_h2f_lw_begintransfer         => CONNECTED_TO_pd_bbox_h2f_lw_begintransfer,         --                            .begintransfer
			pd_bbox_h2f_lw_beginbursttransfer    => CONNECTED_TO_pd_bbox_h2f_lw_beginbursttransfer,    --                            .beginbursttransfer
			pd_bbox_h2f_lw_burstcount            => CONNECTED_TO_pd_bbox_h2f_lw_burstcount,            --                            .burstcount
			pd_bbox_h2f_lw_byteenable            => CONNECTED_TO_pd_bbox_h2f_lw_byteenable,            --                            .byteenable
			pd_bbox_h2f_lw_readdatavalid         => CONNECTED_TO_pd_bbox_h2f_lw_readdatavalid,         --                            .readdatavalid
			pd_bbox_h2f_lw_waitrequest           => CONNECTED_TO_pd_bbox_h2f_lw_waitrequest,           --                            .waitrequest
			avalon_f2s2_address                  => CONNECTED_TO_avalon_f2s2_address,                  --                 avalon_f2s2.address
			avalon_f2s2_burstcount               => CONNECTED_TO_avalon_f2s2_burstcount,               --                            .burstcount
			avalon_f2s2_waitrequest              => CONNECTED_TO_avalon_f2s2_waitrequest,              --                            .waitrequest
			avalon_f2s2_readdata                 => CONNECTED_TO_avalon_f2s2_readdata,                 --                            .readdata
			avalon_f2s2_readdatavalid            => CONNECTED_TO_avalon_f2s2_readdatavalid,            --                            .readdatavalid
			avalon_f2s2_read                     => CONNECTED_TO_avalon_f2s2_read,                     --                            .read
			avalon_f2s2_writedata                => CONNECTED_TO_avalon_f2s2_writedata,                --                            .writedata
			avalon_f2s2_byteenable               => CONNECTED_TO_avalon_f2s2_byteenable,               --                            .byteenable
			avalon_f2s2_write                    => CONNECTED_TO_avalon_f2s2_write                     --                            .write
		);

