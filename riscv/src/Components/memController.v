`include "ram.v"


module memController(
    //control signal

    input clk_in,
    input rst_in,
    input rdy_in,

    //with fetchBuffer

    output reg[7:0] fetch_out,
    input 
);
    ram ram(
        .clk_in(clk_in),

    );

endmodule