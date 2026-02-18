// writeback_stage.sv

module writeback_stage (
    // clk and rst_n (active_low)
    input logic clk,
    input logic rst_n,
    
    // consumer of the mem_wb pipeline register
    // producer of the wb_dec pipeline register
    input rv_pipe_pkg::mem_wb_t mem_wb,
    output rv_pipe_pkg::wb_dec_t wb_dec
);
    always_ff @(posedge clk) begin
        if (mem_wb.valid == 1) begin // only bother doing the writeback when memory is valid
            if (mem_wb.opcode == REGISTER || mem_wb.opcode == IMMEDIATE || mem_wb.opcode == LOAD_IMEDIATE) begin // only these three opcodes write back
                wb_dec.valid <= valid; // pipeline the valid bit
                wb_dec.rd_addr <= mem_wb.rd_addr; // the write adress is the same for anything writing to the RF
                wb_dec.we = 1; // if the opcode is any of the above, guarenteed to write, so asser WE
                if (mem_wb.opcode == REGISTER || mem_wb.opcode == IMMEDIATE) begin // these two opcodes pull from the execute value
                    wb_dec.write_value <= mem_wb.execute_out; // send the RF the execute value
                end else begin // otherwise the RF recieves some function of the memory out data
                    case (mem_wb.func3) // the load commands come in a variety of types, determined by func3
                        3'h0: begin // LB, rightmost, MSB sign extended from loaded data
                            wb_dec.write_value <= {{24{read_data[7:0]}},read_data[7:0]};
                        end
                        3'h1: begin // LH, rightmost, MSB sign extended from loaded data
                            wb_dec.write_value <= {{16{read_data[15:0]}},read_data[15:0]};
                        end
                        3'h2: begin // LW, no sign extension, just takes the memory output
                            wb_dec.write_value <= read_data;
                        end
                        3'h4: begin // LBU, rightmost, 0 extended
                            wb_dec.write_value <= {{24{0}},read_data[7:0]};
                        end
                        3'h5: begin // LHU, rightmost, 0 extended
                            wb_dec.write_value <= {{16{0},read_data[15:0]};
                        end
                        default: begin // default to LW
                            wb_dec.write_value <= read_data;
                        end
                    endcase
                end
            end
        end else begin
            wb_dec.we <= 0; // if not a writing opcode, WE goes low to prevent damage
        end
    end
endmodule
