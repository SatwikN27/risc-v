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
    output logic        instr_valid_out // intstruction valid output
    );
    
    logic valid_pr;     // valid bit pipeline register
    logic i_reset;      // internal reset
    
    
    blk_mem_gen_0 i_mem (       // bram initilization
        .clka       (clk),
        .rsta       (rst_n),
        .ena        (instr_en),
        .addra      (instr_addr),
        .douta      (instr_data),
        .rsta_busy  (i_reset)
    );
    
    always_ff @ (posedge clk) begin
        if(!rst_n) begin
            valid_pr <= 1'b0;
            instr_valid_out <= 1'b0;
        end else begin
            valid_pr <= instr_en && !i_reset;
            instr_valid_out <= valid_pr;
        end
    end
endmodule
