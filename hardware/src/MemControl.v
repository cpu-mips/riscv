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
//    Uart_trans: Transmit signal for UART
//    Uart_recv: Receive signal for UART
//-----------------------------------------------------------------------------

`include "Opcode.vh"

module MemControl(
    input [6:0] Opcode,
    input [2:0] Funct3,
    input [31:0] A,
    output [3:0] Dmem_enable,
    output [3:0] Imem_enable,
    output [3:0] Uart_trans,
    output Uart_recv);

    reg [3:0] dmem_reg, imem_reg, mask_reg, uart_trans_reg;
    reg uart_recv_reg;

    assign Dmem_enable = dmem_reg;
    assign Imem_enable = imem_reg;
    assign Uart_trans = uart_trans_reg;
    assign Uart_recv = uart_recv_reg;

    always@(*)
    begin
        case(Opcode)
            `OPC_LOAD:
            begin
                dmem_reg = 4'b000;
                imem_reg = 4'b000;
                uart_trans_reg = 4'b000;
                if (4'b1000 == A[31:28])
                begin
                    uart_recv_reg = 1'b1;
                end
                else
                begin
                    uart_recv_reg = 1'b0;
                end
            end
            `OPC_STORE:
            begin
                case (Funct3)
                    `FNC_SB:mask_reg = 4'b0001;
                    `FNC_SH:mask_reg = 4'b0011;
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
                    uart_trans_reg = mask_reg;
                end
                else
                begin
                    uart_trans_reg = 4'b000;
                end
            end
            default:
            begin
                dmem_reg = 4'b000;
                imem_reg = 4'b000;
                uart_trans_reg = 4'b000;
                uart_recv_reg = 1'b0;
            end
        endcase
    end

endmodule
