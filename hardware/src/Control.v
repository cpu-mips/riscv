// UC Berkeley CS150
// Lab 4, Fall 2014
// Module: Control.v
// Desc:   32-bit Control for the RISc-V Processor
// Inputs: 
//    Opcode: Opcode for instruction 
//    Funct3: 3 bit funct field for instruction
//    Funct7: 7 bit funct field for instruction 
//    Zero: Zero bit from ALU for branch instruction
// 						
// Outputs:
//    Lui: Control signal for lui mux.
//    Pass: Control signal for mux to determine if value passes through ALU
//    ALUop: Control signal for ALU
//    ALUSrc2: Control signal to determine whether to use immediate or reg
//    Dest: Control signal for mux to determine destination
//    Diverge: Control signal for mux to determine if PC is incremented

`include "Opcode.vh"

input Control(
    input [6:0] Opcode,
    input [3:0] Funct3,
    input [6:0] Funct7,
    input Stall,
    output Lui,
    output Pass,
    output ALUop,
    output ALUSrc2,
    output [1:0] Dest, 
    output Jal,
    output Jalr);

    ALUdec decoder(
        .opcode(Opcode),
        .funct(Funct3),
        .add_rshift_type(add_rshift_type),
        .ALUop(ALUop));
    )

    wire add_rshift_type;
    assign add_rshift_type = Funct7[5];

    always@(*)
    begin
        case (opcode)
            `OPC_LUI:
            begin
                Lui = 1'b1;
                Pass = 1'b0;
                ALUSrc2 = 1'b1;
                Dest = 2'b00;
                Jal = 1'b0;
                Jalr = 1'b0
            end
            `OPC_AUIPC:
            begin
                Lui = 1'b0;
                Pass = 1'b1;
                ALUSrc2 = 1'b1;
                Dest = 2'b10;
                Jal = 1'b0;
                Jalr = 1'b0;
            end
            `OPC_JAL:
            begin
                Lui = 1'b1;
                Pass = 1'b0;
                ALUSrc2 = 1'b1;
                Dest = 2'bxx;
                Jal = 1'b1
                Jalr = 1'b0;
            end
            `OPC_JALR:
            begin
                Lui = 1'b1;
                Pass = 1'b0;
                ALUSrc2 = 1'b1;
                Dest = 2'b10;
                Jal = 1'b1;
                Jalr = 1'b1;
            end
            //All branch instructions subtract.
            `OPC_BRANCH:
            begin
                Lui = 1'b0;
                Pass = 1'b0;
                ALUSrc2 = 1'b0;
                Dest = 2'bxx;
                Jal = 1'b0;
                Jalr = 1'b0;
            end
            `OPC_STORE:
            begin
                Lui = 1'b0;
                Pass = 1'b0;
                ALUSrc2 = 1'b1;
                Dest = 2'bxx;
                Jal = 1'b0;
                Jalr = 1'b0;
            end
            `OPC_LOAD:
            begin
                Lui = 1'b0;
                Pass = 1'b0;
                ALUSrc2 = 1'b1;
                Dest = 2'b01;
                Jal = 1'b0;
                Jalr = 1'b0;
            end
            `OPC_ARI_ITYPE:
            begin
                Lui = 1'b0;
                Pass = 1'b0;
                ALUSrc2 = 1'b1;
                Dest = 2'b00;
                Jal = 1'b0;
                Jalr = 1'b0;
            end
            `OPC_ARI_RTYPE:
            begin
                Lui = 1'b0;
                Pass = 1'b0;
                ALUSrc2 = 1'b1;
                Dest = 2'b00;
                Jal = 1'b0;
                Jalr = 1'b0;
            end
            default:
            begin
                Lui = 1'bx;
                Pass = 1'bx;
                ALUSrc2 = 1'bx;
                Dest = 2'bxx;
                Jal = 1'bx;
            end
        endcase
    end
