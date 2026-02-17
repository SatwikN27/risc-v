`timescale 1ns / 1ps

module top(
    input clk,
    input rst_n
);


    pipe_if #(rv_pipe_pkg::if_id_t) if_id_bus();

    fetch_stage u_fetch(
        .clk(clk),
        .rst_n(rst_n),
        .if_id_out(if_id_bus)
    );

endmodule
