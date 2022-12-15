`include "def.v"

module PC(
           input wire clk_in,
           input wire rst_in,
           input wire rdy_in,

           input wire [`DATA_WIDTH] rob2pc_pc,
           input wire rob2pc_enable,

           output reg [`DARA_WIDTH] pc2fetch_pc,
           output reg pc2fetch_enable
       );

reg[`ADDR_WIDTH] pc;

initial begin
    
end

always @(posedge clk_in ) begin
    if(rst_in) begin
        pc2fetch_enable<=`TRUE;
    end
    else if(rdy_in) begin
        if(rob2pc_enable)begin
            pc<=rob2pc_pc;
            pc2fetch_enable<=rob2pc_pc;
            pc2fetch_enable<=`TRUE;
        end
        else begin
            pc<=pc+4;
            pc2fetch_enable<=`TRUE;
            pc2fetch_pc<=`TRUE;
        end
    end
end

endmodule
