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
    input logic         execute_pc_JAL_MUX,
    input logic [31:0]  execute_pc_JAL_addr,

    // output is a 
    output rv_pipe_pkg::if_id_t if_id,
    //output logic [31:0] instruction
    output logic        JAL_taken    //set to 1 when PC is set to JAL_addr
);
    import rv_pipe_pkg::*;


    // PC init
    logic [31:0]    PC;
    
    // I_MEM init
    logic [31:0]    instr_data;
    logic           instr_valid_out;
    
    instruction_memory instr_mem (
        .clk                (clk),
        .rst_n              (rst_n),
        .flush              (pc_flush),
        .stall              (pc_stall),
        .instr_en           (!pc_stall),
        .instr_addr         (PC),
        .instr_data         (instr_data),
        .instr_valid_out    (instr_valid_out)
    );

    logic [15:0] PC_pipe_0_lower;
    logic [15:0] PC_pipe_0_upper;
    
    logic PC_pipe_0_cout;
    
    logic [15:0] PC_pipe_1_lower;
    logic [15:0] PC_pipe_1_upper;
    logic JAL_taken_pipe;

    always_ff @ (posedge clk) begin
        if(!rst_n) begin
            PC <= 32'b0;
            {PC_pipe_1_upper, PC_pipe_1_lower} <= 32'd4;
            PC_pipe_0_cout <= 1'b0;
            {PC_pipe_0_upper, PC_pipe_0_lower} <= 32'd8;
            JAL_taken                          <= 1'b0;
        end else if (pc_flush) begin
            {PC_pipe_0_lower, PC_pipe_0_upper} <= pc_flush_addr;
            JAL_taken                          <= 1'b0;
            end //lse if (execute_pc_JAL_MUX) begin
            //{PC_pipe_0_lower, PC_pipe_0_upper} <= execute_pc_JAL_addr;
            //JAL_taken                          <= 1'b1;
        //end 
        else begin
            PC_pipe_0_upper <= PC[31:16];
            {PC_pipe_0_cout, PC_pipe_0_lower} <= PC[15:0] + 12;
                
            PC_pipe_1_lower <= PC_pipe_0_lower;
            PC_pipe_1_upper <= PC_pipe_0_upper + PC_pipe_0_cout;
            JAL_taken                          <= 1'b0;
        end 
    end
    
    
    always_ff @ (posedge clk) begin
        PC <= {PC_pipe_1_upper, PC_pipe_1_lower};
    end
    

    always_ff @(posedge clk) begin
        if(!pc_stall) begin
            if_id.pc             <= PC;
            if_id.instruction    <= instr_data;
            if_id.valid          <= instr_valid_out;
            if_id.opcode         <= instr_data[6:0];
            if_id.JAL_taken      <= JAL_taken_pipe;
            JAL_taken_pipe       <= JAL_taken;
        
            //instruction          <= instr_data;
        end
    end

endmodule
