// rv_pipe_pkg.sv

package rv_pipe_pkg;
    typedef enum logic [6:0] {
        REGISTER        =0110011,
        IMMEDIATE       =0010011,
        LOAD_IMMEDIATE  =0000011,
        STORE           =0100011,
        BRANCH          =1100011,
        JUMP            =1101111,
        JALR            =1100111
    } opcodes_t;


    // IF/ID payload
    typedef struct packed {
        logic [31:0]    pc;
        logic [31:0]    instruction;
    } if_id_t;

endpackage
