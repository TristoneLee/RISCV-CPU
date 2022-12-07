`include "def.v"

module ReorderBuffer(
           input wire clk_in,
           input wire rst_in,
           input wire rdy_in,

           output wire rob2decoder_full,

           input wire [`REG_WIDTH] decoder2rob_rs1_request,
           input wire [`REG_WIDTH] decoder2rob_rs2_request,
           input wire [`REG_WIDTH] decoder2rob_rd_request,

           output wire[`ROB_WIDTH] rob2decoder_rs1_rename,
           output wire[`ROB_WIDTH] rob2decoder_rs2_rename,
           output wire [`DATA_WIDTH]rob2decoder_rs1_value,
           output wire [`DATA_WIDTH]rob2decoder_rs2_value,
           output wire [`ROB_WIDTH] rob2decoder_reorder,
           output wire rob2decoder_rs1_if_rename,
           output wire rob2decoder_rs2_if_rename,

           input wire[`ROB_LINE_LENGTH-1:0] decoder2rob_robline

           output wire [`REG_WIDTH] rob2reg_rs1_request,
           output wire [`REG_WIDTH] rob2reg_rs2_request,
           output wire [`REG_WIDTH] rob2reg_rd_request,
           input wire[`DATA_WIDTH] reg2rob_rs1_value,
           input wire[`DATA_WIDTH] reg2rob_rs2_value,
           input wire[`DATA_WIDTH] reg2rob_rs1_rename,
           input wire[`DATA_WIDTH] reg2rob_rs2_rename,
           input wire reg2rob_rs1_if_rename,
           input wire reg2rob_rs2_if_rename,

           output reg rob2reg_commit_enable,
           output reg[`REG_WIDTH] rob2reg_commit_des,
           output reg[`DATA_WIDTH] rob2reg_commit_value,
           output reg[`ROB_WIDTH] rob2reg_commit_reorder

       );

reg head[`ROB_WIDTH];
reg tail[`ROB_WIDTH];
reg [ROB_LINE_LENGTH-1:0] rob_queue[`ROB_SIZE-1:0];

assign rob2reg_rs1_request=decoder2rob_rs1_request;
assign rob2reg_rs2_request=decoder2rob_rs2_request;

assign rob2decoder_rs1_rename=reg2rob_rs1_if_rename?reg2rob_rs1_rename:`ZERO_ROB;
assign rob2decoder_rs1_if_rename=reg2rob_rs1_if_rename&&!rob_queue[rob2decoder_rs1_rename][`ROB_READY];
assign rob2decoder_rs1_value=reg2rob_rs1_if_rename?(rob2decoder_rs1_if_rename?`ZERO_DATA:rob_queue[reg2rob_rs1_rename][`ROB_VALUE]):reg2rob_rs1_value;
assign rob2decoder_rs2_rename=reg2rob_rs2_if_rename?reg2rob_rs2_rename:`ZERO_ROB;
assign rob2decoder_rs2_if_rename=reg2rob_rs2_if_rename&&!rob_queue[rob2decoder_rs2_rename][`ROB_READY];
assign rob2decoder_rs2_value=reg2rob_rs2_if_rename?(rob2decoder_rs2_if_rename?`ZERO_DATA:rob_queue[reg2rob_rs2_rename][`ROB_VALUE]):reg2rob_rs1_value;

integer i;

always @(posedge clk_in ) begin
    if(rst_in) begin
        for(i=0;i<`ROB_SIZE;i=i+i) begin
            rob_queue[i]=`ROB_LINE_LENGTH;
        end
    end
    else if(rdy_in) begin

    end
end
endmodule
