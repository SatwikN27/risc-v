// writeback_stage.sv

module writeback_stage (
    // clk and rst_n (active low)
    input  logic clk,
    input  logic rst_n,
    
    // pipeline interfaces
    input  rv_pipe_pkg::mem_wb_t mem_wb,
    output rv_pipe_pkg::wb_dec_t wb_dec,
    output rv_pipe_pkg::wb_out_t wb_out
);

    import rv_pipe_pkg::*;

    always_ff @(posedge clk) begin
        if (mem_wb.opcode == REGISTER ||
            mem_wb.opcode == IMMEDIATE ||
            mem_wb.opcode == LOAD_IMMEDIATE) begin

            // destination register
            wb_dec.rd_addr <= mem_wb.rd_addr;
            wb_out.rd_addr <= mem_wb.rd_addr;

            // write enable if rd != x0
            if (mem_wb.rd_addr != 5'b0) begin
                wb_dec.we <= 1;
                wb_out.we <= 1;
            end

            // ALU-based writeback
            if (mem_wb.opcode == REGISTER ||
                mem_wb.opcode == IMMEDIATE) begin
                wb_dec.write_value <= mem_wb.execute_out;
                wb_out.write_value <= mem_wb.execute_out;
            end

            // valid pipeline stage
            if (mem_wb.valid == 1) begin

                if (mem_wb.opcode == LOAD_IMMEDIATE) begin
                    wb_dec.valid <= mem_wb.valid;
                    wb_out.valid <= mem_wb.valid;

                    wb_out.we <= 1;
                    

                    case (mem_wb.func3)

                        // LB (sign-extend byte)
                        3'h0: begin
                            wb_dec.write_value <= {{24{mem_wb.read_data[7]}},
                                                    mem_wb.read_data[7:0]};
                            wb_out.write_value <= {{24{mem_wb.read_data[7]}},
                                                    mem_wb.read_data[7:0]};
                        end

                        // LH (sign-extend halfword)
                        3'h1: begin
                            wb_dec.write_value <= {{16{mem_wb.read_data[15]}},
                                                    mem_wb.read_data[15:0]};
                            wb_out.write_value <= {{16{mem_wb.read_data[15]}},
                                                    mem_wb.read_data[15:0]};
                        end

                        // LW
                        3'h2: begin
                            wb_dec.write_value <= mem_wb.read_data;
                            wb_out.write_value <= mem_wb.read_data;
                        end

                        // LBU (zero-extend byte)
                        3'h4: begin
                            wb_dec.write_value <= {{24{1'b0}},
                                                    mem_wb.read_data[7:0]};
                            wb_out.write_value <= {{24{1'b0}},
                                                    mem_wb.read_data[7:0]};
                        end

                        // LHU (zero-extend halfword)
                        3'h5: begin
                            wb_dec.write_value <= {{16{1'b0}},
                                                    mem_wb.read_data[15:0]};
                            wb_out.write_value <= {{16{1'b0}},
                                                    mem_wb.read_data[15:0]};
                        end

                        // default = LW
                        default: begin
                            wb_dec.write_value <= mem_wb.read_data;
                            wb_out.write_value <= mem_wb.read_data;
                        end

                    endcase
                end
            end
        end else begin
            // disable writes if not writing instruction
            wb_dec.we <= 0;
            wb_out.we <= 0;
        end
    end

endmodule
