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


// $Id: //depot/users/tgngo/new_burst_adapter/opt_work/altera_merlin_burst_adapter_new.sv#13 $
// $Revision: #13 $
// $Date: 2014/04/23 $
// $Author: tgngo $

// -------------------------------------------------------------------
// Merlin Burst Adapter: convert incoming bursts to fit slaves' bursts
// -------------------------------------------------------------------

`timescale 1 ns / 1 ns

module altera_merlin_burst_adapter_new
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
    OUT_BYTE_CNT_H              = 5,
    OUT_BURSTWRAP_H             = 11,
    COMPRESSED_READ_SUPPORT     = 1,
    // Optimization parameters
    NO_WRAP_SUPPORT             = 1,
    INCOMPLETE_WRAP_SUPPORT     = 0,
    PIPE_INPUTS                 = 0,
    PIPE_INTERNAL               = 0
)
(
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                           sink0_valid,
    input  [ST_DATA_W    -1 : 0]    sink0_data,
    input  [ST_CHANNEL_W -1 : 0]    sink0_channel,
    input                           sink0_startofpacket,
    input                           sink0_endofpacket,
    output reg                      sink0_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output reg                       source0_valid,
    output reg [ST_DATA_W    -1 : 0] source0_data,
    output reg [ST_CHANNEL_W -1 : 0] source0_channel,
    output reg                       source0_startofpacket,
    output reg                       source0_endofpacket,
    input                            source0_ready
);
  localparam PKT_BURSTWRAP_W = PKT_BURSTWRAP_H - PKT_BURSTWRAP_L + 1;

    generate if (COMPRESSED_READ_SUPPORT == 1) begin : altera_merlin_burst_adapter_full
    altera_merlin_burst_adapter_full_new #(
     .PKT_BEGIN_BURST           (PKT_BEGIN_BURST),
     .PKT_ADDR_H                (PKT_ADDR_H),
     .PKT_ADDR_L                (PKT_ADDR_L),
     .PKT_BYTE_CNT_H            (PKT_BYTE_CNT_H),
     .PKT_BYTE_CNT_L            (PKT_BYTE_CNT_L),
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
     .PIPE_INTERNAL             (PIPE_INTERNAL),
     .NO_WRAP_SUPPORT           (NO_WRAP_SUPPORT),
     .INCOMPLETE_WRAP_SUPPORT   (INCOMPLETE_WRAP_SUPPORT),
     .OUT_BYTE_CNT_H            (OUT_BYTE_CNT_H),
     .OUT_BURSTWRAP_H           (OUT_BURSTWRAP_H)
    ) the_ba_new (
     .clk                       (clk),
     .reset                     (reset),
     .in0_valid                 (sink0_valid),
     .in0_data                  (sink0_data),
     .in0_channel               (sink0_channel),
     .in0_startofpacket         (sink0_startofpacket),
     .in0_endofpacket           (sink0_endofpacket),
     .in0_ready                 (sink0_ready),
     .source0_valid             (source0_valid),
     .source0_data              (source0_data),
     .source0_channel           (source0_channel),
     .source0_startofpacket     (source0_startofpacket),
     .source0_endofpacket       (source0_endofpacket),
     .source0_ready             (source0_ready)
    );
  end
  else begin : altera_merlin_burst_adapter_uncompressed_only
    altera_merlin_burst_adapter_uncompressed_only_new #(
     .PKT_BYTE_CNT_H        (PKT_BYTE_CNT_H),
     .PKT_BYTE_CNT_L        (PKT_BYTE_CNT_L),
     .PKT_BYTEEN_H          (PKT_BYTEEN_H),
     .PKT_BYTEEN_L          (PKT_BYTEEN_L),
     .ST_DATA_W             (ST_DATA_W),
     .ST_CHANNEL_W          (ST_CHANNEL_W)
    ) the_ba_new (
     .clk                   (clk),
     .reset                 (reset),
     .in0_valid             (sink0_valid),
     .in0_data              (sink0_data),
     .in0_channel           (sink0_channel),
     .in0_startofpacket     (sink0_startofpacket),
     .in0_endofpacket       (sink0_endofpacket),
     .in0_ready             (sink0_ready),
     .source0_valid         (source0_valid),
     .source0_data          (source0_data),
     .source0_channel       (source0_channel),
     .source0_startofpacket (source0_startofpacket),
     .source0_endofpacket   (source0_endofpacket),
     .source0_ready         (source0_ready)
    );
  end endgenerate

  // synthesis translate_off
  // Check for incoming burstwrap values inconsistent with
  // BURSTWRAP_CONST_MASK.
  always @(posedge clk or posedge reset) begin
    if (~reset && sink0_valid &&
        BURSTWRAP_CONST_MASK[PKT_BURSTWRAP_W - 1:0] &
        (BURSTWRAP_CONST_VALUE[PKT_BURSTWRAP_W - 1:0] ^ sink0_data[PKT_BURSTWRAP_H : PKT_BURSTWRAP_L])
      ) begin
      $display("%t: %m: Error: burstwrap value %X is inconsistent with BURSTWRAP_CONST_MASK value %X", $time(), sink0_data[PKT_BURSTWRAP_H : PKT_BURSTWRAP_L], BURSTWRAP_CONST_MASK[PKT_BURSTWRAP_W - 1:0]);
    end
  end
  // synthesis translate_on
endmodule

module altera_merlin_burst_adapter_full_new
#(
  parameter // Merlin packet parameters
    PKT_BEGIN_BURST             = 81,
    PKT_ADDR_H                  = 103,
    PKT_ADDR_L                  = 72,
    PKT_BYTE_CNT_H              = 8,
    PKT_BYTE_CNT_L              = 3,
    PKT_BURSTWRAP_H             = 16,
    PKT_BURSTWRAP_L             = 11,
    PKT_TRANS_COMPRESSED_READ   = 18,
    PKT_TRANS_WRITE             = 20,
    PKT_TRANS_READ              = 19,
    PKT_BYTEEN_H                = 111,
    PKT_BYTEEN_L                = 108,
    PKT_BURST_TYPE_H            = 125,
    PKT_BURST_TYPE_L            = 124,
    PKT_BURST_SIZE_H            = 120,
    PKT_BURST_SIZE_L            = 118,
    IN_NARROW_SIZE              = 0,
    OUT_NARROW_SIZE             = 0,
    OUT_FIXED                   = 0,
    OUT_COMPLETE_WRAP           = 0,
    ST_DATA_W                   = 126,
    ST_CHANNEL_W                = 8,

    // Component-specific parameters
    BYTEENABLE_SYNTHESIS        = 0,
    BURSTWRAP_CONST_MASK        = 0,
    BURSTWRAP_CONST_VALUE       = -1,
    NO_WRAP_SUPPORT             = 0,
    INCOMPLETE_WRAP_SUPPORT     = 1,
    PIPE_INPUTS                 = 0,
    PIPE_INTERNAL               = 0,
    OUT_BYTE_CNT_H              = 7,
    OUT_BURSTWRAP_H             = 14,
    COMPRESSED_READ_SUPPORT     = 1
)
(
    input                             clk,
    input                             reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                             in0_valid,
    input [ST_DATA_W - 1 : 0]         in0_data,
    input [ST_CHANNEL_W - 1 : 0]      in0_channel,
    input                             in0_startofpacket,
    input                             in0_endofpacket,
    output reg                        in0_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output reg                        source0_valid,
    output reg [ST_DATA_W - 1 : 0]    source0_data,
    output reg [ST_CHANNEL_W - 1 : 0] source0_channel,
    output reg                        source0_startofpacket,
    output reg                        source0_endofpacket,
    input                             source0_ready
);
localparam
    PKT_BYTE_CNT_W         = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1,
    PKT_ADDR_W             = PKT_ADDR_H - PKT_ADDR_L + 1,
    PKT_BYTEEN_W           = PKT_BYTEEN_H - PKT_BYTEEN_L + 1,
    OUT_BYTE_CNT_W         = OUT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1,
    OUT_BURSTWRAP_W        = OUT_BURSTWRAP_H - PKT_BURSTWRAP_L + 1,
    PKT_BURSTWRAP_W        = PKT_BURSTWRAP_H - PKT_BURSTWRAP_L + 1,
    NUM_SYMBOLS            = PKT_BYTEEN_H - PKT_BYTEEN_L + 1,
    PKT_BURST_SIZE_W       = PKT_BURST_SIZE_H - PKT_BURST_SIZE_L + 1,
    PKT_BURST_TYPE_W       = PKT_BURST_TYPE_H - PKT_BURST_TYPE_L + 1,
    LOG2_NUM_SYMBOLS       = log2ceil(NUM_SYMBOLS),
    ADDR_MASK_SEL          = (NUM_SYMBOLS == 1) ? 1 : log2ceil(NUM_SYMBOLS),

    // Use in term of "burst length" not "bytecount"
    IN_LEN_W               = PKT_BYTE_CNT_W - LOG2_NUM_SYMBOLS,
    MAX_IN_LEN             = 1 << (IN_LEN_W - 1),
    OUT_LEN_W              = OUT_BYTE_CNT_W - LOG2_NUM_SYMBOLS,
    MAX_OUT_LEN            = 1 << (OUT_LEN_W - 1),
    BNDRY_WIDTH            = PKT_BURSTWRAP_W,
    LEN_WIDTH              = log2ceil(MAX_IN_LEN) + 1,
    OUT_BOUNDARY           = MAX_OUT_LEN * NUM_SYMBOLS,
    ADDR_SEL               = log2ceil(OUT_BOUNDARY),
    OUT_BOUNDARY_WIDTH     = ADDR_SEL + 1,
    BYTE_TO_WORD_SHIFT     = log2ceil(NUM_SYMBOLS),
    BYTE_TO_WORD_SHIFT_W   = log2ceil(BYTE_TO_WORD_SHIFT) + 1,

    IS_NON_BURSTING_SLAVE  = (MAX_OUT_LEN == 1),
    IS_AXI_SLAVE           = OUT_FIXED && OUT_NARROW_SIZE & OUT_COMPLETE_WRAP,
    IS_WRAP_AVALON_SLAVE   = !IS_AXI_SLAVE && (PKT_BURSTWRAP_H != OUT_BURSTWRAP_H),
    IS_INCR_SLAVE          = !IS_AXI_SLAVE && !IS_WRAP_AVALON_SLAVE,
    // This parameter indicates that system is purely INCR avalon master and slave ONLY
    INCR_AVALON_SYS        = IS_INCR_SLAVE && (PKT_BURSTWRAP_W == 1) && (OUT_BURSTWRAP_W == 1);

    // ---------------------------------------------------
    // AXI Burst Type Encoding
    // ---------------------------------------------------
    typedef enum bit  [1:0]
    {
     FIXED       = 2'b00,
     INCR        = 2'b01,
     WRAP        = 2'b10,
     RESERVED    = 2'b11
    } AxiBurstType;

    wire [ST_DATA_W    - 1 : 0] sink0_data;
    wire [ST_CHANNEL_W - 1 : 0] sink0_channel;
    wire                        sink0_startofpacket;
    wire                        sink0_endofpacket;
    wire                        sink0_ready;
    wire                        sink0_valid;
    wire                        int_sink0_ready;

    generate begin
    if (PIPE_INPUTS == 1) begin : input_pipeline_stage
        altera_avalon_st_pipeline_stage #(
         .SYMBOLS_PER_BEAT (1),
         .BITS_PER_SYMBOL  (ST_DATA_W),
         .USE_PACKETS      (1),
         .USE_EMPTY        (0),
         .EMPTY_WIDTH      (0),
         .CHANNEL_WIDTH    (ST_CHANNEL_W),
         .PACKET_WIDTH     (2),
         .ERROR_WIDTH      (0),
         .PIPELINE_READY   (1)
        ) pipeline_stage (
         .clk               (clk),
         .reset             (reset),
         .in_ready          (in0_ready),
         .in_valid          (in0_valid),
         .in_startofpacket  (in0_startofpacket),
         .in_endofpacket    (in0_endofpacket),
         .in_data           (in0_data),
         .in_channel        (in0_channel),
         .out_ready         (int_sink0_ready),
         .out_valid         (sink0_valid),
         .out_startofpacket (sink0_startofpacket),
         .out_endofpacket   (sink0_endofpacket),
         .out_data          (sink0_data),
         .out_channel       (sink0_channel),
         .in_empty          (1'b0),
         .out_empty         (),
         .out_error         (),
         .in_error          (1'b0)
        );
        end
        else begin : no_input_pipeline_stage
            assign sink0_valid          = in0_valid;
            assign sink0_data           = in0_data;
            assign sink0_channel        = in0_channel;
            assign sink0_startofpacket  = in0_startofpacket;
            assign sink0_endofpacket    = in0_endofpacket;
            assign in0_ready            = int_sink0_ready;
        end
    end
    endgenerate

    assign sink0_ready = int_sink0_ready;

    // --------------------------------------------------
    // Signals from direct input
    // --------------------------------------------------
    wire [63 : 0]                    log2_numsymbols  = log2ceil(NUM_SYMBOLS);
    wire [PKT_BURST_TYPE_W - 1 : 0]  in_bursttype;
    wire [PKT_BYTE_CNT_W   - 1 : 0]  in_bytecount;
    wire [PKT_ADDR_W       - 1 : 0]  in_addr;
    wire [PKT_BYTE_CNT_W   - 1 : 0]  in_burstcount;
    wire [IN_LEN_W         - 1 : 0]  in_len;
    wire [PKT_BURST_SIZE_W - 1 : 0]  in_size;
    wire                             in_write;
    wire                             in_compressed_read;
    wire                             in_read;
    wire                             in_uncompressed_read;
    wire                             in_sop;
    wire                             in_eop;
    wire                             in_passthru;
    wire [PKT_BYTEEN_W      - 1 : 0] in_byteen;
    wire                             in_narrow;

    assign in_compressed_read   = sink0_data[PKT_TRANS_COMPRESSED_READ];
    assign in_read              = sink0_data[PKT_TRANS_READ];
    assign in_uncompressed_read = in_read & ~sink0_data[PKT_TRANS_COMPRESSED_READ];
    assign in_sop               = sink0_startofpacket;
    assign in_eop               = sink0_endofpacket;
    assign in_passthru          = in_burstcount <= 16;
    assign in_byteen            = sink0_data[PKT_BYTEEN_H : PKT_BYTEEN_L];
    assign in_bursttype         = sink0_data[PKT_BURST_TYPE_H : PKT_BURST_TYPE_L];
    assign in_bytecount         = sink0_data[PKT_BYTE_CNT_H : PKT_BYTE_CNT_L];
    assign in_addr              = sink0_data[PKT_ADDR_H : PKT_ADDR_L];
    assign in_burstcount        = in_bytecount >> log2_numsymbols[PKT_BYTE_CNT_W - 1 : 0];
    assign in_len               = in_burstcount[IN_LEN_W - 1 : 0];
    assign in_size              = sink0_data[PKT_BURST_SIZE_H : PKT_BURST_SIZE_L];
    assign in_write             = sink0_data[PKT_TRANS_WRITE];
    assign in_narrow            = in_size < log2_numsymbols[PKT_BYTE_CNT_W - 1 :0];

    // ------------------------------------------------------------------------------------------
    // Note on signal naming convention used
    // in_*       --> These signals are either coming directly from sink or a combi off the sink signals
    //            --> Timing - zero cycle
    // d0_in_*    --> Signals that are output of initial flop stage.
    //            --> Timing - zero cycle (IF PIPE_INPUTS == 0) else 1 clock
    // d1_in_*    --> Signals that are output of initial flop stage.
    //            --> Timing - always delayed by 1 clock. (vs the input)
    // d0_in_*_value  --> Signals that are selected from in_* and its register d1_* via new_burst signal
    //                --> these value will be held unchanged thru the burst
    // --------------------------------------------------------------------------------------------
    // Internal registers and signals declaration
    // --------------------------------------------------------------------------------------------
    reg                             in_ready_hold;
    reg                             in_eop_reg;
    reg                             in_sop_reg;
    wire                            in_valid  = sink0_valid & in_ready_hold;
    reg                             in_valid_reg;
    reg                             in_compressed_read_reg;
    reg                             in_uncompressed_read_reg;
    reg                             in_write_reg;
    reg                             in_full_size_write_wrap_reg;
    reg                             in_full_size_read_wrap_reg;

    // ---------------------------------------------------
    // new_burst signals: indicates when new burst is comning
    // *_new_burst : stand for each accordingly conveter
    // new_burst   : is used when there are multiple conveters
    // ---------------------------------------------------
    wire                            new_burst;
    wire                            fixed_new_burst;
    wire                            wrap_new_burst;
    wire                            incr_new_burst;

    reg [PKT_BURST_SIZE_W - 1 : 0]  in_size_reg;
    reg [ST_DATA_W        - 1 : 0]  in_data_reg;
    reg [ST_CHANNEL_W     - 1 : 0]  in_channel_reg;
    wire [PKT_BURSTWRAP_W - 1 : 0]  in_burstwrap;
    wire [PKT_BURSTWRAP_W - 1 : 0]  in_boundary;
    reg  [PKT_BURSTWRAP_W - 1 : 0]  in_burstwrap_reg;
    reg [PKT_BYTEEN_W     - 1 : 0]  in_byteen_reg;
    reg [PKT_ADDR_W       - 1 : 0]  in_addr_reg;
    reg [PKT_ADDR_W       - 1 : 0]  in_aligned_addr_reg;
    reg [PKT_ADDR_W       - 1 : 0]  in_aligned_addr;
    reg [IN_LEN_W         - 1 : 0]  in_len_reg;
    reg                             in_narrow_reg;

    wire [PKT_BYTE_CNT_W  - 1 : 0]  out_byte_cnt;
    wire [IN_LEN_W        - 1 : 0]  incr_out_len;
    wire [IN_LEN_W        - 1 : 0]  wrap_out_len;
    wire [IN_LEN_W        - 1 : 0]  incr_uncompr_out_len;
    wire [IN_LEN_W        - 1 : 0]  wrap_uncompr_out_len;
    wire [PKT_ADDR_W      - 1 : 0]  incr_out_addr;
    wire [PKT_ADDR_W      - 1 : 0]  wrap_out_addr;
    wire [PKT_ADDR_W      - 1 : 0]  fixed_out_addr;
    reg  [PKT_ADDR_W      - 1 : 0]  uncompr_out_addr;
    wire [IN_LEN_W        - 1 : 0]  fixed_out_len;
    wire [PKT_ADDR_W      - 1 : 0]  out_addr;
    wire [PKT_BYTEEN_W - 1 : 0 ]    out_byteen_pre;
    wire [PKT_BURST_TYPE_W - 1 : 0] out_bursttype;

    // ---------------------------------------------------
    // Signals that used with pipeline stage
    // ---------------------------------------------------
    reg [PKT_ADDR_W       - 1 : 0]  d0_in_addr;
    reg [PKT_ADDR_W       - 1 : 0]  d0_in_aligned_addr;
    reg                             d0_in_sop;
    reg                             d0_in_compressed_read;
    reg                             d0_in_uncompressed_read;
    reg                             d0_in_write;
    reg [PKT_BURST_SIZE_W - 1 : 0]  d0_in_size;
    reg [IN_LEN_W         - 1 : 0]  d0_in_len;
    reg                             d0_in_valid;

    reg                             d1_in_narrow;
    reg [PKT_ADDR_W       - 1 : 0]  d1_in_aligned_addr;
    reg                             d1_in_eop;
    reg                             d1_in_compressed_read;
    reg                             d1_in_uncompressed_read;
    reg [ST_DATA_W        - 1 : 0]  d1_in_data;
    reg [ST_CHANNEL_W     - 1 : 0]  d1_in_channel;
    reg                             d1_in_write;
    reg [PKT_BURST_SIZE_W - 1 : 0]  d1_in_size;
    reg [PKT_BYTEEN_W     - 1 : 0]  d1_in_byteen;

    // ---------------------------------------------------
    // State machine definitions
    // ---------------------------------------------------
    typedef enum bit [2:0] {
    ST_IDLE         = 3'b000,
    ST_COMP_TRANS   = 3'b001,   // This state is used for compressed transactions
                                // - Address and byte count needs to be calculated for every round internally
    ST_UNCOMP_TRANS = 3'b010,   // This state is used for uncompressed transaction where address is passthrough
                                // and bytecount is decremented based on max
    ST_UNCOMP_WR_SUBBURST = 3'b100
    } t_state;
    t_state state, next_state;

    // ---------------------------------------------------
    // Input burstwrap
    // ---------------------------------------------------
    genvar       i;
    generate begin : constant_or_variable_burstwrap
        for (i = 0; i < PKT_BURSTWRAP_W; i = i + 1) begin: assign_burstwrap_bit
            if (BURSTWRAP_CONST_MASK[i]) begin
                assign in_burstwrap[i]  = BURSTWRAP_CONST_VALUE[i];
            end
            else begin
                assign in_burstwrap[i]  = sink0_data[PKT_BURSTWRAP_L + i];
            end
        end
    end
    endgenerate

    // -------------------------------------------------------------------
    // Address Alignment:
    // AXI can send unaligned address, the BA internally aligns addresses
    // for it's calculation, first output address will be unaligned.
    // -------------------------------------------------------------------
    wire [PKT_ADDR_W + LOG2_NUM_SYMBOLS - 1 : 0 ] out_mask_and_aligned_addr;
    assign in_aligned_addr = out_mask_and_aligned_addr[PKT_ADDR_W - 1 : 0];
    altera_merlin_address_alignment
    #(
     .ADDR_W             (PKT_ADDR_W),
     .BURSTWRAP_W        (1), // Not used in burst adapter calculation usage of this module
     .TYPE_W             (0), // Not used in burst adapter calculation usage of this module
     .SIZE_W             (PKT_BURST_SIZE_W),
     .INCREMENT_ADDRESS  (0),
     .NUMSYMBOLS         (NUM_SYMBOLS)
    ) align_address_to_size
    (
     .clk(1'b0), .reset(1'b0), .in_valid(1'b0), .in_sop(1'b0), .in_eop(1'b0), .out_ready(),  // Dummy. Not used in INCREMENT_ADDRESS=0 settings
                                                                                             // This block is purely combi
     .in_data    ( { in_addr , in_size } ),
     .out_data   ( out_mask_and_aligned_addr )
    );

    // ------------------------------------------------------------
    // Internal registers which are shared for all calculations
    // ------------------------------------------------------------
    generate begin : pipe_blocks
        if (PIPE_INTERNAL == 0) begin : NO_PIPELINE_INPUT
            always_ff @(posedge clk or posedge reset) begin
                if (reset) begin
                    in_eop_reg               <= '0;
                    in_compressed_read_reg   <= '0;
                    in_uncompressed_read_reg <= '0;
                    in_data_reg              <= '0;
                    in_channel_reg           <= '0;
                    in_write_reg             <= '0;
                    in_size_reg              <= '0;
                    in_byteen_reg            <= '0;
                    in_aligned_addr_reg      <= '0;
                    in_narrow_reg            <= '0;
                end else begin
                    if (sink0_ready & sink0_valid) begin
                        in_eop_reg               <= in_eop;
                        in_data_reg              <= sink0_data;
                        in_channel_reg           <= sink0_channel;
                        in_compressed_read_reg   <= in_compressed_read;
                        in_uncompressed_read_reg <= in_uncompressed_read;
                        in_write_reg             <= in_write;
                        in_size_reg              <= in_size;
                        in_byteen_reg            <= in_byteen;
                        in_aligned_addr_reg      <= in_aligned_addr;
                        in_narrow_reg            <= in_narrow;
                    end // if (sink0_ready & sink0_valid)
                end // else: !if(reset)
            end // always_ff @
            always_comb begin
                d0_in_sop                = in_sop;
                d0_in_compressed_read    = in_compressed_read;
                d0_in_uncompressed_read  = in_uncompressed_read;
                d0_in_write              = in_write;
                d0_in_size               = in_size;
                d0_in_addr               = in_addr;
                d0_in_aligned_addr       = in_aligned_addr;
                d0_in_len                = in_len;
                d0_in_valid              = in_valid;

                d1_in_eop                = in_eop_reg;
                d1_in_compressed_read    = in_compressed_read_reg;
                d1_in_data               = in_data_reg;
                d1_in_channel            = in_channel_reg;
                d1_in_write              = in_write_reg;
                d1_in_size               = in_size_reg;
                d1_in_byteen             = in_byteen_reg;
                d1_in_aligned_addr       = in_aligned_addr_reg;
                d1_in_narrow             = in_narrow_reg;
                d1_in_uncompressed_read  = in_uncompressed_read_reg;
            end // always_comb
        end // block: NO_PIPELINE_INPUT
        else begin : PIPELINE_INPUT
            always_ff @(posedge clk or posedge reset) begin
                if (reset) begin
                    in_eop_reg               <= '0;
                    in_sop_reg               <= '0;
                    in_compressed_read_reg   <= '0;
                    in_uncompressed_read_reg <= '0;
                    in_data_reg              <= '0;
                    in_channel_reg           <= '0;
                    in_write_reg             <= '0;
                    in_size_reg              <= '0;
                    in_byteen_reg            <= '0;
                    in_addr_reg              <= '0;
                    in_aligned_addr_reg      <= '0;
                    in_len_reg               <= '0;
                    in_narrow_reg            <= '0;
                    in_valid_reg             <= '0;

                    d1_in_eop                <= '0;
                    d1_in_compressed_read    <= '0;
                    d1_in_data               <= '0;
                    d1_in_channel            <= '0;
                    d1_in_write              <= '0;
                    d1_in_size               <= '0;
                    d1_in_byteen             <= '0;
                end else begin
                    if (sink0_ready & sink0_valid) begin
                        in_eop_reg               <= in_eop;
                        in_sop_reg               <= in_sop;
                        in_data_reg              <= sink0_data;
                        in_channel_reg           <= sink0_channel;
                        in_compressed_read_reg   <= in_compressed_read;
                        in_uncompressed_read_reg <= in_uncompressed_read;
                        in_write_reg             <= in_write;
                        in_size_reg              <= in_size;
                        in_byteen_reg            <= in_byteen;
                        in_addr_reg              <= in_addr;
                        in_aligned_addr_reg      <= in_aligned_addr;
                        in_len_reg               <= in_len;
                        in_narrow_reg            <= in_narrow;
                    end
                    if (sink0_ready)
                        in_valid_reg <= in_valid;
                    if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                        ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                        d1_in_eop               <= in_eop_reg;
                        d1_in_compressed_read   <= in_compressed_read_reg;
                        d1_in_data              <= in_data_reg;
                        d1_in_channel           <= in_channel_reg;
                        d1_in_write             <= in_write_reg;
                        d1_in_size              <= in_size_reg;
                        d1_in_byteen            <= in_byteen_reg;
                        d1_in_aligned_addr      <= in_aligned_addr_reg;
                        d1_in_narrow            <= in_narrow_reg;
                        d1_in_uncompressed_read <= in_uncompressed_read_reg;
                    end // if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |...
                end // else: !if(reset)
            end // always_ff @
            always_comb begin
                d0_in_valid             = in_valid_reg;
                d0_in_sop               = in_sop_reg;
                d0_in_compressed_read   = in_compressed_read_reg;
                d0_in_uncompressed_read = in_uncompressed_read_reg;
                d0_in_write             = in_write_reg;
                d0_in_size              = in_size_reg;
                d0_in_addr              = in_addr_reg;
                d0_in_aligned_addr      = in_aligned_addr_reg;
                d0_in_len               = in_len_reg;
            end // always_comb
        end // block: PIPELINE_INPUT
    end // block: pipe_blocks
    endgenerate

    // --------------------------------------------------------
    // Calculate aligned length for first sub-burst which includes
    // 1. Aligned to master/slave boundaty
    // 2. Select first length for different cases
    // --------------------------------------------------------
    altera_merlin_burst_adapter_burstwrap_increment #(.WIDTH (PKT_BURSTWRAP_W)) the_burstwrap_increment
    (
     .mask (in_burstwrap),
     .inc  (in_boundary)
    );

    wire [PKT_ADDR_W           - 1 : 0]     addr_sel_in_bdry_smaller; // when in_bounday is smaller than out_boundary
    wire [OUT_BOUNDARY_WIDTH   - 1 : 0]     aligned_len_to_out_bdry;
    wire [LEN_WIDTH            - 1 : 0]     aligned_len_to_in_bdry;
    wire [BYTE_TO_WORD_SHIFT_W - 1 : 0]     byte_to_word_shift;
    reg  [LEN_WIDTH            - 1 : 0]     first_len;
    wire                                    in_len_smaller_not_cross_out_bndry;
    wire                                    in_len_smaller_not_cross_in_bndry;

    assign byte_to_word_shift  = BYTE_TO_WORD_SHIFT[BYTE_TO_WORD_SHIFT_W - 1 : 0];
    // ----------------------------------------
    // 1. Aligned to either slave boundary or
    //    master boundary
    // ----------------------------------------
    // Do a shift as we are dealing with length
    // ----------------------------------------
    assign addr_sel_in_bdry_smaller    = in_aligned_addr & in_burstwrap;
    assign aligned_len_to_in_bdry  = (in_boundary - addr_sel_in_bdry_smaller) >> byte_to_word_shift;

    // If MAX_OUT_LEN=1 and NUM_SYMBOLS=1, ADDR_SEL will become 0.
    // So, we handle it in 2 cases.
    // make a shift as we are dealing with length not bytecount
    generate begin: addr_sel_in_bdry_larger_signal_generator // when in_boundary is larger than out_boundary
        if (ADDR_SEL > 0) begin
            wire [ADDR_SEL - 1 : 0] addr_sel_in_bdry_larger  = in_aligned_addr[ADDR_SEL - 1 : 0];
            assign aligned_len_to_out_bdry                   = (OUT_BOUNDARY - addr_sel_in_bdry_larger) >> byte_to_word_shift;
        end else begin
            wire addr_sel_in_bdry_larger    = 0;
            assign aligned_len_to_out_bdry  = (OUT_BOUNDARY - addr_sel_in_bdry_larger) >> byte_to_word_shift;
        end
    end
    endgenerate

    wire                    in_full_size_write_wrap;
    wire                    in_full_size_read_wrap;
    wire                    in_default_converter;
    wire                    in_full_size_incr;
    reg                     in_default_converter_reg;
    reg                     in_full_size_incr_reg;

    wire                    next_out_sop;
    wire                    next_out_eop;
    wire                    is_passthru;
    wire                    enable_incr_converter;

    wire                    enable_fixed_converter;
    wire                    enable_write_wrap_converter;
    wire                    enable_read_wrap_converter;
    wire                    enable_incr_write_converter;
    wire                    enable_incr_read_converter;
    reg [LEN_WIDTH - 1 : 0] d0_first_len;

    wire                    is_write;
    assign is_write  = new_burst ? (d0_in_write) : d1_in_write;

    // -----------------------------------------------------------------------
    // Main calculation and conveters instantiation
    // -----------------------------------------------------------------------
    // Enable the converters when:
    // - (sink0_valid  && (source0_ready | ~source0_valid):
    //         : when the BA is in idle (!source_valid) and there is a packet coming at input
    //           or the outpacket has been accepted and there is a packet coming
    // - (source0_endofpacket ?  1'b0 :(state == ST_COMP_TRANS) && (!source0_valid | source0_ready))
    //         : For compressed read, need something consider at end_of_packet, only when seeing
    //           end_of_packet then turn off converter.
    // Each converter will be turned on with its own enable based on different type of incoming burst
    // -----------------------------------------------------------------------
    generate begin : internal_signals_conveter_instantiation_for_different_typeofslave
        if (IS_NON_BURSTING_SLAVE || (INCR_AVALON_SYS && IN_NARROW_SIZE)) begin : non_bursting_slave
            // in case the slave is non-bursting and incr system but it does non data packing, so slave
            // still see in narrrow : narrow-to-wide axi4 lite master, n-w ahb slave
            reg [PKT_BURST_TYPE_W - 1 : 0]  in_bursttype_reg;
            wire [PKT_BYTE_CNT_W  - 1 : 0]  fixed_out_byte_cnt;
            wire [PKT_BURST_SIZE_W - 1 : 0] d0_in_size_value;
            wire [PKT_BURST_TYPE_W - 1 : 0] d0_in_bursttype_value;
            reg [PKT_BURST_TYPE_W - 1 : 0]  d0_in_bursttype;
            reg [PKT_BURST_TYPE_W - 1 : 0]  d1_in_bursttype;
            reg [PKT_BURSTWRAP_W  - 1 : 0]  d1_in_burstwrap;
            assign fixed_out_byte_cnt = fixed_out_len << log2_numsymbols;
            //----------------------------------------------------------------
            // I. Pipeline input stage
            //----------------------------------------------------------------
            if(PIPE_INTERNAL == 0) begin : NO_PIPELINE_INPUT
                always_ff @(posedge clk or posedge reset) begin
                    if (reset) begin
                        in_bursttype_reg <= '0;
                        in_burstwrap_reg <= '0;
                    end else begin
                        if (sink0_ready & sink0_valid) begin
                            in_bursttype_reg <= in_bursttype;
                            in_burstwrap_reg <= in_burstwrap;
                        end
                    end // else: !if(reset)
                end // always_ff @
                always_comb begin
                    d0_in_bursttype  = in_bursttype;
                    d1_in_bursttype  = in_bursttype_reg;
                    d1_in_burstwrap  = in_burstwrap_reg;
                end // always_comb
            end
            else begin : PIPELINE_INPUT
                always_ff @(posedge clk or posedge reset) begin
                    if (reset) begin
                        d1_in_bursttype  <= '0;
                        d1_in_burstwrap  <= '0;
                        in_bursttype_reg <= '0;
                        in_burstwrap_reg <= '0;
                    end else begin
                        if (sink0_ready & sink0_valid) begin
                            in_bursttype_reg <= in_bursttype;
                            in_burstwrap_reg <= in_burstwrap;
                        end
                        if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                            ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                            d1_in_bursttype <= in_bursttype_reg;
                            d1_in_burstwrap <= in_burstwrap_reg;
                        end
                    end // else: !if(reset)
                end // always_ff @
                always_comb begin
                    d0_in_bursttype  = in_bursttype_reg;
                end // always_comb
            end // block: PIPELINE_INPUT

            assign new_burst               =  fixed_new_burst;
            assign d0_in_size_value        = new_burst ? d0_in_size : d1_in_size;
            assign d0_in_bursttype_value   = new_burst ? d0_in_bursttype : d1_in_bursttype;

            // -----------------------------------------------------------------------
            // II. Conveter enable signals: Turn on/off each conveter accordingly
            // -----------------------------------------------------------------------
            assign enable_fixed_converter = (d0_in_valid  && (source0_ready | !source0_valid) || (source0_endofpacket ?  1'b0 :(state == ST_COMP_TRANS) && (!source0_valid | source0_ready)));

            // -----------------------------------------------------------------------
            // III. Packet signals
            // -----------------------------------------------------------------------
            assign next_out_sop  = ((state == ST_COMP_TRANS) & source0_ready & !(fixed_new_burst)) ? 1'b0 : d0_in_sop;
            assign next_out_eop = (state == ST_COMP_TRANS) ?  fixed_new_burst  : d1_in_eop;

            // -----------------------------------------------------------------------
            // IV. Output signals
            // -----------------------------------------------------------------------
            assign out_byte_cnt  = fixed_out_byte_cnt;
            assign out_addr      = fixed_out_addr;
            assign out_bursttype =  INCR;
            // -----------------------------------------------------------------------
            // V. Converters instantiation
            // -----------------------------------------------------------------------
            // When the slave is non-bursting, use default conveter which conveter all
            // to non-bursting.
            //------------------------------------------------------------------------
            altera_default_burst_converter
            #(
             .BURST_TYPE_W      (PKT_BURST_TYPE_W),
             .ADDR_W            (PKT_ADDR_W),
             .BNDRY_W           (PKT_BURSTWRAP_W),
             .BURST_SIZE_W      (PKT_BURST_SIZE_W),
             .BYTEEN_W          (PKT_BYTEEN_W),
             .LEN_W             (IN_LEN_W),
             .LOG2_NUM_SYMBOLS  (LOG2_NUM_SYMBOLS),
             .IN_NARROW_SIZE    (IN_NARROW_SIZE),
             .IS_AXI_SLAVE      (IS_AXI_SLAVE)
            )
            the_default_burst_converter
            (
             .clk                       (clk),
             .reset                     (reset),
             .enable                    (enable_fixed_converter),
             .in_addr                   (d0_in_aligned_addr),
             .in_addr_reg               (d1_in_aligned_addr),
             .in_bursttype              (d0_in_bursttype_value),
             .in_burstwrap_reg          (d1_in_burstwrap),
             .in_len                    (d0_in_len),
             .in_size_value             (d0_in_size_value),
             .in_is_write               (is_write),
             .out_len                   (fixed_out_len),
             .out_addr                  (fixed_out_addr),
             .new_burst                 (fixed_new_burst),
             .out_byteen                (out_byteen_pre)
            );
        end
        else if (INCR_AVALON_SYS) begin : incr_avalon_system
            reg [PKT_BURSTWRAP_W  - 1 : 0]  d1_in_burstwrap;
            //----------------------------------------------------------------
            // I. Pipeline input stage
            //----------------------------------------------------------------
            if (PIPE_INTERNAL == 0) begin : NO_PIPELINE_INPUT
                always_ff @(posedge clk or posedge reset) begin
                    if (reset) begin
                        in_burstwrap_reg <= '0;
                    end else begin
                        if (sink0_ready & sink0_valid) begin
                            in_burstwrap_reg <= in_burstwrap;
                        end
                    end // else: !if(reset)
                end // always_ff @
                always_comb begin
                    d1_in_burstwrap  = in_burstwrap_reg;
                end // always_comb
            end // block: NO_PIPELINE_INPUT
            else begin : PIPELINE_INPUT
                reg [PKT_BURST_SIZE_W - 1 : 0] d0_in_size_dl;
                always_ff @(posedge clk or posedge reset) begin
                    if (reset) begin
                        in_burstwrap_reg <= '0;
                        d1_in_burstwrap  <= '0;
                    end else begin
                        if (sink0_ready & sink0_valid) begin
                            in_burstwrap_reg <= in_burstwrap;
                        end
                        if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                            ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                            d1_in_burstwrap <= in_burstwrap_reg;
                            end // if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |...
                    end // else: !if(reset)
                end // always_ff @
            end // block: PIPELINE_INPUT

            wire [PKT_BYTE_CNT_W  - 1 : 0]  incr_out_byte_cnt;
            assign incr_out_byte_cnt  = (d1_in_compressed_read ? incr_out_len : incr_uncompr_out_len) << log2_numsymbols;
            assign new_burst  = incr_new_burst;

            // -----------------------------------------------------------------------
            // I. Conveter enable signals: Turn on/off each conveter accordingly
            // -----------------------------------------------------------------------
            assign enable_incr_converter = (d0_in_valid  && (source0_ready | !source0_valid) || (source0_endofpacket ?  1'b0 :(state == ST_COMP_TRANS) && (!source0_valid | source0_ready)));

            // -----------------------------------------------------------------------
            // III. Packet signals
            // -----------------------------------------------------------------------
            assign next_out_sop  = ((state == ST_COMP_TRANS) & source0_ready & !(incr_new_burst)) ? 1'b0 : d0_in_sop;
            assign next_out_eop  = (state == ST_COMP_TRANS) ?  incr_new_burst  : d1_in_eop;

            // -----------------------------------------------------------------------
            // IV. Output signals
            // -----------------------------------------------------------------------
            assign out_byte_cnt  = incr_out_byte_cnt;
            assign out_addr  = incr_out_addr;
            // avoid QIS warning
            assign out_byteen_pre  = d1_in_byteen;
            assign out_bursttype =  INCR;
            // -----------------------------------------------------------------------
            // V. Converters instantiation
            // -----------------------------------------------------------------------
            // When system is purely INCR, only need one converter incr.
            //------------------------------------------------------------------------
            altera_incr_burst_converter
            #(
             .LEN_W                 (IN_LEN_W),
             .MAX_OUT_LEN           (MAX_OUT_LEN),
             .ADDR_W                (PKT_ADDR_W),
             .BNDRY_W               (PKT_BURSTWRAP_W),
             .BURSTSIZE_W           (PKT_BURST_SIZE_W),
             .IN_NARROW_SIZE        (IN_NARROW_SIZE),
             .NUM_SYMBOLS           (NUM_SYMBOLS),
             .LOG2_NUM_SYMBOLS      (LOG2_NUM_SYMBOLS),
             .PURELY_INCR_AVL_SYS   (INCR_AVALON_SYS)
            )
            the_converter_for_avalon_incr_slave
            (
             .clk                     (clk),
             .reset                   (reset),
             .enable                  (enable_incr_converter),
             .in_len                  (d0_in_len),
             .in_sop                  (d0_in_sop),
             .in_burstwrap_reg        (d1_in_burstwrap),
             .in_size                 (d0_in_size),
             .in_size_reg             (d1_in_size),
             .in_addr                 (d0_in_aligned_addr),
             .in_addr_reg             (d1_in_aligned_addr),
             .is_write                (is_write),
             .out_len                 (incr_out_len),
             .uncompr_out_len         (incr_uncompr_out_len),
             .out_addr                (incr_out_addr),
             .new_burst_export        (incr_new_burst)
            );

        end
        else begin
            if (IS_WRAP_AVALON_SLAVE) begin : wrap_avalon_slave
                reg [LEN_WIDTH - 1 : 0]        first_len_reg;
                wire                           in_narrow_or_fixed;
                reg [PKT_BURST_TYPE_W - 1 : 0] in_bursttype_reg;
                wire [PKT_BYTE_CNT_W - 1 : 0]  incr_out_byte_cnt;
                wire [PKT_BYTE_CNT_W - 1 : 0]  fixed_out_byte_cnt;
                wire                           in_read_but_not_fixed_or_narrow;
                wire                           in_write_but_not_fixed_or_narrow;
                reg                            in_read_but_not_fixed_or_narrow_reg;
                reg                            in_write_but_not_fixed_or_narrow_reg;
                reg                            in_narrow_or_fixed_reg;

                reg                            d0_in_read_but_not_fixed_or_narrow;
                reg                            d0_in_write_but_not_fixed_or_narrow;
                reg                            d0_in_default_converter;
                reg [PKT_BURSTWRAP_W  - 1 : 0] d0_in_burstwrap;
                wire [PKT_BURST_TYPE_W - 1 : 0] d0_in_bursttype_value;
                wire [PKT_BURST_SIZE_W - 1 : 0] d0_in_size_value;
                reg [PKT_BURST_TYPE_W - 1 : 0]  d0_in_bursttype;

                reg                             d1_in_narrow_or_fixed;
                reg                             d1_in_read_but_not_fixed_or_narrow;
                reg                             d1_in_write_but_not_fixed_or_narrow;
                reg                             d1_in_default_converter;
                reg [PKT_BURSTWRAP_W  - 1 : 0]  d1_in_burstwrap;
                reg [PKT_BURST_TYPE_W - 1 : 0]  d1_in_bursttype;

                wire                            in_fixed  = (in_bursttype == 2'b00) || (in_bursttype == 2'b11);

                assign new_burst                         = (d1_in_narrow_or_fixed ? fixed_new_burst : incr_new_burst);
                assign in_read_but_not_fixed_or_narrow  = in_compressed_read & !in_narrow_or_fixed;
                assign in_write_but_not_fixed_or_narrow = in_write & !in_narrow_or_fixed;
                assign in_narrow_or_fixed               = in_narrow || in_fixed;
                assign in_default_converter             = in_fixed || in_narrow || in_uncompressed_read;
                assign incr_out_byte_cnt                = (d1_in_compressed_read ? incr_out_len : incr_uncompr_out_len) << log2_numsymbols;
                assign fixed_out_byte_cnt               = fixed_out_len << log2_numsymbols;

                //----------------------------------------------------------------
                // I. Pipeline input stage
                //----------------------------------------------------------------
                if (PIPE_INTERNAL == 0) begin : NO_PIPELINE_INPUT
                    always_ff @(posedge clk or posedge reset) begin
                        if (reset) begin
                            in_narrow_or_fixed_reg               <= '0;
                            in_read_but_not_fixed_or_narrow_reg  <= '0;
                            in_write_but_not_fixed_or_narrow_reg <= '0;
                            in_default_converter_reg             <= '0;
                            in_burstwrap_reg                     <= '0;
                            in_bursttype_reg                     <= '0;
                        end else begin
                            if (sink0_ready & sink0_valid) begin
                                in_narrow_or_fixed_reg               <= in_narrow_or_fixed;
                                in_read_but_not_fixed_or_narrow_reg  <= in_read_but_not_fixed_or_narrow;
                                in_write_but_not_fixed_or_narrow_reg <= in_write_but_not_fixed_or_narrow;
                                in_default_converter_reg             <= in_default_converter;
                                in_burstwrap_reg                     <= in_burstwrap;
                                in_bursttype_reg                     <= in_bursttype;
                            end // if (sink0_ready & sink0_valid)
                        end // else: !if(reset)
                    end // always_ff @
                    always_comb begin
                        d0_first_len                         = first_len;
                        d0_in_read_but_not_fixed_or_narrow   = in_read_but_not_fixed_or_narrow;
                        d0_in_write_but_not_fixed_or_narrow  = in_write_but_not_fixed_or_narrow;
                        d0_in_default_converter              = in_default_converter;
                        d1_in_narrow_or_fixed                = in_narrow_or_fixed_reg;
                        d1_in_read_but_not_fixed_or_narrow   = in_read_but_not_fixed_or_narrow_reg;
                        d1_in_write_but_not_fixed_or_narrow  = in_write_but_not_fixed_or_narrow_reg;
                        d1_in_default_converter              = in_default_converter_reg;
                        d0_in_burstwrap                      = in_burstwrap;
                        d1_in_burstwrap                      = in_burstwrap_reg;
                        d0_in_bursttype                      = in_bursttype;
                        d1_in_bursttype                      = in_bursttype_reg;
                    end // always_comb
                end // block: NO_PIPELINE_INPUT
                else begin : PIPELINE_INPUT
                    always_ff @(posedge clk or posedge reset) begin
                        if (reset) begin
                            in_narrow_or_fixed_reg               <= '0;
                            in_read_but_not_fixed_or_narrow_reg  <= '0;
                            in_write_but_not_fixed_or_narrow_reg <= '0;
                            in_default_converter_reg             <= '0;
                            d1_in_narrow_or_fixed                <= '0;
                            d1_in_read_but_not_fixed_or_narrow   <= '0;
                            d1_in_write_but_not_fixed_or_narrow  <= '0;
                            d1_in_default_converter              <= '0;
                            first_len_reg                        <= '0;
                            in_burstwrap_reg                     <= '0;
                            in_bursttype_reg                     <= '0;
                            d1_in_bursttype                      <= '0;
                        end else begin
                        if (sink0_ready & sink0_valid) begin
                            in_bursttype_reg                     <= in_bursttype;
                            in_burstwrap_reg                     <= in_burstwrap;
                            in_narrow_or_fixed_reg               <= in_narrow_or_fixed;
                            in_read_but_not_fixed_or_narrow_reg  <= in_read_but_not_fixed_or_narrow;
                            in_write_but_not_fixed_or_narrow_reg <= in_write_but_not_fixed_or_narrow;
                            in_default_converter_reg             <= in_default_converter;
                        end // if (sink0_ready & sink0_valid)
                            if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                                ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                                first_len_reg                       <= first_len;
                                d1_in_narrow_or_fixed               <= in_narrow_or_fixed_reg;
                                d1_in_read_but_not_fixed_or_narrow  <= in_read_but_not_fixed_or_narrow_reg;
                                d1_in_write_but_not_fixed_or_narrow <= in_write_but_not_fixed_or_narrow_reg;
                                d1_in_default_converter             <= in_default_converter_reg;
                                d1_in_burstwrap                     <= in_burstwrap_reg;
                                d1_in_bursttype                     <= in_bursttype_reg;
                            end
                        end // else: !if(reset)
                    end // always_ff @
                    always_comb begin
                        d0_in_default_converter              = in_default_converter_reg;
                        d0_first_len                         = first_len_reg;
                        d0_in_read_but_not_fixed_or_narrow   = in_read_but_not_fixed_or_narrow_reg;
                        d0_in_write_but_not_fixed_or_narrow  = in_write_but_not_fixed_or_narrow_reg;
                        d0_in_burstwrap                      = in_burstwrap_reg;
                        d0_in_bursttype                      = in_bursttype_reg;
                    end
                end // block: PIPELINE_INPUT

                assign d0_in_size_value        = new_burst ? d0_in_size : d1_in_size;
                assign d0_in_bursttype_value   = new_burst ? d0_in_bursttype : d1_in_bursttype;
                // -------------------------------------------------------------------------
                // II. First length calculation
                // -------------------------------------------------------------------------
                wire same_boundary;
                // ----------------------------------------------------------
                // Slave is a wrapping slave, if in_burst wrap has same boundary
                // pass the burst untouched.
                // ----------------------------------------------------------
                if (ADDR_SEL <= PKT_BURSTWRAP_W - 1) begin
                    assign same_boundary = (in_boundary[ADDR_SEL] == 1);
                end else begin
                    assign same_boundary = 0;
                end

                // --------------------------------------------------------------------------
                // 1. If in_burst wrapping boundary is lager or INCR burst then always
                // send first sub_burst length is aligned to slave boudary,
                // 2. Else aligned to master boundary
                // Notes:
                // For INCR, it is tricky that the length can be any value but as the slave is
                // wrapping, still needs to convert the burst at slave boundary
                // (in_len <= aligned_len_to_out_bdry): can tell the in INCR burst can totally
                // fit in slave boundary -> pass thru
                // This works same way for INCOMPLETE wrap as well, so cannot make seperate
                // optimization when dont support INCOMPLETE wrap
                // --------------------------------------------------------------------------
                assign in_len_smaller_not_cross_out_bndry  = (in_len <= aligned_len_to_out_bdry);
                assign in_len_smaller_not_cross_in_bndry   = (in_len <= aligned_len_to_in_bdry);
                always_comb begin
                    if ((in_boundary > OUT_BOUNDARY) || (in_burstwrap[BNDRY_WIDTH - 1] == 1)) begin
                        first_len  = aligned_len_to_out_bdry;
                        if (in_len_smaller_not_cross_out_bndry || same_boundary)
                            first_len  = in_len;
                    end
                    else begin
                        first_len  = aligned_len_to_in_bdry;
                        if (in_len_smaller_not_cross_in_bndry || same_boundary)
                            first_len = in_len;
                    end
                end // always_comb

                // -----------------------------------------------------------------------
                // III. Conveter enable signals: Turn on/off each conveter accordingly
                // -----------------------------------------------------------------------
                // WRAPPING AVALON: two conveters:
                //  1. wrap_burst_conveter    -> handle full_size INCR, WRAP
                //  2. default_burst_conveter -> handle narrow_size burst
                //  opt, seperate enable for write and reach
                // -----------------------------------------------------------------------
                // fixed_new_burst && incr_new_burst : note this for incr_write as it is write_enable, cannot turn on incase a read happen before
                assign enable_incr_write_converter = (d0_in_valid && d0_in_write_but_not_fixed_or_narrow && fixed_new_burst && incr_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_write_but_not_fixed_or_narrow && !new_burst));
                assign enable_incr_read_converter  = (d0_in_valid && d0_in_read_but_not_fixed_or_narrow && fixed_new_burst && (source0_ready || !source0_valid) || (( state == ST_COMP_TRANS) && source0_ready && d1_in_read_but_not_fixed_or_narrow && !new_burst));
                assign enable_fixed_converter      = (d0_in_valid && d0_in_default_converter && incr_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_default_converter && !new_burst));

                // -----------------------------------------------------------------------
                // IV. Packet signals
                // -----------------------------------------------------------------------
                assign next_out_sop  = ((state == ST_COMP_TRANS) & source0_ready & !(d1_in_default_converter ? fixed_new_burst : incr_new_burst)) ? 1'b0 : d0_in_sop;
                assign next_out_eop  = (state == ST_COMP_TRANS) ?  (d1_in_default_converter ? fixed_new_burst : incr_new_burst)  : d1_in_eop;

                // -----------------------------------------------------------------------
                // V. Output signals
                // -----------------------------------------------------------------------
                assign out_byte_cnt  = d1_in_default_converter ? fixed_out_byte_cnt : incr_out_byte_cnt;
                assign out_addr      = d1_in_default_converter ? fixed_out_addr : incr_out_addr;
                assign out_bursttype  = INCR;
                // -----------------------------------------------------------------------
                // VI. Converters instantiation
                // -----------------------------------------------------------------------
                // When slave is Wrap Avalon slave, use wrap conveter and default
                //------------------------------------------------------------------------
                top_wrap_and_default_conveters
                #(
                .LEN_W                  (IN_LEN_W),
                .MAX_OUT_LEN            (MAX_OUT_LEN),
                .ADDR_W                 (PKT_ADDR_W),
                .BNDRY_W                (PKT_BURSTWRAP_W),
                .OPTIMIZE_WRITE_BURST   (0),
                .BURST_TYPE_W           (PKT_BURST_TYPE_W),
                .BURST_SIZE_W           (PKT_BURST_SIZE_W),
                .BYTEEN_W               (PKT_BYTEEN_W),
                .NUM_SYMBOLS            (NUM_SYMBOLS),
                .IN_NARROW_SIZE         (IN_NARROW_SIZE),
                .LOG2_NUM_SYMBOLS       (LOG2_NUM_SYMBOLS),
                .IS_AXI_SLAVE           (IS_AXI_SLAVE)
                )
                the_conveters_for_wrap_avalon_slave
                (
                .clk                            (clk),
                .reset                          (reset),
                // -------------------
                // wrap conveter
                // -------------------
                .enable_read                    (enable_incr_read_converter),
                .enable_write                   (enable_incr_write_converter),
                .in_len                         (d0_in_len),
                .first_len                      (d0_first_len),
                .in_sop                         (d0_in_sop),
                .in_burstwrap                   (d0_in_burstwrap),
                .in_burstwrap_reg               (d1_in_burstwrap),
                .in_aligned_addr                (d0_in_aligned_addr),
                .in_aligned_addr_reg            (d1_in_aligned_addr),
                .wrap_conveter_out_len          (incr_out_len),
                .wrap_conveter_uncompr_out_len  (incr_uncompr_out_len),
                .wrap_conveter_out_addr         (incr_out_addr),
                 .wrap_conveter_new_burst        (incr_new_burst),
                // -------------------
                // default conveter
                // -------------------
                .enable_fixed_converter         (enable_fixed_converter),
                .in_bursttype                   (d0_in_bursttype_value),
                .in_size_value                  (d0_in_size_value),
                .is_write                       (is_write),
                .fixed_conveter_out_len         (fixed_out_len),
                .fixed_conveter_out_addr        (fixed_out_addr),
                .fixed_conveter_new_burst       (fixed_new_burst),
                .out_byteen_pre                 (out_byteen_pre)
                );
            end // if (IS_WRAP_AVALON_SLAVE)

            if (IS_AXI_SLAVE) begin
                reg [PKT_BURST_TYPE_W - 1 : 0] in_bursttype_reg;
                reg                            in_passthru_reg;
                reg                            in_incr_reg;
                wire                           in_read_wrap_conveter;
                wire                           in_write_wrap_conveter;
                reg                            in_read_wrap_conveter_reg;
                reg                            in_write_wrap_conveter_reg;
                wire                           in_incr                          = (in_bursttype == 2'b01) && !in_uncompressed_read;
                wire                           in_wrap                          = (in_bursttype == 2'b10);
                wire                           in_fixed                         = (in_bursttype == 2'b00) || (in_bursttype == 2'b11);
                wire                           in_narrow_read_wrap_smaller_16   = in_narrow && in_wrap && is_passthru && in_compressed_read;
                wire                           in_narrow_write_wrap_smaller_16  = in_narrow && in_wrap && is_passthru && in_write;
                wire                           in_narrow_wrap_larger_16         = in_narrow && in_wrap && !is_passthru;
                reg [LEN_WIDTH - 1 : 0]        first_len_reg;
                wire [PKT_BYTE_CNT_W  - 1 : 0]  wrap_out_byte_cnt;
                wire [PKT_BYTE_CNT_W  - 1 : 0]  fixed_out_byte_cnt;
                wire [PKT_BYTE_CNT_W  - 1 : 0]  incr_out_byte_cnt;
                wire [PKT_BURST_SIZE_W - 1 : 0] d0_in_size_value;

                reg                             d0_in_incr;
                reg                             d0_in_read_wrap_conveter;
                reg                             d0_in_write_wrap_conveter;
                reg                             d0_in_default_converter;
                reg [PKT_BURSTWRAP_W  - 1 : 0]  d0_in_burstwrap;
                wire [PKT_BURST_TYPE_W - 1 : 0] d0_in_bursttype_value;
                reg [PKT_BURST_TYPE_W - 1 : 0]  d0_in_bursttype;

                reg                             d1_in_incr;
                reg                             d1_in_read_wrap_conveter;
                reg                             d1_in_write_wrap_conveter;
                reg                             d1_in_default_converter;
                reg [PKT_BURSTWRAP_W  - 1 : 0]  d1_in_burstwrap;
                reg [PKT_BURST_TYPE_W - 1 : 0]  d1_in_bursttype;
                reg                             d1_in_passthru;


                assign incr_out_byte_cnt  = (d1_in_compressed_read ? incr_out_len : incr_uncompr_out_len) << log2_numsymbols;
                assign wrap_out_byte_cnt  = (d1_in_compressed_read ? wrap_out_len : wrap_uncompr_out_len) << log2_numsymbols;
                assign fixed_out_byte_cnt = fixed_out_len << log2_numsymbols;

                assign in_full_size_read_wrap  = in_compressed_read & in_wrap & !in_narrow;
                assign in_full_size_write_wrap = in_write & in_wrap & !in_narrow;
                assign in_read_wrap_conveter   = in_full_size_read_wrap  || in_narrow_read_wrap_smaller_16;
                assign in_write_wrap_conveter  = in_full_size_write_wrap || in_narrow_write_wrap_smaller_16;
                assign in_default_converter    = in_narrow_wrap_larger_16 || in_fixed || in_uncompressed_read;


                assign new_burst                       = (d1_in_default_converter ? fixed_new_burst : (d1_in_incr ? incr_new_burst : wrap_new_burst));
                // is_passthru : still read from real input, as we want to shift 1 clock here, all control signal and first len
                assign is_passthru = in_sop ? (in_passthru) : in_passthru_reg;
                //----------------------------------------------------------------
                // I. Pipeline input stage
                //----------------------------------------------------------------
                if(PIPE_INTERNAL == 0) begin : NO_PIPELINE_INPUT
                    always_ff @(posedge clk or posedge reset) begin
                        if (reset) begin
                            in_write_wrap_conveter_reg <= '0;
                            in_read_wrap_conveter_reg  <= '0;
                            in_default_converter_reg   <= '0;
                            in_incr_reg                <= '0;
                            in_burstwrap_reg           <= '0;
                            in_bursttype_reg           <= '0;
                            in_passthru_reg            <= '0;
                        end else begin
                            if (sink0_ready & sink0_valid) begin
                                in_burstwrap_reg           <= in_burstwrap;
                                in_write_wrap_conveter_reg <= in_write_wrap_conveter;
                                in_read_wrap_conveter_reg  <= in_read_wrap_conveter;
                                in_default_converter_reg   <= in_default_converter;
                                in_incr_reg                <= in_incr;
                                in_bursttype_reg           <= in_bursttype;
                            end
                            if (sink0_valid & sink0_ready & in_sop) begin
                                in_passthru_reg         <= in_passthru;
                            end
                        end // else: !if(reset)
                    end // always_ff @
                    always_comb begin
                        d0_in_incr                 = in_incr;
                        d0_in_default_converter    = in_default_converter;
                        d0_in_read_wrap_conveter   = in_read_wrap_conveter;
                        d0_in_write_wrap_conveter  = in_write_wrap_conveter;
                        d0_first_len               = first_len;
                        d0_in_burstwrap            = in_burstwrap;
                        d0_in_bursttype            = in_bursttype;
                        d1_in_burstwrap            = in_burstwrap_reg;
                        d1_in_bursttype            = in_bursttype_reg;
                        d1_in_passthru             = in_passthru_reg;
                        d1_in_default_converter    = in_default_converter_reg;
                        d1_in_read_wrap_conveter   = in_read_wrap_conveter_reg;
                        d1_in_write_wrap_conveter  = in_write_wrap_conveter_reg;
                        d1_in_incr                 = in_incr_reg;
                    end
                end
                else begin : PIPELINE_INPUT
                    always_ff @(posedge clk or posedge reset) begin
                        if (reset) begin
                            in_write_wrap_conveter_reg <= '0;
                            in_read_wrap_conveter_reg  <= '0;
                            in_default_converter_reg   <= '0;
                            d1_in_default_converter    <= '0;
                            d1_in_read_wrap_conveter   <= '0;
                            d1_in_write_wrap_conveter  <= '0;
                            first_len_reg              <= '0;
                            in_incr_reg                <= '0;
                            d1_in_burstwrap            <= '0;
                            in_burstwrap_reg           <= '0;
                            in_bursttype_reg           <= '0;
                            d1_in_bursttype            <= '0;
                            in_passthru_reg            <= '0;
                        end else begin
                            if (sink0_ready & sink0_valid) begin
                                in_burstwrap_reg           <= in_burstwrap;
                                in_write_wrap_conveter_reg <= in_write_wrap_conveter;
                                in_read_wrap_conveter_reg  <= in_read_wrap_conveter;
                                in_default_converter_reg   <= in_default_converter;
                                first_len_reg              <= first_len;
                                in_incr_reg                <= in_incr;
                                in_bursttype_reg           <= in_bursttype;
                            end
                            if (in_valid & sink0_ready & in_sop)
                                in_passthru_reg <= in_passthru;
                            if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                                ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                                d1_in_default_converter   <= in_default_converter_reg;
                                d1_in_read_wrap_conveter  <= in_read_wrap_conveter_reg;
                                d1_in_write_wrap_conveter <= in_write_wrap_conveter_reg;
                                d1_in_incr                <= in_incr_reg;
                                d1_in_burstwrap           <= in_burstwrap_reg;
                                d1_in_bursttype           <= in_bursttype_reg;
                                d1_in_passthru            <= in_passthru_reg;
                            end
                        end // else: !if(reset)
                    end // always_ff @
                    always_comb begin
                        d0_in_burstwrap            = in_burstwrap_reg;
                        d0_in_incr                 = in_incr_reg;
                        d0_in_default_converter    = in_default_converter_reg;
                        d0_in_read_wrap_conveter   = in_read_wrap_conveter_reg;
                        d0_in_write_wrap_conveter  = in_write_wrap_conveter_reg;
                        d0_first_len               = first_len_reg;
                        d0_in_bursttype            = in_bursttype_reg;
                    end
                end

                assign d0_in_size_value        = new_burst ? d0_in_size : d1_in_size;
                assign d0_in_bursttype_value   = new_burst ? d0_in_bursttype : d1_in_bursttype;
                // -------------------------------------------------------------------------
                // II. First length calculation
                // -------------------------------------------------------------------------
                // For AXI slave, avalon master must set alwaysBurstMaxBurst so
                // INCOMPLETE wrap burst will not happen
                // 1. If any wrapping burst that smaller than 16 -> pass thru
                // 2. Else first sub_burst length is aligned to slave boundary
                // -------------------------------------------------------------------------
                //wire passthru = (in_len < aligned_len_to_out_bdry) || is_passthru; // why compare here? Keep this until we figure out why.
                always_comb begin
                    if (in_boundary > OUT_BOUNDARY) begin
                        first_len = is_passthru ? in_len : aligned_len_to_out_bdry;
                    end else begin
                        first_len = is_passthru ? in_len : aligned_len_to_in_bdry;
                    end
                end // always_comb

                // -----------------------------------------------------------------------
                // III. Conveter enable signals: Turn on/off each conveter accordingly
                // -----------------------------------------------------------------------
                // AXI slave: three conveters:
                //  1. wrap_burst_conveter    -> handle WRAP
                //     1.1 : full size wrap   --> convert to fit in slave boundary
                //     1.2 : narrow size wrap
                //                            ---> <= 16 : pass thru
                //                            ---> > 16 : convert to non-bursting
                //  2. incr_burst_convter     -> handle full/narrow size INCR
                //  3. default_burst_conveter -> handle FIXED
                // -----------------------------------------------------------------------
                // Note: narrow wrap with length larger 16 can happen with Avalon narrow wraping
                // master to AXI slave. To support this, it will hurt fmax
                // also the WA adapter currently not pack data in this case, to be better support
                // need to start from WA first
                // -----------------------------------------------------------------------
                wire incr_wrap_new_burst;
                assign incr_wrap_new_burst                   = incr_new_burst && wrap_new_burst;

                assign enable_incr_converter       = (d0_in_valid && d0_in_incr && fixed_new_burst && wrap_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_incr && !new_burst));
                assign enable_write_wrap_converter = (d0_in_valid && d0_in_write_wrap_conveter && fixed_new_burst && incr_wrap_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_write_wrap_conveter && !new_burst));
                assign enable_read_wrap_converter  = (d0_in_valid && d0_in_read_wrap_conveter && fixed_new_burst && incr_wrap_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_read_wrap_conveter && !new_burst));
                assign enable_fixed_converter      = (d0_in_valid && d0_in_default_converter && incr_wrap_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_default_converter && !new_burst));

                // -----------------------------------------------------------------------
                // IV. Packet signals
                // -----------------------------------------------------------------------
                assign next_out_sop  = ((state == ST_COMP_TRANS) & source0_ready & !(d1_in_default_converter ? fixed_new_burst : (d1_in_incr ? incr_new_burst : wrap_new_burst))) ? 1'b0 : d0_in_sop;
                assign next_out_eop  = (state == ST_COMP_TRANS) ?  (d1_in_default_converter ? fixed_new_burst : (d1_in_incr ? incr_new_burst : wrap_new_burst))  : d1_in_eop;

                // -----------------------------------------------------------------------
                // V. Output signal
                // -----------------------------------------------------------------------
                assign out_byte_cnt  = d1_in_default_converter ? fixed_out_byte_cnt : (d1_in_incr ? incr_out_byte_cnt : wrap_out_byte_cnt);
                assign out_addr      = d1_in_default_converter ? fixed_out_addr : (d1_in_incr ? incr_out_addr : wrap_out_addr);
                // If AXI slave, out_bursttype = INCR if either of the following 2 conditions is met:
                //  1) in_passthru (i.e. the input burst count < 16).
                //  2) input packet has bursttype == RESERVED (Repeated Wrap).
                // Else, out_bursttype = in_bursttype.
                // For all other slaves, change the bursttype to INCR.
                assign out_bursttype  = (!d1_in_passthru || d1_in_bursttype == RESERVED) ? INCR : d1_in_bursttype;

                // -----------------------------------------------------------------------
                // VI. Converters instantiation
                // -----------------------------------------------------------------------
                // When slave is AXI slave, use 3 convrters, wrap, incr and default(fixed handling)
                //------------------------------------------------------------------------
                top_wrap_incr_and_default_conveters
                #(
                .LEN_W                  (IN_LEN_W),
                .MAX_OUT_LEN            (MAX_OUT_LEN),
                .ADDR_W                 (PKT_ADDR_W),
                .BNDRY_W                (PKT_BURSTWRAP_W),
                .OPTIMIZE_WRITE_BURST   (0),
                .BURST_TYPE_W           (PKT_BURST_TYPE_W),
                .BURST_SIZE_W           (PKT_BURST_SIZE_W),
                .BYTEEN_W               (PKT_BYTEEN_W),
                .NUM_SYMBOLS            (NUM_SYMBOLS),
                .LOG2_NUM_SYMBOLS       (LOG2_NUM_SYMBOLS),
                .IN_NARROW_SIZE         (IN_NARROW_SIZE),
                .IS_AXI_SLAVE           (IS_AXI_SLAVE),
                .PURELY_INCR_AVL_SYS    (INCR_AVALON_SYS)
                )
                the_conveters_for_axi_slave
                (
                .clk                                (clk),
                .reset                              (reset),
                // -------------------
                // wrap conveter
                // -------------------
                .enable_read_wrap_converter         (enable_read_wrap_converter),
                .enable_write_wrap_converter        (enable_write_wrap_converter),
                .in_len                             (d0_in_len),
                .first_len                          (d0_first_len),
                .in_sop                             (d0_in_sop),
                .in_burstwrap                       (d0_in_burstwrap),
                .in_burstwrap_reg                   (d1_in_burstwrap),
                .in_aligned_addr                    (d0_in_aligned_addr),
                .in_aligned_addr_reg                (d1_in_aligned_addr),
                .wrap_conveter_out_len              (wrap_out_len),
                .wrap_conveter_uncompr_out_len      (wrap_uncompr_out_len),
                .wrap_conveter_out_addr             (wrap_out_addr),
                .wrap_conveter_new_burst            (wrap_new_burst),

                // -------------------
                // incr conveter
                // -------------------
                .enable_incr_converter              (enable_incr_converter),
                .in_size                            (d0_in_size),
                .in_size_reg                        (d1_in_size),
                .incr_conveter_out_len              (incr_out_len) ,
                .incr_conveter_uncompr_out_len      (incr_uncompr_out_len),
                .incr_conveter_out_addr             (incr_out_addr),
                .incr_conveter_new_burst            (incr_new_burst),

                // -------------------
                // default conveter
                // -------------------
                .enable_fixed_converter             (enable_fixed_converter),
                .in_bursttype                       (d0_in_bursttype_value),
                .in_size_value                      (d0_in_size_value),
                .is_write                           (is_write),
                .fixed_conveter_out_len             (fixed_out_len),
                .fixed_conveter_out_addr            (fixed_out_addr),
                .fixed_conveter_new_burst           (fixed_new_burst),
                .out_byteen_pre                     (out_byteen_pre)
                );
            end // if (IS_AXI_SLAVE)

            if (IS_INCR_SLAVE ) begin
                reg [PKT_BURST_TYPE_W - 1 : 0] in_bursttype_reg;
                reg                            in_incr_reg;
                wire                           in_incr  = (in_bursttype == 2'b01);
                wire                           in_wrap  = (in_bursttype == 2'b10);

                wire [PKT_BURST_TYPE_W - 1 : 0] d0_in_bursttype_value;
                wire [PKT_BURST_SIZE_W - 1 : 0] d0_in_size_value;
                reg [PKT_BURST_TYPE_W - 1 : 0]  d0_in_bursttype;
                reg                             d0_in_default_converter;
                reg                             d0_in_full_size_incr;
                reg                             d0_in_full_size_write_wrap;
                reg                             d0_in_full_size_read_wrap;

                reg                             d1_in_default_converter;
                reg                             d1_in_full_size_incr;
                reg                             d1_in_full_size_write_wrap;
                reg                             d1_in_full_size_read_wrap;
                reg                             d1_in_incr;
                reg [PKT_BURST_TYPE_W - 1 : 0]  d1_in_bursttype;

                reg [LEN_WIDTH - 1 : 0]         first_len_reg;
                wire [PKT_BYTE_CNT_W  - 1 : 0]  incr_out_byte_cnt;
                wire [PKT_BYTE_CNT_W  - 1 : 0]  fixed_out_byte_cnt;

                assign incr_out_byte_cnt  = (d1_in_compressed_read ? incr_out_len : incr_uncompr_out_len) << log2_numsymbols;
                assign fixed_out_byte_cnt = fixed_out_len << log2_numsymbols;

                if (NO_WRAP_SUPPORT) begin
                    assign in_default_converter  = !in_full_size_incr;
                    assign new_burst  = d1_in_default_converter ? fixed_new_burst : incr_new_burst;
                end
                else begin
                    wire    in_narrow_incr;
                    wire    in_fixed = (in_bursttype == 2'b00) || (in_bursttype == 2'b11);

                    assign in_narrow_incr       = in_incr & in_narrow;
                    assign in_default_converter = in_fixed || in_narrow || in_narrow_incr || in_uncompressed_read;
                    assign new_burst                   = (d1_in_default_converter ? fixed_new_burst : (d1_in_incr ? incr_new_burst : wrap_new_burst));
                end

                assign in_full_size_incr         = in_incr & !in_narrow & !in_uncompressed_read;
                assign in_full_size_write_wrap   = in_write & in_wrap & !in_narrow;
                assign in_full_size_read_wrap    = in_compressed_read & in_wrap & !in_narrow;

                //----------------------------------------------------------------
                // I. Pipeline input stage
                //----------------------------------------------------------------
                reg [PKT_BURSTWRAP_W  - 1 : 0]  d0_in_burstwrap;
                reg [PKT_BURSTWRAP_W  - 1 : 0]  d1_in_burstwrap;

                if(PIPE_INTERNAL == 0) begin : NO_PIPELINE_INPUT
                    always_ff @(posedge clk or posedge reset) begin
                        if (reset) begin
                            in_full_size_write_wrap_reg <= '0;
                            in_full_size_read_wrap_reg  <= '0;
                            in_full_size_incr_reg       <= '0;
                            in_default_converter_reg    <= '0;
                            in_incr_reg                 <= '0;
                            in_burstwrap_reg            <= '0;
                            in_bursttype_reg            <= '0;
                        end else begin
                            if (sink0_ready & sink0_valid) begin
                                in_burstwrap_reg            <= in_burstwrap;
                                in_bursttype_reg            <= in_bursttype;
                                in_incr_reg                 <= in_incr;
                                in_full_size_incr_reg       <= in_full_size_incr;
                                in_full_size_write_wrap_reg <= in_full_size_write_wrap;
                                in_full_size_read_wrap_reg  <= in_full_size_read_wrap;
                                in_default_converter_reg    <= in_default_converter;
                            end
                        end // else: !if(reset)
                    end // always_ff @
                    always_comb begin
                        d0_in_burstwrap             = in_burstwrap;
                        d0_in_default_converter     = in_default_converter;
                        d0_in_full_size_incr        = in_full_size_incr;
                        d0_in_full_size_write_wrap  = in_full_size_write_wrap;
                        d0_in_full_size_read_wrap   = in_full_size_read_wrap;
                        d0_first_len                = first_len;
                        d0_in_bursttype             = in_bursttype;
                        d1_in_burstwrap             = in_burstwrap_reg;
                        d1_in_bursttype             = in_bursttype_reg;
                        d1_in_incr                  = in_incr_reg;
                        d1_in_default_converter     = in_default_converter_reg;
                        d1_in_full_size_incr        = in_full_size_incr_reg;
                        d1_in_full_size_write_wrap  = in_full_size_write_wrap_reg;
                        d1_in_full_size_read_wrap   = in_full_size_read_wrap_reg;
                    end
                end
                else begin : PIPELINE_INPUT
                    always_ff @(posedge clk or posedge reset) begin
                        if (reset) begin
                            in_full_size_write_wrap_reg <= '0;
                            in_full_size_read_wrap_reg  <= '0;
                            in_full_size_incr_reg       <= '0;
                            in_default_converter_reg    <= '0;
                            first_len_reg               <= '0;
                            in_incr_reg                 <= '0;
                            in_burstwrap_reg            <= '0;
                            in_bursttype_reg            <= '0;
                            d1_in_burstwrap             <= '0;
                            d1_in_bursttype             <= '0;
                            d1_in_default_converter     <= '0;
                            d1_in_full_size_incr        <= '0;
                            d1_in_full_size_write_wrap  <= '0;
                            d1_in_full_size_read_wrap   <= '0;
                            d1_in_incr                  <= '0;
                        end else begin
                            if (sink0_ready & sink0_valid) begin
                                in_burstwrap_reg            <= in_burstwrap;
                                in_full_size_incr_reg       <= in_full_size_incr;
                                in_full_size_write_wrap_reg <= in_full_size_write_wrap;
                                in_full_size_read_wrap_reg  <= in_full_size_read_wrap;
                                in_default_converter_reg    <= in_default_converter;
                                in_incr_reg                 <= in_incr;
                                first_len_reg               <= first_len;
                                in_bursttype_reg            <= in_bursttype;
                            end
                            if (((state != ST_COMP_TRANS) & (~source0_valid | source0_ready)) |
                                ( (state == ST_COMP_TRANS) & (~source0_valid | source0_ready & source0_endofpacket) ) ) begin
                                d1_in_default_converter    <= in_default_converter_reg;
                                d1_in_full_size_incr       <= in_full_size_incr_reg;
                                d1_in_full_size_write_wrap <= in_full_size_write_wrap_reg;
                                d1_in_full_size_read_wrap  <= in_full_size_read_wrap_reg;
                                d1_in_incr                 <= in_incr_reg;
                                d1_in_burstwrap            <= in_burstwrap_reg;
                                d1_in_bursttype            <= in_bursttype_reg;
                            end
                        end // else: !if(reset)
                    end // always_ff @
                    always_comb begin
                        d0_in_burstwrap             = in_burstwrap_reg;
                        d0_in_default_converter     = in_default_converter_reg;
                        d0_in_full_size_incr        = in_full_size_incr_reg;
                        d0_in_full_size_write_wrap  = in_full_size_write_wrap_reg;
                        d0_in_full_size_read_wrap   = in_full_size_read_wrap_reg;
                        d0_first_len                = first_len_reg;
                        d0_in_bursttype             = in_bursttype_reg;
                    end
                end

                assign d0_in_size_value        = new_burst ? d0_in_size : d1_in_size;
                assign d0_in_bursttype_value   = new_burst ? d0_in_bursttype : d1_in_bursttype;
                // --------------------------------------------------------------------------------------
                // II. First length calculation
                // --------------------------------------------------------------------------------------
                // Note: the slave is INCR slave, in pratical is has no boundary so if in burst is wrap
                // the sub burst can send out "slave max length" first fs the in burst not yet wraps back
                // To simplify and optimize: the first sub_burst length stills send out aligned length first
                // --------------------------------------------------------------------------------------
                // If no INCOMPLETE wrap burst
                // 1. in_boundary is larger out_boundary; first sub_burst length is: aligned to out boundary
                // 2. in_boundary is smaller out_boundary; first sub_burst length is: aligned to in boundary
                // --------------------------------------------------------------------------------------
                if (!NO_WRAP_SUPPORT) begin : HAVE_WRAP_BURSTING_SUPPORT
                    if (!INCOMPLETE_WRAP_SUPPORT) begin : no_incomplete_wrap_support
                        assign first_len = (in_boundary > OUT_BOUNDARY) ? aligned_len_to_out_bdry : aligned_len_to_in_bdry;
                    end
                    else begin : incomplete_wrap_support
                        // -------------------------------------------------------------------------
                        // If INCOMPLETE wrap support
                        // 1. The idea is still same, based on boundary and select either aligned to in/out boundary
                        // 2. But need to check if in_len is smaller to "aligned" in/out boundary for incomplete case
                        // -> the burst is pass thru is in_len is smaller
                        // -------------------------------------------------------------------------
                        wire in_len_smaller_aligned_out_bdry = (in_len <= aligned_len_to_out_bdry);
                        wire in_len_smaller_aligned_in_bdry  = (in_len <= aligned_len_to_in_bdry);
                        always_comb begin
                            if (in_boundary > OUT_BOUNDARY) begin
                                first_len = (in_len_smaller_aligned_out_bdry) ? in_len : aligned_len_to_out_bdry;
                            end
                            else begin
                                first_len = (in_len_smaller_aligned_in_bdry) ? in_len : aligned_len_to_in_bdry;
                            end
                        end
                    end // block: incomplete_wrap_support
                end

                // -----------------------------------------------------------------------
                // III. Conveter enable signals: Turn on/off each conveter accordingly
                // -----------------------------------------------------------------------
                // INCR slave: three conveters:
                //  1. wrap_burst_conveter    -> handle WRAP
                //  2. incr_burst_convter     -> handle INCR
                //  2. default_burst_conveter -> handle narrow burst
                // -----------------------------------------------------------------------
                // -----------------------------------------------------------------------
                // Purposely support AXI to Avalon: with no wrapping suppport
                // all wrapping transaction witll be converted to non-bursting sub-burst
                // 21-January-2014
                // -----------------------------------------------------------------------
                if (NO_WRAP_SUPPORT) begin
                    assign enable_incr_converter        = (d0_in_valid && d0_in_full_size_incr && fixed_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_full_size_incr && !new_burst));
                    assign enable_fixed_converter       = (d0_in_valid && d0_in_default_converter && incr_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_default_converter && !new_burst));

                    // -----------------------------------------------------------------------
                    // IV. Packet signals
                    // -----------------------------------------------------------------------
                    assign next_out_sop  = (state == ST_COMP_TRANS) & source0_ready & !(d1_in_default_converter ? fixed_new_burst : incr_new_burst) ? 1'b0 : d0_in_sop;
                    assign next_out_eop  = (state == ST_COMP_TRANS) ?  (d1_in_default_converter ? fixed_new_burst : incr_new_burst)  : d1_in_eop;

                    // -----------------------------------------------------------------------
                    // V. Output signals
                    // -----------------------------------------------------------------------
                    assign out_byte_cnt  = d1_in_default_converter ? fixed_out_byte_cnt : incr_out_byte_cnt;
                    assign out_addr  = d1_in_default_converter ? fixed_out_addr : incr_out_addr;
                end
                else begin
                    wire incr_wrap_new_burst;
                    assign incr_wrap_new_burst  = incr_new_burst && wrap_new_burst;

                    assign enable_incr_converter        = (d0_in_valid && d0_in_full_size_incr && fixed_new_burst && wrap_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_full_size_incr && !new_burst));
                    assign enable_fixed_converter       = (d0_in_valid && d0_in_default_converter && incr_wrap_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_default_converter && !new_burst));
                    assign enable_write_wrap_converter  = (d0_in_valid && d0_in_full_size_write_wrap && fixed_new_burst && incr_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_full_size_write_wrap && !new_burst));
                    assign enable_read_wrap_converter   = (d0_in_valid && d0_in_full_size_read_wrap  && fixed_new_burst && incr_new_burst && (source0_ready || !source0_valid) || ((state == ST_COMP_TRANS) && source0_ready && d1_in_full_size_read_wrap && !new_burst));

                    // -----------------------------------------------------------------------
                    // IV. Packet signals
                    // -----------------------------------------------------------------------
                    assign next_out_sop  = ((state == ST_COMP_TRANS) & source0_ready & !(d1_in_default_converter ? fixed_new_burst : (d1_in_incr ? incr_new_burst : wrap_new_burst))) ? 1'b0 : d0_in_sop;
                    assign next_out_eop = (state == ST_COMP_TRANS) ?  (d1_in_default_converter ? fixed_new_burst : (d1_in_incr ? incr_new_burst : wrap_new_burst))  : d1_in_eop;

                    // -----------------------------------------------------------------------
                    // V. Output signals
                    // -----------------------------------------------------------------------
                    wire [PKT_BYTE_CNT_W  - 1 : 0]  wrap_out_byte_cnt;
                    assign wrap_out_byte_cnt  = (d1_in_compressed_read ? wrap_out_len : wrap_uncompr_out_len) << log2_numsymbols;
                    assign out_byte_cnt       = d1_in_default_converter ? fixed_out_byte_cnt : (d1_in_incr ? incr_out_byte_cnt : wrap_out_byte_cnt);
                    assign out_addr           = d1_in_default_converter ? fixed_out_addr : (d1_in_incr ? incr_out_addr : wrap_out_addr);
                end // else: !if(NO_WRAP_SUPPORT)
                // Assign out burstyype; both cases are ICNR
                assign out_bursttype  = INCR;

                    // -----------------------------------------------------------------------
                    // VI. Converters instantiation
                    // -----------------------------------------------------------------------
                    // If no wrap support (wrap transaction will be converted to non-bursting transaction)
                    // then we only need to use incr and default conveter
                    // if not, then use all three conveters to handling all types of burst
                    //------------------------------------------------------------------------
                if (NO_WRAP_SUPPORT) begin : no_wrap_incr_slave_conveter_sel
                    top_incr_and_default_conveters
                        #(
                        .LEN_W                  (IN_LEN_W),
                        .MAX_OUT_LEN            (MAX_OUT_LEN),
                        .ADDR_W                 (PKT_ADDR_W),
                        .BNDRY_W                (PKT_BURSTWRAP_W),
                        .OPTIMIZE_WRITE_BURST   (0),
                        .BURST_TYPE_W           (PKT_BURST_TYPE_W),
                        .BURST_SIZE_W           (PKT_BURST_SIZE_W),
                        .BYTEEN_W               (PKT_BYTEEN_W),
                        .NUM_SYMBOLS            (NUM_SYMBOLS),
                        .LOG2_NUM_SYMBOLS       (LOG2_NUM_SYMBOLS),
                        .IN_NARROW_SIZE         (IN_NARROW_SIZE),
                        .PURELY_INCR_AVL_SYS    (INCR_AVALON_SYS),
                        .IS_AXI_SLAVE           (IS_AXI_SLAVE)
                        )
                        the_conveters_for_incr_slave_no_wrap_support
                        (
                        .clk                                (clk),
                        .reset                              (reset),

                        // -------------------
                        // incr conveter
                        // -------------------
                        .in_len                             (d0_in_len),
                        .in_sop                             (d0_in_sop),
                        .in_burstwrap_reg                   (d1_in_burstwrap),
                        .in_aligned_addr                    (d0_in_aligned_addr),
                        .in_aligned_addr_reg                (d1_in_aligned_addr),
                        .enable_incr_converter              (enable_incr_converter),
                        .in_size_reg                        (d1_in_size),
                        .incr_conveter_out_len              (incr_out_len) ,
                        .incr_conveter_uncompr_out_len      (incr_uncompr_out_len),
                        .incr_conveter_out_addr             (incr_out_addr),
                        .incr_conveter_new_burst            (incr_new_burst),

                        // -------------------
                        // default conveter
                        // -------------------
                        .enable_fixed_converter             (enable_fixed_converter),
                        .in_bursttype                       (d0_in_bursttype_value),
                        .in_size_value                      (d0_in_size_value),
                        .is_write                           (is_write),
                        .fixed_conveter_out_len             (fixed_out_len),
                        .fixed_conveter_out_addr            (fixed_out_addr),
                        .fixed_conveter_new_burst           (fixed_new_burst),
                        .out_byteen_pre                     (out_byteen_pre)
                        );
                end
                else begin : wrap_incr_slave_conveter_sel
                    top_wrap_incr_and_default_conveters
                        #(
                        .LEN_W                  (IN_LEN_W),
                        .MAX_OUT_LEN            (MAX_OUT_LEN),
                        .ADDR_W                 (PKT_ADDR_W),
                        .BNDRY_W                (PKT_BURSTWRAP_W),
                        .OPTIMIZE_WRITE_BURST   (0),
                        .BURST_TYPE_W           (PKT_BURST_TYPE_W),
                        .BURST_SIZE_W           (PKT_BURST_SIZE_W),
                        .BYTEEN_W               (PKT_BYTEEN_W),
                        .NUM_SYMBOLS            (NUM_SYMBOLS),
                        .LOG2_NUM_SYMBOLS       (LOG2_NUM_SYMBOLS),
                        .IN_NARROW_SIZE         (IN_NARROW_SIZE),
                        .IS_AXI_SLAVE           (IS_AXI_SLAVE),
                        .PURELY_INCR_AVL_SYS    (INCR_AVALON_SYS)
                        )
                        the_conveters_for_incr_slave_wrap_support
                        (
                        .clk                                (clk),
                        .reset                              (reset),
                        // -------------------
                        // wrap conveter
                        // -------------------
                        .enable_read_wrap_converter         (enable_read_wrap_converter),
                        .enable_write_wrap_converter        (enable_write_wrap_converter),
                        .in_len                             (d0_in_len),
                        .first_len                          (d0_first_len),
                        .in_sop                             (d0_in_sop),
                        .in_burstwrap                       (d0_in_burstwrap),
                        .in_burstwrap_reg                   (d1_in_burstwrap),
                        .in_aligned_addr                    (d0_in_aligned_addr),
                        .in_aligned_addr_reg                (d1_in_aligned_addr),
                        .wrap_conveter_out_len              (wrap_out_len),
                        .wrap_conveter_uncompr_out_len      (wrap_uncompr_out_len),
                        .wrap_conveter_out_addr             (wrap_out_addr),
                        .wrap_conveter_new_burst            (wrap_new_burst),

                        // -------------------
                        // incr conveter
                        // -------------------
                        .enable_incr_converter              (enable_incr_converter),
                        .in_size                            (d0_in_size),
                        .in_size_reg                        (d1_in_size),
                        .incr_conveter_out_len              (incr_out_len) ,
                        .incr_conveter_uncompr_out_len      (incr_uncompr_out_len),
                        .incr_conveter_out_addr             (incr_out_addr),
                        .incr_conveter_new_burst            (incr_new_burst),

                        // -------------------
                        // default conveter
                        // -------------------
                        .enable_fixed_converter             (enable_fixed_converter),
                        .in_bursttype                       (d0_in_bursttype_value),
                        .in_size_value                      (d0_in_size_value),
                        .is_write                           (is_write),
                        .fixed_conveter_out_len             (fixed_out_len),
                        .fixed_conveter_out_addr            (fixed_out_addr),
                        .fixed_conveter_new_burst           (fixed_new_burst),
                        .out_byteen_pre                     (out_byteen_pre)
                        );
                end // block: wrap_incr_slave_conveter_sel
            end // if (IS_INCR_SLAVE )
        end // else: !if(INCR_AVALON_SYS)
    end // block: internal_signals_conveter_instantiation_for_different_typeofslave
    endgenerate

    // --------------------------------------------------
    // Control signals
    // --------------------------------------------------
    // sink0_ready: it needs to be asserted first to take in first packet -- it is a must
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            in_ready_hold <= '0;
        end else begin
            in_ready_hold <= '1;
        end
    end

    // -----------------------------------------------------------------------
    reg   source0_valid_reg;
    wire  next_source0_valid;
    reg   source0_startofpacket_reg;


    //-------------------------------------------------------------------------
    // Handshaking and packet signals
    // -----------------------------------------------------------------------
    // source0_valid: takes from in sink_valid unless read then wait until end_of_packet
    assign next_source0_valid  = ((state == ST_COMP_TRANS) & !source0_endofpacket) ? 1'b1 : d0_in_valid;

    // sink0_ready needs alway to be asserted first, hold one after reset
    assign int_sink0_ready  = (state == ST_UNCOMP_TRANS) ? source0_ready || !source0_valid : (state == ST_COMP_TRANS) ? new_burst && source0_ready || !source0_valid : in_ready_hold;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)  begin
            state                     <= ST_IDLE;
            source0_valid_reg         <= '0;
            source0_startofpacket_reg <= '1;
        end else begin
            if (~source0_valid | source0_ready) begin
                state                     <= next_state;
                source0_valid_reg         <= next_source0_valid;
                source0_startofpacket_reg <= next_out_sop;
            end
        end // else: !if(reset)
    end // always_ff @

    // Assign output signals
    always_comb begin
        source0_endofpacket    = next_out_eop;
        source0_startofpacket  = source0_startofpacket_reg;
        source0_valid          = source0_valid_reg;
    end

    // ----------------------------------------------------
    // FSM : Finite State Machine
    // ---------------------------------------------------
    always_comb begin : state_transition
        // default
        next_state = ST_IDLE;
        case (state)
            ST_IDLE : begin
                next_state = ST_IDLE;

                if (d0_in_valid) begin
                    if (d0_in_write | d0_in_uncompressed_read)    next_state = ST_UNCOMP_TRANS;
                    if (d0_in_compressed_read)                  next_state = ST_COMP_TRANS;
                end
            end

            ST_UNCOMP_TRANS : begin
                next_state = ST_UNCOMP_TRANS;

                if (source0_endofpacket) begin
                    if (!d0_in_valid) next_state = ST_IDLE;
                    else begin
                        if (d0_in_write | d0_in_uncompressed_read)    next_state = ST_UNCOMP_TRANS;
                        if (d0_in_compressed_read)                  next_state = ST_COMP_TRANS;
                    end
                end
            end
            ST_COMP_TRANS : begin
                next_state = ST_COMP_TRANS;

                if (source0_endofpacket) begin
                    if (!d0_in_valid) begin
                        next_state = ST_IDLE;
                    end
                    else begin
                        if (d0_in_write | d0_in_uncompressed_read)    next_state = ST_UNCOMP_TRANS;
                        if (d0_in_compressed_read)             next_state = ST_COMP_TRANS;
                    end
                end
            end
        endcase
    end

    // --------------------------------------------------
    // Ceil(log2()) function
    // --------------------------------------------------
    function unsigned[63:0] log2ceil;
        input reg [63:0] val;
        reg [63:0]       i;
        begin
            i = 1;
            log2ceil = 0;
            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

    // ---------------------------------------------------
    // Mapping of output signals.
    // ---------------------------------------------------
    wire load_next_output_pck  = source0_ready | !source0_valid;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            uncompr_out_addr <= '0;
        end
        else if (load_next_output_pck) begin
            uncompr_out_addr <= d0_in_addr;
        end

    end

    // At source0_startofpacket, out_addr_read is the in_addr.
    wire [PKT_ADDR_W - 1 : 0] out_addr_read;
    assign out_addr_read = source0_startofpacket_reg ? uncompr_out_addr : out_addr;

    // Choose between uncompressed or compressed trans address.
    wire [PKT_ADDR_W - 1 : 0] out_addr_assigned_to_packet;
    assign out_addr_assigned_to_packet = (d1_in_write || d1_in_uncompressed_read) ?  uncompr_out_addr : out_addr_read;

    // ---------------------------------------------------
    // Byteenable Generation.
    // ---------------------------------------------------
    // if BYTEENABLE_SYNTHESIS == 1, select the byteenable from default conveter
    // this only happpens for case slave is Avalon and master issues narrow transaction
    reg [PKT_BYTEEN_W - 1 : 0] out_byteen;
    always_comb begin
    if (BYTEENABLE_SYNTHESIS == 1 && d1_in_narrow == 1 && (state == ST_COMP_TRANS))
        out_byteen  = out_byteen_pre;
    else
        out_byteen  = d1_in_byteen;
    end
    // -- End of Byteenable Generation --

    always_comb begin : source0_out_assignments
        source0_data                                       = d1_in_data;
        source0_channel                                    = d1_in_channel;
        // Override fields the component is aware of.
        source0_data[PKT_BURST_TYPE_H : PKT_BURST_TYPE_L]  = out_bursttype;
        source0_data[PKT_BYTE_CNT_H   : PKT_BYTE_CNT_L  ]  = out_byte_cnt;
        source0_data[PKT_ADDR_H       : PKT_ADDR_L      ]  = out_addr_assigned_to_packet;
        source0_data[PKT_BYTEEN_H     : PKT_BYTEEN_L    ]  = out_byteen;
    end

    //----------------------------------------------------
    // "min" operation on burstwrap values is a bitwise AND.
    //----------------------------------------------------
    function [PKT_BURSTWRAP_W - 1 : 0] altera_merlin_burst_adapter_burstwrap_min;
        input [PKT_BURSTWRAP_W - 1 : 0] a, b;
        begin
            altera_merlin_burst_adapter_burstwrap_min  = a & b;
        end
    endfunction

endmodule

module altera_merlin_burst_adapter_uncompressed_only_new
#(
  parameter // Merlin packet parameters
    PKT_BYTE_CNT_H  = 5,
    PKT_BYTE_CNT_L  = 0,
    PKT_BYTEEN_H    = 83,
    PKT_BYTEEN_L    = 80,
    ST_DATA_W       = 84,
    ST_CHANNEL_W    = 8
)
(
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                           in0_valid,
    input     [ST_DATA_W-1    : 0]  in0_data,
    input     [ST_CHANNEL_W-1 : 0]  in0_channel,
    input                           in0_startofpacket,
    input                           in0_endofpacket,
    output reg                      in0_ready,

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
  localparam
    PKT_BYTE_CNT_W    = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1,
    NUM_SYMBOLS       = PKT_BYTEEN_H - PKT_BYTEEN_L + 1;

  wire [PKT_BYTE_CNT_W - 1 : 0] num_symbols_sig = NUM_SYMBOLS[PKT_BYTE_CNT_W - 1 : 0];

  always_comb begin : source0_data_assignments
    source0_valid         = in0_valid;
    source0_channel       = in0_channel;
    source0_startofpacket = in0_startofpacket;
    source0_endofpacket   = in0_endofpacket;
    in0_ready             = source0_ready;

    source0_data          = in0_data;
    source0_data[PKT_BYTE_CNT_H : PKT_BYTE_CNT_L] = num_symbols_sig;
  end

endmodule

// -------------------------------------------------------------
// Sub modules that instantiate conveter for different slaves
// The name if the module shows what conveters are instantiated
// -------------------------------------------------------------

module top_wrap_and_default_conveters
#(
  parameter
    LEN_W                   = 4,
    MAX_OUT_LEN             = 4,
    ADDR_W                  = 12,
    BNDRY_W                 = 12,
    OPTIMIZE_WRITE_BURST    = 0,
    BURST_TYPE_W            = 2,
    BURST_SIZE_W            = 2,
    IN_NARROW_SIZE          = 1,
    BYTEEN_W                = 4,
    NUM_SYMBOLS             = 4,
    LOG2_NUM_SYMBOLS        = 2,
    IS_AXI_SLAVE            = 1
)
(
    input                          clk,
    input                          reset,

    // -------------------
    // wrap conveter
    // -------------------
    input                          enable_read,
    input                          enable_write,
    input [LEN_W - 1 : 0]          in_len,
    input [LEN_W - 1 : 0]          first_len,
    input                          in_sop,
    input [BNDRY_W -1 :0]          in_burstwrap,
    input [BNDRY_W -1 :0]          in_burstwrap_reg,

    input [ADDR_W -1 : 0]          in_aligned_addr,
    input [ADDR_W -1 : 0]          in_aligned_addr_reg,

    output wire [LEN_W - 1 : 0]    wrap_conveter_out_len,
    output wire [LEN_W - 1 : 0]    wrap_conveter_uncompr_out_len,
    output wire [ADDR_W - 1 : 0]   wrap_conveter_out_addr,
    output wire                    wrap_conveter_new_burst,


    // -------------------
    // default conveter
    // -------------------
    input                          enable_fixed_converter,
    input [BURST_TYPE_W -1 :0]     in_bursttype,
    input [BURST_SIZE_W -1 : 0]    in_size_value,
    input                          is_write,

    output wire [LEN_W - 1 : 0]    fixed_conveter_out_len,
    output wire [ADDR_W - 1 :0]    fixed_conveter_out_addr,
    output wire                    fixed_conveter_new_burst,
    output wire [BYTEEN_W - 1 : 0] out_byteen_pre

);


altera_wrap_burst_converter
#(
    .LEN_W                  (LEN_W),
    .MAX_OUT_LEN            (MAX_OUT_LEN),
    .ADDR_W                 (ADDR_W),
    .BNDRY_W                (BNDRY_W),
    .NUM_SYMBOLS            (NUM_SYMBOLS),
    .LOG2_NUM_SYMBOLS       (LOG2_NUM_SYMBOLS),
    .OPTIMIZE_WRITE_BURST   (0)
 )
the_converter_for_avalon_wrap_slave
(
    .clk                               (clk),
    .reset                             (reset),
    .enable_read                       (enable_read),
    .enable_write                      (enable_write),
    .in_len                            (in_len),
    .first_len                         (first_len),
    .in_sop                            (in_sop),
    .in_burstwrap                      (in_burstwrap),
    .in_burstwrap_reg                  (in_burstwrap_reg),
    .in_addr                           (in_aligned_addr),
    .in_addr_reg                       (in_aligned_addr_reg),
    .out_len                           (wrap_conveter_out_len),
    .uncompr_out_len                   (wrap_conveter_uncompr_out_len),
    .out_addr                          (wrap_conveter_out_addr),
    .new_burst_export                  (wrap_conveter_new_burst)
  );

altera_default_burst_converter
#(
    .BURST_TYPE_W       (BURST_TYPE_W),
    .ADDR_W             (ADDR_W),
    .BNDRY_W            (BNDRY_W),
    .BURST_SIZE_W       (BURST_SIZE_W),
    .BYTEEN_W           (BYTEEN_W),
    .LEN_W              (LEN_W),
    .IN_NARROW_SIZE     (IN_NARROW_SIZE),
    .LOG2_NUM_SYMBOLS   (LOG2_NUM_SYMBOLS),
    .IS_AXI_SLAVE       (IS_AXI_SLAVE)
 )
the_default_burst_converter
(
    .clk                       (clk),
    .reset                     (reset),
    .enable                    (enable_fixed_converter), // turn on if a fixed
    .in_addr                   (in_aligned_addr),
    .in_addr_reg               (in_aligned_addr_reg),
    .in_bursttype              (in_bursttype),
    .in_burstwrap_reg          (in_burstwrap_reg),
    .in_len                    (in_len),
    .in_size_value             (in_size_value),
    .in_is_write               (is_write),
    .out_len                   (fixed_conveter_out_len),
    .out_addr                  (fixed_conveter_out_addr),
    .new_burst                 (fixed_conveter_new_burst),
    .out_byteen                (out_byteen_pre)
);
endmodule

module top_wrap_incr_and_default_conveters
#(
  parameter
    LEN_W                   = 4,
    MAX_OUT_LEN             = 4,
    ADDR_W                  = 12,
    BNDRY_W                 = 12,
    OPTIMIZE_WRITE_BURST    = 0,
    BURST_TYPE_W            = 2,
    BURST_SIZE_W            = 2,
    BYTEEN_W                = 4,
    NUM_SYMBOLS             = 4,
    LOG2_NUM_SYMBOLS        = 2,
    IN_NARROW_SIZE          = 1,
    PURELY_INCR_AVL_SYS     = 0,
    IS_AXI_SLAVE            = 1
)
(
    input                          clk,
    input                          reset,

    // -------------------
    // wrap conveter
    // -------------------
    input                          enable_read_wrap_converter,
    input                          enable_write_wrap_converter,
    input [LEN_W - 1 : 0]          in_len,
    input [LEN_W - 1 : 0]          first_len,
    input                          in_sop,
    input [BNDRY_W -1 :0]          in_burstwrap,
    input [BNDRY_W -1 :0]          in_burstwrap_reg,
    input [ADDR_W -1 : 0]          in_aligned_addr,
    input [ADDR_W -1 : 0]          in_aligned_addr_reg,
    output wire [LEN_W - 1 : 0]    wrap_conveter_out_len,
    output wire [LEN_W - 1 : 0]    wrap_conveter_uncompr_out_len,
    output wire [ADDR_W - 1 : 0]   wrap_conveter_out_addr,
    output wire                    wrap_conveter_new_burst,

    // -------------------
    // incr conveter
    // -------------------
    input                          enable_incr_converter,
    input [BURST_SIZE_W - 1 : 0]   in_size,
    input [BURST_SIZE_W - 1 : 0]   in_size_reg,
    output wire [LEN_W - 1 : 0]    incr_conveter_out_len,
    output wire [LEN_W - 1 : 0]    incr_conveter_uncompr_out_len,
    output wire [ADDR_W - 1 : 0]   incr_conveter_out_addr,
    output wire                    incr_conveter_new_burst,

    // -------------------
    // default conveter
    // -------------------
    input                          enable_fixed_converter,
    input [BURST_TYPE_W -1 :0]     in_bursttype,
    input [BURST_SIZE_W -1 : 0]    in_size_value,
    input                          is_write,
    output wire [LEN_W - 1 : 0]    fixed_conveter_out_len,
    output wire [ADDR_W - 1 :0]    fixed_conveter_out_addr,
    output wire                    fixed_conveter_new_burst,
    output wire [BYTEEN_W - 1 : 0] out_byteen_pre
 );

altera_wrap_burst_converter
#(
   .LEN_W                   (LEN_W),
   .MAX_OUT_LEN             (MAX_OUT_LEN),
   .ADDR_W                  (ADDR_W),
   .BNDRY_W                 (BNDRY_W),
   .NUM_SYMBOLS             (NUM_SYMBOLS),
   .LOG2_NUM_SYMBOLS        (LOG2_NUM_SYMBOLS),
   .AXI_SLAVE               (IS_AXI_SLAVE),
   .OPTIMIZE_WRITE_BURST    (0)
   )
the_converter_for_avalon_wrap_slave
(
   .clk                 (clk),
   .reset               (reset),
   .enable_read         (enable_read_wrap_converter),
   .enable_write        (enable_write_wrap_converter),
   .in_len              (in_len),
   .first_len           (first_len),
   .in_sop              (in_sop),
   .in_burstwrap        (in_burstwrap),
   .in_burstwrap_reg    (in_burstwrap_reg),
   .in_addr             (in_aligned_addr),
   .in_addr_reg         (in_aligned_addr_reg),
   .out_len             (wrap_conveter_out_len),
   .uncompr_out_len     (wrap_conveter_uncompr_out_len),
   .out_addr            (wrap_conveter_out_addr),
   .new_burst_export    (wrap_conveter_new_burst)
   );

altera_incr_burst_converter
#(
   .LEN_W               (LEN_W),
   .MAX_OUT_LEN         (MAX_OUT_LEN),
   .ADDR_W              (ADDR_W),
   .BNDRY_W             (BNDRY_W),
   .BURSTSIZE_W         (BURST_SIZE_W),
   .IN_NARROW_SIZE      (IN_NARROW_SIZE),
   .NUM_SYMBOLS         (NUM_SYMBOLS),
   .LOG2_NUM_SYMBOLS    (LOG2_NUM_SYMBOLS),
   .PURELY_INCR_AVL_SYS (PURELY_INCR_AVL_SYS)
   )
the_converter_for_avalon_incr_slave
(
   .clk                (clk),
   .reset              (reset),
   .enable             (enable_incr_converter),
   .in_len             (in_len),
   .in_sop             (in_sop),
   .in_burstwrap_reg   (in_burstwrap_reg),
   .in_size            (in_size),
   .in_size_reg        (in_size_reg),
   .in_addr            (in_aligned_addr),
   .in_addr_reg        (in_aligned_addr_reg),
   .is_write           (is_write),
   .out_len            (incr_conveter_out_len),
   .uncompr_out_len    (incr_conveter_uncompr_out_len),
   .out_addr           (incr_conveter_out_addr),
   .new_burst_export   (incr_conveter_new_burst)
   );


altera_default_burst_converter
#(
   .BURST_TYPE_W        (BURST_TYPE_W),
   .ADDR_W              (ADDR_W),
   .BNDRY_W             (BNDRY_W),
   .BURST_SIZE_W        (BURST_SIZE_W),
   .BYTEEN_W            (BYTEEN_W),
   .LEN_W               (LEN_W),
   .IN_NARROW_SIZE      (IN_NARROW_SIZE),
   .LOG2_NUM_SYMBOLS    (LOG2_NUM_SYMBOLS),
   .IS_AXI_SLAVE        (IS_AXI_SLAVE)
   )
the_default_burst_converter
(
   .clk                 (clk),
   .reset               (reset),
   .enable              (enable_fixed_converter),
   .in_addr             (in_aligned_addr),
   .in_addr_reg         (in_aligned_addr_reg),
   .in_bursttype        (in_bursttype),
   .in_burstwrap_reg    (in_burstwrap_reg),
   .in_len              (in_len),
   .in_size_value       (in_size_value),
   .in_is_write         (is_write),
   .out_len             (fixed_conveter_out_len),
   .out_addr            (fixed_conveter_out_addr),
   .new_burst           (fixed_conveter_new_burst),
   .out_byteen          (out_byteen_pre)
   );
endmodule

module top_incr_and_default_conveters
#(
  parameter
    LEN_W                   = 4,
    MAX_OUT_LEN             = 4,
    ADDR_W                  = 12,
    BNDRY_W                 = 12,
    OPTIMIZE_WRITE_BURST    = 0,
    BURST_TYPE_W            = 2,
    BURST_SIZE_W            = 2,
    BYTEEN_W                = 4,
    NUM_SYMBOLS             = 4,
    LOG2_NUM_SYMBOLS        = 2,
    IN_NARROW_SIZE          = 1,
    PURELY_INCR_AVL_SYS     = 0,
    IS_AXI_SLAVE            = 1
)
(
    input                            clk,
    input                            reset,

    // -------------------
    // incr conveter
    // -------------------
    input [LEN_W - 1 : 0]           in_len,
    input                           in_sop,
    input [BNDRY_W -1 :0]           in_burstwrap_reg,
    input [ADDR_W -1 : 0]           in_aligned_addr,
    input [ADDR_W -1 : 0]           in_aligned_addr_reg,
    input                           enable_incr_converter,
    input [BURST_SIZE_W - 1 : 0]    in_size,
    input [BURST_SIZE_W - 1 : 0]    in_size_reg,
    output wire [LEN_W - 1 : 0]     incr_conveter_out_len,
    output wire [LEN_W - 1 : 0]     incr_conveter_uncompr_out_len,
    output wire [ADDR_W - 1 : 0]    incr_conveter_out_addr,
    output wire                     incr_conveter_new_burst,

    // -------------------
    // default conveter
    // -------------------
    input                           enable_fixed_converter,
    input [BURST_TYPE_W -1 :0]      in_bursttype,
    input [BURST_SIZE_W -1 : 0]     in_size_value,
    input                           is_write,
    output wire [LEN_W - 1 : 0]     fixed_conveter_out_len,
    output wire [ADDR_W - 1 :0]     fixed_conveter_out_addr,
    output wire                     fixed_conveter_new_burst,
    output wire [BYTEEN_W - 1 : 0]  out_byteen_pre
 );
altera_incr_burst_converter
#(
   .LEN_W               (LEN_W),
   .MAX_OUT_LEN         (MAX_OUT_LEN),
   .ADDR_W              (ADDR_W),
   .BNDRY_W             (BNDRY_W),
   .BURSTSIZE_W         (BURST_SIZE_W),
   .IN_NARROW_SIZE      (0), // not support narrow transaction as this is INCR avalon slave
   .NUM_SYMBOLS         (NUM_SYMBOLS),
   .LOG2_NUM_SYMBOLS    (LOG2_NUM_SYMBOLS),
   .PURELY_INCR_AVL_SYS (PURELY_INCR_AVL_SYS)
   )
the_converter_for_avalon_incr_slave
(
   .clk                (clk),
   .reset              (reset),
   .enable             (enable_incr_converter),
   .in_len             (in_len),
   .in_sop             (in_sop),
   .in_burstwrap_reg   (in_burstwrap_reg),
   .in_size            (in_size),
   .in_size_reg        (in_size_reg),
   .in_addr            (in_aligned_addr),
   .in_addr_reg        (in_aligned_addr_reg),
   .is_write           (is_write),
   .out_len            (incr_conveter_out_len),
   .uncompr_out_len    (incr_conveter_uncompr_out_len),
   .out_addr           (incr_conveter_out_addr),
   .new_burst_export   (incr_conveter_new_burst)
   );

altera_default_burst_converter
#(
   .BURST_TYPE_W        (BURST_TYPE_W),
   .ADDR_W              (ADDR_W),
   .BNDRY_W             (BNDRY_W),
   .BURST_SIZE_W        (BURST_SIZE_W),
   .BYTEEN_W            (BYTEEN_W),
   .LEN_W               (LEN_W),
   .IN_NARROW_SIZE      (IN_NARROW_SIZE),
   .LOG2_NUM_SYMBOLS    (LOG2_NUM_SYMBOLS),
   .IS_AXI_SLAVE        (IS_AXI_SLAVE)
   )
the_default_burst_converter
(
   .clk                 (clk),
   .reset               (reset),
   .enable              (enable_fixed_converter),
   .in_addr             (in_aligned_addr),
   .in_addr_reg         (in_aligned_addr_reg),
   .in_bursttype        (in_bursttype),
   .in_burstwrap_reg    (in_burstwrap_reg),
   .in_len              (in_len),
   .in_size_value       (in_size_value),
   .in_is_write         (is_write),
   .out_len             (fixed_conveter_out_len),
   .out_addr            (fixed_conveter_out_addr),
   .new_burst           (fixed_conveter_new_burst),
   .out_byteen          (out_byteen_pre)
   );
endmodule
