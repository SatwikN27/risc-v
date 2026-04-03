//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 03/30/2026 11:24:40 PM
//// Design Name: 
//// Module Name: L1_instruction_cache
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//module L1_instruction_cache #(parameter N = 4, parameter WORD_SIZE = 32, parameter CACHE_LINE = 32)(
//    input logic clk,
//    input logic rst,
//    input logic [31:0] address,
//    output logic data
//);
//    localparam int SET_ID_BITS = $clog2((32768/(CACHE_LINE*8))/N);
//    localparam int WORD_ID_BITS = $clog2(CACHE_LINE*8/WORD_SIZE);
//    localparam int TAG_BITS = 32 - SET_ID_BITS - WORD_BITS;
    
//    logic [SET_ID_BITS-1:0] set_id;
//    logic [WORD_ID_BITS-1:0] word_id;
//    logic [TAG_BITS-1:0] tag;
    
//    logic [CACHE_LINE*8-1:0] data_array [((32768/(CACHE_LINE*8))/N)-1:0][N-1:0]; //l1 cache size 4 kilobytes: num_sets x 4 cache lines
//    logic [TAG_BITS-1:0] tag_array [((32768/(CACHE_LINE*8))/N)-1:0][N-1:0];
    
    
//    assign {tag, set_id, word_id} = address;
    
//    logic [N-1:0] hit_array;

//    generate
//        for (genvar i = 0; i < N; i++) begin
//            //assign hit_array[i] = 
//        end
//    endgenerate

//    always_ff @(posedge clk) begin
        
//    end

//endmodule
