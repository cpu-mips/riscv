//-----------------------------------------------------------------------------
//  Module: MemControl.v
//  Desc: Memory Control module  
//  Inputs Interface:
//    Opcode: Opcode for instruction (asynchronous)
//    Funct3: Funct3 field for instruction (asynchronous)
//    A: Memory address (asynchronous)
//  Output Interface:
//    Dmem_enable: Enable for dmem write
//    Imem_enable: Enable for imem write
//    io_trans: Transmit signal for io
//    io_recv: Receive signal for io
//-----------------------------------------------------------------------------

`include "Opcode.vh"

module MemControl(
    input [6:0] Opcode,
    input [2:0] Funct3,
    input [31:0] A,
    input haz_ena,
    output [3:0] Dmem_enable,
    output [3:0] Imem_enable,
    output [3:0] Io_trans,
    output Io_recv);

    reg [3:0] dmem_reg, imem_reg, mask_reg, io_trans_reg;
    reg io_recv_reg;

    assign Dmem_enable = dmem_reg;
    assign Imem_enable = imem_reg;
    assign Io_trans = io_trans_reg;
    assign Io_recv = io_recv_reg;

    always@(*)
    begin
        case(Opcode)
            `OPC_LOAD:
            begin
                dmem_reg = 4'b000;
                imem_reg = 4'b000;
                io_trans_reg = 4'b000;
                if (4'b1000 == A[31:28])
                begin
                    io_recv_reg = 1'b1;
                end
                else
                begin
                    io_recv_reg = 1'b0;
                end
            end
            `OPC_STORE:
            begin
                io_recv_reg = 1'bx;
                case (Funct3)
                    `FNC_SB:
                    begin
                        case (A[1:0])
                            2'b00:mask_reg = 4'b0001;
                            2'b01:mask_reg = 4'b0010;
                            2'b10:mask_reg = 4'b0100;
                            2'b11:mask_reg = 4'b1000;
                            default:mask_reg = 4'bx;
                        endcase
                    end
                    `FNC_SH:
                    begin
                        case (A[1:0])
                            2'b00:mask_reg = 4'b0011;
                            2'b10:mask_reg = 4'b1100;
                            default:mask_reg = 4'bx;
                        endcase
                    end
                    default:mask_reg = 4'b1111;
                endcase
                if (1'b0 == A[31] && 1'b1 == A[28])
                begin
                    dmem_reg = mask_reg;
                end
                else
                begin
                    dmem_reg = 4'b000;
                end
                if (1'b0 == A[31] && 1'b1 == A[29])
                begin
                    imem_reg = mask_reg;
                end
                else
                begin
                    imem_reg = 4'b000;
                end
                if (4'b1000 == A[31:28])
                begin
                    if (1'b1 == haz_ena)
                    begin
                    io_trans_reg = mask_reg;
                    end
                    else
                    begin
                        io_trans_reg = 4'b000;
                    end
                end
                else
                begin
                    io_trans_reg = 4'b000;
                end
            end
            default:
            begin
                dmem_reg = 4'b000;
                imem_reg = 4'b000;
                io_trans_reg = 4'b000;
                io_recv_reg = 1'b0;
            end
        endcase
    end

endmodule
