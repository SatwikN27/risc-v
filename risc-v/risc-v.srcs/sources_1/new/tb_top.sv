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
            $display("cycle=%0d pc=%d if_id_instr=%h if_instr_addr=%h if_instr_data=%h if_rst_en=%b if_pc_stall=%b",
                cycle_count,
                dut.if_id.pc,
                dut.if_id.instruction,
                dut.u_fetch.PC,
                dut.u_fetch.instr_data,
                dut.u_fetch.rst_n,
                dut.u_fetch.pc_stall,
                
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