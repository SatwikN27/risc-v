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


    // Control pipeline register — 1 cycle delay, shared by both stage-2 blocks
    id_ex_t id_ex_s1;

    // ── mem_addr Stage 1 registers ───────────────────────────────────────────
    logic [31:0] mem_addr_I;  // rs1 + immI  (load)
    logic [31:0] mem_addr_S;  // rs1 + immS  (store)

    // ── mem_addr Stage 1 registers ───────────────────────────────────────────
	logic [15:0] mem_addr_I_sum_lower;
	logic [15:0] mem_addr_S_sum_lower;

	logic	 	 mem_addr_I_co;
	logic	 	 mem_addr_S_co;

    // ── execute Stage 1 registers ────────────────────────────────────────────
	logic [15:0] add_sum_lower; // ADD
	logic        add_co_lower;

	logic [15:0] sub_sum_lower; // SUB
	logic        sub_co_lower;

	logic [15:0] sll_half_shift; // SLL

	logic        slt_top_equals; // SLT
	logic        slt_top_lt;

	logic        sltu_top_equals; // SLTU
	logic        sltu_top_lt;

	logic [15:0] xor_res_bottom; // XOR

	logic [31:0] srl_half_shift; // SRL

	logic [31:0] sra_half_shift; // SRA

	logic [15:0] or_res_bottom; // OR

	logic [15:0] and_res_bottom; // AND
				
	logic [15:0] jal_sum_lower; // JAL
	logic        jal_co_lower;

	// Piped inputs
	logic [31:0] rs1_pipe;
	logic [31:0] value2_pipe;
	logic [31:0] pc_pipe;
	logic [31:0] immJ_pipe;

    // ── execute Stage 2 registers ────────────────────────────────────────────
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
	
	logic [31:0] rs1, rs2, value2;
    id_ex_t id_ex_s0;  // pre-stage: registered alongside rs1/value2

	// ── Mux tree intermediates ────────────────────────────────────────────────
	logic [31:0] mux_0_1, mux_2_3, mux_4_5, mux_6_7;
	logic [31:0] mux_01_23, mux_45_67;
	id_ex_t      id_ex_s2, id_ex_s3;
	logic [31:0] jal_s2, jal_s3;

	// ── Mem addr pipeline through mux tree stages ─────────────────────────────
	logic [31:0] mem_addr_I_s2, mem_addr_S_s2;
	logic [31:0] mem_addr_I_s3, mem_addr_S_s3;

    // -- Rst Values on neg edge of rst_n --------------------------------------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            execute_pc_JAL_MUX <= 1'b0;
            id_ex_s1 <= '{default:0};
            id_ex_s2 <= '{default:0};
            id_ex_s3 <= '{default:0};
        end
    end


	// ── Latch and pipeline rs values and necessary imediates ───────────────────
	always_ff @(posedge clk) begin
		rs1      <= id_ex.rs1;
		rs2      <= id_ex.rs2;
		value2   <= {id_ex.opcode[5], id_ex.opcode[4]} == 2'b11 ? id_ex.rs2 : id_ex.immediates.immI;
		id_ex_s0 <= id_ex;
	end

    // ── mem_addr Stage 1: compute both address candidates ────────────────────
    always_ff @(posedge clk) begin
        {mem_addr_I_co, mem_addr_I_sum_lower} <= rs1[15:0] + id_ex_s0.immediates.immI[15:0];
        {mem_addr_S_co, mem_addr_S_sum_lower} <= rs1[15:0] + id_ex_s0.immediates.immS[15:0];
        id_ex_s1   <= id_ex_s0;  // pipeline control signals for both stage-2 blocks
    end

    // ── mem_addr Stage 2: select correct address ─────────────────────────────
	always_ff @(posedge clk) begin
		mem_addr_I <= {rs1[31:0] + id_ex_s1.immediates.immI[31:0] + mem_addr_I_co, mem_addr_I_sum_lower};
		mem_addr_S <= {rs1[31:0] + id_ex_s1.immediates.immS[31:0] + mem_addr_S_co, mem_addr_S_sum_lower};
	end

    // ── execute stage 2: first half of execute operations  ─────────────────────────────
	always_ff @(posedge clk) begin
		{add_co_lower, add_sum_lower} <= rs1[15:0] + value2[15:0]; // ADD

		{sub_co_lower, sub_sum_lower} <= rs1[15:0] + !value2[15:0] + 1; // SUB

		sll_half_shift <= rs1 <<< value2[2:0]; // SLL

		slt_top_equals <= rs1[31:16] == value2[31:16]; // SLT
		slt_top_lt     <= $signed(rs1[31:16]) < $signed(value2[31:16]);

		sltu_top_equals <= rs1[31:16] == value2[31:16]; // SLTU
		sltu_top_lt     <= rs1[31:16] < value2[31:16];

		xor_res_bottom <= rs1[15:0] ^ value2[15:0]; // XOR

		srl_half_shift <= rs1 >>> value2[2:0]; // SRL

		sra_half_shift <= 32'($signed(rs1) >>> value2[2:0]); // SRA

		or_res_bottom <= rs1[15:0] | value2[15:0]; // OR

		and_res_bottom <= rs1[15:0] & value2[15:0]; // AND

		{jal_co_lower, jal_sum_lower} <= id_ex.pc[15:0] + id_ex_s0.immediates.immJ[15:0]; // JAL

		// Pipeline inputs
		rs1_pipe   <= rs1;
		value2_pipe <= value2;
		pc_pipe    <= id_ex_s0.pc;
		immJ_pipe  <= id_ex_s0.immediates.immJ;
	end

	always_ff @(posedge clk) begin
		add     <= 32'({rs1_pipe[31:16] + value2_pipe[31:16] + add_co_lower, add_sum_lower}); // ADD
		sub     <= 32'({rs1_pipe[31:16] + !value2_pipe[31:16] + sub_co_lower, sub_sum_lower}); // SUB
		sll     <= sll_half_shift <<< {value2_pipe[4:3], 3'b000}; // SLL
		slt     <= slt_top_lt | (slt_top_equals & ($signed(rs1_pipe[15:0]) < $signed(value2_pipe[15:0]))); // SLT
		sltu    <= sltu_top_lt | (sltu_top_equals & (rs1_pipe[15:0] < value2_pipe[15:0])); // SLTU
		xor_res <= {rs1_pipe[31:16] ^ value2_pipe[31:16], xor_res_bottom}; // XOR
		srl     <= srl_half_shift >> {value2_pipe[4:3], 3'b000}; // SRL
		sra     <= 32'($signed(sra_half_shift) >>> {value2_pipe[4:3], 3'b000}); // SRA
		or_res  <= {rs1_pipe[31:16] | value2_pipe[31:16], or_res_bottom}; // OR
		and_res <= {rs1_pipe[31:16] & value2_pipe[31:16], and_res_bottom}; // AND
		jal     <= 32'({pc_pipe[31:16] + immJ_pipe[31:16] + jal_co_lower, jal_sum_lower}); // JAL
	end

	// ── Mux tree stage A: level-1 select by func3[0] ─────────────────────────
	always_ff @(posedge clk) begin
		mux_0_1 <= id_ex_s1.func3[0] ? sll                                    : (id_ex_s1.func7 == 7'h20 ? sub : add);
		mux_2_3 <= id_ex_s1.func3[0] ? sltu                                   : slt;
		mux_4_5 <= id_ex_s1.func3[0] ? (id_ex_s1.func7 == 7'h20 ? sra : srl) : xor_res;
		mux_6_7 <= id_ex_s1.func3[0] ? and_res                                : or_res;

		mem_addr_I_s2 <= mem_addr_I;
		mem_addr_S_s2 <= mem_addr_S;

		jal_s2   <= jal;
		id_ex_s2 <= id_ex_s1;
	end

	// ── Mux tree stage B: level-2 select by func3[1] ─────────────────────────
	always_ff @(posedge clk) begin
		mux_01_23 <= id_ex_s2.func3[1] ? mux_2_3 : mux_0_1;
		mux_45_67 <= id_ex_s2.func3[1] ? mux_6_7 : mux_4_5;

		mem_addr_I_s3 <= mem_addr_I_s2;
		mem_addr_S_s3 <= mem_addr_S_s2;

		jal_s3   <= jal_s2;
		id_ex_s3 <= id_ex_s2;
	end

	// ── Mux tree stage C: level-3 select by func3[2] → output ────────────────
	always_ff @(posedge clk) begin
		if (id_ex_s3.opcode == JAL && !jal_last_stage) begin
			jal_last_stage <= 1;
		end else begin
			jal_last_stage <= 0;
		end
																
		if (id_ex_s3.opcode == JAL) begin
			valid_and_execute_out[31:0] <= jal_s3;
			execute_pc_JAL_addr         <= jal_s3;
            execute_pc_JAL_MUX          <= 1'b1;
		end else begin
			valid_and_execute_out <= {1'b1, id_ex_s3.func3[2] ? mux_45_67 : mux_01_23};
			execute_pc_JAL_MUX          <= 1'b0;
		end

		ex_mem.opcode  <= id_ex_s3.opcode;
		ex_mem.rd_addr <= id_ex_s3.rd_addr;
		ex_mem.rs2     <= id_ex_s3.rs2;
		ex_mem.func3   <= id_ex_s3.func3;

		if ({id_ex_s3.opcode[6], id_ex_s3.opcode[5], id_ex_s3.opcode[4],
			 id_ex_s3.opcode[1], id_ex_s3.opcode[0]} == 5'b00011) begin
			ex_mem.mem_addr <= mem_addr_I_s3;  // load: rs1 + immI
		end else begin
			ex_mem.mem_addr <= mem_addr_S_s3;  // store: rs1 + immS
		end

		if (jal_last_stage) begin
			valid_and_execute_out <= 32'b0;
			if (id_ex_s3.JAL_taken) begin
				jal_last_stage <= 0;
			end
		end else begin
			valid_and_execute_out[32] <= id_ex_s3.valid;
		end
	end
endmodule
