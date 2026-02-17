`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2026 03:56:31 AM
// Design Name: 
// Module Name: instruction_memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////


module instruction_memory(
    input logic         clk,            // clock
    input logic         rst_n,          // reset
    input logic         instr_en,       // instruction enable
    input logic  [31:0] instr_addr,     // instruction address
    output logic [31:0] instr_data,     // instruction data
    input logic         instr_valid_in, // instruction valid input
    output logic        instr_valid_out // intstruction valid output
    );
    
    logic valid_pr;      // valid bit pipeline register
    logic i_reset;  // internal reset
    
    
    blk_mem_gen_0 i_mem (       // bram initilization
        .clka       (clk),
        .rsta       (rst_n),
        .ena        (instr_en),
        .addra      (instr_addr),
        .douta      (instr_data),
        .rsta_busy  (i_reset)
    );
    
    always_ff @ (posedge clk) begin
        valid_pr <= instr_valid_in && !i_reset;
        instr_valid_out <= valid_pr;
    end
endmodule
