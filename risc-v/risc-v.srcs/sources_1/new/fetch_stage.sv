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
    
	// instruction memory internal reset signal
	logic i_reset;

    instruction_memory instr_mem (
        .clk                (clk),
        .rst_n              (rst_n),
        .flush              (pc_flush),
        .stall              (pc_stall),
        .instr_en           (!pc_stall),
        .instr_addr         (PC),
        .instr_data         (instr_data),
        .instr_valid_out    (instr_valid_out),
		.i_reset			(i_reset)
    );

    logic [15:0] PC_pipe_0_lower;
    logic [15:0] PC_pipe_0_upper;
    
    logic PC_pipe_0_cout;
    
    logic [15:0] PC_pipe_1_lower;
    logic [15:0] PC_pipe_1_upper;
    logic JAL_taken_pipe;

    always_ff @ (posedge clk) begin
        if(!rst_n) begin 
            {PC_pipe_1_upper, PC_pipe_1_lower} <= 32'd0;
            PC_pipe_0_cout <= 1'b0;
            {PC_pipe_0_upper, PC_pipe_0_lower} <= 32'd4;
            JAL_taken                          <= 1'b0;
            if_id <= '{default:0};
        end else if (pc_flush) begin
            {PC_pipe_0_lower, PC_pipe_0_upper} <= pc_flush_addr;
            JAL_taken                          <= 1'b0;
        end else if (execute_pc_JAL_MUX) begin
            {PC_pipe_0_lower, PC_pipe_0_upper} <= execute_pc_JAL_addr;
            JAL_taken                          <= 1'b1;
        end else begin
            PC_pipe_1_lower <= PC_pipe_0_lower;
            PC_pipe_1_upper <= PC_pipe_0_upper + PC_pipe_0_cout;
            JAL_taken                          <= 1'b0;
        
            PC_pipe_0_upper <= PC[31:16];
            {PC_pipe_0_cout, PC_pipe_0_lower} <= PC[15:0] + 16'd8;
                

        end 
    end
    
    
    assign PC = {PC_pipe_1_upper, PC_pipe_1_lower};

    always_ff @(posedge clk) begin
        if(!pc_stall && rst_n) begin
            if_id.pc             <= PC;
            if_id.instruction    <= instr_data;
            if_id.valid          <= (!(| instr_data)) & instr_valid_out; // If all bits from the instr data are 0s, this is a nop and an invalid instruction
            if_id.opcode         <= instr_data[6:0];
            if_id.JAL_taken      <= JAL_taken_pipe;
            JAL_taken_pipe       <= JAL_taken;
        
            //instruction          <= instr_data;
        end
    end

endmodule
