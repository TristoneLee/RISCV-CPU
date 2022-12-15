`include "def.v"

module LoadStoreUnit(
           input clk_in,
           input rst_in,
           input rdy_in,

           input wire[`DATA_WIDTH] memCon2lsu_return,
           input wire memCon2lsu_enable,
           output reg[1:0] lsu2memCon_width,
           output reg[`ADDR_WIDTH] lsu2memCon_addr,
           output reg lsu2memCon_rw,
           output reg lsu2memCon_enable,
           output reg[`DATA_WIDTH] lsu2memCon_value,
           output reg lsu2memCon_ifSigned,

           input wire rob2lsu_store_enable;

           input wire decoder2lsu_enable,
           input wire[`RS_LINE_LENGTH-1:0] decoder2lsu_rsline,
           output wire lsu2decoder_full,

           output reg lsu2rs_bypass_enable,
           output reg[`ROB_WIDTH] lsu2rs_bypass_reorder,
           output reg[`DATA_WIDTH] lsu2rs_bypass_value,

           input wire alu2lsu_bypass_enable,
           input wire [`ROB_WIDTH] alu2lsu_bypass_reorder,
           input wire [`DATA_WIDTH] alu2rs_bypass_value,

           output reg lsu2rob_enable,
           output reg[`ROB_WIDTH]  lsu2rob_reorder,
           output reg[`DATA_WIDTH] lsu2rob_value
       );

reg[`RS_LINE_LENGTH-1:0] lsu_queue[`LSU_SZIE-1:0];

reg [`LSU_WIDTH]head;
reg [`LSU_WIDTH]tail;
reg empty;
reg busy;
wire full = head == tail&&!empty;
wire head_next_ready=lsu_queue[head+1][`RS_READY_1]&&lsu_queue[head+1][`RS_READY_2];
wire head_ready=lsu_queue[head][`RS_READY_1]&&lsu_queue[head][`RS_READY_2];
wire head_ifLoad==lsu_queue[head][`RS_TYPE]==`LB||lsu_queue[head][`RS_TYPE]==`LBU||lsu_queue[head][`RS_TYPE]==`LHU||lsu_queue[head][`RS_TYPE]==`LH||lsu_queue[head][`RS_TYPE]==`LW;


assign lsu2decoder_full=full;

integer i,alu_i,rsu_i;

initial begin
    head<=4'b0000;
    tail<=4'b0000;
    empty<=1'b1;
end

//数据读写逻辑
always @(posedge clk_in) begin
    if(rst_in) begin
        head<=4'b0000;
        tail<=4'b0000;
        empty<=`TRUE;
    end
    else if (rdy_in) begin
        if(!full&&decoder2lsu_enable) begin
            empty<=`TRUE;
            tail<=tail+1;
            lsu_queue[tail]<=decoder2lsu_rsline;
        end
        if(memCon2lsu_enable) begin
            //todo 符号处理
            //broadcast result
            lsu2rs_bypass_enable<=head_ifLoad;
            lsu2rs_bypass_reorder<=lsu_queue[head][`RS_REORDER];
            lsu2rs_bypass_value<=memCon2lsu_return;
            lsu2rob_enable<=`TRUE;
            lsu2rob_reorder<=lsu_queue[head][`RS_REORDER];
            lsu2rob_value<=memCon2lsu_return;
            head<=head+1;
            //todo 可以压缩周期，读入一个指令同时完成一个指令
            //rw request to memory
            if(head+1==tail) begin
                empty<=1'b0;
            end
            if(head+1!=tail&&head_next_ready) begin
                case(lsu_queue[head+1][`RS_TYPE])
                    `LB: begin
                        lsu2memCon_addr<=lsu_queue[head+1][`RS_VJ]+lsu_queue[head+1][`RS_A];
                        lsu2memCon_rw<=`MEM_READ;
                        lsu2memCon_width<=2'd0;
                        lsu2memCon_enable<=`TRUE;
                        busy<=`TRUE;
                        lsu2memCon_ifSigned<=`TRUE;
                    end
                    `LBU: begin
                        lsu2memCon_addr<=lsu_queue[head+1][`RS_VJ]+lsu_queue[head+1][`RS_A];
                        lsu2memCon_rw<=`MEM_READ;
                        lsu2memCon_width<=2'd0;
                        lsu2memCon_enable<=`TRUE;
                        busy<=`TRUE;
                        lsu2memCon_ifSigned<=`FALSE;
                    end
                    `LH: begin
                        lsu2memCon_addr<=lsu_queue[head+1][`RS_VJ]+lsu_queue[head+1][`RS_A];
                        lsu2memCon_rw<=`MEM_READ;
                        lsu2memCon_width<=2'd1;
                        lsu2memCon_enable<=`TRUE;
                        busy<=`TRUE;
                        lsu2memCon_ifSigned<=`TRUE;
                    end
                    `LHU: begin
                        lsu2memCon_addr<=lsu_queue[head+1][`RS_VJ]+lsu_queue[head+1][`RS_A];
                        lsu2memCon_rw<=`MEM_READ;
                        lsu2memCon_width<=2'd1;
                        lsu2memCon_enable<=`TRUE;
                        busy<=`TRUE;
                        lsu2memCon_ifSigned<=`FALSE;
                    end
                    `LW: begin
                        lsu2memCon_addr<=lsu_queue[head+1][`RS_VJ]+lsu_queue[head+1][`RS_A];
                        lsu2memCon_rw<=`MEM_READ;
                        lsu2memCon_width<=2'd2;
                        lsu2memCon_enable<=`TRUE;
                        busy<=`TRUE;
                        lsu2memCon_ifSigned<=`FALSE;
                    end
                    `SB: begin
                        if(rob2lsu_store_enable) begin
                            lsu2memCon_addr<=lsu_queue[head+1][`RS_VJ]+lsu_queue[head+1][`RS_A];
                            lsu2memCon_rw<=`MEM_WRITE;
                            lsu2memCon_width<=2'd0;
                            lsu2memCon_value<={24{1'b0},lsu_queue[head+1][`RS_VK][7:0]};
                            lsu2memCon_enable<=`TRUE;
                            busy<=`TRUE;
                            lsu2memCon_ifSigned<=`FALSE;
                        end
                        else begin
                            lsu2memCon_enable<=`FALSE;
                            busy<=`FALSE;
                        end
                    end
                    `SH: begin
                        if(rob2lsu_store_enable) begin
                            lsu2memCon_addr<=lsu_queue[head+1][`RS_VJ]+lsu_queue[head+1][`RS_A];
                            lsu2memCon_rw<=`MEM_WRITE;
                            lsu2memCon_width<=2'd1;
                            lsu2memCon_value<={16{1'b0},lsu_queue[head+1][`RS_VK][15:0]};
                            lsu2memCon_enable<=`TRUE;
                            lsu2memCon_ifSigned<=`FALSE;
                            busy<=`TRUE;
                        end
                        else begin
                            lsu2memCon_enable<=`FALSE;
                            busy<=`FALSE;
                        end
                    end
                    `SW: begin
                        if(rob2lsu_store_enable) begin
                            lsu2memCon_addr<=lsu_queue[head+1][`RS_VJ]+lsu_queue[head+1][`RS_A];
                            lsu2memCon_rw<=`MEM_WRITE;
                            lsu2memCon_width<=2'd2;
                            lsu2memCon_value<=lsu_queue[head+1][`RS_VK];
                            lsu2memCon_ifSigned<=`FALSE;
                            lsu2memCon_enable<=`TRUE;
                            busy<=`TRUE;
                        end
                        else begin
                            lsu2memCon_enable<=`FALSE;
                            busy<=`FALSE;
                        end
                    end
                endcase
            end
            else begin
                busy<=`FALSE;
                lsu2memCon_enable<=`FALSE;
            end
            if(decoder2lsu_enable&&!full) begin
                if(lsu_queue[tail][`RS_QJ]==lsu_queue[head][`RS_REORDER]) begin
                    lsu_queue[tail][`RS_VJ]<=memCon2iCache_return;
                    lsu_queue[tail][`RS_READY_1]<=`TRUE;
                end
                if(lsu_queue[tail][`RS_QK]==lsu_queue[head][`RS_REORDER]) begin
                    lsu_queue[tail][`RS_VK]<=memCon2iCache_return;
                    lsu_queue[tail][`RS_READY_2]<=`TRUE;
                end
            end
            for(i=head;i!=tail;i=i+1)
                if(lsu_queue[i][`RS_QJ]==lsu_queue[head][`RS_REORDER]) begin
                    lsu_queue[i][`RS_VJ]<=memCon2iCache_return;
                    lsu_queue[i][`RS_READY_1]<=`TRUE;
                end
            if(lsu_queue[i][`RS_QK]==lsu_queue[head][`RS_REORDER]) begin
                lsu_queue[i][`RS_VK]<=memCon2iCache_return;
                lsu_queue[i][`RS_READY_2]<=`TRUE;
            end
        end
        else begin
            if(!busy&&head_ready) begin
                case(lsu_queue[head][`RS_TYPE])
                    `LB: begin
                        lsu2memCon_addr<=lsu_queue[head][`RS_VJ]+lsu_queue[head][`RS_A];
                        lsu2memCon_rw<=`MEM_READ;
                        lsu2memCon_width<=2'd0;
                        busy<=`TRUE;
                        lsu2memCon_enable<=`TRUE;
                        lsu2memCon_ifSigned<=`TRUE;
                    end
                    `LBU: begin
                        lsu2memCon_addr<=lsu_queue[head][`RS_VJ]+lsu_queue[head][`RS_A];
                        lsu2memCon_rw<=`MEM_READ;
                        lsu2memCon_width<=2'd0;
                        busy<=`TRUE;
                        lsu2memCon_enable<=`TRUE;
                        lsu2memCon_ifSigned<=`FALSE;
                    end
                    `LH: begin
                        lsu2memCon_addr<=lsu_queue[head][`RS_VJ]+lsu_queue[head][`RS_A];
                        lsu2memCon_rw<=`MEM_READ;
                        lsu2memCon_width<=2'd1;
                        busy<=`TRUE;
                        lsu2memCon_enable<=`TRUE;
                        lsu2memCon_ifSigned<=`TRUE;
                    end
                    `LHU: begin
                        lsu2memCon_addr<=lsu_queue[head][`RS_VJ]+lsu_queue[head][`RS_A];
                        lsu2memCon_rw<=`MEM_READ;
                        lsu2memCon_width<=2'd1;
                        busy<=`TRUE;
                        lsu2memCon_enable<=`TRUE;
                        lsu2memCon_ifSigned<=`FALSE;
                    end
                    `LW: begin
                        lsu2memCon_addr<=lsu_queue[head][`RS_VJ]+lsu_queue[head][`RS_A];
                        lsu2memCon_rw<=`MEM_READ;
                        lsu2memCon_width<=2'd2;
                        busy<=`TRUE;
                        lsu2memCon_ifSigned<=`FALSE;
                        lsu2memCon_enable<=`FALSE;
                    end
                    `SB: begin
                        if(rob2lsu_store_enable) begin
                            lsu2memCon_addr<=lsu_queue[head][`RS_VJ]+lsu_queue[head][`RS_A];
                            lsu2memCon_rw<=`MEM_WRITE;
                            lsu2memCon_width<=2'd0;
                            lsu2memCon_value<={24{1'b0},lsu_queue[head][`RS_VK][7:0]};
                            lsu2memCon_ifSigned<=`FALSE;
                        end
                        else begin
                            busy<=`FALSE;
                            lsu2memCon_enable<=`FALSE;
                        end
                    end
                    `SH: begin
                        if(rob2lsu_store_enable) begin
                            lsu2memCon_addr<=lsu_queue[head][`RS_VJ]+lsu_queue[head][`RS_A];
                            lsu2memCon_rw<=`MEM_WRITE;
                            lsu2memCon_width<=2'd1;
                            lsu2memCon_value<={16{1'b0},lsu_queue[head][`RS_VK][15:0]};
                            lsu2memCon_ifSigned<=`FALSE;
                        end
                        else begin
                            busy<=`FALSE;
                            lsu2memCon_enable<=`FALSE;
                        end
                    end
                    `SW: begin
                        if(rob2lsu_store_enable) begin
                            lsu2memCon_addr<=lsu_queue[head][`RS_VJ]+lsu_queue[head][`RS_A];
                            lsu2memCon_rw<=`MEM_WRITE;
                            lsu2memCon_width<=2'd2;
                            lsu2memCon_value<=lsu_queue[head][`RS_VK];
                            lsu2memCon_ifSigned<=`FALSE;
                        end
                        else begin
                            busy<=`FALSE;
                            lsu2memCon_enable<=`FALSE;
                        end
                    end
                endcase
            end
        end
        if(alu2lsu_bypass_enable) begin
            if(decoder2lsu_enable&&!full) begin
                if(lsu_queue[tail][`RS_QJ]==alu2lsu_bypass_reorder) begin
                    lsu_queue[tail][`RS_VJ]<=alu2lsu_bypass_value;
                    lsu_queue[tail][`RS_READY_1]<=`TRUE;
                end
                if(lsu_queue[tail][`RS_QK]==alu2lsu_bypass_reorder) begin
                    lsu_queue[tail][`RS_VK]<=alu2lsu_bypass_value;
                    lsu_queue[tail][`RS_READY_2]<=`TRUE;
                end
            end
            for(alu_i=head;alu_i!=tail;alu_i=alu_i+1)
                if(lsu_queue[alu_i][`RS_QJ]==alu2lsu_bypass_reorder) begin
                    lsu_queue[alu_i][`RS_VJ]<=alu2lsu_bypass_value;
                    lsu_queue[alu_i][`RS_READY_1]<=`TRUE;
                end
            if(lsu_queue[alu_i][`RS_QK]==alu2lsu_bypass_reorder) begin
                lsu_queue[alu_i][`RS_VK]<=alu2lsu_bypass_value;
                lsu_queue[alu_i][`RS_READY_2]<=`TRUE;
            end
        end

    end

end

endmodule //lsu
