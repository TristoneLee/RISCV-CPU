`include "def.v"

module decoder(input wire clk_in,
               input wire rst_in,
               input wire rdy_in,
               input wire rob_full,
               input wire rs_full,
               //control signal

               input wire fetch2decoder_enable,
               input wire[`INS_WIDTH] fetch2decoder_ins,
               input wire[`ADDR_WIDTH] fetch2decoder_pc,
               //with fetcher

               output wire[`REG_WIDTH] decoder2rob_rs1_request,
               output wire[`REG_WIDTH] decoder2rob_rs2_request,
               input wire rob2decoder_rs1_if_rename,
               input wire rob2decoder_rs2_if_rename,
               input wire[`ROB_WIDTH] rob2decoder_rs1_rename,
               input wire[`ROB_WIDTH] rob2decoder_rs2_rename,
               input wire [`DATA_WIDTH]rob2decoder_rs1_value,
               input wire [`DATA_WIDTH]   rob2decoder_rs2_value,
               input wire [`ROB_WIDTH] rob2decoder_reorder,
               //with rob for renaming

               output wire decoder2rob_enable,
               output wire[`ROB_LINE_LENGTH-1:0] decoder2rob_robline,
               //with rob for data delivering

               output wire decoder2lsu_enable,
               output wire decoder2rs_enable,
               output wire[`RS_LINE_LENGTH-1:0] decoder2rs_rsline,
               output wire[`RS_LINE_LENGTH-1:0] decoder2lsu_lsuline
              );

wire decoder_rdy=!rob_full&&!rs_full&&rdy_in;
wire [`INS_WIDTH]curins=fetch2decoder_ins;
wire [`INS_TYPE_WIDTH]cur_type=get_ins_type(input curins);
wire curins_rs1_default=curins[`INS_OPCODE]==7'b0110111||curins[`INS_OPCODE]==7'b0010111||curins[`INS_OPCODE]==7'b1101111||curins[`INS_OPCODE]==7'b1100111;
wire curins_rs2_default=curins[`INS_OPCODE]==7'b0110111||curins[`INS_OPCODE]==7'b0010111||curins[`INS_OPCODE]==7'b1101111||curins[`INS_OPCODE]==7'b1100111||curins[`INS_OPCODE]==7'b0000011||curins[`INS_OPCODE]==7'b0010011;

assign decode2rob_rs1_request=curins[`INS_RS1];
assign decoder2rob_rs2_request=curins[`INS_RS2];

assign decoder2rob_robline[`ROB_BUSY]=`TRUE;
assign decoder2rob_robline[`ROB_DEST]=curins[`INS_RD];
assign decoder2rob_robline[`ROB_TYPE]=cur_type;
assign decoder2rob_robline[`ROB_PC]=fetch2decoder_pc;
assign decoder2rob_robline[`ROB_VALUE]=`ZERO_DATA;
assign decoder2rob_line[`ROB_READY]=`FALSE;

assign decoder2rs_rsline[`RS_A]=get_ins_imm(input curins);
assign decoder2rs_rsline[`RS_BUSY]=`TRUE;
assign decoder2rs_rsline[`RS_TYPE]=cur_type;
assign decoder2rs_rsline[`RS_VJ]=curins_rs1_default?`ZERO_DATA: rob2decoder_rs1_value;
assign decoder2rs_rsline[`RS_VK]=curins_rs2_default?`ZERO_DATA: rob2decoder_rs2_value;
assign decoder2rs_rsline[`RS_QJ]=curins_rs1_default?`ZERO_ROB: rob2decoder_rs1_rename;
assign decoder2rs_rsline[`RS_QK]=curins_rs2_default?`ZERO_ROB: rob2decoder_rs2_rename;
assign decoder2rs_rsline[`RS_DEST]=rob2decoder_rsdest;
assign decoder2rs_rsline[`RS_READY_1]=(curins_rs1_default)?1b'1:!rob2decoder_rs1_if_rename;
assign decoder2rs_rsline[`RS_READY_2]=(curins_rs2_default)?1b'1:!rob2decoder_rs2_if_rename;
assign decoder2rs_rsline[`RS_PC]=fetch2decoder_pc;

assign decoder2lsu_lsuline=decoder2rs_rsline;

assign decoder2rob_enable=fetch2decoder_enable;
assign decoder2lsu_enable=fetch2decoder_enable && (curins[`INS_OPCODE]==7'b0000011||curins[`INS_OPCODE]==7'b0100011);
assign decoder2rs_enable=fetch2decoder_enable && !(curins[`INS_OPCODE]==7'b0000011||curins[`INS_OPCODE]==7'b0100011);


function [`UOP_TYPE] get_ins_type (input [`INS_WIDTH] ins);
    begin
        case (ins[`INS_OPCODE])
            7'b0110111:
                get_ins_type = `LUI;
            7'b0010111:
                get_ins_type = `AUIPC;
            7'b1101111:
                get_ins_type = `JAL;
            7'b1100111:
                get_ins_type = `JALR;
            7'b1100011:
            case(ins[`INS_FUNCT3])
                3'b000:
                    get_ins_type = `BEQ;
                3'b001:
                    get_ins_type= `BNE;
                3'b100:
                    get_ins_type=`BLT;
                3'b101:
                    get_ins_type=`BGE;
                3'b110:
                    get_ins_type=`BLTU;
                3'b11:
                    get_ins_type=`BGEU;
            endcase
            7'b0000011:
            case(ins[`INS_FUNCT3])
                3'b000:
                    get_ins_type=`LB;
                3'b001:
                    get_ins_type=`LH;
                3'b010:
                    get_ins_type=`LW;
                3'b100:
                    get_ins_type=`LBU;
                3'b101:
                    get_ins_type=`LHU;
            endcase
            7'b0100011:
            case(ins[`INS_FUNCT3])
                3'b000:
                    get_ins_type= `SB;
                3'b001:
                    get_ins_type= `SH;
                3'b010:
                    get_ins_type= `SW;
            endcase
            7'b0010011:
            case (ins[`INS_FUNCT3])
                3'b000:
                    get_ins_type=`ADDI;
                3'b010:
                    get_ins_type=`SLTI;
                3'b011:
                    get_ins_type=`SLTIU;
                3'b100:
                    get_ins_type=`XORI;
                3'b110:
                    get_ins_type=`ORI;
                3'b111:
                    get_ins_type=`ANDI;
                3'b001:
                    get_ins_type=`SLLI;
                3'b101:
                case (ins[`INS_FUNCT7])
                    7'b0000000:
                        get_ins_type=`SRLI;
                    7'b0100000:
                        get_ins_type=`SRAI;
                endcase
            endcase
            7'b0110011:
            case(ins[`INS_FUNCT3])
                3'b000:
                case (ins[`INS_FUNCT7])
                    7'b0000000:
                        get_ins_type=`ADD;
                    7'b0100000:
                        get_ins_type=`SUB;
                endcase
                3b'001:
                    get_ins_type=`SLL;
                3b'010:
                    get_ins_type=`SLT;
                3b'011:
                    get_ins_type=`SLTU;
                3b'100:
                    get_ins_type=`XOR;
                3b'110:
                    get_ins_type=`OR;
                3b'111:
                    get_ins_type=`AND;
                3'b101:
                case (ins[`INS_FUNCT7])
                    7'b0000000:
                        get_ins_type=`SRL;
                    7'b0100000:
                        get_ins_type=`SRA;
                endcase
            endcase
        endcase
    end
endfunction

function [`UOP_IMM] get_ins_imm(input [`INS_WIDTH] ins);
    begin
        case (ins[`INS_OPCODE])
            7'b0110111, 7'b0010111:
                get_ins_imm={ins[31:12],12{1'b0}};
            7'b1101111:
                get_ins_imm={11{1'b0},ins[31],ins[19,12],ins[20],ins[30,21],1b'0};
            7'b1100111,7'b0000011,7'b0010011:
                get_ins_imm={20{1'b0},ins[31:20]};
            7'b1100011:
                get_ins_imm={19{1'b0},ins[31],ins[7],ins[30:25],ins[11:8],1'b0};
            7'b0100011:
                get_ins_imm={20{1'b0},ins[31:25],ins[11:7]};
        endcase
    end
endfunction
endmodule
