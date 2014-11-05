//-----------------------------------------------------------------------------
//  Module: IOInterface.v
//  Desc: Handles Communication with IO  
//  Inputs Interface:
//    A: Input address (asynchronous)
//    IO_trans: Signal for IO transmission (asynchronous)
//    IO_recv: Signal for IO receiving
//  Output Interface:
//    Received: Received IO signal
//-----------------------------------------------------------------------------

module IOInterface(
    input [31:0] rd2,
    input [31:0] Addr,
    input [3:0] IO_trans,
    input IO_recv,
    input Clock,
    input FPGA_Sin,
    output FPGA_Sout,
    output [31:0] Received);

    wire dout_valid, din_ready, reset;
    reg  dout_ready, din_valid;
    wire [7:0] dout;

    reg [7:0] din;
    reg [31:0] io_out;

    UART uart(
        .Clock(Clock),
        .Reset(reset),
        .DataIn(din),
        .DataInValid(din_valid),
        .DataInReady(din_ready),
        .DataOut(dout),
        .DataOutValid(dout_valid),
        .DataOutReady(dout_ready),
        .SIn(FPGA_Sin),
        .SOut(FPGA_Sout)
    );


    assign reset = 1'b0;
    assign Received = io_out;


    always@(*)
    begin
        case (Addr)
            32'h80000000:
            begin
                din = 7'bx;
                din_valid = 1'b0;
                dout_ready = 1'b0;
                if (1'b1 == IO_recv && 1'b0 == IO_trans[0])
                begin
                    io_out = {30'b0, dout_valid, din_ready};
                end
                else
                begin
                    io_out = 32'bx;
                end
            end
            32'h80000004:
            begin
                din = 7'bx;
                din_valid = 1'b0;
                if (1'b1 == IO_recv && 1'b0 == IO_trans[0])
                begin
                    dout_ready = 1'b1;
                    if (1'b1 == dout_valid)
                    begin
                        io_out = {24'b0, dout};
                    end
                    else
                    begin
                        io_out = 32'bx;
                    end
                end
                else
                begin
                    io_out = 32'bx;
                end
                dout_ready = 1'b0;
            end
            32'h80000008:
            begin
                io_out = 32'bx;
                dout_ready = 1'b0;
                if (1'b1 == IO_trans[0] && 1'b0 == IO_recv)
                begin
                    din = rd2[7:0];
                    if (1'b1 == din_ready)
                    begin
                        din_valid = 1'b1;
                    end
                    else
                    begin
                        din_valid = 1'b0;
                    end
                end
                else
                begin
                    din_valid = 1'b0;
                end
                din_valid = 1'b0;
            end
            default:
            begin
                io_out = 32'hxxxxxxxx;
            end
        endcase
    end

endmodule
