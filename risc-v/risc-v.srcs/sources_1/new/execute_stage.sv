// execute_stage.sv

module execute_stage(
    // clk and rst_n (active low) definitions
    input clk,
    input rst_n,

    // consumer of the id_ex pipeline register stage
    input rv_pipe_pkg::id_ex_t id_ex,
    // producer/driver of the ex_mem pipeline register stage
    output rv_pipe_pkg::ex_mem_t ex_mem
);
    logic [31:0] rs1 = id_ex.rs1;
    logic [31:0] rs2 = id_ex.rs2;

    logic [31:0] value2 = id_ex.opcode == 7'b0110011 ? rs1 : id_ex.immediates.immI; 

    always_ff @(posedge clk) begin
        case (id_ex.func3)
            3'h0: begin // ADD & SUB
                if (id_ex.func7 == 7'h20) begin // SUB
                    ex_mem.execute_out <= rs1 - value2; 
                end else begin // ADD
                    ex_mem.execute_out <= rs1 + value2;
                end
                ex_mem.valid <= 1;
            end
            3'h1: begin // SLL
                ex_mem.execute_out <= rs1 << value2[4:0]; // technically onl rs2[4:0] works correctly (32 bit shift)
                ex_mem.valid <= 1;
            end
            3'h2: begin // SLT
                ex_mem.execute_out <= ($signed(rs1) < $signed(value2)) ? 1 : 0; // if rs1 < rs2 -> 1 else -> 0
                // note, SV treats all packed arrays as unsigned by default.
                // SLT uses signed values, so rs1 and rs2 need to be converted
                ex_mem.valid <= 1;
            end
            3'h3: begin // SLTU
                ex_mem.execute_out <= (rs1 < value2) ? 1 : 0; // same as SLT but with unsigned values
                // on the contrary to the above, default comparison is
                // unsigned, so no conversion needs to happen
                ex_mem.valid <= 1;
            end
            3'h4: begin // XOR
                ex_mem.execute_out <= (rs1 ^ value2);
                ex_mem.valid <= 1;
            end
            3'h5: begin // SRL & SRA
                if (id_ex.func7 == 7'h20) begin // SRA
                    ex_mem.execute_out <= $signed(rs1) >>> value2[4:0];
                end else begin // SRL
                    ex_mem.execute_out <= rs1 >> value2[4:0];
                end
                ex_mem.valid <= 1;
            end
            3'h6: begin // OR
                ex_mem.execute_out <= rs1 || value2;
                ex_mem.valid <= 1;
            end
            3'h7: begin // AND
                ex_mem.execute_out <= rs1 && value2;
                ex_mem.valid <= 1;
            end
            default: begin
                ex_mem.valid <= 0;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        ex_mem.opcode <= id_ex.opcode;
        ex_mem.rd_addr <= id_ex.rd_addr;
        ex_mem.func3 <= id_ex.func3;
        ex_mem.func7 <= id_ex.func7;
    end
endmodule
