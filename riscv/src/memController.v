`include "def.v"

`define WIDTH_BITS 18:17
`define ADDR_BITS 16:0
`define SRC_BIT 20
`define RW_BIT 19

module memController #(parameter COMMAND_LENGTH = 21)
       (input wire clk_in,
        input wire rst_in,
        input wire rdy_in,                                                     //control signal
        output reg[`WORD_WIDTH] memCon2iCache_return,
        output wire memCon2iCache_ifbusy,
        input wire iCache2memCon_valid,
        input wire [`ADDR_WIDTH] iCache2memCon_adderss,                   //with iCache
        output reg[`WORD_WIDTH] memCon2lsu_return,
        output reg memCon2lsu_enable,
        input wire[1:0] lsu2memCon_width,
        input wire [`ADDR_BITS] lsu2memCon_addr,
        input wire lsu2memCon_rw,
        input wire lsu2memCon_enable,                                      //with lsu
        input wire [`MEM_WIDTH] mem2memCon_din,
        output reg [`ADDR_WIDTH] memCon2mem_addr,
        output reg memCon2mem_rw_select,
        output reg [`MEM_WIDTH] memCon2mem_dout);                         //with memory

reg ram_en;
reg[COMMAND_LENGTH-1:0] current_command;
reg[COMMAND_LENGTH-1:0] reserve_command;
reg reserve_valid;
integer count_down;
reg[`WORD_WIDTH] io_buffer;
reg[`MEM_WIDTH] mem_out;

// assign memCon2iCache_ifbusy =

always @(posedge clk_in)
  begin
    if (rst_in)
      begin
        current_command <= 0;
      end
    else if (rdy_in)
      begin
        if(count_down!=0)
          begin
            io_buffer[count_down*8-1:(count_down-1)*8]<=mem2memCon_din;
            count_down<=count_down-1;
            memCon2mem_addr<=current_command[`ADDR_BITS]+count_down-1;
          end
        else
          begin
            if (current_command[`SRC_BIT] == 1'd0)
              begin
                memCon2iCache_return <= io_buffer;
                io_buffer            <= 32'd0;
              end
            else
              begin
                memCon2lsu_return <= io_buffer;
                io_buffer         <= 32'd0;
              end
            if (reserve_valid == 1'd1)
              begin
                current_command <= reserve_command;
                case (reserve_command[`WIDTH_BITS])
                  2'd0:
                    count_down <= 1;
                  2'd1:
                    count_down <= 2;
                  2'd2:
                    count_down <= 4;
                endcase
                reserve_valid        <= 1'd0;
                memCon2mem_addr      <= reserve_command[`ADDR_BITS];
                memCon2mem_rw_select <= 1'd0;
              end
            else
              begin
                if (iCache2memCon_valid == 1'd1)
                  begin
                    current_command[`ADDR_BITS]  <= iCache2memCon_adderss;
                    current_command[`WIDTH_BITS] <= 2'd2;
                    current_command[`SRC_BIT]    <= 1'd0;
                    current_command[`RW_BIT]      <= 1'd0;
                    count_down                   <= 3'd4;
                  end
                else if (lsu2memCon_valid == 1'd1)
                  begin
                    current_command[`ADDR_BITS]  <= lsu2memCon_addr;
                    current_command[`WIDTH_BITS] <= lsu2memCon_width;
                    current_command[`SRC_BIT]    <= 1'd1;
                    current_command [`RW_BIT]     <= lsu2memCon_rw;
                  end
              end
          end
        if (reserve_valid == 1'd0)
          begin
            if (iCache2memCon_valid == 1'd1)
              begin
                current_command[`ADDR_BITS]   <= iCache2memCon_adderss;
                current_command[`WIDTH_BITS]  <= 2'd2;
                current_command[`SRC_BIT]     <= 1'd0;
                current_command[`RW_BIT]      <= 1'd0;
                count_down                    <= 3'd4;
              end
            else if (lsu2memCon_valid == 1'd1)
              begin
                current_command[`ADDR_BITS]  <= lsu2memCon_addr;
                current_command[`WIDTH_BITS] <= lsu2memCon_width;
                current_command[`SRC_BIT]    <= 1'd1;
                current_command [`RW_BIT]    <= lsu2memCon_rw;
              end
            reserve_valid <= 1'd1;
          end
      end
  end


endmodule
