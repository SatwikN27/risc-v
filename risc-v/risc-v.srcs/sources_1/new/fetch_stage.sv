// fetch_stage.sv

// module declaration for the fetch stage
// drives the if_id (instruction fetch / instruction decode) interface

module fetch_stage (
    // clk and rst_n (active low) inputs, since this state doesnt have
    // conventional drivers like the other
    input clk,
    input rst_n,

    // 
    pipe_if #(rv_pipe_pkg::if_id_t).cons if_id_out
);
    import rv_pipe_pkg::*;

    always_comb begin
        if_id_out.valid         = 1'b1; // TODO: add gated logic for valid states
        if_id_out.pc            = 32'b0; // TODO: replace with incrementing PC
        if_id_out.instruction   = 32'b0; // TODO: replace with instruction memory
    end


endmodule
