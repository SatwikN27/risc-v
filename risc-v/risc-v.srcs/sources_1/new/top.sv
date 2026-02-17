`timescale 1ns / 1ps

module top(
    input logic clk,
    input logic rst_n,
    output logic the_stupid_godamn_output
);
    import rv_pipe_pkg::*;
    
    if_id_t if_id;
    logic stall;
    logic flush;
    logic flushPC;
    
    assign the_stupid_godamn_output = clk;

    fetch_stage u_fetch(
        .clk        (clk),
        .rst_n      (rst_n),
        .stall      (stall),
        .flush      (flush),
        .flushPC    (flushPC),
        .data       (if_id)
    );

endmodule
