/**
 * Top-level module for the RISCV processor.
 * This should contain instantiations of your datapath and control unit.
 * For CP1, the imem and dmem should be instantiated in this top-level module.
 * For CP2 and CP3, the memories are moved to a different module (Memory150),
 * and connected to the datapath via memory ports in the RISC I/O interface.
 *
 * CS150 Fall 14. Template written by Simon Scott.
 */
`include "Opcode.vh"
module Riscv150(
    input clk,
    input rst,
    input stall,

    // Ports for UART that go off-chip to UART level shifter
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX

    // Memory system ports
    // Only used for checkpoint 2 and 3
`ifdef CS150_CHKPNT_2_OR_3
    ,
    output [31:0] dcache_addr,
    output [31:0] icache_addr,
    output [3:0] dcache_we,
    output [3:0] icache_we,
    output dcache_re,
    output icache_re,
    output [31:0] dcache_din,
    output [31:0] icache_din,
    input [31:0] dcache_dout,
    input [31:0] instruction
`endif

    // Graphics ports
    // Only used for checkpoint 3
`ifdef CS150_CHKPNT_3
    ,
    output [31:0]  bypass_addr,
    output [31:0]  bypass_din,
    output [3:0]   bypass_we,

    input          filler_ready,
    input          line_ready,
    output  [23:0] filler_color,
    output         filler_valid,
    output  [31:0] line_color,
    output  [9:0]  line_point,
    output         line_color_valid,
    output         line_x0_valid,
    output         line_y0_valid,
    output         line_x1_valid,
    output         line_y1_valid,
    output         line_trigger
`endif
);
   reg [31:0] 	   inst, a,out_write, b, forwarded, val, dmem_out, Data_UART, inst_mem_out, inst_fetch;
   wire [31:0] 	   out, imm, Dmem_out, Proc_Mem_Out, inst_fetch_wire, rd1, rd2, UART_out;
   reg [11:0] 	   PC, PC_next, next_PC_execute, PC_execute, next_PC_write, PCJAL;
   reg [31:0] 	   PC_imm, AIUPC_imm, AIUPC_out, JALR_data, Dmem_UART_Out;
   wire [19:0] 	   immA;
   reg [6:0] 	   opcodew;
   wire [6:0] 	   opcodex, funct7, immC;
   wire [4:0] 	   rs1, rs2;
   wire [11:0] 	   immB;
   reg [4:0] 	   rd_write;
   wire [4:0] 	   immD;
   wire [4:0] 	   rd;
   wire [3:0] 	   uart_trans;
   wire [2:0] 	   funct3;
   reg [2:0] 	   funct3_write;
   wire [1:0] 	   dest;
   wire [3:0] 	   aluop;
   reg 		   CWE2, CWE3;
   wire 	   zero, pcdelay, lui2, pass2,ALUSrcB2, diverge, isJAL, isJALR, uart_recv;
   wire [3:0] 	   imem_enable, dmem_enable;
   wire [11:0] 	   rd2_mem;

   assign ena_hardwire = 1;
   assign rd2_mem = rd2[13:2];

    // Instantiate the instruction memory here (checkpoint 1 only)
   imem_blk_ram imem(.clka(clk),
		     .ena(ena_hardwire),
		     .wea(imem_enable),
		     .addra(rd2_mem),
		     .dina(rd2),
		     .clkb(clk),
		     .addrb(PC),
		     .doutb(inst_fetch_wire));
    // Instantiate the data memory here (checkpoint 1 only)
   dmem_blk_ram dmem(.clka(clk),
           .ena(ena_hardwire),
           .wea(dmem_enable),
           .addra(rd2_mem),
           .dina(rd2),
           .douta(Dmem_out));
   RegFile regfile(.clk(clk),
		   .we(CWE3),
		   .ra1(rs1),
		   .ra2(rs2),
		   .wa(rd_write),
		   .wd(val),
		   .rd1(rd1),
		   .rd2(rd2));
   
    // Instantiate your control unit here
   ALU alu(.A(a), 
	   .B(b), 
	   .ALUop(aluop), 
	   .Out(out), 
	   .Zero(zero));
   IOInterface io(.rd2(rd2),
		  .Addr(out),
		  .IO_trans(uart_trans),
		  .IO_recv(uart_recv),
		  .Clock(clk),
                  .FPGA_Sin(FPGA_Serial_Rx),
                  .FPGA_Sout(FPGA_Serial_Tx),
		  .Received(UART_out));
   MemoryProc memoryproc(.Mem(Dmem_UART_Out),
			 .Opcode(opcodew),
			 .Funct3(funct3_write),
			 .Address(forwarded),
			 .Proc_Mem(Proc_Mem_Out));
   
   MemControl memcontrol(.Opcode(opcodex),
			 .Funct3(funct3),
			 .A(out),
			 .Dmem_enable(dmem_enable),
			 .Imem_enable(imem_enable),
			 .Io_trans(uart_trans),
			 .Io_recv(uart_recv));
   
   HazardController hazard(.stall(stall), 
			   .OpcodeW(opcodew), 
			   .OpcodeX(opcodex), 
			   .rd(rd), 
			   .rs1(rs1), 
			   .rs2(rs2), 
			   .isZero(diverge), 
			   .CWE2(cwe2),
			   .noop(noop),
			   .ForwardA(FA), 
			   .ForwardB(FB), 
			   .PCDelay(pcdelay));
  
   ImmController immcontroller(.Opcode(opcodex), 
			       .immA(immA), 
			       .immB(immB), 
			       .immC(immC), 
			       .immD(immD), 
			       .imm(imm));
   Splitter splitter(.Instruction(inst), 
		     .Opcode(opcodex), 
		     .Funct3(funct3), 
		     .Funct7(funct7), 
		     .Rs1(rs1), 
		     .Rs2(rs2),
		     .Rd(rd), 
		     .UTypeImm(immA), 
		     .ITypeImm(immB), 
		     .STypeImm1(immD), 
		     .STypeImm2(immC));
   Control control(.Opcode(opcodex),
		   .Funct3(funct3),
		   .Funct7(funct7),
		   .Stall(stall),
		   .Lui(lui2),
		   .Pass(pass2),
		   .ALUop(aluop),
		   .ALUSrc2(ALUSrcB2),
		   .Dest(dest),
		   .Jal(isJAL),
		   .Jalr(isJALR)
		   );
   BranchControl branchcontrol(.Opcode(opcodex), 
			       .Funct3(funct3), 
			       .ALUOut(out),
			       .Zero(zero),
			       .Diverge(diverge));
   
   
    // Instantiate your datapath here
   always @ (posedge clk) 
   begin
      // Fetch stage
      PC<=PC_next;
      
      // Execute stage
      inst<=inst_fetch_wire;
      next_PC_execute <= PC+4;
      PC_execute<=PC;

      // Writeback stage
      funct3_write <= funct3;
      out_write<=out;
      opcodew <= opcodex;
      next_PC_write <= next_PC_execute;
      AIUPC_imm <= PC_imm;
      forwarded<=out;
      rd_write <=rd;
      CWE3<=CWE2;
   end 
   
   always @ (*) 
   begin
      // Fetch Stage
      if (rst)
      begin
          PC_next = 12'b0;
      end
      else if (diverge)
      begin
          PC_next = PCJAL;
      end
      else if (pcdelay)
      begin
          PC_next = PC;
      end
      else
      begin
          PC = PC + 4;
      end
      inst_fetch_wire = (noop) ? `OPC_NOOP : inst_fetch_wire;

      //Execute Stage
      PC_imm = imm + PC_execute;
      PCJAL = (isJAL) ? (out & 12'b111111111110) : PC_imm;
      if (FA)
      begin
          a = forwarded;
      end
      else if (pass2)
      begin
          a = 32'b0;
      end
      else if (lui2)
      begin
          a = 12;
      end
      else
      begin
          a = rd1;
      end

      if (FB)
      begin
          b = forwarded;
      end
      else if (ALUSrcB2)
      begin
          b = imm;
      end
      else
      begin
          b = rd2;
      end


      //Writeback Stage
      Dmem_UART_Out = (uart_recv) ? UART_out : Dmem_out;
      AIUPC_out = AIUPC_imm + forwarded;
      JALR_data = (isJALR) ? next_PC_write : AIUPC_out;
      Data_UART = (uart_trans) ? UART_out : dmem_out;
      if (dest == 2'b00) 
      begin
          val = forwarded;
      end
      else if (dest == 2'b01) 
      begin
          val = Proc_Mem_Out;
      end
      else if (dest == 2'b10) 
      begin
          val = JALR_data;
      end
      else
      begin
          val = 32'bx;
      end
   end
endmodule
