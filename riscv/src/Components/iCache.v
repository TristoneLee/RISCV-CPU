`include "../def.v"

module iCache #(parameter CACHE_SIZE = 1024,
                parameter CACHE_SET_SIZE = 4,
                parameter CACHELINE_SIZE = 32)
               (input wire clk_in,
                input wire rst_in,
                input wire rdy_in,                             //with systemController
                input wire [`ADDR_WIDTH]fetch2iCache_address,
                input wire fetch2iCache_en,
                output reg [`INS_WIDTH] iCache2fetch_return,
                output reg iCache2fetch_stall,                 //with fetchBuffer
                output reg [`ADDR_WIDTH]iCache2memCon_adderss,
                input wire [`INS_WIDTH] memCon2iCache_return); //with memoryController
    
    parameter LINE_COUNT   = CACHE_SIZE/CACHELINE_SIZE;
    parameter SET_COUNT    = LINE_COUNT/CACHELINE_SIZE;
    parameter INDEX_LENGTH = $clog2(SET_COUNT);
    parameter TAG_LENGTH   = `ADDR_LENGTH-INDEX_LENGTH;
    
    reg[TAG_LENGTH:0] index_array[SET_COUNT][CACHE_SET_SIZE]; //first bit is valid bit
    reg[CACHELINE_SIZE-1:0] data_array[SET_COUNT][CACHE_SET_SIZE];
    reg[`ADDR_WIDTH] ins_2_read;
    reg if_find;
    
    
    always @(posedge clk_in) begin
        if (rst_in)begin
            
        end
        else if (rdy_in)begin
            if_find = 1b'0;
            if (fetch2iCache_en)
            begin
                ins_2_read = fetch2iCache_address;
                integer index;
                index = ins_2_read[INDEX_LENGTH-1:0];
                integer i;
                for(i = 0;i<CACHE_SET_SIZE;i = i+1)
                begin
                    if (index_array[index][i][TAG_LENGTH])
                    begin
                        if (index_array[index][i][TAG_LENGTH-1:0] == ins_2_read[`ADDR_LENGTH-1:INDEX_LENGTH])
                        begin
                            iCache2fetch_return = data_array[index][i];
                        end
                    end
                end
                if (!if_find)
                begin
                    
                end
            end
        end
            end
            endmodule
