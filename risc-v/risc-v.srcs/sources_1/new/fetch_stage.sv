// fetch_stage.sv

// module declaration for the fetch stage
// drives the if_id (instruction fetch / instruction decode) interface

module fetch_stage (
    // clk and rst_n (active low) inputs, since this state doesnt have
    // conventional drivers like the other
    input logic         clk,
    input logic         rst_n,
    input logic         pc_stall,
    input logic         pc_flush,
    input logic [31:0]  pc_flush_addr,

    // output is a 
    output rv_pipe_pkg::if_id_t if_id
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
        .instr_en           (!pc_stall),
        .instr_addr         (PC),
        .instr_data         (instr_data),
        .instr_valid_out    (instr_valid_out)
    );

    always_ff @ (posedge clk) begin
        if(!rst_n) begin
            PC <= 32'b0;
        end else if(pc_flush) begin
            PC <= pc_flush_addr;
        end else begin
            PC <= PC + 4;
        end
    end

    always_comb begin
        if_id.pc             = PC;
        if_id.instruction    = instr_data;
        if_id.valid          = instr_valid_out;
    end


endmodule
