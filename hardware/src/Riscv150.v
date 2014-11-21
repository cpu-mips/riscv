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
   reg [31:0] 	   inst_final,a,out_write, forwarded, val, Data_UART, inst_mem_out, rd2_or_forwarded;
   wire [31:0] 	   inst, out, imm, Dmem_out, Proc_Mem_Out, rd1, rd2, UART_out, mem_in, b;
   reg [31:0]       inst_bios_imem, out_bios_dmem;
   reg [31:0] 	   PC, PC_next, next_PC_execute, PC_execute, next_PC_write, PCJAL, AIUPC_imm;
   reg [31:0] 	   PC_imm, AIUPC_out, JALR_data, Dmem_UART_Out;
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
   reg [1:0]       dest_write;
   wire [3:0] 	   aluop;
   reg 		   CWE3,noop_final, uart_recv_write, isJAL_write;
   wire 	   noop, zero, lui2,ALUSrcB2, diverge, isJAL, isJALR, uart_recv, CWE2, delayW, ena_hardwire, select_bios, select_bios_X;
   wire [3:0] 	   imem_enable, dmem_enable;
   wire [11:0] 	   addr;
   
   parameter NOP=32'd19;
   assign enaX = ~(delayW);
   assign addr = out[13:2];
   assign ena_hardwire = 1;
   assign b = (ALUSrcB2) ? imm : rd2_or_forwarded; 
   assign select_bios = (PC[31:28] == 4'b0100)?1:0;
   assign select_bios_X = (mem_in[31:28] == 4'b0100 && ~dmem_enable)?1:0;
    // Instantiate the instruction memory here (checkpoint 1 only)
   imem_blk_ram imem(.clka(clk),
		     .ena(enaX),
		     .wea(imem_enable),
		     .addra(addr),
		     .dina(mem_in),
		     .clkb(clk),
		     .addrb(PC[13:2]),
		     .doutb(inst));
    // Instantiate the data memory here (checkpoint 1 only)
   dmem_blk_ram dmem(.clka(clk),
           .ena(ena_hardwire),
           .wea(dmem_enable),
           .addra(addr),
           .dina(mem_in),
           .douta(Dmem_out));
   bios_mem bios(.clka(clk),
           .ena(enaX),
           .addra(PC[13:2]),
           .douta(inst_bios),
	   .clkb(clk),
           .enb(ena_hardwire),
           .addrb(mem_in),
           .doutb(Bios_out));
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
   IOInterface io(.rd2(mem_in),
		  .Addr(out),
		  .IO_trans(uart_trans),
		  .IO_recv(uart_recv),
		  .Clock(clk),
		  .Reset(rst),
                  .FPGA_Sin(FPGA_SERIAL_RX),
                  .FPGA_Sout(FPGA_SERIAL_TX),
		  .Received(UART_out));
   MemoryProc memoryproc(.Mem(Dmem_UART_Out),
			 .Opcode(opcodew),
			 .Funct3(funct3_write),
			 .Address(forwarded),
			 .Proc_Mem(Proc_Mem_Out));
   
   MemControl memcontrol(.Opcode(opcodex),
			 .Funct3(funct3),
			 .A(out),
             .rd2(rd2_or_forwarded),
             .haz_ena(enaX),
			 .Dmem_enable(dmem_enable),
			 .Imem_enable(imem_enable),
			 .Io_trans(uart_trans),
			 .Io_recv(uart_recv),
             .shifted_rd2(mem_in));
   
   HazardController hazard(.OpcodeW(opcodew), 
			   .OpcodeX(opcodex), 
			   .rd(rd_write), 
			   .rs1(rs1), 
			   .rs2(rs2), 
			   .diverge(diverge), 
                           .PC_X(PC_execute),
                           .PC_W(AIUPC_imm),
			   .CWE2(CWE2),
			   .ForwardA(FA), 
			   .ForwardB(FB), 
			   .delayW(delayW),
			   .noop(noop)
			   );
  
   ImmController immcontroller(.Opcode(opcodex), 
			       .immA(immA), 
			       .immB(immB), 
			       .immC(immC), 
			       .immD(immD), 
			       .imm(imm));
   Splitter splitter(.Instruction(inst_final), 
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
		   .Lui(lui2),
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
       if (~stall)
       begin
          if (enaX) 
          begin
              // Fetch stage
              if (rst) 
              begin
                  PC <= 12'b0;
              end
              else if (diverge)
              begin
                PC <= PCJAL;
              end
              else 
              begin
                  PC <= PC + 4;
              end

              // Execute stage
              next_PC_execute <= PC + 4;
              PC_execute<=PC;
              noop_final<=noop;
          end
          else
          begin
              PC <= PC_execute;
              next_PC_execute <= next_PC_execute;
              PC_execute <= PC_execute;
              noop_final <= noop;
          end

          // Writeback stage
          isJAL_write <= isJAL;
          dest_write<=dest;
          uart_recv_write <= uart_recv; 
          funct3_write <= funct3;
          out_write<=out;
          opcodew <= opcodex;
          next_PC_write <= next_PC_execute;
          AIUPC_imm <= PC_execute;
          forwarded<=out;
          rd_write <=rd;
          CWE3<=CWE2;
      end
   end 
   
   always @ (*) 
   begin

      //Execute Stage
      inst_bios_imem = (select_bios) ? inst_bios:inst;
      inst_final = (noop_final)? NOP:inst_bios_imem;
      PC_imm = $signed(PC_execute) + $signed(imm<<1);
      //PCJAL = (isJALR) ? {out[13:1], 1'b0}  : PC_imm[13:0];
      PCJAL = (isJALR) ? {out[31:1], 1'b0}  : PC_imm;
      if (FA)
      begin
          a = forwarded;
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
          rd2_or_forwarded = forwarded;
      end
      else
      begin
          rd2_or_forwarded = rd2;
      end


      //Writeback Stage
      out_bios_dmem = (select_bios_X) ? Bios_out : Dmem_out;
      Dmem_UART_Out = (uart_recv_write) ? UART_out : out_bios_dmem;
      AIUPC_out = $signed(AIUPC_imm) + $signed(forwarded);
      //JALR_data = (isJAL_write) ? {18'b0, next_PC_write} : AIUPC_out;
      JALR_data = (isJAL_write) ?  next_PC_write : AIUPC_out;
      case (dest_write)
          2'b00: val = forwarded;
          2'b01: val = Proc_Mem_Out;
          2'b10: val = JALR_data;
          default: val = 32'bx;
      endcase
   end
endmodule
