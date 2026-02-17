// decode_stage.sv

module decode_stage (
    // clk and rst_n (active low) declarations
    input logic clk,
    input logic rst_n,

    // flush deetermines if new values will be read into/out of the pipeline
    input logic flush,

    // the stage inputs and outputs
    // decode is the consumer of the if_id pipeline values (data_d)
    // decode is the driver/producer of the id_ex pipeline values (data_q)
    input rv_pipe_pkg::if_id_t data_d,
    output rv_pipe_pkg::id_ex_t data_q
);
    import rv_pipe_pkg::*;

    logic [31:0] instruction = data_d.instruction;
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
            data_q <= '0; // on rst assert low, all members of data_q go to 0
        end else begin
            if (!flush) begin
                data_d.rs1 <= register_file[instruction[19:15]];
                data_d.rs2 <= register_file[instruction[24:20]];
                data_d.rd_addr <= data_q[11:7];
                data_d.pc <= data_q.pc;
                data_d.control_bits <= control_bits;
                data_d.immediates <= immediates;
                data_d.func3 <= instruction[14:12];
                data_d.func7 <= instruction[31:25];
                data_d.valid <= data_q.valid;
            end
        end
    end
endmodule
