`include "def.v"

module registers(
         input wire clk_in,
         input wire rdy_in,
         input wire rst_in,

         input wire[`LOGICAL_REG_WIDTH] decoder2reg_rs1_virtual,
         input wire[`LOGICAL_REG_WIDTH] decoder2reg_rs2_virtual,
         input wire[`LOGICAL_REG_WIDTH] decoder2reg_rd_virtual,
         output reg[`PHYSICAL_REG_WIDTH] reg2decoder_rs1_physical,
         output reg[`PHYSICAL_REG_WIDTH] reg2decoder_rs2_physical,
         output reg[`PHYSICAL_REG_WIDTH] reg2decoder_rd_physical,
       );

reg[`WORD_WIDTH] regs[`PHYSICAL_REG_NUM-1:0];



endmodule
