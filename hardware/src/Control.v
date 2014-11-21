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
//    ALUop: Control signal for ALU
//    ALUSrc2: Control signal to determine whether to use immediate or reg
//    Dest: Control signal for mux to determine destination
//    Diverge: Control signal for mux to determine if PC is incremented

`include "Opcode.vh"

module Control(
    input [6:0] Opcode,
    input [2:0] Funct3,
    input [6:0] Funct7,
    output Lui,
    output [3:0] ALUop,
    output ALUSrc2,
    output [1:0] Dest, 
    output Jal,
    output Jalr);

    wire add_rshift_type;
    assign add_rshift_type = Funct7[5];

    ALUdec decoder(
        .opcode(Opcode),
        .funct(Funct3),
        .add_rshift_type(add_rshift_type),
        .ALUop(ALUop));


    reg lui_reg, alusrc2_reg, jal_reg, jalr_reg;
    reg [1:0] dest_reg;
    
    assign Lui = lui_reg;
    assign ALUSrc2 = alusrc2_reg;
    assign Dest = dest_reg;
    assign Jal = jal_reg;
    assign Jalr = jalr_reg;

    always@(*)
    begin
        case (Opcode)
            `OPC_LUI:
            begin
                lui_reg = 1'b1;
                alusrc2_reg = 1'b1;
                dest_reg = 2'b00;
                jal_reg = 1'b0;
                jalr_reg = 1'b0;
            end
            `OPC_AUIPC:
            begin
                lui_reg = 1'b1;
                alusrc2_reg = 1'b1;
                dest_reg = 2'b10;
                jal_reg = 1'b0;
                jalr_reg = 1'b0;
            end
            `OPC_JAL:
            begin
                lui_reg = 1'b0;
                alusrc2_reg = 1'b1;
                dest_reg = 2'b10;
                jal_reg = 1'b1;
                jalr_reg = 1'b0;
            end
            `OPC_JALR:
            begin
                lui_reg = 1'b0;
                alusrc2_reg = 1'b1;
                dest_reg = 2'b10;
                jal_reg = 1'b1;
                jalr_reg = 1'b1;
            end
            `OPC_BRANCH:
            begin
                lui_reg = 1'b0;
                alusrc2_reg = 1'b0;
                dest_reg = 2'bxx;
                jal_reg = 1'b0;
                jalr_reg = 1'b0;
            end
            `OPC_STORE:
            begin
                lui_reg = 1'b0;
                alusrc2_reg = 1'b1;
                dest_reg = 2'bxx;
                jal_reg = 1'b0;
                jalr_reg = 1'b0;
            end
            `OPC_LOAD:
            begin
                lui_reg = 1'b0;
                alusrc2_reg = 1'b1;
                dest_reg = 2'b01;
                jal_reg = 1'b0;
                jalr_reg = 1'b0;
            end
            `OPC_ARI_ITYPE:
            begin
                lui_reg = 1'b0;
                alusrc2_reg = 1'b1;
                dest_reg = 2'b00;
                jal_reg = 1'b0;
                jalr_reg = 1'b0;
            end
            `OPC_ARI_RTYPE:
            begin
                lui_reg = 1'b0;
                alusrc2_reg = 1'b0;
                dest_reg = 2'b00;
                jal_reg = 1'b0;
                jalr_reg = 1'b0;
            end
            default:
            begin
                lui_reg = 1'bx;
                alusrc2_reg = 1'bx;
                dest_reg = 2'bxx;
                jal_reg = 1'bx;
                jalr_reg = 1'bx;
            end
        endcase
    end
endmodule
