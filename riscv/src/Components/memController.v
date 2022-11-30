`include "ram.v"
`include "def.v"

module memController(
    //control signal

    input clk_in,
    input rst_in,
    input rdy_in,

    //with fetchBuffer

    output reg[`MEM_WIDTH ] fetch_out
);

    ram ram(
        .clk_in(clk_in),

    );

endmodule