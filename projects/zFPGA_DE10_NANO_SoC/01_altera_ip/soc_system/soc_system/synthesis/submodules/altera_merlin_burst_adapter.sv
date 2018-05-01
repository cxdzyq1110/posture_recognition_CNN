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


`timescale 1 ns / 1 ns

module altera_merlin_burst_adapter
#(
  parameter // Merlin packet parameters
    PKT_BEGIN_BURST             = 81,
    PKT_ADDR_H                  = 79,
    PKT_ADDR_L                  = 48,
    PKT_BYTE_CNT_H              = 5,
    PKT_BYTE_CNT_L              = 0,
    PKT_BURSTWRAP_H             = 11,
    PKT_BURSTWRAP_L             = 6,
    PKT_TRANS_COMPRESSED_READ   = 14,
    PKT_TRANS_WRITE             = 13,
    PKT_TRANS_READ              = 12,
    PKT_BYTEEN_H                = 83,
    PKT_BYTEEN_L                = 80,
    PKT_BURST_TYPE_H            = 88,
    PKT_BURST_TYPE_L            = 87,
    PKT_BURST_SIZE_H            = 86,
    PKT_BURST_SIZE_L            = 84,
    IN_NARROW_SIZE              = 0,
    OUT_NARROW_SIZE             = 0,
    OUT_FIXED                   = 0,
    OUT_COMPLETE_WRAP           = 0,
    ST_DATA_W                   = 89,
    ST_CHANNEL_W                = 8,

    // Component-specific parameters
    BYTEENABLE_SYNTHESIS        = 0,
    BURSTWRAP_CONST_MASK        = 0,
    BURSTWRAP_CONST_VALUE       = -1,
    NO_WRAP_SUPPORT             = 0,
    PIPE_INPUTS                 = 0,
    INCOMPLETE_WRAP_SUPPORT     = 1,
    OUT_BYTE_CNT_H              = 5,
    OUT_BURSTWRAP_H             = 11,
    ADAPTER_VERSION             = "13.1",
    COMPRESSED_READ_SUPPORT     = 1
)
(
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                           sink0_valid,
    input  [ST_DATA_W-1 : 0]        sink0_data,
    input  [ST_CHANNEL_W-1 : 0]     sink0_channel,
    input                           sink0_startofpacket,
    input                           sink0_endofpacket,
    output reg                      sink0_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output reg                      source0_valid,
    output reg [ST_DATA_W-1    : 0] source0_data,
    output reg [ST_CHANNEL_W-1 : 0] source0_channel,
    output reg                      source0_startofpacket,
    output reg                      source0_endofpacket,
    input                           source0_ready
);

generate if (ADAPTER_VERSION == "13.1") begin : altera_merlin_burst_adapter_13_1
    altera_merlin_burst_adapter_13_1 #(
      .PKT_BEGIN_BURST           (PKT_BEGIN_BURST),
      .PKT_ADDR_H                (PKT_ADDR_H ),
      .PKT_ADDR_L                (PKT_ADDR_L),
      .PKT_BYTE_CNT_H            (PKT_BYTE_CNT_H),
      .PKT_BYTE_CNT_L            (PKT_BYTE_CNT_L ),
      .PKT_BURSTWRAP_H           (PKT_BURSTWRAP_H),
      .PKT_BURSTWRAP_L           (PKT_BURSTWRAP_L),
      .PKT_TRANS_COMPRESSED_READ (PKT_TRANS_COMPRESSED_READ),
      .PKT_TRANS_WRITE           (PKT_TRANS_WRITE),
      .PKT_TRANS_READ            (PKT_TRANS_READ),
      .PKT_BYTEEN_H              (PKT_BYTEEN_H),
      .PKT_BYTEEN_L              (PKT_BYTEEN_L),
      .PKT_BURST_TYPE_H          (PKT_BURST_TYPE_H),
      .PKT_BURST_TYPE_L          (PKT_BURST_TYPE_L),
      .PKT_BURST_SIZE_H          (PKT_BURST_SIZE_H),
      .PKT_BURST_SIZE_L          (PKT_BURST_SIZE_L),
      .IN_NARROW_SIZE            (IN_NARROW_SIZE),
      .BYTEENABLE_SYNTHESIS      (BYTEENABLE_SYNTHESIS),
      .OUT_NARROW_SIZE           (OUT_NARROW_SIZE),
      .OUT_FIXED                 (OUT_FIXED),
      .OUT_COMPLETE_WRAP         (OUT_COMPLETE_WRAP),
      .ST_DATA_W                 (ST_DATA_W),
      .ST_CHANNEL_W              (ST_CHANNEL_W),
      .BURSTWRAP_CONST_MASK      (BURSTWRAP_CONST_MASK),
      .BURSTWRAP_CONST_VALUE     (BURSTWRAP_CONST_VALUE),
      .PIPE_INPUTS               (PIPE_INPUTS),
      .NO_WRAP_SUPPORT           (NO_WRAP_SUPPORT),
      .INCOMPLETE_WRAP_SUPPORT   (INCOMPLETE_WRAP_SUPPORT),
      .OUT_BYTE_CNT_H            (OUT_BYTE_CNT_H),
      .OUT_BURSTWRAP_H           (OUT_BURSTWRAP_H),
      .COMPRESSED_READ_SUPPORT   (COMPRESSED_READ_SUPPORT)
    ) burst_adapter_13_1(
      .clk                   (clk),
      .reset                 (reset),
      .sink0_valid           (sink0_valid),
      .sink0_data            (sink0_data),
      .sink0_channel         (sink0_channel),
      .sink0_startofpacket   (sink0_startofpacket),
      .sink0_endofpacket     (sink0_endofpacket),
      .sink0_ready           (sink0_ready),
      .source0_valid         (source0_valid),
      .source0_data          (source0_data),
      .source0_channel       (source0_channel),
      .source0_startofpacket (source0_startofpacket),
      .source0_endofpacket   (source0_endofpacket),
      .source0_ready         (source0_ready)
    );
  end
  else begin : altera_merlin_burst_adapter_new
    altera_merlin_burst_adapter_new #(
      .PKT_BEGIN_BURST           (PKT_BEGIN_BURST),
      .PKT_ADDR_H                (PKT_ADDR_H ),
      .PKT_ADDR_L                (PKT_ADDR_L),
      .PKT_BYTE_CNT_H            (PKT_BYTE_CNT_H),
      .PKT_BYTE_CNT_L            (PKT_BYTE_CNT_L ),
      .PKT_BURSTWRAP_H           (PKT_BURSTWRAP_H),
      .PKT_BURSTWRAP_L           (PKT_BURSTWRAP_L),
      .PKT_TRANS_COMPRESSED_READ (PKT_TRANS_COMPRESSED_READ),
      .PKT_TRANS_WRITE           (PKT_TRANS_WRITE),
      .PKT_TRANS_READ            (PKT_TRANS_READ),
      .PKT_BYTEEN_H              (PKT_BYTEEN_H),
      .PKT_BYTEEN_L              (PKT_BYTEEN_L),
      .PKT_BURST_TYPE_H          (PKT_BURST_TYPE_H),
      .PKT_BURST_TYPE_L          (PKT_BURST_TYPE_L),
      .PKT_BURST_SIZE_H          (PKT_BURST_SIZE_H),
      .PKT_BURST_SIZE_L          (PKT_BURST_SIZE_L),
      .IN_NARROW_SIZE            (IN_NARROW_SIZE),
      .BYTEENABLE_SYNTHESIS      (BYTEENABLE_SYNTHESIS),
      .OUT_NARROW_SIZE           (OUT_NARROW_SIZE),
      .OUT_FIXED                 (OUT_FIXED),
      .OUT_COMPLETE_WRAP         (OUT_COMPLETE_WRAP),
      .ST_DATA_W                 (ST_DATA_W),
      .ST_CHANNEL_W              (ST_CHANNEL_W),
      .BURSTWRAP_CONST_MASK      (BURSTWRAP_CONST_MASK),
      .BURSTWRAP_CONST_VALUE     (BURSTWRAP_CONST_VALUE),
      .PIPE_INPUTS               (PIPE_INPUTS),
      .NO_WRAP_SUPPORT           (NO_WRAP_SUPPORT),
      .INCOMPLETE_WRAP_SUPPORT   (INCOMPLETE_WRAP_SUPPORT),
      .OUT_BYTE_CNT_H            (OUT_BYTE_CNT_H),
      .OUT_BURSTWRAP_H           (OUT_BURSTWRAP_H),
      .COMPRESSED_READ_SUPPORT   (COMPRESSED_READ_SUPPORT)
    ) burst_adapter_new(
      .clk                   (clk),
      .reset                 (reset),
      .sink0_valid           (sink0_valid),
      .sink0_data            (sink0_data),
      .sink0_channel         (sink0_channel),
      .sink0_startofpacket   (sink0_startofpacket),
      .sink0_endofpacket     (sink0_endofpacket),
      .sink0_ready           (sink0_ready),
      .source0_valid         (source0_valid),
      .source0_data          (source0_data),
      .source0_channel       (source0_channel),
      .source0_startofpacket (source0_startofpacket),
      .source0_endofpacket   (source0_endofpacket),
      .source0_ready         (source0_ready)
    );
  end endgenerate
endmodule