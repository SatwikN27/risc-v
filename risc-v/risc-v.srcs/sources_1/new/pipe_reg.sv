// pipe_reg.sv

// an instantializable generic pipeline module
// T is a packed data type containing the ports for the pipeline instance
// stall and flush are control bits for every pipeline, detailed below
// valid is a pipelined bit which asserts if the the pipeline is valid

module pipe_reg #(
    parameter type T = logic [0:0]
) (
    // clk and rst_n (active low) signals
    input logic clk,
    input logic rst_n,

    // control bits stall and flush
    // stall: prevents pulling new data and evicting old data
    // flush: sets valid/outputs to 0
    input logic stall,
    input logic flush,

    // valid_d: pipelined valid bit in that travels with the instruction
    // data_d: data input to pipeline from previous stage
    input logic valid_d,
    input T     data_d,

    // valid_q: pipelined valid bit out that travels with the instruction
    // data_q: data output to next pipeline stage
    output logic valid_q,
    output T     data_q
);
    always_ff @(posedge  clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_q <= 1'b0; // on reset the pipelines data becomes invalid
            data_q <= '0; // on reset all of the data structs members get 0
        end else if (flush) begin // flush is same as reset
            valid_q <= 1'b0;
            data_q <= '0;
        end else if (!stall) begin // pipeline inputs to outputs (d -> q)
            valid_q <= valid_d;
            data_q <= data_d;
        end
    end
endmodule
