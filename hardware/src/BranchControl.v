//-----------------------------------------------------------------------------
//  Module: BranchControl.v
//  Desc: Handles control for branching  
//  Inputs Interface:
//    Opcode: first input (asynchronous)
//    Funct3: second input (asynchronous)
//    ALUOut: Output from the ALU (asynchronous)
//    Zero: Whether the ALUOut is 0 or not (asynchronous)
//  Output Interface:
//    Branch: Whether to take the branch or not
//-----------------------------------------------------------------------------

`include  "Opcode.vh"

module BranchControl(
    input [6:0]  Opcode,
    input [2:0] Funct3,
    input [31:0] ALUOut,
    input Zero,
    output Diverge);


    reg diverge_reg;

    assign Diverge = diverge_reg;

    always@(*)
    begin
        if (`OPC_JAL == Opcode|| `OPC_JALR == Opcode)
        begin
            diverge_reg = 1'b1;
        end
        else if (`OPC_BRANCH == Opcode)
        begin
            case (Funct3)
                `FNC_BEQ:
                begin
                    if (1'b1 == Zero)
                    begin
                        diverge_reg = 1'b1;
                    end
                    else
                    begin
                        diverge_reg = 1'b0;
                    end
                end
                `FNC_BNE:
                begin
                    if (1'b1 == Zero)
                    begin
                        diverge_reg = 1'b0;
                    end
                    else
                    begin
                        diverge_reg = 1'b1;
                    end
                end
                `FNC_BLT:
                begin
                    if(1'b1 == ALUOut)
                    begin
                        diverge_reg = 1'b1;
                    end
                    else
                    begin
                        diverge_reg = 1'b0;
                    end
                end
                `FNC_BGE:
                begin
                    if(1'b1 == ALUOut)
                    begin
                        diverge_reg = 1'b0;
                    end
                    else
                    begin
                        diverge_reg = 1'b1;
                    end
                end
                `FNC_BLTU:
                begin
                    if(1'b1 == ALUOut)
                    begin
                        diverge_reg = 1'b1;
                    end
                    else
                    begin
                        diverge_reg = 1'b0;
                    end
                end
                `FNC_BGEU:
                begin
                    if(1'b1 == ALUOut)
                    begin
                        diverge_reg = 1'b0;
                    end
                    else
                    begin
                        diverge_reg = 1'b1;
                    end
                end
                default: diverge_reg = 1'bx;
            endcase
        end
        else
        begin
            diverge_reg = 1'b0;
        end
    end

endmodule
