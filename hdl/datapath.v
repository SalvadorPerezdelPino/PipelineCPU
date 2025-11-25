// Camino de datos de la CPU
module datapath #(
	parameter DATA_WIDTH = 16,
	parameter ADDR_WIDTH = 8
	) (
	input wire clk, 
	input wire reset,
	input wire enable_pc, enable_if,
	input wire we3, we_flags, s_mem_in, s_addr, s_pc,
	input wire [2:0] op_alu,
	input wire [1:0] s_wd3,
	input wire read, write, flush_if,
	output wire [9:0] pc,
	output wire [5:0] opcode,
	output wire zero, sign, carry, overflow, 
	output wire mem_read, mem_write,
	output wire [19:0] bus_addr,
	output wire [15:0] bus_data,
	output wire stall
	);
	
	wire z_alu, s_alu, c_alu, o_alu;
	wire [9:0] next_pc, inc_pc, jmp_pc;
	wire [31:0] instruction;
	
	wire [3:0] dr_ra1, dr_ra2, dr_wa3, ex_wa3, mem_wa3, wb_wa3;
	wire [15:0] dr_rd1, dr_rd2, ex_rd1, ex_rd2, mem_rd1, mem_rd2, mem_wd3, wb_wd3;
	wire [15:0] dr_inm, ex_inm, mem_inm, ex_alu_res, mem_alu_res, mem_data_in;
	wire ex_we3, mem_we3, wb_we3;
	wire [2:0] ex_op_alu;
	wire [1:0] ex_s_wd3, mem_s_wd3;
	
	wire [15:0] mem_data;
	wire [7:0] dr_short_inm, ex_short_inm, mem_short_inm;
	wire [19:0] if_address, dr_address, ex_address, mem_address;
	wire ex_we_flags;
	wire ex_read, ex_write;
	wire ex_s_mem_in, mem_s_mem_in;
	wire ex_s_addr, mem_s_addr;
	wire ex_s_pc, mem_s_pc;
	wire [9:0] dr_jmp_addr, ex_jmp_addr, mem_jmp_addr;
	wire nop = (opcode == 6'b000000);
	
	assign stall = (reset) ? 1'b0 :  ((((dr_ra1 == ex_wa3) && ex_we3) || ((dr_ra1 == mem_wa3) && mem_we3) || ((dr_ra1 == wb_wa3) && wb_we3)) && (dr_ra1 != 0)) || 
												((((dr_ra2 == ex_wa3) && ex_we3) || ((dr_ra2 == mem_wa3) && mem_we3) || ((dr_ra2 == wb_wa3) && wb_we3)) && (dr_ra2 != 0));
	
	// ----------INSTRUCTION FETCH------------
	registro #(10) program_counter (
		.clk		(clk),
		.reset	(reset),
		.d			(next_pc),
		.enable	(enable_pc),
		.q			(pc)
	);
	
	sum increment_pc (
		.a	(pc),
		.b	(10'b1),
		.y	(inc_pc)
	);

	mux2 #(10) mux_pc ( // Asumimos que las flags siempre se han resuelto antes con nops
		.d0	(inc_pc),
		.d1	(dr_jmp_addr),
		.s		(s_pc),
		.y		(next_pc)
	);
	
	program_memory pm (
		.clk	(clk),
		.addr		(pc),
		.inst	(instruction)
	);
	
	
	if_dr if_dr0 (
		.clk				(clk),
		.reset			(reset),
		.enable			(enable_if),
		.flush_if		(flush_if),
		.if_ra1			(instruction[11:8]),
		.if_ra2			(instruction[7:4]),
		.if_wa3			(instruction[3:0]),
		.if_opcode		(instruction[31:26]),
		.if_inm			(instruction[19:4]),
		.if_short_inm	(instruction[7:0]),
		.if_address		(instruction[27:8]),
		.if_jmp_addr	(instruction[9:0]),
		.dr_ra1			(dr_ra1),
		.dr_ra2			(dr_ra2),
		.dr_wa3			(dr_wa3),
		.dr_opcode		(opcode),
		.dr_inm			(dr_inm),
		.dr_short_inm	(dr_short_inm),
		.dr_address		(dr_address),
		.dr_jmp_addr	(dr_jmp_addr)
	);
	
	// ----------DECODE/REGISTERS------------
	
	regfile #(16) register_bank (
		.clk	(clk),
		.we3	(wb_we3),
		.ra1	(dr_ra1),
		.ra2	(dr_ra2),
		.wa3	(wb_wa3),
		.wd3	(wb_wd3),
		.rd1	(dr_rd1),
		.rd2	(dr_rd2)
	);
	
	
	
	dr_ex dr_ex0 (
		.clk				(clk),
		.reset			(reset),
		.dr_rd1			(dr_rd1),
		.dr_rd2			(dr_rd2),
		.dr_wa3			(dr_wa3),
		.dr_inm			(dr_inm),
		.dr_op_alu		(op_alu),
		.dr_s_wd3		(s_wd3),
		.dr_we3			(we3),
		.dr_short_inm	(dr_short_inm),
		.dr_address		(dr_address),
		.dr_read			(read),
		.dr_write		(write),
		.dr_s_mem_in	(s_mem_in),
		.dr_s_addr		(s_addr),
		.dr_s_pc			(s_pc),
		.dr_jmp_addr	(dr_jmp_addr),
		.dr_we_flags	(we_flags),
		.ex_rd1			(ex_rd1),
		.ex_rd2			(ex_rd2),
		.ex_wa3			(ex_wa3),
		.ex_inm			(ex_inm),
		.ex_op_alu		(ex_op_alu),
		.ex_s_wd3		(ex_s_wd3),
		.ex_we3			(ex_we3),
		.ex_short_inm	(ex_short_inm),
		.ex_address		(ex_address),
		.ex_read			(ex_read),
		.ex_write		(ex_write),
		.ex_s_mem_in	(ex_s_mem_in),
		.ex_s_addr		(ex_s_addr),
		.ex_s_pc			(ex_s_pc),
		.ex_jmp_addr	(ex_jmp_addr),
		.ex_we_flags	(ex_we_flags)
	);
	
	// ----------EXECUTION------------
	alu alu0 (
		.a			(ex_rd1),
		.b			(ex_rd2),
		.op_alu	(ex_op_alu),
		.y			(ex_alu_res),
		.zero		(z_alu),
		.sign		(s_alu),
		.carry	(c_alu),
		.overflow(o_alu)
	);
	
	ffd flag_zero (
		.clk		(clk),
		.reset	(reset),
		.d			(z_alu),
		.carga	(ex_we_flags),
		.q			(zero)
	);
	
	ffd flag_sign (
		.clk		(clk),
		.reset	(reset),
		.d			(s_alu),
		.carga	(ex_we_flags),
		.q			(sign)
	);
	
	ffd flag_carry (
		.clk		(clk),
		.reset	(reset),
		.d			(c_alu),
		.carga	(ex_we_flags),
		.q			(carry)
	);
	
	ffd flag_overflow (
		.clk		(clk),
		.reset	(reset),
		.d			(o_alu),
		.carga	(ex_we_flags),
		.q			(overflow)
	);
	
	ex_mem ex_mem0 (
		.clk				(clk),
		.reset			(reset),
		.ex_alu_res 	(ex_alu_res),
		.ex_inm			(ex_inm),
		.ex_wa3			(ex_wa3),
		.ex_s_wd3		(ex_s_wd3),
		.ex_we3			(ex_we3),
		.ex_rd1			(ex_rd1),
		.ex_rd2			(ex_rd2),
		.ex_short_inm	(ex_short_inm),
		.ex_address		(ex_address),
		.ex_read			(ex_read),
		.ex_write		(ex_write),
		.ex_s_mem_in	(ex_s_mem_in),
		.ex_s_addr		(ex_s_addr),
		.ex_s_pc			(ex_s_pc),
		.ex_jmp_addr	(ex_jmp_addr),
		.mem_alu_res 	(mem_alu_res),
		.mem_inm			(mem_inm),
		.mem_wa3			(mem_wa3),
		.mem_s_wd3		(mem_s_wd3),
		.mem_we3			(mem_we3),
		.mem_rd1			(mem_rd1),
		.mem_rd2			(mem_rd2),
		.mem_short_inm	(mem_short_inm),
		.mem_address	(mem_address),
		.mem_read		(mem_read),
		.mem_write		(mem_write),
		.mem_s_mem_in	(mem_s_mem_in),
		.mem_s_addr		(mem_s_addr),
		.mem_s_pc		(mem_s_pc),
		.mem_jmp_addr	(mem_jmp_addr)
	);
	
	// ----------MEMORY------------
	
	mux2 #(16) mem_data_selector (
		.d0	(mem_rd2), // El contenido de un registro
		.d1	({8'b0, mem_short_inm}), // El inmediato reducido
		.s		(mem_s_mem_in),
		.y		(mem_data_in)
	);
	
	mux2 #(20) mux_addr (
		.d0	(mem_address),
		.d1	({4'b0, mem_rd1}),
		.s		(mem_s_addr),
		.y		(bus_addr)
	);
	
	/*memdata memory (
		.clk			(clk),
		.data_in		(mem_data_in),
		.address		(bus_addr[8:0]), // Expandible a más memoria
		.data_out	(mem_data_out),
		.we			(~bus_addr[19] & mem_write) // Solo escribe si está en la primera mitad del direccionamiento
	);*/
	
	cd_io cd_io0 (
		.bus_data		(bus_data),
		.data_from_cpu	(mem_data_in),
		.data_to_cpu	(mem_data),
		.write			(mem_write),
		.read			   (mem_read)
	);
	
	assign bus_data = (mem_write) ? mem_data_in : 16'bz;
	
	/*mux2 #(16) mux_device (
		.d0	(mem_data_out),
		.d1	(bus_data),
		.s		(bus_addr[19]),
		.y		(mem_data)
	);*/
	
	mux4 #(16) mux_wd3 (
		.d0	(mem_alu_res), // de la ALU
		.d1	(mem_inm),		// un inmediato (LI)
		.d2	(mem_data),		// de memoria o periférico	 (LW)
		.d3	(),
		.s		(mem_s_wd3), 
		.y		(mem_wd3)
	);
	
	mem_wb mem_wb0 (
		.clk		(clk),
		.reset	(reset),
		.mem_wa3	(mem_wa3),
		.mem_wd3	(mem_wd3),
		.mem_we3	(mem_we3),
		.wb_wa3	(wb_wa3),
		.wb_wd3	(wb_wd3),
		.wb_we3	(wb_we3)
	);
	
	// ----------WRITE BACK------------
	// En esta etapa no hay que hacer nada más, todo está seleccionado de antes
	
endmodule
