//reference: The design of allocation and select circuit is inspired by YPU

module ReservationStation(
           input wire clk_in,
           input wire rst_in,
           input wire rdy_in,
           output wire rs_full,

           input wire decoder2rs_enable,
           input wire[`RS_LINE_LENGTH-1:0] decoder2rs_rsline,

           output reg rs2alu_enable,
           output reg[`DATA_WIDTH] rs2alu_rs1,
           output reg[`DATA_WIDTH] rs2alu_rs2,
           output reg[`DATA_WIDTH] rs2alu_imm,
           output reg[`INS_TYPE_WIDTH] rs2alu_ins_type,
           output reg[`ADDR_WIDTH] rs2alu_pc,
           output reg[`ROB_WIDTH] rs2alu_reorder,

           input wire alu2rs_bypass_enable,
           input wire[`ROB_WIDTH] alu2rs_bypass_reorder,
           input wire[`DATA_WIDTH] alu2rs_bypass_value,

           input wire lsu2rs_bypass_enable,
           input wire[`ROB_WIDTH] lsu2rs_bypass_reorder,
           input wire[`DATA_WIDTH] lsu2rs_bypass_value,
       );

reg[`RS_LINE_LENGTH-1:0] reservation_station[`RS_SIZE-1:0];
wire [`RS_LINE_LENGTH-1:0] ready_table;

assign ready_table[0] =reservation_station[0] [`RS_READY_1]&&reservation_station[0] [`RS_READY_2]&&reservation_station[0] [`RS_BUSY];
assign ready_table[1] =reservation_station[1] [`RS_READY_1]&&reservation_station[1] [`RS_READY_2]&&reservation_station[1] [`RS_BUSY];
assign ready_table[2] =reservation_station[2] [`RS_READY_1]&&reservation_station[2] [`RS_READY_2]&&reservation_station[2] [`RS_BUSY];
assign ready_table[3] =reservation_station[3] [`RS_READY_1]&&reservation_station[3] [`RS_READY_2]&&reservation_station[3] [`RS_BUSY];
assign ready_table[4] =reservation_station[4] [`RS_READY_1]&&reservation_station[4] [`RS_READY_2]&&reservation_station[4] [`RS_BUSY];
assign ready_table[5] =reservation_station[5] [`RS_READY_1]&&reservation_station[5] [`RS_READY_2]&&reservation_station[5] [`RS_BUSY];
assign ready_table[6] =reservation_station[6] [`RS_READY_1]&&reservation_station[6] [`RS_READY_2]&&reservation_station[6] [`RS_BUSY];
assign ready_table[7] =reservation_station[7] [`RS_READY_1]&&reservation_station[7] [`RS_READY_2]&&reservation_station[7] [`RS_BUSY];
assign ready_table[8] =reservation_station[8] [`RS_READY_1]&&reservation_station[8] [`RS_READY_2]&&reservation_station[8] [`RS_BUSY];
assign ready_table[9] =reservation_station[9] [`RS_READY_1]&&reservation_station[9] [`RS_READY_2]&&reservation_station[9] [`RS_BUSY];
assign ready_table[10]=reservation_station[10][`RS_READY_1]&&reservation_station[10][`RS_READY_2]&&reservation_station[10][`RS_BUSY];
assign ready_table[11]=reservation_station[11][`RS_READY_1]&&reservation_station[11][`RS_READY_2]&&reservation_station[11][`RS_BUSY];
assign ready_table[12]=reservation_station[12][`RS_READY_1]&&reservation_station[12][`RS_READY_2]&&reservation_station[12][`RS_BUSY];
assign ready_table[13]=reservation_station[13][`RS_READY_1]&&reservation_station[13][`RS_READY_2]&&reservation_station[13][`RS_BUSY];
assign ready_table[14]=reservation_station[14][`RS_READY_1]&&reservation_station[14][`RS_READY_2]&&reservation_station[14][`RS_BUSY];
assign ready_table[15]=reservation_station[15][`RS_READY_1]&&reservation_station[15][`RS_READY_2]&&reservation_station[15][`RS_BUSY];

wire[`RS_WIDTH] free_index;
wire ready_table;
wire[`RS_LINE_LENGTH-1:0] ready_entry=reservation_station[ready_index];

assign rs_full=free_entry==`ZERO_RS;

integer i,alu_i,rsu_i;

always @(posedge clk_in) begin
    if(rst_in) begin
        for(i=1;i<`RS_SIZE;i=i+1) begin
            reservation_station[i][`RS_BUSY]<=`FALSE;
            rs2alu_enable<=`FALSE;
        end
    end
    else if(rdy_in) begin
        if(decoder2rs_enable&&!rs_full) begin
            reservation_station[free_index]<=decoder2rs_rsline;
        end
        if(ready_table!=`RS_ZERO) begin
            rs2alu_enable<=`TRUE;
            rs2alu_imm<=ready_entry[`RS_A];
            rs2alu_ins_type<=ready_entry[`RS_TYPE];
            rs2alu_pc<=ready_entry[`RS_PC];
            rs2alu_reorder<=ready_entry[`RS_DEST];
            rs2alu_rs1<=ready_entry[`RS_VJ];
            rs2alu_rs2<=ready_entry[`RS_VK];
            ready_entry[`RS_BUSY]<=`FALSE;
        end
        if(alu2rs_bypass_enable) begin
            for(alu_i=1;alu_i<`RS_SIZE;i=i+1) begin
                if(decoder2rs_enable&&!rs_full&&alu_i==free_index) begin
                    if(reservation_station[alu_i][`RS_QJ]==alu2rs_bypass_reorder) begin
                        reservation_station[alu_i][`RS_VJ]<=alu2rs_bypass_value;
                        reservation_station[alu_i][`RS_READY_1]<=`TRUE;
                    end
                    if(reservation_station[alu_i][`RS_QK]==alu2rs_bypass_reorder) begin
                        reservation_station[alu_i][`RS_VK]<=alu2rs_bypass_value;
                        reservation_station[alu_i][`RS_READY_2]<=`TRUE;
                    end
                end
                else begin
                    if(reservation_station[alu_i][`RS_QJ]==alu2rs_bypass_reorder) begin
                        reservation_station[alu_i][`RS_VJ]<=alu2rs_bypass_value;
                        reservation_station[alu_i][`RS_READY_1]<=`TRUE;
                    end
                    if(reservation_station[alu_i][`RS_QK]==alu2rs_bypass_reorder) begin
                        reservation_station[alu_i][`RS_VK]<=alu2rs_bypass_value;
                        reservation_station[alu_i][`RS_READY_2]<=`TRUE;
                    end
                end
            end
        end
        if(lsu2rs_bypass_enable) begin
            for(lsu_i=1;lsu_i<`RS_SIZE;i=i+1) begin
                if(decoder2rs_enable&&!rs_full&&lsu_i==free_index) begin
                    if(reservation_station[lsu_i][`RS_QJ]==lsu2rs_bypass_reorder) begin
                        reservation_station[lsu_i][`RS_VJ]<=lsu2rs_bypass_value;
                        reservation_station[lsu_i][`RS_READY_1]<=`TRUE;
                    end
                    if(reservation_station[lsu_i][`RS_QK]==lsu2rs_bypass_reorder) begin
                        reservation_station[lsu_i][`RS_VK]<=lsu2rs_bypass_value;
                        reservation_station[lsu_i][`RS_READY_2]<=`TRUE;
                    end
                end
                else begin
                    if(reservation_station[lsu_i][`RS_QJ]==lsu2rs_bypass_reorder) begin
                        reservation_station[lsu_i][`RS_VJ]<=lsu2rs_bypass_value;
                        reservation_station[lsu_i][`RS_READY_1]<=`TRUE;
                    end
                    if(reservation_station[lsu_i][`RS_QK]==lsu2rs_bypass_reorder) begin
                        reservation_station[lsu_i][`RS_VK]<=lsu2rs_bypass_value;
                        reservation_station[lsu_i][`RS_READY_2]<=`TRUE;
                    end
                end
            end
        end
    end
end


assign free_index =  !reservation_station[1][`RS_BUSY]  ? 4'd1  :
       !reservation_station[2][`RS_BUSY]   ? 4'd2  :
       !reservation_station[3][`RS_BUSY]   ? 4'd3  :
       !reservation_station[4][`RS_BUSY]   ? 4'd4  :
       !reservation_station[5][`RS_BUSY]   ? 4'd5  :
       !reservation_station[6][`RS_BUSY]   ? 4'd6  :
       !reservation_station[7][`RS_BUSY]   ? 4'd7  :
       !reservation_station[8][`RS_BUSY]   ? 4'd8  :
       !reservation_station[9][`RS_BUSY]   ? 4'd9  :
       !reservation_station[10][`RS_BUSY]  ? 4'd10 :
       !reservation_station[11][`RS_BUSY]  ? 4'd11 :
       !reservation_station[12][`RS_BUSY]  ? 4'd12 :
       !reservation_station[13][`RS_BUSY]  ? 4'd13 :
       !reservation_station[14][`RS_BUSY]  ? 4'd14 :
       !reservation_station[15][`RS_BUSY]  ? 4'd15 :
       `ZERO_RS;

assign ready_index =    ready_table[1]  ? 4'd1  :
       ready_table[2]  ? 4'd2  :
       ready_table[3]  ? 4'd3  :
       ready_table[4]  ? 4'd4  :
       ready_table[5]  ? 4'd5  :
       ready_table[6]  ? 4'd6  :
       ready_table[7]  ? 4'd7  :
       ready_table[8]  ? 4'd8  :
       ready_table[9]  ? 4'd9  :
       ready_table[10] ? 4'd10 :
       ready_table[11] ? 4'd11 :
       ready_table[12] ? 4'd12 :
       ready_table[13] ? 4'd13 :
       ready_table[14] ? 4'd14 :
       ready_table[15] ? 4'd15 :
       `ZERO_RS;

endmodule
