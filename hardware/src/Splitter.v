//-----------------------------------------------------------------------------
//  Module: Splitter.v
//  Desc: Splits instruction into different possible values  
//  Inputs Interface:
//    a: Instruction (asynchronous)
//  Output Interface:
//    Opcode: Opcode field of instruction (asynchronous)
//    Funct3: Funct3 field of instruction (asynchronous)
//    Funct7: Funct7 field of instruction (asynchronous)
//    Rs1: Rs1 field of instruction (asynchronous)
//    Rs2: Rs2 field of instruction (asynchronous)
//    Rd: Rd field of instruction (asynchronous)
//    UTypeImm: U Type immediate field of instruction (asynchronous)
//    ITypeImm: I Type immediate field of instruction (asynchronous)
//    STypeImm1: S Type immediate field 1 of instruction (asynchronous)
//    STypeImm2: S Type immediate field 2 of instruction (asynchronous)
//-----------------------------------------------------------------------------

module Splitter(
    input [31:0] Instruction,
    output [6:0] Opcode,
    output [2:0] Funct3,
    output [6:0] Funct7,
    output [4:0] Rs1,
    output [4:0] Rs2,
    output [4:0] Rd,
    output [19:0] UTypeImm,
    output [11:0] ITypeImm,
    output [4:0] STypeImm1,
    output [6:0] STypeImm2
    );

    assign Opcode = Instruction[6:0];
    assign Funct3 = Instruction[14:12];
    assign Funct7 = Instruction[31:25];
    assign Rs1 = Instruction[19:15];
    assign Rs2 = Instruction[24:20];
    assign Rd = Instruction[11:7];
    assign UTypeImm = Instruction[31:12];
    assign ITypeImm = Instruction[31:20];
    assign STypeImm1 = Instruction[11:7];
    assign STypeImm2 = Instruction[31:25];

endmodule
