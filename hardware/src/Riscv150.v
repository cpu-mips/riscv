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
   //NOP signal;
   parameter NOP = 32'd19;

   //Fetch control signals
   wire Fnoop, ena_hardwire, select_bios;

   //Fetch registers    
   reg [31:0] pc, inst_temp; 
   //Fetch wires
   wire [31:0] inst_bios;

   //Execute control signals
   reg Xnoop;
   wire lui, alu_src_b, Xreg_write, Xselect_bios;
   wire [3:0] aluop;
   wire [1:0] Xdest;
   wire [3:0] io_trans;
   wire Xio_recv;
   wire [3:0] imem_enable, dmem_enable;
   wire diverge, Xjal, jalr;

   //Execute registers
   reg [31:0] Xpc, Xnext_pc, jump_vector, inst_or_noop, rd2_or_forwarded, a, b, branch_jal_target;

   //Execute wires
   wire [6:0] Xopcode, funct7;
   wire [2:0] Xfunct3;
   wire [31:0] inst, imm, rd1, rd2, Xalu_out, mem_in; 
   wire zero;
   wire [4:0] rs1, rs2, Xrd;
   wire [31:0] addr;
   wire dmem_read_enable;
   wire [19:0] imm_inA;
   wire [11:0] imm_inB;
   wire [6:0] imm_inC;
   wire [4:0] imm_inD;

   //Writeback control signals
   reg [1:0] Wdest;
   reg Wreg_write, Wio_recv, Wjal;
   wire forward_a, forward_b, delay;
   //Writeback registers
   reg [31:0] 	   Walu_out, rd_val, Waddr, out_bios_dmem;
   reg [31:0] 	   auipc_out, pc_writeback, mem_out;
   reg [31:0] 	   Wnext_pc, Wpc;
   reg [6:0] 	   Wopcode;
   reg [2:0] 	   Wfunct3;
   reg [4:0] 	   Wrd;
   //Writeback wires
   wire [31:0] 	   aligned_mem_out, dmem_out, io_out, Bios_out;
   wire load_haz;
   
   //Fetch wire assignemnts
   assign ena_hardwire = 1;
   assign dmem_read_enable = (addr[31] == 1'b0 && addr[30] == 1'b0 && addr[28] == 1'b1 && Xopcode == `OPC_LOAD) ? 1:0;
   assign select_bios = (pc[31:28] == 4'b0100) ? 1 : 0;
   //Execute wire assignments
   assign load_haz = ~(delay) && ~stall;
   assign Xselect_bios = (Waddr[31:28] == 4'b0100 && Wopcode == `OPC_LOAD) ? 1 : 0;
   //Writeback wire assignments
   assign addr = Xalu_out;

   //Icache wire assignments
   /*assign icache_addr = pc;
   assign icache_we = imem_enable;
   assign icache_re = load_haz;
   assign icache_din = mem_in;
   assign inst=instruction;*/

   //Dcache wire assignments
   assign dcache_addr = {4'b0,addr[27:2],2'b0};
   assign dcache_we = dmem_enable;
   assign dcache_re = dmem_read_enable;
   assign dmem_out = dcache_dout;
   assign dcache_din = mem_in;

    // Instantiate the instruction memory here (checkpoint 1 only)
   imem_blk_ram imem(.clka(clk),
		     .ena(load_haz),
		     .wea(imem_enable),
		     .addra(addr[13:2]),
		     .dina(mem_in),
		     .clkb(clk),
		     .addrb(pc[13:2]),
		     .doutb(inst));

    // Instantiate the data memory here (checkpoint 1 only)
   /*dmem_blk_ram dmem(.clka(clk),
           .ena(ena_hardwire),
           .wea(dmem_enable),
           .addra(addr[13:2]),
           .dina(mem_in),
           .douta(dmem_out));*/

   Splitter splitter(.Instruction(inst_or_noop), 
		     .Opcode(Xopcode), 
		     .Funct3(Xfunct3), 
		     .Funct7(funct7), 
		     .Rs1(rs1), 
		     .Rs2(rs2),
		     .Rd(Xrd), 
		     .UTypeImm(imm_inA), 
		     .ITypeImm(imm_inB), 
		     .STypeImm1(imm_inD), 
		     .STypeImm2(imm_inC));

   bios_mem bios(.clka(clk),
           .ena(load_haz),
           .addra(pc[13:2]),
           .douta(inst_bios),
	   .clkb(clk),
           .enb(ena_hardwire),
           .addrb(addr[13:2]),
           .doutb(Bios_out));
    RegFile regfile(.clk(clk),
		   .we(Wreg_write),
		   .ra1(rs1),
		   .ra2(rs2),
		   .wa(Wrd),
		   .wd(rd_val),
		   .rd1(rd1),
		   .rd2(rd2));
   
   ImmController immcontroller(.Opcode(Xopcode), 
			       .immA(imm_inA), 
			       .immB(imm_inB), 
			       .immC(imm_inC), 
			       .immD(imm_inD), 
			       .imm(imm));

   Control control(.Opcode(Xopcode),
		   .Funct3(Xfunct3),
		   .Funct7(funct7),
		   .Lui(lui),
		   .ALUop(aluop),
		   .ALUSrc2(alu_src_b),
		   .Dest(Xdest),
		   .Jal(Xjal),
		   .Jalr(jalr));

   ALU alu(.A(a), 
	   .B(b), 
	   .ALUop(aluop), 
	   .Out(Xalu_out), 
	   .Zero(zero));

   BranchControl branchcontrol(.Opcode(Xopcode), 
			       .Funct3(Xfunct3), 
			       .ALUOut(Xalu_out),
			       .Zero(zero),
			       .Diverge(diverge));
   
   MemControl memcontrol(.opcode(Xopcode),
			 .funct3(Xfunct3),
			 .addr(Xalu_out),
             .rd2(rd2_or_forwarded),
             .haz_ena(load_haz),
             .pc(Xpc),
             .dmem_en(),
			 .dmem_wr_en(dmem_enable),
			 .imem_wr_en(imem_enable),
			 .io_trans(io_trans),
			 .io_recv(Xio_recv),
             .mem_in(mem_in));
   
   IOInterface io(.rd2(mem_in),
		  .Addr(Xalu_out),
		  .IO_trans(io_trans),
		  .IO_recv(Xio_recv),
		  .Clock(clk),
		  .Reset(rst),
          .FPGA_Sin(FPGA_SERIAL_RX),
          .FPGA_Sout(FPGA_SERIAL_TX),
		  .Received(io_out));

   HazardController hazard(.OpcodeW(Wopcode), 
			   .OpcodeX(Xopcode), 
			   .rd(Wrd), 
			   .rs1(rs1), 
			   .rs2(rs2), 
			   .diverge(diverge), 
               .PC_X(Xpc),
               .PC_W(Wpc),
			   .CWE2(Xreg_write),
			   .ForwardA(forward_a), 
			   .ForwardB(forward_b), 
			   .delayW(delay),
			   .noop(Fnoop));

   MemoryProc memoryproc(.Mem(mem_out),
			 .Opcode(Wopcode),
			 .Funct3(Wfunct3),
			 .Address(Walu_out),
			 .Proc_Mem(aligned_mem_out));
   
   
   always @ (posedge clk) 
   begin
       if (~stall)
       begin
          if (load_haz) 
          begin
              // Fetch stage
              if (rst) 
              begin
                  pc <= 32'h40000000;
              end
              else if (diverge)
              begin
                pc <= jump_vector;
              end
              else 
              begin
                  pc <= pc + 4;
              end

              // Execute stage
              Xnext_pc <= pc + 4;
              Xpc<=pc;
              Xnoop<=Fnoop;
          end
          else
          begin
              pc <= Xpc;
              Xnext_pc <= Xnext_pc;
              Xpc <= Xpc;
              Xnoop <= Fnoop;
          end

          // Writeback stage
          Waddr <= addr;
          Wjal <= Xjal;
          Wdest<=Xdest;
          Wio_recv <= Xio_recv; 
          Wfunct3 <= Xfunct3;
          Walu_out<=Xalu_out;
          Wopcode <= Xopcode;
          Wnext_pc <= Xnext_pc;
          Wpc <= Xpc;
          Wrd <=Xrd;
          Wreg_write<=Xreg_write;
      end
      else
      begin
          pc <= pc;
          Xnext_pc <= Xnext_pc;
          Xpc <= Xpc;
          Xnoop <= Xnoop;
          Waddr <= Waddr;
          Wjal <= Wjal;
          Wdest <= Wdest;
          Wio_recv <= Wio_recv;
          Wfunct3 <= Wfunct3;
          Walu_out <= Walu_out;
          Wopcode <= Wopcode;
          Wnext_pc <= Wnext_pc;
          Wpc <= Wpc;
          Wrd <= Wrd;
          Wreg_write <= Wreg_write;
      end
   end 
   
   always @ (*) 
   begin

      //Fetch Stage 
      inst_temp = (select_bios) ? inst_bios:inst;
      inst_or_noop = (Xnoop) ? NOP : inst_temp;

      //Execute Stage
      branch_jal_target = $signed(Xpc) + $signed(imm<<1);
      jump_vector = (jalr) ? {Xalu_out[31:1], 1'b0}  : branch_jal_target;
      rd2_or_forwarded = (forward_b) ? Walu_out : rd2;
      b = (alu_src_b) ? imm : rd2_or_forwarded; 

      if (forward_a)
      begin
          a = Walu_out;
      end
      else if (lui)
      begin
          a = 12;
      end
      else
      begin
          a = rd1;
      end


      //Writeback Stage
      out_bios_dmem = (Xselect_bios) ? Bios_out : dmem_out;
      mem_out = (Wio_recv) ? io_out : out_bios_dmem;
      auipc_out = $signed(Wpc) + $signed(Walu_out);
      pc_writeback = (Wjal) ? Wnext_pc : auipc_out;

      case (Wdest)
          2'b00: rd_val = Walu_out;
          2'b01: rd_val = aligned_mem_out;
          2'b10: rd_val = pc_writeback;
          default: rd_val = 32'bx;
      endcase
   end
endmodule
