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
    input [6:0] opcode,
    input [2:0] funct3,
    input [31:0] addr,
    input [31:0] rd2,
    input [31:0] pc,
    input haz_ena,
    output dmem_en,
    output [3:0] dmem_wr_en,
    output [3:0] imem_wr_en,
	output [3:0] bypass_wr_en,
    output [3:0] io_trans,
    output io_recv,
    output [31:0] mem_in);

    reg [31:0] out_rd2_reg;
    reg [3:0] dmem_wr_reg, imem_wr_reg, mask_reg, io_trans_reg, bypass_wr_reg;
    reg dmem_reg, io_recv_reg;
	
    assign dmem_en = dmem_reg;
    assign dmem_wr_en = dmem_wr_reg;
    assign imem_wr_en = imem_wr_reg;
	assign bypass_wr_en = bypass_wr_reg;
    assign io_trans = io_trans_reg;
    assign io_recv = io_recv_reg;
    assign mem_in = out_rd2_reg;

    always@(*)
    begin
        case(opcode)
            `OPC_LOAD:
            begin
                dmem_wr_reg = 4'b000;
                imem_wr_reg = 4'b000;
                io_trans_reg = 4'b000;
                if (4'b1000 == addr[31:28])
                begin
                    io_recv_reg = 1'b1;
                    dmem_reg = 1'b0;
                end
                else if (2'b00 == addr[31:30] && 1'b1 == addr[28])
                begin
                    dmem_reg = 1'b1;
                    io_recv_reg = 1'b0;
                end
                else
                begin
                    io_recv_reg = 1'b0;
                    dmem_reg = 1'b0;
                end
            end
            `OPC_STORE:
            begin
                dmem_reg = 1'b0;
                io_recv_reg = 1'b0;
                case (funct3)
                    `FNC_SB:
                    begin
                        case (addr[1:0])
                            2'b00:
                            begin
                                mask_reg = 4'b0001;
                                out_rd2_reg = rd2;
                            end
                            2'b01:
                            begin
                                mask_reg = 4'b0010;
                                out_rd2_reg = rd2 << 8;
                            end
                            2'b10:
                            begin
                                mask_reg = 4'b0100;
                                out_rd2_reg = rd2 << 16;
                            end
                            2'b11:
                            begin
                                mask_reg = 4'b1000;
                                out_rd2_reg = rd2 << 24;
                            end
                            default:
                            begin
                                mask_reg = 4'bx;
                                out_rd2_reg = rd2;
                            end
                        endcase
                    end
                    `FNC_SH:
                    begin
                        case (addr[1:0])
                            2'b00:
                            begin
                                mask_reg = 4'b0011;
                                out_rd2_reg = rd2;
                            end
                            2'b10:
                            begin
                                mask_reg = 4'b1100;
                                out_rd2_reg = rd2 << 8;
                            end
                            default:
                            begin
                                mask_reg = 4'bx;
                                out_rd2_reg = rd2;
                            end
                        endcase
                    end
                    default:
                    begin
                        mask_reg = 4'b1111;
                        out_rd2_reg = rd2;
                    end
                endcase
                if (2'b00 == addr[31:30] && 1'b1 == addr[28])
                begin
                    dmem_wr_reg = mask_reg;
                end
                else
                begin
                    dmem_wr_reg = 4'b0000;
                end
                if (2'b00 == addr[31:30] && 1'b1 == addr[29] && 1'b1 == pc[30])
                begin
                    imem_wr_reg = mask_reg;
                end
                else
                begin
                    imem_wr_reg = 4'b0000;
                end
				if (4'b0100 == addr[31:28]) 
                begin
					if (haz_ena == 1'b1) 
                    begin
						bypass_wr_reg = mask_reg;
					end
					else 
                    begin 
						bypass_wr_reg = 4'b0000;
					end
				end 
                else 
                begin 
					bypass_wr_reg = 4'b0000;
				end
                if (4'b1000 == addr[31:28])
                begin
                    if (1'b1 == haz_ena)
                    begin
                    io_trans_reg = mask_reg;
                    end
                    else
                    begin
                        io_trans_reg = 4'b0000;
                    end
                end
                else
                begin
                    io_trans_reg = 4'b0000;
                end
            end
            default:
            begin
                dmem_reg = 1'b0;
                dmem_wr_reg = 4'b0000;
				bypass_wr_reg = 4'b0000;
                imem_wr_reg = 4'b0000;
                io_trans_reg = 4'b0000;
                io_recv_reg = 1'b0;
                out_rd2_reg = 32'bxxxxxxxx;
            end
        endcase
    end

endmodule
