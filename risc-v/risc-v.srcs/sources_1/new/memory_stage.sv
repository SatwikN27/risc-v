`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2026 01:21:21 AM
// Design Name: 
// Module Name: memory_stage
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
// 
//////////////////////////////////////////////////////////////////////////////////


module memory_stage(
    input logic clk,
    input logic rst_n,
    
    
    
    input logic memory_flush,
    input logic memory_stall,
    
    input rv_pipe_pkg::ex_mem_t ex_mem,
    output rv_pipe_pkg::mem_wb_t mem_wb
    );
    import rv_pipe_pkg::*;
    
    // data pipeline registers
    logic           valid_pr1;
    logic [6:0]     opcode_pr1;
    logic [2:0]     func3_pr1;
    logic [2:0]     func7_pr1;
    logic [4:0]     rd_addr_pr1;
    logic [31:0]    execute_out_pr1;
    
    logic           valid_pr2;
    logic [6:0]     opcode_pr2;
    logic [2:0]     func3_pr2;
    logic [2:0]     func7_pr2;
    logic [4:0]     rd_addr_pr2;
    logic [31:0]    execute_out_pr2;
    
    
        
    logic           write_chip_en = 1'b1;
    logic           write_en;
    logic [31:0]    write_addr;
    logic [31:0]    write_data;
    logic           read_chip_en = 1'b1;
    logic           read_valid_in;
    logic [31:0]    read_addr;
    logic [31:0]    read_data;

    
    //opcode decode stage. Replace with control bits
    always_comb begin
        if(ex_mem.opcode == LOAD_IMMEDIATE) begin
            write_en = 1'b0;
            read_addr = ex_mem.mem_addr;
            
        end else if(ex_mem.opcode == STORE) begin
            write_en = 1'b1;
            write_addr = ex_mem.mem_addr;
            
        end else begin
            write_en = 1'b0;
        end
    end
    
    // main memory instantiation
    main_memory main_mem(.*);
    
    always_ff @ (posedge clk or negedge rst_n) begin
        if(!rst_n || memory_flush) begin
            valid_pr1 <= 1'b0;
            valid_pr2 <= 1'b0;
  
        end else if(!memory_stall) begin
            valid_pr1 <= ex_mem.valid;
            opcode_pr1 <= ex_mem.opcode;
            func3_pr1 <= ex_mem.func3;
            func7_pr1 <= ex_mem.func7;
            rd_addr_pr1 <= ex_mem.rd_addr;
            execute_out_pr1 <= ex_mem.execute_out;
            
            valid_pr2 <= valid_pr1;
            opcode_pr2 <= opcode_pr1;
            func3_pr2 <= func3_pr1;
            func7_pr2 <= func7_pr1;
            rd_addr_pr2 <= rd_addr_pr1;
            execute_out_pr2 <= execute_out_pr1;
            
            mem_wb.valid <= valid_pr2;
            mem_wb.read_data <= read_data; 
            mem_wb.opcode <= opcode_pr2;
            mem_wb.func3 <= func3_pr2;
            mem_wb.func7 <= func7_pr2;
            mem_wb.rd_addr <= rd_addr_pr2;
            mem_wb.execute_out <= execute_out_pr2;
        end
    end
    
endmodule
