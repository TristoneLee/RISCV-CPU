`include "def.v"

module ReorderBuffer(
           input wire clk_in,
           input wire rst_in,
           input wire rdy_in,

           output reg rob_rst_enable;

           output wire rob2decoder_full,

           output reg[`ADDR_WIDTH] rob2pc_pc;

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

           output wire rob2lsu_store_enable;

           input wire alu2rob_enable;
           input wire[`ROB_WIDTH] alu2rob_reorder,
           input wire[`DATA_WIDTH] alu2rob_value,
           input wire[`ADDR_WIDTH] alu2rob_pc,

           input wire  lsu2rob_enable,
           input wire [`ROB_WIDTH]  lsu2rob_reorder,
           input wire [`DATA_WIDTH] lsu2rob_value
       );

reg [`ROB_WIDTH]head;
reg [`ROB_WIDTH]tail;
reg [ROB_LINE_LENGTH-1:0] rob_queue[`ROB_SIZE-1:0];
reg empty;
wire full=head==tail&&!empty;

wire head_ready=rob_queue[head][`ROB_READY];

assign rob2reg_rs1_request=decoder2rob_rs1_request;
assign rob2reg_rs2_request=decoder2rob_rs2_request;

assign rob2decoder_rs1_rename=reg2rob_rs1_if_rename?reg2rob_rs1_rename:`ZERO_ROB;
assign rob2decoder_rs1_if_rename=reg2rob_rs1_if_rename&&!rob_queue[rob2decoder_rs1_rename][`ROB_READY];
assign rob2decoder_rs1_value=reg2rob_rs1_if_rename?(rob2decoder_rs1_if_rename?`ZERO_DATA:rob_queue[reg2rob_rs1_rename][`ROB_VALUE]):reg2rob_rs1_value;
assign rob2decoder_rs2_rename=reg2rob_rs2_if_rename?reg2rob_rs2_rename:`ZERO_ROB;
assign rob2decoder_rs2_if_rename=reg2rob_rs2_if_rename&&!rob_queue[rob2decoder_rs2_rename][`ROB_READY];
assign rob2decoder_rs2_value=reg2rob_rs2_if_rename?(rob2decoder_rs2_if_rename?`ZERO_DATA:rob_queue[reg2rob_rs2_rename][`ROB_VALUE]):reg2rob_rs1_value;
assign rob2decoder_reorder=tail;

integer i;

initial begin
    
    for(i=0;i<`ROB_SIZE;i=i+i) begin
        rob_queue[i]=`ROB_LINE_LENGTH;
    end
    haed<=`ZERO_ROB;
    tail<=`ZERO_ROB;
end

always @(posedge clk_in ) begin
    if(rst_in) begin
        for(i=0;i<`ROB_SIZE;i=i+i) begin
            rob_queue[i]=`ROB_LINE_LENGTH;
        end
        haed<=`ZERO_ROB;
        tail<=`ZERO_ROB;
    end
    else if(rdy_in) begin
        //commit procedure
        if(head[ready]) begin
            if(alu_queue[head][`ROB_TYPE]==`JALR)begin
                rob_rst_enable<=`TRUE;
                rob2pc_pc<=alu_queue[head][`ROB_JUMP];
                
            end
        end

        //update procedure
        if(alu2rob_enable) begin
            alu_queue[alu2rob_reorder][`ROB_VALUE] <=alu2rob_value;
            alu_queue[alu2rob_reorder][`ROB_JUMP]  <=alu2rob_pc;
            alu_queue[alu2rob_reorder][`ROB_READY] <=`TRUE;
        end
        if(lsu2rob_enable) begin
            alu_queue[lsu2rob_reorder][`ROB_READY]<=`TRUE;
            alu_queue[lsu2rob_reorder][`ROB_VALUE]<=lsu2rob_value;
        end
    end
end
endmodule
