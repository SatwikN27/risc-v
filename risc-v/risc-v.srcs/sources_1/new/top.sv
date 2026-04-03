`timescale 1ns / 1ps

module top(
   input logic clk,
   input logic rst_n,
   //input rv_pipe_pkg::mem_wb_t mem_wb,
   output rv_pipe_pkg::wb_out_t wb_out

   //output logic out, // requried output otherwise the module gets optimized away
   //output logic [31:0] register_file_exposed // expose register file to prevent vivado from optimizing away
   // input logic [31:0]    pc,
   // input logic [31:0]    instruction,
   // input logic [6:0]     opcode,
   // input logic           valid,

   // logic [6:0]     opcode;
   // output logic [31:0]        rs1;
   // output logic [31:0]        rs2;
   // output logic [4:0]         rd_addr;
   // output logic [31:0]        pc;
   // output control_t     control_bits;
   // output rv_pipe_pkg::immediates_t  immediates;
   // output logic [2:0]         func3;
   // output logic [6:0]         func7;
   // output logic               valid;
);
    import rv_pipe_pkg::*;
    //logic rst_n = 1;
    //assign out = clk;   // required top output conneciton
                        // to prevent vivado from breaking

    // initialize if_id pipeline register
    // initialize fetch stage control bits
    if_id_t if_id;
    logic pc_stall = 0 ;
    logic pc_flush = 0;
    logic [31:0] pc_flush_addr = 32'b0;

    fetch_stage u_fetch(.*);

    // initialize id_ex pipeline register
    // initialize decode stage control bits
    id_ex_t id_ex;
    
    wb_dec_t wb_dec;

    logic decode_flush = 0; // TODO: ts stall not flush


    decode_stage u_decode(.*);

    ex_mem_t ex_mem;

    execute_stage u_execute(.*);

    logic [31:0] execute_pc_JAL_addr;
    logic        execute_pc_JAL_MUX;
    logic        JAL_taken;

    mem_wb_t mem_wb;
    
    logic memory_flush = 0;
    logic memory_stall= 0;
    memory_stage u_memory(.*);

    writeback_stage u_writeback(.*);

endmodule
