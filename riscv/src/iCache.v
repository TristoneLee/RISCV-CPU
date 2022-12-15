`include "def.v"

module iCache #(parameter CACHE_SIZE = 1024,
                parameter CACHE_SET_SIZE = 4,
                parameter CACHELINE_SIZE = 32)
               (input wire clk_in,
                input wire rst_in,
                input wire rdy_in,                             
                //with systemController
                
                input wire [`ADDR_WIDTH]fetch2iCache_address,
                input wire fetch2iCache_enable,
                output reg [`INS_WIDTH] iCache2fetch_return,
                output reg iCache2fetch_stall,                 
                //with fetchBuffer
                
                output reg [`ADDR_WIDTH]iCache2memCon_address,
                output reg iCache2memCon_enable,
                input wire [`INS_WIDTH] memCon2iCache_return
                //with memoryController
                ); 
    
    parameter LINE_COUNT   = CACHE_SIZE/CACHELINE_SIZE;
    parameter SET_COUNT    = LINE_COUNT/CACHE_SET_SIZE;
    parameter INDEX_LENGTH = $clog2(SET_COUNT);
    parameter TAG_LENGTH   = `ADDR_LENGTH-INDEX_LENGTH;
    
    reg[TAG_LENGTH:0] index_array[SET_COUNT-1:0][CACHE_SET_SIZE-1:0]; //first bit is valid bit
    reg[CACHELINE_SIZE-1:0] data_array[SET_COUNT-1:0][CACHE_SET_SIZE-1:0];
    reg[`ADDR_WIDTH] ins_2_read;
    reg if_find;
    
    reg [`ADDR_WIDTH] reserved_address;
    reg reserved_valid;
    
    integer i,j,index;
    
    always @(posedge clk_in)
    begin
        if (rst_in == 1'd1)
        begin
            if_find <= 1'd0;
            for(i = 0;i<SET_COUNT;i = i+1)
            begin
                for(j = 0;j<CACHE_SET_SIZE;j = j+1)
                begin
                    index_array[i][j] <= 0;
                    data_array[i][j]  <= 0;
                end
            end
        end
        else if (rdy_in)
        begin
            if_find <= 1'd0;
            if (fetch2iCache_enable == 1'd1)
            begin
                ins_2_read <= fetch2iCache_address;
                index      <= ins_2_read[INDEX_LENGTH-1:0];
                for(i = 0;i<CACHE_SET_SIZE;i = i+1)
                begin
                    if (index_array[index][i][TAG_LENGTH] == 1'd1)
                    begin
                        if (index_array[index][i][TAG_LENGTH-1:0] == ins_2_read[`ADDR_LENGTH-1:INDEX_LENGTH])
                        begin
                            iCache2fetch_return <= data_array[index][i];
                            if_find             <= 1'd1;
                        end
                    end
                end
            end
        end
    end
            
    always @(*) 
    begin
        if (if_find == 1'd0)
        begin
            
        end
    end
endmodule
