`include "def.v"

module registers(
           input wire clk_in,
           input wire rdy_in,
           input wire rst_in,

           input wire[`REG_WIDTH] rob2reg_rs1_request,
           input wire[`REG_WIDTH] rob2reg_rs2_request,
           output wire[`DATA_WIDTH] reg2rob_rs1_value,
           output wire[`DATA_WIDTH] reg2rob_rs2_value,
           output wire[`DATA_WIDTH] reg2rob_rs1_rename,
           output wire[`DATA_WIDTH] reg2rob_rs2_rename,
           output wire reg2rob_rs1_if_rename,
           output wire reg2rob_rs2_if_rename,

           input wire rob2reg_reserve_enable,
           input wire[`REG_WIDTH] rob2reg_reserve_rd,
           input wire[`ROB_WIDTH] rob2reg_reserve_reorder,

           input wire rob2reg_commit_enable,
           input wire[`REG_WIDTH] rob2reg_commit_des,
           input wire[`DATA_WIDTH] rob2reg_commit_value,
           input wire[`ROB_WIDTH] rob2reg_commit_reorder
       );

reg[`DATA_WIDTH] regs[`REG_SIZE-1:0];
reg[`ROB_WIDTH] reg_rename_table[`REG_SIZE-1:0];
reg reg_if_rename[`REG_SIZE-1:0];

assign reg2rob_rs1_if_rename=reg_if_rename[rob2reg_rs1_request];
assign reg2rob_rs1_value=reg2rob_rs1_if_rename?ZERO_DATA:regs[rob2reg_rs1_request];
assign reg2rob_rs1_rename=reg2rob_rs1_if_rename? reg_rename_table[rob2reg_rs1_request];
assign reg2rob_rs2_if_rename=reg_if_rename[rob2reg_rs2_request];
assign reg2rob_rs2_value=reg2rob_rs2_if_rename?ZERO_DATA:regs[rob2reg_rs2_request];
assign reg2rob_rs2_rename=reg2rob_rs2_if_rename? reg_rename_table[rob2reg_rs2_request];

integer i;

initial
begin
    for(i=0;i<`REG_SIZE;i=i+1)
    begin
        regs[i]<=`ZERO_DATA;
        reg_if_rename[i]<=`FALSE;
        reg_rename_table[i]<=4'b0000;
    end
end

always @(posedge clk_in )
begin
    if(rst_in)
    begin
        for(i=0;i<`REG_SIZE;i=i+1)
        begin
            regs[i]<=`ZERO_DATA;
            reg_if_rename[i]<=`FALSE;
            reg_rename_table[i]<=`ZERO_ROB;
        end
    end
    else if(rdy_in)
    begin
        if(rob2reg_commit_enable)
        begin
            regs[rob2reg_commit_des]<=rob2reg_commit_value;
            if(reg_rename_table[rob2reg_commit_des]==rob2reg_commit_reorder)
            begin
                reg_rename_table[rob2reg_commit_des]<=`ZERO_ROB;
                reg_if_rename[rob2reg_commit_des]<=`FALSE;
            end
        end
        if(rob2reg_reserve_enable)
        begin
            reg_rename_table[rob2reg_reserve_rd]<=rob2reg_reserve_reorder;
            reg_if_rename[rob2reg_reserve_rd]<=`TRUE;
        end
    end
end

endmodule
