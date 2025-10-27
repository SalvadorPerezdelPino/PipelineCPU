module cpu #(
	parameter ADDR_WIDTH = 20,
	parameter DATA_WIDTH = 16) (
	input wire clk, reset, 
	output wire [9:0] pc, 
	output wire [5:0] opcode,
	inout wire [DATA_WIDTH-1:0] bus_data, 
	output wire [ADDR_WIDTH-1:0] bus_addr, 
	output wire mem_read, 
	output wire mem_write,
	output reg [DATA_WIDTH-1:0] solution,
	output wire halted
);
	 
	wire z, s;
	wire s_addr, s_pc;
	wire [1:0] s_wd3, dr_s_wd3, ex_s_wd3;
	wire we3, we_flags, we_alu, we_reg, we_next_pc, we_rmem, we_wd3;
	wire dr_we3, ex_we3, mem_we3;
	wire enable_pc, enable_if;
	wire [2:0] op_alu, dr_op_alu;
	wire read, write;
	
	wire s_mem_in, stall, flush_if;
	
	control_unit cu1 (
		.opcode 		(opcode), 
	   .z      		(z),
		.s				(s),
		.clk			(clk),
		.reset		(reset),
	   .we3    		(we3), 
		.we_flags	(we_flags),
		.enable_pc	(enable_pc),
		.enable_if	(enable_if),
		.s_wd3		(s_wd3),
		.s_mem_in	(s_mem_in),
		.s_addr		(s_addr),
		.s_pc			(s_pc),
	   .op_alu 		(op_alu),
		.read			(read),
		.write		(write),
		.stall		(stall),
		.flush_if	(flush_if),
		.halted		(halted)
	);

			  
	datapath #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
		) dp1 (
		.clk      	(clk),
		.reset    	(reset),
		.opcode		(opcode),
		.op_alu		(op_alu),
		.pc			(pc),
		.enable_pc	(enable_pc),
		.enable_if	(enable_if),
		.s_wd3		(s_wd3),
		.s_mem_in	(s_mem_in),
		.s_addr		(s_addr),
		.s_pc			(s_pc),
		.we3			(we3),
		.we_flags	(we_flags),
		.z				(z),
		.s				(s),
		.read			(read),
		.write		(write),
		.mem_read	(mem_read),
		.mem_write	(mem_write), // Sincronizados con la etapa en la que se utilizan
		.stall		(stall),
		.bus_addr	(bus_addr),
		.bus_data	(bus_data),
		.flush_if	(flush_if)
	);
	
	always @(posedge clk, posedge reset) begin
		if (reset) begin
			solution <= 0;
		end
		else if (mem_write) begin
			solution <= bus_data;
		end
	end
	
	
endmodule
