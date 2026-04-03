// execute_stage.sv
module execute_stage(
    input clk,
    input rst_n,
    input rv_pipe_pkg::id_ex_t id_ex,
    output rv_pipe_pkg::ex_mem_t ex_mem,
    output logic [31:0] execute_pc_JAL_addr,
    output logic execute_pc_JAL_MUX
);
    import rv_pipe_pkg::*;

    logic [31:0] rs1, rs2, value2;
    assign rs1    = id_ex.rs1;
    assign rs2    = id_ex.rs2;
    assign value2 = {id_ex.opcode[5], id_ex.opcode[4]} == 2'b11 ? rs2 : id_ex.immediates.immI;

    // Control pipeline register — 1 cycle delay, shared by both stage-2 blocks
    id_ex_t id_ex_s1;

    // ── mem_addr Stage 1 registers ───────────────────────────────────────────
    logic [31:0] mem_addr_I;  // rs1 + immI  (load)
    logic [31:0] mem_addr_S;  // rs1 + immS  (store)

    // ── execute Stage 1 registers ────────────────────────────────────────────
    logic [31:0] add;      // ADD
    logic [31:0] sub;      // SUB
    logic [31:0] sll;      // SLL
    logic [31:0] slt;      // SLT
    logic [31:0] sltu;     // SLTU
    logic [31:0] xor_res;  // XOR
    logic [31:0] srl;      // SRL
    logic [31:0] sra;      // SRA
    logic [31:0] or_res;   // OR
    logic [31:0] and_res;  // AND
    logic [31:0] jal;      // JAL

    logic [31:0] jal_last_stage; //Set valid bit for rst
	logic [32:0] valid_and_execute_out; // {1, execute_out} for simplifying switch case

	assign {ex_mem.valid, ex_mem.execute_out} = valid_and_execute_out;
 
    // ── mem_addr Stage 1: compute both address candidates ────────────────────
    always_ff @(posedge clk) begin
        mem_addr_I <= rs1 + id_ex.immediates.immI;
        mem_addr_S <= rs1 + id_ex.immediates.immS;
        id_ex_s1   <= id_ex;  // pipeline control signals for both stage-2 blocks
    end

    // ── mem_addr Stage 2: select correct address ─────────────────────────────
    always_ff @(posedge clk) begin
        if ({id_ex_s1.opcode[6], id_ex_s1.opcode[5], id_ex_s1.opcode[4],
             id_ex_s1.opcode[1], id_ex_s1.opcode[0]} == 5'b00011) begin
            ex_mem.mem_addr <= mem_addr_I;  // load: rs1 + immI
        end else begin
            ex_mem.mem_addr <= mem_addr_S;  // store: rs1 + immS
        end
    end

    // ── execute Stage 1: compute all candidates ──────────────────────────────
    always_ff @(posedge clk) begin
        add     <= rs1 + value2;
        sub     <= rs1 - value2;
        sll     <= rs1 << value2[4:0];
        slt     <= ($signed(rs1) < $signed(value2)) ? 32'd1 : 32'd0;
        sltu    <= (rs1 < value2)                   ? 32'd1 : 32'd0;
        xor_res <= rs1 ^ value2;
        srl     <= rs1 >> value2[4:0];
        sra     <= 32'($signed(rs1) >>> value2[4:0]);
        or_res  <= rs1 | value2;
        and_res <= rs1 & value2;
        jal     <= id_ex.pc + id_ex.immediates.immJ;
    end

    // ── execute Stage 2: select correct result ───────────────────────────────
    always_ff @(posedge clk) begin
       
        if (id_ex_s1.opcode == JAL) begin
            ex_mem.valid <= 0;      //clear output valid bit
            if (id_ex_s1.JAL_taken) begin
            jal_last_stage <= 0;
        end else if(!jal_last_stage) begin
            jal_last_stage <= 1;
        end
        end else begin
            ex_mem.valid        <= id_ex_s1.valid;
        end
        
        if (id_ex_s1.opcode != JAL) begin
            unique case (id_ex_s1.func3)
                3'h0: valid_and_execute_out <= {1, id_ex_s1.func7 == 7'h20 ? sub : add}; // SUB & ADD
                3'h1: valid_and_execute_out <= {1, sll};
                3'h2: valid_and_execute_out <= {1, slt}; // SLT
                3'h3: valid_and_execute_out <= {1, sltu}; // SLTU
                3'h4: valid_and_execute_out <= {1, xor_res}; // XOR
                3'h5: valid_and_execute_out <= {1, id_ex_s1.func7 == 7'h20 ? sra : srl}; // SRL & SRA
                3'h6: valid_and_execute_out <= {1, or_res}; // OR
                3'h7: valid_and_execute_out <= {1, and_res}; // AND
                default: valid_and_execute_out <= 32'b0;
            endcase
            begin
                execute_pc_JAL_MUX  <= 1'b0;
            end
        end else begin
            valid_and_execute_out[31:0]  <= jal;
            execute_pc_JAL_addr <= jal;
            execute_pc_JAL_MUX  <= 1'b1; //if JAL, set PC JAL mux control bit
        end
    
        ex_mem.opcode  <= id_ex_s1.opcode;
        ex_mem.rd_addr <= id_ex_s1.rd_addr;
        ex_mem.rs2     <= id_ex_s1.rs2;
        ex_mem.func3   <= id_ex_s1.func3;
        
<<<<<<< HEAD
=======
        if(jal_last_stage) begin    //check if instruction reaches end of pipeline and branch is not yet taken
            valid_and_execute_out <= 32'b0;      //clear output valid bit
            if(id_ex_s1.JAL_taken) begin
                jal_last_stage <= 0;
            end
        end else begin
            valid_and_execute_out[32]        <= id_ex_s1.valid;
        end
>>>>>>> 64a6a07accd82247929877677383ed4125f224a6
    end
endmodule
