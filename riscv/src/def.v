`timescale 1ns/1ps

`define ADDR_WIDTH 31:0
`define MEM_WIDTH 7:0
`define INS_WIDTH 31:0
`define BYTE_WIDTH 7:0
`define HALFWORD_WIDTH 15:0
`define WORD_WIDTH 31:0
`define LOGICAL_REG_WIDTH 4:0
`define PHYSICAL_REG_WIDTH 5:0

`define PHYSICAL_REG_NUM 64

`define ADDR_LENGTH 32

`define UOP_LENGTH 88
`define UOP_TYPE 5:0
`define UOP_RS1_V 10:6
`define UOP_RS2_V 15:11
`define UOP_RD_V 20:16
`define UOP_RS1_P 26:21
`define UOP_RS2_P 32:27
`define UOP_RD_P 38:33
`define UOP_IMM 70:39
`define UOP_PC 87:71

`define INS_OPCODE 6:0
`define INS_RD 11:7
`define INS_FUNCT3 14:12
`define INS_RS1 19:15
`define INS_RS2 24:20
`define INS_FUNCT7 31:25


`define LUI 6'd0
`define AUIPC 6'd1
`define JAL 6'd2
`define JALR 6'd3

`define BEQ 6'd4
`define BNE 6'd5    
`define BLT 6'd6
`define BGE 6'd7
`define BLTU 6'd8
`define BGEU 6'd9

`define LB 6'd10
`define LH 6'd11
`define LW 6'd12
`define LBU 6'd13
`define LHU 6'd14

`define SB 6'd15
`define SH 6'd16
`define SW 6'd17

`define ADDI 6'd18
`define SLTI 6'd19
`define SLTIU 6'd20
`define XORI 6'd21
`define ORI 6'd22
`define ANDI 6'd23  
`define SLLI 6'd24
`define SRLI 6'd25
`define SRAI 6'd26

`define ADD 6'd27
`define SUB 6'd28
`define SLL 6'd29
`define SLT 6'd30
`define SLTU 6'd31
`define XOR 6'd32
`define SRL 6'd33
`define SRA 6'd34
`define OR 6'd35
`define AND 6'd36

`define NOP 6'd37


`define 