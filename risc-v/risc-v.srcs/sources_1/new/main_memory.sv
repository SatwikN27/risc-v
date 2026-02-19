`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2026 09:06:19 PM
// Design Name: 
// Module Name: main_memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// wrapper for main memory
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main_memory(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        write_chip_en,
    input  logic        write_en,
    input  logic [31:0] write_addr,
    input  logic [31:0] write_data,
    input  logic        read_chip_en,
    input  logic [31:0] read_addr,
    output logic [31:0] read_data
    );
    
    logic write_busy;
    logic read_busy;
    
    blk_mem_gen_1 main_mem_block(
        .clka       (clk),
        .ena        (write_chip_en),
        .wea        (write_en),
        .addra      (write_addr),
        .dina       (write_data),
        .clkb       (clk),
        .rstb       (rst_n),
        .enb        (read_chip_en),
        .addrb      (read_addr),
        .doutb      (read_data),
        .rsta_busy  (write_busy),
        .rstb_busy  (read_busy)
    );
    
endmodule
