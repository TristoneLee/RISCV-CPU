`timescale 1ns/1ps

`define FALSE 1'b0
`define TRUE 1'b1

`define ADDR_WIDTH 31:0
`define MEM_WIDTH 7:0
`define INS_WIDTH 31:0
`define BYTE_WIDTH 7:0
`define HALFWORD_WIDTH 15:0
`define WORD_WIDTH 31:0
`define DATA_WIDTH 31:0
`define REG_WIDTH 4:0
`define ROB_WIDTH 3:0
`define RS_WIDTH 3:0
`define INS_TYPE_WIDTH 5:0

`define ADDR_LENGTH 32


`define ROB_SIZE 16
`define RS_SIZE 16
`define REG_SIZE 32

`define ROB_LINE_LENGTH 77
`define ROB_BUSY 0
`define ROB_READY 1
`define ROB_TYPE 7:2
`define ROB_PC 39:8
`define ROB_DEST 44:40
`define ROB_VALUE 76:45

`define RS_LINE_LENGTH 149 
`define RS_BUSY 0
`define RS_TYPE 6:1
`define RS_VJ 38:7
`define RS_VK 70:39
`define RS_QJ 74:71
`define RS_QK 78:75
`define RS_DEST 82:79
`define RS_A 114:83
`define RS_READY_1 115
`define RS_READY_2 116
`define RS_PC 117:148

`define INS_OPCODE 6:0
`define INS_RD 11:7
`define INS_FUNCT3 14:12
`define INS_RS1 19:15
`define INS_RS2 24:20
`define INS_FUNCT7 31:25

`define ZERO_DATA 32'b0
`define ZERO_ADDR 32'b0
`define ZERO_REG 5'b0
`define ZERO_RS  4'b0
`define ZERO_LSB 4'b0
`define ZERO_ROB 4'b0


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

