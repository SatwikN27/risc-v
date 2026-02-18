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
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main_memory(
    input   clk,
    input   rst_n,
    input   mem_en,
    input   write_en,
    input   write_addr,
    input   write_data,
    input   read_en,
    input   read_addr,
    output  read_data,
    output  write_busy,
    output  read_busy
    );
    
    blk_mem_gen_1 main_mem_block(
        .clka       (clk),
        .ena        (mem_en),
        .wea        (write_en),
        .addra      (write_addr),
        .dina       (write_data),
        .clkb       (clk),
        .rstb       (rst_n),
        .enb        (read_en),
        .addrb      (read_addr),
        .doutb      (read_data),
        .rsta_busy  (write_busy),
        .rstb_busy  (read_busy)
    );
    
endmodule
