// (C) 2001-2014 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module soc_system_hps_0_hps_io_border(
// memory
  output wire [15 - 1 : 0 ] mem_a
 ,output wire [3 - 1 : 0 ] mem_ba
 ,output wire [1 - 1 : 0 ] mem_ck
 ,output wire [1 - 1 : 0 ] mem_ck_n
 ,output wire [1 - 1 : 0 ] mem_cke
 ,output wire [1 - 1 : 0 ] mem_cs_n
 ,output wire [1 - 1 : 0 ] mem_ras_n
 ,output wire [1 - 1 : 0 ] mem_cas_n
 ,output wire [1 - 1 : 0 ] mem_we_n
 ,output wire [1 - 1 : 0 ] mem_reset_n
 ,inout wire [32 - 1 : 0 ] mem_dq
 ,inout wire [4 - 1 : 0 ] mem_dqs
 ,inout wire [4 - 1 : 0 ] mem_dqs_n
 ,output wire [1 - 1 : 0 ] mem_odt
 ,output wire [4 - 1 : 0 ] mem_dm
 ,input wire [1 - 1 : 0 ] oct_rzqin
// hps_io
 ,output wire [1 - 1 : 0 ] hps_io_emac1_inst_TX_CLK
 ,output wire [1 - 1 : 0 ] hps_io_emac1_inst_TXD0
 ,output wire [1 - 1 : 0 ] hps_io_emac1_inst_TXD1
 ,output wire [1 - 1 : 0 ] hps_io_emac1_inst_TXD2
 ,output wire [1 - 1 : 0 ] hps_io_emac1_inst_TXD3
 ,input wire [1 - 1 : 0 ] hps_io_emac1_inst_RXD0
 ,inout wire [1 - 1 : 0 ] hps_io_emac1_inst_MDIO
 ,output wire [1 - 1 : 0 ] hps_io_emac1_inst_MDC
 ,input wire [1 - 1 : 0 ] hps_io_emac1_inst_RX_CTL
 ,output wire [1 - 1 : 0 ] hps_io_emac1_inst_TX_CTL
 ,input wire [1 - 1 : 0 ] hps_io_emac1_inst_RX_CLK
 ,input wire [1 - 1 : 0 ] hps_io_emac1_inst_RXD1
 ,input wire [1 - 1 : 0 ] hps_io_emac1_inst_RXD2
 ,input wire [1 - 1 : 0 ] hps_io_emac1_inst_RXD3
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_CMD
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_D0
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_D1
 ,output wire [1 - 1 : 0 ] hps_io_sdio_inst_CLK
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_D2
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_D3
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D0
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D1
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D2
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D3
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D4
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D5
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D6
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D7
 ,input wire [1 - 1 : 0 ] hps_io_usb1_inst_CLK
 ,output wire [1 - 1 : 0 ] hps_io_usb1_inst_STP
 ,input wire [1 - 1 : 0 ] hps_io_usb1_inst_DIR
 ,input wire [1 - 1 : 0 ] hps_io_usb1_inst_NXT
 ,output wire [1 - 1 : 0 ] hps_io_spim1_inst_CLK
 ,output wire [1 - 1 : 0 ] hps_io_spim1_inst_MOSI
 ,input wire [1 - 1 : 0 ] hps_io_spim1_inst_MISO
 ,output wire [1 - 1 : 0 ] hps_io_spim1_inst_SS0
 ,input wire [1 - 1 : 0 ] hps_io_uart0_inst_RX
 ,output wire [1 - 1 : 0 ] hps_io_uart0_inst_TX
 ,inout wire [1 - 1 : 0 ] hps_io_i2c0_inst_SDA
 ,inout wire [1 - 1 : 0 ] hps_io_i2c0_inst_SCL
 ,inout wire [1 - 1 : 0 ] hps_io_i2c1_inst_SDA
 ,inout wire [1 - 1 : 0 ] hps_io_i2c1_inst_SCL
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_GPIO09
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_GPIO35
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_GPIO40
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_GPIO53
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_GPIO54
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_GPIO61
);

assign hps_io_emac1_inst_MDIO = intermediate[1] ? intermediate[0] : 'z;
assign hps_io_sdio_inst_CMD = intermediate[3] ? intermediate[2] : 'z;
assign hps_io_sdio_inst_D0 = intermediate[5] ? intermediate[4] : 'z;
assign hps_io_sdio_inst_D1 = intermediate[7] ? intermediate[6] : 'z;
assign hps_io_sdio_inst_D2 = intermediate[9] ? intermediate[8] : 'z;
assign hps_io_sdio_inst_D3 = intermediate[11] ? intermediate[10] : 'z;
assign hps_io_usb1_inst_D0 = intermediate[13] ? intermediate[12] : 'z;
assign hps_io_usb1_inst_D1 = intermediate[15] ? intermediate[14] : 'z;
assign hps_io_usb1_inst_D2 = intermediate[17] ? intermediate[16] : 'z;
assign hps_io_usb1_inst_D3 = intermediate[19] ? intermediate[18] : 'z;
assign hps_io_usb1_inst_D4 = intermediate[21] ? intermediate[20] : 'z;
assign hps_io_usb1_inst_D5 = intermediate[23] ? intermediate[22] : 'z;
assign hps_io_usb1_inst_D6 = intermediate[25] ? intermediate[24] : 'z;
assign hps_io_usb1_inst_D7 = intermediate[27] ? intermediate[26] : 'z;
assign hps_io_spim1_inst_MOSI = intermediate[29] ? intermediate[28] : 'z;
assign hps_io_i2c0_inst_SDA = intermediate[30] ? '0 : 'z;
assign hps_io_i2c0_inst_SCL = intermediate[31] ? '0 : 'z;
assign hps_io_i2c1_inst_SDA = intermediate[32] ? '0 : 'z;
assign hps_io_i2c1_inst_SCL = intermediate[33] ? '0 : 'z;
assign hps_io_gpio_inst_GPIO09 = intermediate[35] ? intermediate[34] : 'z;
assign hps_io_gpio_inst_GPIO35 = intermediate[37] ? intermediate[36] : 'z;
assign hps_io_gpio_inst_GPIO40 = intermediate[39] ? intermediate[38] : 'z;
assign hps_io_gpio_inst_GPIO53 = intermediate[41] ? intermediate[40] : 'z;
assign hps_io_gpio_inst_GPIO54 = intermediate[43] ? intermediate[42] : 'z;
assign hps_io_gpio_inst_GPIO61 = intermediate[45] ? intermediate[44] : 'z;

wire [46 - 1 : 0] intermediate;

wire [102 - 1 : 0] floating;

cyclonev_hps_peripheral_emac emac1_inst(
 .EMAC_GMII_MDO_I({
    hps_io_emac1_inst_MDIO[0:0] // 0:0
  })
,.EMAC_GMII_MDO_OE({
    intermediate[1:1] // 0:0
  })
,.EMAC_PHY_TXD({
    hps_io_emac1_inst_TXD3[0:0] // 3:3
   ,hps_io_emac1_inst_TXD2[0:0] // 2:2
   ,hps_io_emac1_inst_TXD1[0:0] // 1:1
   ,hps_io_emac1_inst_TXD0[0:0] // 0:0
  })
,.EMAC_CLK_TX({
    hps_io_emac1_inst_TX_CLK[0:0] // 0:0
  })
,.EMAC_PHY_RXDV({
    hps_io_emac1_inst_RX_CTL[0:0] // 0:0
  })
,.EMAC_PHY_RXD({
    hps_io_emac1_inst_RXD3[0:0] // 3:3
   ,hps_io_emac1_inst_RXD2[0:0] // 2:2
   ,hps_io_emac1_inst_RXD1[0:0] // 1:1
   ,hps_io_emac1_inst_RXD0[0:0] // 0:0
  })
,.EMAC_GMII_MDO_O({
    intermediate[0:0] // 0:0
  })
,.EMAC_GMII_MDC({
    hps_io_emac1_inst_MDC[0:0] // 0:0
  })
,.EMAC_PHY_TX_OE({
    hps_io_emac1_inst_TX_CTL[0:0] // 0:0
  })
,.EMAC_CLK_RX({
    hps_io_emac1_inst_RX_CLK[0:0] // 0:0
  })
);


cyclonev_hps_peripheral_sdmmc sdio_inst(
 .SDMMC_DATA_I({
    hps_io_sdio_inst_D3[0:0] // 3:3
   ,hps_io_sdio_inst_D2[0:0] // 2:2
   ,hps_io_sdio_inst_D1[0:0] // 1:1
   ,hps_io_sdio_inst_D0[0:0] // 0:0
  })
,.SDMMC_CMD_O({
    intermediate[2:2] // 0:0
  })
,.SDMMC_CCLK({
    hps_io_sdio_inst_CLK[0:0] // 0:0
  })
,.SDMMC_DATA_O({
    intermediate[10:10] // 3:3
   ,intermediate[8:8] // 2:2
   ,intermediate[6:6] // 1:1
   ,intermediate[4:4] // 0:0
  })
,.SDMMC_CMD_OE({
    intermediate[3:3] // 0:0
  })
,.SDMMC_CMD_I({
    hps_io_sdio_inst_CMD[0:0] // 0:0
  })
,.SDMMC_DATA_OE({
    intermediate[11:11] // 3:3
   ,intermediate[9:9] // 2:2
   ,intermediate[7:7] // 1:1
   ,intermediate[5:5] // 0:0
  })
);


cyclonev_hps_peripheral_usb usb1_inst(
 .USB_ULPI_STP({
    hps_io_usb1_inst_STP[0:0] // 0:0
  })
,.USB_ULPI_DATA_I({
    hps_io_usb1_inst_D7[0:0] // 7:7
   ,hps_io_usb1_inst_D6[0:0] // 6:6
   ,hps_io_usb1_inst_D5[0:0] // 5:5
   ,hps_io_usb1_inst_D4[0:0] // 4:4
   ,hps_io_usb1_inst_D3[0:0] // 3:3
   ,hps_io_usb1_inst_D2[0:0] // 2:2
   ,hps_io_usb1_inst_D1[0:0] // 1:1
   ,hps_io_usb1_inst_D0[0:0] // 0:0
  })
,.USB_ULPI_NXT({
    hps_io_usb1_inst_NXT[0:0] // 0:0
  })
,.USB_ULPI_DIR({
    hps_io_usb1_inst_DIR[0:0] // 0:0
  })
,.USB_ULPI_DATA_O({
    intermediate[26:26] // 7:7
   ,intermediate[24:24] // 6:6
   ,intermediate[22:22] // 5:5
   ,intermediate[20:20] // 4:4
   ,intermediate[18:18] // 3:3
   ,intermediate[16:16] // 2:2
   ,intermediate[14:14] // 1:1
   ,intermediate[12:12] // 0:0
  })
,.USB_ULPI_CLK({
    hps_io_usb1_inst_CLK[0:0] // 0:0
  })
,.USB_ULPI_DATA_OE({
    intermediate[27:27] // 7:7
   ,intermediate[25:25] // 6:6
   ,intermediate[23:23] // 5:5
   ,intermediate[21:21] // 4:4
   ,intermediate[19:19] // 3:3
   ,intermediate[17:17] // 2:2
   ,intermediate[15:15] // 1:1
   ,intermediate[13:13] // 0:0
  })
);


cyclonev_hps_peripheral_spi_master spim1_inst(
 .SPI_MASTER_RXD({
    hps_io_spim1_inst_MISO[0:0] // 0:0
  })
,.SPI_MASTER_TXD({
    intermediate[28:28] // 0:0
  })
,.SPI_MASTER_SSI_OE_N({
    intermediate[29:29] // 0:0
  })
,.SPI_MASTER_SCLK({
    hps_io_spim1_inst_CLK[0:0] // 0:0
  })
,.SPI_MASTER_SS_0_N({
    hps_io_spim1_inst_SS0[0:0] // 0:0
  })
);


cyclonev_hps_peripheral_uart uart0_inst(
 .UART_RXD({
    hps_io_uart0_inst_RX[0:0] // 0:0
  })
,.UART_TXD({
    hps_io_uart0_inst_TX[0:0] // 0:0
  })
);


cyclonev_hps_peripheral_i2c i2c0_inst(
 .I2C_DATA({
    hps_io_i2c0_inst_SDA[0:0] // 0:0
  })
,.I2C_CLK({
    hps_io_i2c0_inst_SCL[0:0] // 0:0
  })
,.I2C_DATA_OE({
    intermediate[30:30] // 0:0
  })
,.I2C_CLK_OE({
    intermediate[31:31] // 0:0
  })
);


cyclonev_hps_peripheral_i2c i2c1_inst(
 .I2C_DATA({
    hps_io_i2c1_inst_SDA[0:0] // 0:0
  })
,.I2C_CLK({
    hps_io_i2c1_inst_SCL[0:0] // 0:0
  })
,.I2C_DATA_OE({
    intermediate[32:32] // 0:0
  })
,.I2C_CLK_OE({
    intermediate[33:33] // 0:0
  })
);


cyclonev_hps_peripheral_gpio gpio_inst(
 .GPIO1_PORTA_I({
    hps_io_gpio_inst_GPIO54[0:0] // 25:25
   ,hps_io_gpio_inst_GPIO53[0:0] // 24:24
   ,floating[11:0] // 23:12
   ,hps_io_gpio_inst_GPIO40[0:0] // 11:11
   ,floating[15:12] // 10:7
   ,hps_io_gpio_inst_GPIO35[0:0] // 6:6
   ,floating[21:16] // 5:0
  })
,.GPIO1_PORTA_OE({
    intermediate[43:43] // 25:25
   ,intermediate[41:41] // 24:24
   ,floating[33:22] // 23:12
   ,intermediate[39:39] // 11:11
   ,floating[37:34] // 10:7
   ,intermediate[37:37] // 6:6
   ,floating[43:38] // 5:0
  })
,.GPIO2_PORTA_O({
    intermediate[44:44] // 3:3
   ,floating[46:44] // 2:0
  })
,.GPIO0_PORTA_O({
    intermediate[34:34] // 9:9
   ,floating[55:47] // 8:0
  })
,.GPIO2_PORTA_I({
    hps_io_gpio_inst_GPIO61[0:0] // 3:3
   ,floating[58:56] // 2:0
  })
,.GPIO2_PORTA_OE({
    intermediate[45:45] // 3:3
   ,floating[61:59] // 2:0
  })
,.GPIO0_PORTA_I({
    hps_io_gpio_inst_GPIO09[0:0] // 9:9
   ,floating[70:62] // 8:0
  })
,.GPIO0_PORTA_OE({
    intermediate[35:35] // 9:9
   ,floating[79:71] // 8:0
  })
,.GPIO1_PORTA_O({
    intermediate[42:42] // 25:25
   ,intermediate[40:40] // 24:24
   ,floating[91:80] // 23:12
   ,intermediate[38:38] // 11:11
   ,floating[95:92] // 10:7
   ,intermediate[36:36] // 6:6
   ,floating[101:96] // 5:0
  })
);


hps_sdram hps_sdram_inst(
 .mem_dq({
    mem_dq[31:0] // 31:0
  })
,.mem_odt({
    mem_odt[0:0] // 0:0
  })
,.mem_ras_n({
    mem_ras_n[0:0] // 0:0
  })
,.mem_dqs_n({
    mem_dqs_n[3:0] // 3:0
  })
,.mem_dqs({
    mem_dqs[3:0] // 3:0
  })
,.mem_dm({
    mem_dm[3:0] // 3:0
  })
,.mem_we_n({
    mem_we_n[0:0] // 0:0
  })
,.mem_cas_n({
    mem_cas_n[0:0] // 0:0
  })
,.mem_ba({
    mem_ba[2:0] // 2:0
  })
,.mem_a({
    mem_a[14:0] // 14:0
  })
,.mem_cs_n({
    mem_cs_n[0:0] // 0:0
  })
,.mem_ck({
    mem_ck[0:0] // 0:0
  })
,.mem_cke({
    mem_cke[0:0] // 0:0
  })
,.oct_rzqin({
    oct_rzqin[0:0] // 0:0
  })
,.mem_reset_n({
    mem_reset_n[0:0] // 0:0
  })
,.mem_ck_n({
    mem_ck_n[0:0] // 0:0
  })
);

endmodule

