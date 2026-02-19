// rv_pipe_pkg.sv

package rv_pipe_pkg;
    typedef enum logic [6:0] {
        REGISTER        =7'b0110011,
        IMMEDIATE       =7'b0010011,
        LOAD_IMMEDIATE  =7'b0000011,
        STORE           =7'b0100011,
        BRANCH          =7'b1100011,
        JUMP            =7'b1101111,
        JALR            =7'b1100111
    } opcodes_t;

    typedef struct packed {
        logic invert_alu;
    } control_t;

    typedef struct packed {
        logic [31:0] immI;
        logic [31:0] immS;
        logic [31:0] immB;
        logic [31:0] immU;
        logic [31:0] immJ;
    } immediates_t;

    // IF/ID payload
    typedef struct packed {
        logic [31:0]    pc;
        logic [31:0]    instruction;
        logic [6:0]     opcode;
        logic           valid;
    } if_id_t;

    // ID/EX payload
    typedef struct packed {
        logic [6:0]     opcode;
        logic [31:0]        rs1;
        logic [31:0]        rs2;
        logic [4:0]         rd_addr;
        logic [31:0]        pc;
        control_t     control_bits;
        immediates_t  immediates;
        logic [2:0]         func3;
        logic [6:0]         func7;
        logic               valid;
    } id_ex_t;

    typedef struct packed {
        logic [6:0]  opcode;
        logic [31:0] execute_out;
        logic [4:0]  rd_addr;
        logic        valid;
        logic [2:0]  func3;
        logic [6:0]  func7;
        logic [31:0] mem_addr;
    } ex_mem_t;

    typedef struct packed {
        logic valid;
        logic [4:0] rd_addr;
        logic opcode;
        logic [2:0] func3;
        logic [6:0] func7;
        logic [31:0] read_data;
        logic [31:0] execute_out;
    } mem_wb_t;

    typedef struct packed {
        logic valid;
        logic [4:0] rd_addr;
        logic we;
        logic write_value;
    } wb_dec_t;

endpackage
