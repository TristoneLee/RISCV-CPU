`include "def.v"

module decoder(input wire clk_in,
               input wire rst_in,
               input wire rdy_in,
               //control signal

               input wire [`INS_WIDTH]fetch2decoder_ins,
               input wire [`ADDR_WIDTH]fetch2decoder_pc,

               output wire[4:0] decoder2reg_rs1_virtual,
               output wire[4:0] decoder2reg_rs2_virtual,
               output wire[4:0] decoder2reg_rd_virtual,
               input wire[5:0] reg2decoder_rs1_physical,
            //    input wire reg2decoder_rs1_valid,
               input wire[5:0] reg2decoder_rs2_physical,
            //    input wire reg2decoder_rs2_valid,
               input wire[5:0] reg2decoder_rd_physical,
            //    input wire reg2decoder_rd_valid,
               //with reg for explicit renaming

               input wire ROB2decoder_valid,
               output wire[`UOP_LENGTH-1:0] decoder2ROB_uop,
               input wire IQ2decoder_valid,
               output wire[`UOP_LENGTH-1:0] decoder2IQ_uop);

wire [`UOP_LENGTH-1:0] current_uop;
assign decoder2IQ_uop          = current_uop;
assign decoder2ROB_uop       = current_uop;

assign current_uop[`UOP_PC]    = fetch2decoder_pc;
assign current_uop[`UOP_RS1_V] = fetch2decoder_ins[`INS_RS1];
assign current_uop[`UOP_RS2_V] = fetch2decoder_ins[`INS_R];
assign current_uop[`UOP_RD_V]  = fetch2decoder_ins[`INS_RD];
assign current_uop[`UOP_RS1_P] = reg2decoder_rs1_physical;
assign current_uop[`UOP_RS2_P] = reg2decoder_rs2_physical;
assign current_uop[`UOP_RD_P]  = reg2decoder_rd_physical;
assign current_uop[`UOP_TYPE]  = get_ins_type(fetch2decoder_ins);
assign current_uop[`UOP_IMM]   = get_ins_imm(fetch2decoder_ins);

assign decoder2reg_rs1_virtual=current_uop[`UOP_RS1_V];
assign decoder2reg_rs2_virtual=current_uop[`UOP_RS2_V];
assign decoder2reg_rd_virtual=current_uop[`UOP_RD_V];


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
