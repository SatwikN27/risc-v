// pipe_if.sv

// an interface for the pipeline reegisters
// exposes valid and data bits to consumers and producers via modports

interface pipe_if #(parameter tpye T = logic [0:0])
    // exposed valid and data ports    
    logic   valid;
    T       data;

    // producer drives exposed ports, valid and data
    modport prod (
        output valid,
        output data
    );

    // consumer reads exposed ports, valid and data
    modport cons (
        input valid,
        input data
    );

endinterface
