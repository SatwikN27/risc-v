// decode_stage.sv

module decode_stage (
    // clk and rst_n (active low) declarations
    input logic clk,
    input logic rst_n,

    // decode_flush deetermines if new values will be read into/out of the pipeline
    input logic decode_flush,

    // the stage inputs and outputs
    // decode is the consumer of the if_id pipeline values (id_ex)
    // decode is the driver/producer of the id_ex pipeline values (if_id)
    input rv_pipe_pkg::if_id_t if_id,
    output rv_pipe_pkg::id_ex_t id_ex
);
    import rv_pipe_pkg::*;

    logic [31:0] instruction = if_id.instruction;
    logic msb = instruction[31];

    logic [31:0] register_file [0:31];


    control_t control_bits;
    immediates_t immediates;

    always_comb begin
        control_bits.invert_alu = 0;
    end

    always_comb begin
        immediates.immI = {{20{msb}}, instruction[31:20]};
        immediates.immS = {{20{msb}}, instruction[31:25], instruction[11:7]};
        immediates.immB = {{19{msb}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
        immediates.immU = {instruction[31:12],{12{0}}};
        immediates.immJ = {{11{msb}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21]};
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_ex <= '0; // on rst assert low, all members of if_id go to 0
        end else begin
            if (!decode_flush) begin
                id_ex.rs1 <= register_file[instruction[19:15]];
                id_ex.rs2 <= register_file[instruction[24:20]];
                id_ex.rd_addr <= if_id[11:7];
                id_ex.pc <= if_id.pc;
                id_ex.control_bits <= control_bits;
                id_ex.immediates <= immediates;
                id_ex.func3 <= instruction[14:12];
                id_ex.func7 <= instruction[31:25];
                id_ex.valid <= if_id.valid;
                id_ex.opcode <= if_id.opcode;
            end
        end
    end
endmodule
