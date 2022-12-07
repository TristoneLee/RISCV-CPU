module LoadStoreUnit(
           input clk_in,
           input rst_in,
           input rdy_in,

           input wire[`DATA_WIDTH] memCon2lsu_return,
           input wire memCon2lsu_enable,
           output reg[1:0] lsu2memCon_width,
           output reg[`ADDR_BITS] lsu2memCon_addr,
           output reg lsu2memCon_rw,
           output reg lsu2memCon_enable,

           input wire [`decoder2]

           output wire lsu2rs_bypass_enable,
           output wire[`ROB_WIDTH] lsu2rs_bypass_reorder,
           output wire[`DATA_WIDTH] lsu2rs_bypass_value,

           output wire lsu2rob_enable,
           output wire[`ROB_WIDTH]  lsu2rob_reorder,
           output wire[`DATA_WIDTH] lsu2rob_value,
           output wire[`ADDR_WIDTH] lsu2rob_pc
       );

endmodule //lsu
