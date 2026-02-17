`timescale 1ns / 1ps

module top(
    input clk,
    input rst_n
);
    import rv_pipe_pkg::*;

    pipe_if #(.T(if_id_t)) if_id_bus;

    fetch_stage u_fetch(
        .clk(clk),
        .rst_n(rst_n),
        .if_id_out(if_id_bus)
    );

endmodule
