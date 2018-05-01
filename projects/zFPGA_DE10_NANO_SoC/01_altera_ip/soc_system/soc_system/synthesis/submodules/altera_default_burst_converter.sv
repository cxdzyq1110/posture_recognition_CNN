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


// $Id: //depot/users/tgngo/new_burst_adapter/opt_work/altera_default_burst_converter.sv#7 $
// $Revision: #7 $
// $Date: 2014/04/17 $
// $Author: tgngo $

// --------------------------------------------
// Default Burst Converter
// Notes:
//  1) If burst type FIXED and slave is AXI,
//     passthrough the transaction.
//  2) Else, converts burst into non-bursting
//     transactions (length of 1).
// --------------------------------------------

`timescale 1 ns / 1 ns

module altera_default_burst_converter
#(
    parameter BURST_TYPE_W      = 2,
    parameter BNDRY_W           = 5,
    parameter ADDR_W            = 12,
    parameter BYTEEN_W          = 8,
    parameter BURST_SIZE_W      = 3,
    parameter IN_NARROW_SIZE    = 0,
    parameter IS_AXI_SLAVE      = 0,
    parameter LEN_W             = 2,
    parameter LOG2_NUM_SYMBOLS  = 4
)
(
    input                          clk,
    input                          reset,
    input                          enable,

    input [BURST_TYPE_W - 1 : 0]   in_bursttype,
    input [BNDRY_W - 1 : 0]        in_burstwrap_reg,
    input [ADDR_W - 1 : 0]         in_addr,
    input [ADDR_W - 1 : 0]         in_addr_reg,
    input [LEN_W - 1 : 0]          in_len,
    input [BURST_SIZE_W - 1 : 0]   in_size_value,
    input                          in_is_write,

    output reg [ADDR_W - 1 : 0]    out_addr,
    output reg [LEN_W - 1 : 0]     out_len,
    output reg                     new_burst,
    output reg [BYTEEN_W - 1 : 0 ] out_byteen
);
    localparam NUM_SYMBOLS    = BYTEEN_W;
    localparam ADDR_MASK_SEL  = (NUM_SYMBOLS == 1) ? 1 : LOG2_NUM_SYMBOLS;

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


    // -------------------------------------------
    // Internal Signals
    // -------------------------------------------
    reg [ADDR_W - 1 : 0]     incr_wrapped_addr;
    reg [ADDR_W - 1 : 0]     next_incr_addr;
    reg [ADDR_W - 1 : 0]     extended_burstwrap_reg;
    wire [ADDR_W - 1 : 0]     addr_incr_variable_size_value;
    wire [LEN_W - 1 : 0]     unit_len = {{LEN_W - 1 {1'b0}}, 1'b1};
    reg [LEN_W - 1 : 0]      next_len;
    reg [LEN_W - 1 : 0]      remaining_len;

    // -------------------------------------------
    // Byte Count Converter
    // -------------------------------------------
    // Avalon Slave: Read/Write, the out_len is always 1 (unit_len).
    // AXI Slave: Read/Write, the out_len is always the in_len (pass through) of a given cycle.
    //            If bursttype RESERVED, out_len is always 1 (unit_len).
    generate if (IS_AXI_SLAVE == 1) begin : axi_slave_out_len
        always_ff @(posedge clk, posedge reset) begin
            if (reset)
                out_len <= '0;
            else if (enable) begin
                out_len <= (in_bursttype == FIXED) ? in_len : unit_len;
            end
        end
    end // block: axi_slave_out_len
    else // IS_AXI_SLAVE == 0
        begin : non_axi_slave_out_len
            always_comb begin
                out_len = unit_len;
            end
        end
    endgenerate

    // extend the burstwrap value for address increment
    always_comb begin : proc_extend_burstwrap
        extended_burstwrap_reg       = {{(ADDR_W - BNDRY_W){in_burstwrap_reg[BNDRY_W - 1]}}, in_burstwrap_reg};
        //addr_incr_variable_size_value  = {{(ADDR_W - 1){1'b0}}, 1'b1} << in_size_value;
    end
    // -------------------------------------------
    // Address increment
    // -------------------------------------------
    generate if (IN_NARROW_SIZE == 0) begin : addr_increment
        //assign addr_incr_variable_size_value  = NUM_SYMBOLS[ADDR_W - 1 : 0];
        assign addr_incr_variable_size_value  = NUM_SYMBOLS;
    end
    else begin
        assign addr_incr_variable_size_value  = {{(ADDR_W - 1){1'b0}}, 1'b1} << in_size_value;
    end
    endgenerate

    // -------------------------------------------
    // Byte-enable synthesis
    // -------------------------------------------
    // addr_masked is used to shift byteenable pattern
    reg  [ADDR_MASK_SEL - 1 : 0 ]    out_addr_masked;
    wire [511:0]                     initial_byteen = set_byteenable_based_on_size(in_size_value); // To fix quartus integration error. Unused bits are expected to be synthesized away
    always_comb begin
        out_addr_masked = incr_wrapped_addr[ADDR_MASK_SEL-1:0];
    end

    // -------------------------------------------
    // Address Converter
    // -------------------------------------------
    // Write: out_addr = in_addr at every cycle (pass through).
    // Read: out_addr = in_addr at every new_burst. Subsequent addresses calculated by converter.

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            next_incr_addr  <= '0;
            out_addr        <= '0;
            out_byteen      <= '0;
        end
        else if (enable) begin
            next_incr_addr <= incr_wrapped_addr + addr_incr_variable_size_value;
            out_addr    <= incr_wrapped_addr;
            out_byteen  <= initial_byteen[NUM_SYMBOLS-1:0] << out_addr_masked;
        end
    end

    // Calculates addresses of WRAP bursts and works perfectly fine for other burst types too.
    always_comb begin
        incr_wrapped_addr = in_addr;
        if (!new_burst) begin
            incr_wrapped_addr = (in_addr_reg & ~extended_burstwrap_reg) | (next_incr_addr & extended_burstwrap_reg);
        end
    end

    // -------------------------------------------
    // Control Signals
    // -------------------------------------------
    // Determine the min_len.
    //     1) FIXED read to AXI slave: One-time passthrough, therefore the min_len == in_len.
    //     2) FIXED write to AXI slave: min_len == 1.
    //     3) FIXED read/write to Avalon slave: min_len == 1.
    //     4) RESERVED read/write to AXI/Avalon slave: min_len == 1.

    // last beat calculation:
    // if Avalon slave, last beat is when the remaining length == unit length
    // if AXI slave, if read fixed then pass through, but if write fixed, the last beat still need compare with unit_len
    wire last_beat;
    generate if (IS_AXI_SLAVE == 1)
        begin : axi_slave_min_len
            assign last_beat = (!in_is_write && (in_bursttype == FIXED)) || (remaining_len == unit_len);
        end
    else // IS_AXI_SLAVE == 0
        begin : non_axi_slave_min_len
            assign last_beat = (remaining_len == unit_len);
        end
    endgenerate

    // next_len calculation.
    always_comb begin
        remaining_len = in_len;
        if (!new_burst)
            remaining_len = next_len;
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            next_len <= '0;
        end

        else if (enable) begin
            next_len <= remaining_len - unit_len;
        end
    end

    // new_burst calculation.
    always_ff @(posedge clk, posedge reset) begin
       if (reset) begin
            new_burst <= 1'b1;
        end
        else if (enable) begin
            new_burst <= last_beat;
        end
    end

    //----------------------------------------------------
    // AXSIZE encoding: run-time  size of the transaction.
    // ---------------------------------------------------
    function reg[511:0] set_byteenable_based_on_size;
        input [3:0] axsize;
        begin
            case (axsize)
                4'b0000: set_byteenable_based_on_size = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001;
                4'b0001: set_byteenable_based_on_size = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003;
                4'b0010: set_byteenable_based_on_size = 512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000F;
                4'b0011: set_byteenable_based_on_size = 512'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FF;
                4'b0100: set_byteenable_based_on_size = 512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FFFF;
                4'b0101: set_byteenable_based_on_size = 512'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FFFFFFFF;
                4'b0110: set_byteenable_based_on_size = 512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFF;
                4'b0111: set_byteenable_based_on_size = 512'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                4'b1000: set_byteenable_based_on_size = 512'h0000000000000000000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                4'b1001: set_byteenable_based_on_size = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                default: set_byteenable_based_on_size = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001;
            endcase
        end
    endfunction

endmodule
