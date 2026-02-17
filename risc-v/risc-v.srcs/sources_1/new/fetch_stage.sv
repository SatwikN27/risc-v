// fetch_stage.sv

// module declaration for the fetch stage
// drives the if_id (instruction fetch / instruction decode) interface

module fetch_stage (
    // clk and rst_n (active low) inputs, since this state doesnt have
    // conventional drivers like the other
    input logic clk,
    input logic rst_n,

    // output is a 
    output rv_pipe_pkg::if_id_t data,
    output logic valid
);

    import rv_pipe_pkg::*;

    always_comb begin
        data.pc             = 32'b0;
        data.instruction    = 31'b0;
    end


endmodule
