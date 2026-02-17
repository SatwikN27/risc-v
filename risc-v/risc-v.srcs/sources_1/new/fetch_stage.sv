// fetch_stage.sv

// module declaration for the fetch stage
// drives the if_id (instruction fetch / instruction decode) interface

module fetch_stage (
    // clk and rst_n (active low) inputs, since this state doesnt have
    // conventional drivers like the other
    input logic         clk,
    input logic         rst_n,
    input logic         stall,
    input logic         flush,
    input logic [31:0]  flushPC,

    // output is a 
    output rv_pipe_pkg::if_id_t data
);
    import rv_pipe_pkg::*;
    
    
    // PC init
    logic [31:0]    PC;
    
    // I_MEM init
    logic   instr_data;
    logic   instr_valid_out;
    
    instruction_memory instr_mem (
        .clk                (clk),
        .rst_n              (rst_n),
        .instr_en           (!stall),
        .instr_addr         (PC),
        .instr_data         (instr_data),
        .instr_valid_out    (instr_valid_out)
    );

    always_ff @ (posedge clk) begin
        if(!rst_n) begin
            PC <= 32'b0;
        end else if(flush) begin
            PC <= flushPC;
        end else begin
            PC <= PC + 4;
        end
    end

    always_comb begin
        data.pc             = PC;
        data.instruction    = instr_data;
        data.valid          = instr_valid_out;
    end


endmodule
