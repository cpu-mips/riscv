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
`include "Opcode.vh"

module IOInterface(
	input [6:0] opcode,
    input [31:0] rd2,
    input [31:0] Addr,
    input [3:0] IO_trans,
    input IO_recv,
	input line_ready,
    input Clock,
    input Reset,
    input Stall,
    input FPGA_Sin,
    output FPGA_Sout,
    output [31:0] Received,
	output [31:0] LE_color,
	output [9:0] LE_point,
	output LE_color_valid,
	output LE_x0_valid,
	output LE_y0_valid,
	output LE_x1_valid,
	output LE_y1_valid,
	output LE_trigger
	);

    wire dout_valid, din_ready;
    reg  dout_ready, din_valid;
    wire [7:0] dout;

    reg [7:0] din;
    reg [31:0] io_out, synch_io_out;
    reg [31:0] cycles, instructions;
	reg x1_valid, x0_valid, y0_valid, y1_valid, color_valid, le_trigger;
	reg [9:0] point, point_synch;
	reg [31:0] color, color_synch;
	reg x1_valid_synch, x0_valid_synch, y0_valid_synch, y1_valid_synch, color_valid_synch, le_trigger_synch; 

    UART uart(
        .Clock(Clock),
        .Reset(Reset),
        .DataIn(din),
        .DataInValid(din_valid),
        .DataInReady(din_ready),
        .DataOut(dout),
        .DataOutValid(dout_valid),
        .DataOutReady(dout_ready),
        .SIn(FPGA_Sin),
        .SOut(FPGA_Sout)
    );


    assign Received = synch_io_out;
	assign LE_color = color_synch;
	assign LE_point = point_synch;
	assign LE_color_valid = color_valid_synch;
	assign LE_x0_valid = x0_valid_synch;
	assign LE_y0_valid = y0_valid_synch;
	assign LE_x1_valid = x1_valid_synch;
	assign LE_y1_valid = y1_valid_synch;
	assign LE_trigger = le_trigger_synch;
    always@(posedge Clock)
    begin
        synch_io_out <= io_out;
        if (Reset)
        begin
            instructions <= 0;
            cycles <= 0;
        end
        else if (32'h80000018 == Addr)
        begin
            instructions <= 0;
            cycles <= 0;
        end
        else
        begin
            cycles <= cycles + 1;
            if (Stall)
            begin
                instructions <= instructions;
            end
            else
            begin
                instructions <= instructions + 1;
            end
        end
		if (Reset) 
        begin
			x1_valid_synch <= 1'b0;
			x0_valid_synch <= 1'b0;
			y1_valid_synch <= 1'b0;
			y0_valid_synch <= 1'b0;
			le_trigger_synch <= 1'b0;
			color_valid_synch <= 1'b0;
		end 
        else if (Stall) 
        begin
			x1_valid_synch <= x1_valid_synch;
			x0_valid_synch <= x0_valid_synch;
			y1_valid_synch <= y1_valid_synch;
			y0_valid_synch <= y0_valid_synch;
			color_synch <= color_synch;
			point_synch <= point_synch;
			le_trigger_synch <= le_trigger_synch;
			color_valid_synch <= color_valid_synch;
		end 
		else 
        begin
			x1_valid_synch <= x1_valid;
			x0_valid_synch <= x0_valid;
			y1_valid_synch <= y1_valid;
			y0_valid_synch <= y0_valid;
			color_synch <= color;
			point_synch <= point;
			le_trigger_synch <= le_trigger;
			color_valid_synch <= color_valid;
		end
    end


    always@(*)
    begin
        case (Addr)
            32'h80000000:
            begin
                din = 8'bx;
                dout_ready = 1'b0;
                din_valid = 1'b0;
                if (1'b1 == IO_recv)
                begin
                    io_out = {30'b0, dout_valid, din_ready};
                end
                else
                begin
                    io_out = 32'bx;
                end
				x0_valid = 1'b0;
				y0_valid = 1'b0;
				x1_valid = 1'b0;
				y1_valid = 1'b0;
				color_valid = 1'b0;
				le_trigger = 1'b0;
            end
            32'h80000004:
            begin
                din = 8'bx;
                din_valid = 1'b0;
                if (1'b1 == IO_recv && 1'b0 == IO_trans[0])
                begin
                    io_out = {24'b0, dout};
                    dout_ready = 1'b1;
                end
                else
                begin
                    io_out = 32'bx;
                    dout_ready = 1'b0;
                end
				x0_valid = 1'b0;
				y0_valid = 1'b0;
				x1_valid = 1'b0;
				y1_valid = 1'b0;
				color_valid = 1'b0;
				le_trigger = 1'b0;
            end
            32'h80000008:
            begin
                io_out = 32'bx;
                dout_ready = 1'b0;
                if (1'b1 == IO_trans[0])
                begin
                    case (Addr[1:0])
                        2'b00:din = rd2[7:0];
                        2'b01:din = rd2[15:8];
                        2'b10:din = rd2[23:16];
                        2'b11:din = rd2[31:24];
                        default:din = 8'bx;
                    endcase
                    din_valid = 1'b1;
                end
                else
                begin
                    din = 8'bx;
                    din_valid = 1'b0;
                end
				x0_valid = 1'b0;
				y0_valid = 1'b0;
				x1_valid = 1'b0;
				y1_valid = 1'b0;
				color_valid = 1'b0;
				le_trigger = 1'b0;
            end
            32'h80000010:
            begin
                din = 8'bx;
                din_valid = 1'b0;
                dout_ready = 1'b0;
                io_out = cycles;
				x0_valid = 1'b0;
				y0_valid = 1'b0;
				x1_valid = 1'b0;
				y1_valid = 1'b0;
				color_valid = 1'b0;
				le_trigger = 1'b0;
            end
            32'h80000014:
            begin
                din = 8'bx;
                din_valid = 1'b0;
                dout_ready = 1'b0;
                io_out = instructions;
				x0_valid = 1'b0;
				y0_valid = 1'b0;
				x1_valid = 1'b0;
				y1_valid = 1'b0;
				color_valid = 1'b0;
				le_trigger = 1'b0;
            end
			32'h80000028: 
            begin
				din = 8'bx;
                io_out = 32'hxxxxxxxx;
                dout_ready = 1'b0;
                din_valid = 1'b0;
				if (opcode ==`OPC_STORE) 
                begin
				color = {8'b0, rd2[23:0]};
				color_valid = 1'b1;
				end 
                else 
                begin
					color_valid = 1'b0;
				end
				x0_valid = 1'b0;
				y0_valid = 1'b0;
				x1_valid = 1'b0;
				y1_valid = 1'b0;
				le_trigger = 1'b0;
			end
			32'h80000030: 
            begin
				din = 8'bx;
                io_out = 32'hxxxxxxxx;
                dout_ready = 1'b0;
                din_valid = 1'b0;
				if (opcode == `OPC_STORE) 
                begin
				point = rd2[9:0];
				x0_valid = 1'b1;
				end 
                else 
                begin
				x0_valid = 1'b0;
				end
				y0_valid = 1'b0;
				x1_valid = 1'b0;
				y1_valid = 1'b0;
				color_valid = 1'b0;
				le_trigger = 1'b0;
			end
			32'h80000034: 
            begin
				din = 8'bx;
                io_out = 32'hxxxxxxxx;
                dout_ready = 1'b0;
                din_valid = 1'b0;
				if (opcode == `OPC_STORE) 
                begin
				point = rd2[9:0];
				y0_valid = 1'b1;
				end 
                else 
                begin
				y0_valid = 1'b0;
				end
				x0_valid = 1'b0;
				x1_valid = 1'b0;
				y1_valid = 1'b0;
				color_valid = 1'b0;
				le_trigger = 1'b0;
			end
			32'h80000038: 
            begin
				din = 8'bx;
                io_out = 32'hxxxxxxxx;
                dout_ready = 1'b0;
                din_valid = 1'b0;
				if (opcode == `OPC_STORE) 
                begin
				point = rd2[9:0];
				x1_valid = 1'b1;
				end 
                else 
                begin
				x1_valid = 1'b0;
				end
				x0_valid = 1'b0;
				y0_valid = 1'b0;
				y1_valid = 1'b0;
				color_valid = 1'b0;
				le_trigger = 1'b0;
			end
			32'h8000003c: 
            begin
				din = 8'bx;
                io_out = 32'hxxxxxxxx;
                dout_ready = 1'b0;
                din_valid = 1'b0;
				if (opcode == `OPC_STORE) 
                begin
				point = rd2[9:0];
				y1_valid = 1'b1;
				end 
                else 
                begin
				y1_valid = 1'b0;
				end
				x0_valid = 1'b0;
				y0_valid = 1'b0;
				x1_valid = 1'b0;
				color_valid = 1'b0;
				le_trigger = 1'b0;
			end
			32'h80000040: 
            begin
				din = 8'bx;
                io_out = 32'hxxxxxxxx;
                dout_ready = 1'b0;
                din_valid = 1'b0;
				if (opcode == `OPC_STORE) 
                begin
				point = rd2[9:0];
				x0_valid = 1'b1;
				le_trigger = 1'b1;
				end 
                else 
                begin
				x0_valid = 1'b0;
				le_trigger = 1'b0;
				end
				y0_valid = 1'b0;
				x1_valid = 1'b0;
				y1_valid = 1'b0;
				color_valid = 1'b0;
			end
			32'h80000044: 
            begin
				din = 8'bx;
                io_out = 32'hxxxxxxxx;
                dout_ready = 1'b0;
                din_valid = 1'b0;
				if (opcode == `OPC_STORE) 
                begin
				point = rd2[9:0];
				y0_valid = 1'b1;
				le_trigger = 1'b1;
				end 
                else 
                begin
				y0_valid = 1'b0;
				le_trigger = 1'b0;
				end
				x0_valid = 1'b0;		
				x1_valid = 1'b0;
				y1_valid = 1'b0;
				color_valid = 1'b0;
			end
			32'h80000048: 
            begin
				din = 8'bx;
                io_out = 32'hxxxxxxxx;
                dout_ready = 1'b0;
                din_valid = 1'b0;
				if (opcode == `OPC_STORE) 
                begin
				point = rd2[9:0];
				x1_valid = 1'b1;
				le_trigger = 1'b1;
				end 
                else 
                begin
				x1_valid = 1'b0;
				le_trigger = 1'b0;
				end
				x0_valid = 1'b0;
				y0_valid = 1'b0;
				y1_valid = 1'b0;
				color_valid = 1'b0;		
			end
			32'h8000004c: 
            begin
				din = 8'bx;
                io_out = 32'hxxxxxxxx;
                dout_ready = 1'b0;
                din_valid = 1'b0;
				if (opcode == `OPC_STORE) 
                begin
				point = rd2[9:0];
				y1_valid = 1'b1;
				le_trigger = 1'b1;
				end 
                else 
                begin
				le_trigger = 1'b0;
				y1_valid = 1'b0;
				end
				x0_valid = 1'b0;
				y0_valid = 1'b0;
				x1_valid = 1'b0;
				color_valid = 1'b0;
			end
			32'h8000001c:
			begin
				din = 8'bx;
				if (opcode == `OPC_LOAD) 
                begin
                io_out = 32'h00000001;
				end 
                else 
                begin
				io_out = 32'hx;
				end
                dout_ready = 1'b0;
                din_valid = 1'b0;
				y1_valid = 1'b0;
				x0_valid = 1'b0;
				y0_valid = 1'b0;
				x1_valid = 1'b0;
				color_valid = 1'b0;
				le_trigger = 1'b0;
			end
			32'h80000024:
			begin
				din = 8'bx;
				if (opcode == `OPC_LOAD) 
                begin
                io_out = {31'h00000000, line_ready};
				end 
                else 
                begin
				io_out = 32'hx;
				end
                dout_ready = 1'b0;
                din_valid = 1'b0;
				y1_valid = 1'b0;
				x0_valid = 1'b0;
				y0_valid = 1'b0;
				x1_valid = 1'b0;
				color_valid = 1'b0;
				le_trigger = 1'b0;
			end
            default:
            begin
                din = 8'bx;
                io_out = 32'hxxxxxxxx;
                dout_ready = 1'b0;
                din_valid = 1'b0;
				x0_valid = 1'b0;
				y0_valid = 1'b0;
				x1_valid = 1'b0;
				y1_valid = 1'b0;
				color_valid = 1'b0;
				le_trigger = 1'b0;
            end
        endcase
    end

endmodule
