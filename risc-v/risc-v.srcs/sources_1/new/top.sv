`timescale 1ns / 1ps

module top(
    input logic clk,
    //input logic rst_n,
    //output logic out, // requried output otherwise the module gets optimized away
    //output logic [31:0] register_file_exposed // expose register file to prevent vivado from optimizing away
    output logic [31:0] instruction
    
);
    import rv_pipe_pkg::*;
    logic rst_n = 1;
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
//    id_ex_t id_ex;
//    logic decode_flush = 0; // TODO: ts stall not flush


//    decode_stage u_decode(.*);

//    ex_mem_t ex_mem;

//    execute_stage u_execute(.*);

//    mem_wb_t mem_wb;
    
//    logic memory_flush = 0;
//    logic memory_stall= 0;
//    memory_stage u_memory(.*);

//    wb_dec_t wb_dec;
//    writeback_stage u_writeback(.*);

endmodule
