`timescale 1ns / 1ps

module tb_top;

    import rv_pipe_pkg::*;

    logic clk;
    logic rst_n;
    wb_out_t wb_out;

    // DUT
    top dut (
        .clk   (clk),
        .rst_n (rst_n),
        .wb_out(wb_out)
    );

    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #30 clk = ~clk;
    end

    // Reset sequence
    initial begin
        rst_n = 1;
        #70;
        rst_n = 0;
        dut.u_decode.register_file[1] = 32'd5;
        dut.u_decode.register_file[2] = 32'd7;
        #70;
        rst_n = 1;
    end

    // Optional cycle counter
    integer cycle_count;
    initial cycle_count = 0;

    always @(posedge clk) begin
        cycle_count <= cycle_count + 1;
    end

    // Per-cycle log
    always @(posedge clk) begin
        if (rst_n) begin
            $display("cycle=%0d pc=%d if_id_instr=%h wb_we=%b wb_rd=%0d wb_val=%h mem_wb.opcode=%b execute_out=%h id_ex.rs1=%h id_ex.rs2=%h id_ex.func3=%b",//x1=%h x2=%h x3=%h",
                cycle_count,
                dut.if_id.pc,
                dut.if_id.instruction,
                dut.wb_out.we,
                dut.wb_out.rd_addr,
                dut.wb_out.write_value,
                dut.mem_wb.opcode,
                dut.ex_mem.execute_out,
                dut.id_ex.rs1,
                dut.id_ex.rs2,
                dut.id_ex.func3,
//                dut.u_decode.register_file[1],
//                dut.u_decode.register_file[2],
//                dut.u_decode.register_file[3]
            );
        end
    end

    // Final checks
    initial begin
        // wait long enough for a few instructions to execute
        #30000;

        if (dut.u_decode.register_file[1] !== 32'd5) begin
            $display("FAIL: x1 expected 5, got %0d", dut.u_decode.register_file[1]);
            $stop;
        end

        if (dut.u_decode.register_file[2] !== 32'd7) begin
            $display("FAIL: x2 expected 7, got %0d", dut.u_decode.register_file[2]);
            $stop;
        end

        if (dut.u_decode.register_file[3] !== 32'd12) begin
            $display("FAIL: x3 expected 12, got %0d", dut.u_decode.register_file[3]);
            $stop;
        end

        $display("PASS: register checks passed");
        $finish;
    end

endmodule