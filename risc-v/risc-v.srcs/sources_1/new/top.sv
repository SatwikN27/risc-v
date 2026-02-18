`timescale 1ns / 1ps

module top(
    input logic clk,
    input logic rst_n,
    output logic out // requried output otherwise the module gets optimized away
);
    import rv_pipe_pkg::*;

    assign out = clk;   // required top output conneciton
                        // to prevent vivado from breaking

    // initialize if_id pipeline register
    // initialize fetch stage control bits
    if_id_t if_id;
    logic pc_stall, pc_flush, pc_flush_addr;

    fetch_stage u_fetch(.*);

    // initialize id_ex pipeline register
    // initialize decode stage control bits
    id_ex_t id_ex;
    logic decode_flush;
    logic decode_rf_we; // write enable for the register file
    logic [4:0] decode_write_addr;
    logic [31:0] decode_write_value;

    decode_stage u_decode(.*);

    ex_mem_t ex_mem;

    execute_stage u_execute(.*);


    mem_wb_t mem_wb;


endmodule
