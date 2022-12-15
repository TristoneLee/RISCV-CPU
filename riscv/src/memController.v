`include "def.v"

module memController
       (input wire clk_in,
        input wire rst_in,
        input wire rdy_in,
        //control signal

        output reg memCon2iCache_enable;
        output reg[`WORD_WIDTH] memCon2iCache_return,
        output wire memCon2iCache_ifbusy,
        input wire iCache2memCon_enable,
        input wire [`ADDR_WIDTH] iCache2memCon_adderss,
        //with iCache

        output reg[`WORD_WIDTH] memCon2lsu_return,
        output reg memCon2lsu_enable,
        input wire[1:0] lsu2memCon_width,
        input wire [`MEM_COMMAND_ADDR] lsu2memCon_addr,
        input wire lsu2memCon_rw,
        input wire lsu2memCon_ifSigned,
        input wire lsu2memCon_enable,
        //with lsu

        input wire [`MEM_WIDTH] mem2memCon_din,
        output reg [`ADDR_WIDTH] memCon2mem_addr,
        output reg memCon2mem_rw_select,
        output reg [`MEM_WIDTH] memCon2mem_dout
        //with memory
       );

reg ram_en;
reg[`MEM_COMMAND_LENGTH-1:0] current_command;
reg[`MEM_COMMAND_LENGTH-1:0] reserve_command;
reg reserve_valid;
reg[2:0] count_down;
reg[`DATA_WIDTH] io_buffer;
reg[`MEM_WIDTH] mem_out;

always @(posedge clk_in) begin
    if (rst_in) begin
        current_command <= 0;
        reserve_command<=0;
        reserve_valid<=`FALSE;
        io_buffer<=`ZERO_DATA;
        mem_out<=`ZERO_BYTE;
        memCon2mem_addr<=`ZERO_ADDR;
        memCon2mem_dout<=`ZERO_BYTE;
        memCon2iCache_return<=`ZERO_DATA;
        memCon2iCache_enable<=`FALSE;
        memCon2lsu_enable<=`FALSE;
        memCon2lsu_return<=`ZERO_DATA;
    end
    else if (rdy_in) begin
        if(count_down!=0) begin
            io_buffer[count_down*8-1:(count_down-1)*8]<=mem2memCon_din;
            count_down<=count_down-1;
            memCon2mem_addr<=current_command[`MEM_COMMAND_ADDR]+(count_down-1)*32'd8;
        end
        else begin
            if (current_command[`MEM_COMMAND_SRC] == 1'd0) begin
                memCon2iCache_return<=io_buffer;
                io_buffer            <= 32'd0;
            end
            else begin
                memCon2lsu_return <= io_buffer;
                io_buffer         <= 32'd0;
            end
            if (reserve_valid == 1'd1) begin
                current_command <= reserve_command;
                case (reserve_command[`MEM_COMMAND_WIDTH])
                    2'd0:
                        count_down <= 3'd1;
                    2'd1:
                        count_down <= 3'd2;
                    2'd2:
                        count_down <= 3'd4;
                endcase
                reserve_valid        <= `FALSE;
                memCon2mem_addr      <= reserve_command[`MEM_COMMAND_ADDR];
                memCon2mem_rw_select <= reserve_command[`MEM_COMMAND_RW];
            end
            else begin
                if (iCache2memCon_valid == 1'd1) begin
                    current_command[`MEM_COMMAND_ADDR]  <= iCache2memCon_adderss;
                    current_command[`MEM_COMMAND_WIDTH] <= 2'd2;
                    current_command[`MEM_COMMAND_SRC]    <= 1'd0;
                    current_command[`MEM_COMMAND_RW]      <= 1'd0;
                    count_down                   <= 3'd4;
                    current_command[`MEM_COMMAND_SIGN]<= `FALSE;
                end
                else if (lsu2memCon_enable == 1'd1) begin
                    current_command[`MEM_COMMAND_ADDR]  <= lsu2memCon_addr;
                    current_command[`MEM_COMMAND_WIDTH] <= lsu2memCon_width;
                    current_command[`MEM_COMMAND_SRC]    <= 1'd1;
                    current_command[`MEM_COMMAND_RW]     <= lsu2memCon_rw;
                    cuurent_command[`MEM_COMMAND_SIGN]<=lsu2memCon_ifSigned;
                end
            end
        end
        if (reserve_valid == 1'd0) begin
            if (iCache2memCon_valid == 1'd1) begin
                reserve_command[`MEM_COMMAND_ADDR]   <= iCache2memCon_adderss;
                reserve_command[`MEM_COMMAND_WIDTH]  <= 2'd2;
                reserve_command[`MEM_COMMAND_SRC]     <= 1'd0;
                reserve_command[`MEM_COMMAND_RW]      <= 1'd0;
                count_down                    <= 3'd4;
                reserve_command[MEM_COMMAND_ADDR]<=`FALSE;
            end
            else if (lsu2memCon_enable == 1'd1) begin
                reserve_command[`MEM_COMMAND_ADDR]  <= lsu2memCon_addr;
                reserve_command[`MEM_COMMAND_WIDTH] <= lsu2memCon_width;
                reserve_command[`MEM_COMMAND_SRC]    <= `TRUE;
                reserve_command [`MEM_COMMAND_RW]    <= lsu2memCon_rw;
                reserve_command[`MEM_COMMAND_SIGN] <=lsu2memCon_ifSigned;
            end
            reserve_valid <= `TRUE;
        end
    end
end


endmodule
