`include "fifo.v"

module FetchBuffer(
    //with chip control signal

    input wire clk_in,
    input wire rst_in,
    input wire rdy_in,
    input wire stall_in,

    //with memmory
    input wire[7:0] bus_in,
    output wire memory_signal_out,

    //with decoder
    input decoder_read_in,
    output reg[31:0] decoder_out,
    output wire decoder_en_out
);

    //4 bytes to 1 instruction module
    reg[31:0] ins_buffer;
    reg[1:0] ins_counter;

    wire buffer_rd_en;
    wire buffer_wr_en;
    wire buffer_full;
    wire buffer_empty;

    fifo#(.DATA_BITS(32), .ADDR_BITS(3)) buffer(
        .clk(clk),
        .reset(rst_in),
        .rd_en(buffer_rd_en),
        .wr_en(buffer_wr_en),
        .wr_data(ins_buffer),
        .full(buffer_full),
        .empty(buffer_empty)
    );

    always @(posedge clk_in)
        begin
            if (rst_in)
                begin
                    ins_buffer <= 32'd0;
                    ins_counter <= 2'd0;
                    decoder_en_out <= 1'd0;
                    decoder_out <= 32'd0;
                    buffer_wr_en <= 1'd0;
                    buffer_wr_en <= 1'd0;
                end
            else
                begin

                end
        end

endmodule