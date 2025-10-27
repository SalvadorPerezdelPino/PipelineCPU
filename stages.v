// INSTRUCTION FETCH A DECODIFICACIÓN
module if_dr (
	input wire clk, enable, reset,
	input wire [3:0] if_ra1, if_ra2, if_wa3, 
	input wire [5:0] if_opcode, 
	input wire [15:0] if_inm,
	input wire [7:0] if_short_inm,
	input wire [19:0] if_address,
	input wire [9:0] if_jmp_addr,
	input wire flush_if,
	output reg [3:0] dr_ra1, dr_ra2, dr_wa3, 
	output reg [5:0] dr_opcode, 
	output reg [15:0] dr_inm,
	output reg [7:0] dr_short_inm,
	output reg [19:0] dr_address,
	output reg [9:0] dr_jmp_addr
	);
	
	always @(posedge clk) begin
		if (flush_if || reset) begin
			dr_opcode <= 6'b0; // NOP
			dr_ra1 <= 0;
			dr_ra2 <= 0;
			dr_wa3 <= 0;
			dr_inm <= 0;
			dr_short_inm <= 0;
			dr_address <= 0;
			dr_jmp_addr <= 0;
		end
		else if (enable) begin
			dr_ra1 <= if_ra1;
			dr_ra2 <= if_ra2;
			dr_wa3 <= if_wa3;
			dr_opcode <= if_opcode;
			dr_inm <= if_inm;
			dr_short_inm <= if_short_inm;
			dr_address <= if_address;
			dr_jmp_addr <= if_jmp_addr;
		end
	end

endmodule

// DECODIFICACIÓN A EJECUCIÓN
module dr_ex (
	input wire clk, dr_we3, reset,
	input wire [15:0] dr_rd1, dr_rd2, dr_inm,
	input wire [3:0] dr_wa3,
	input wire [2:0] dr_op_alu,
	input wire [1:0] dr_s_wd3,
	input wire [7:0] dr_short_inm,
	input wire [19:0] dr_address,
	input wire [9:0] dr_jmp_addr,
	input wire dr_read, dr_write, dr_s_mem_in, dr_s_addr, dr_s_pc, dr_we_flags,
	output reg ex_we3,
	output reg [15:0] ex_rd1, ex_rd2, ex_inm,
	output reg [3:0] ex_wa3,
	output reg [2:0] ex_op_alu,
	output reg [1:0] ex_s_wd3,
	output reg [7:0] ex_short_inm,
	output reg [19:0] ex_address,
	output reg [9:0] ex_jmp_addr,
	output reg ex_read, ex_write, ex_s_mem_in, ex_s_addr, ex_s_pc, ex_we_flags
	);
	
	always @(posedge clk) begin
		if (reset) begin
			ex_rd1 <= 0;
			ex_rd2 <= 0;
			ex_inm <= 0;
			ex_wa3 <= 0;
			ex_op_alu <= 0;
			ex_s_wd3 <= 0;
			ex_we3 <= 0;
			ex_short_inm <= 0;
			ex_address <= 0;
			ex_read <= 0;
			ex_write <= 0;
			ex_s_mem_in <= 0;
			ex_s_addr <= 0;
			ex_s_pc <= 0;
			ex_jmp_addr <= 0;
			ex_we_flags <= 0;
		end
		else begin
			ex_rd1 <= dr_rd1;
			ex_rd2 <= dr_rd2;
			ex_inm <= dr_inm;
			ex_wa3 <= dr_wa3;
			ex_op_alu <= dr_op_alu;
			ex_s_wd3 <= dr_s_wd3;
			ex_we3 <= dr_we3;
			ex_short_inm <= dr_short_inm;
			ex_address <= dr_address;
			ex_read <= dr_read;
			ex_write <= dr_write;
			ex_s_mem_in <= dr_s_mem_in;
			ex_s_addr <= dr_s_addr;
			ex_s_pc <= dr_s_pc;
			ex_jmp_addr <= dr_jmp_addr;
			ex_we_flags <= dr_we_flags;
		end
	end

endmodule

// EJECUCIÓN A MEMORIA
module ex_mem (
	input wire clk, ex_we3, reset,
	input wire [15:0] ex_alu_res, ex_inm, ex_rd1, ex_rd2,
	input wire [3:0] ex_wa3,
	input wire [1:0] ex_s_wd3,
	input wire [7:0] ex_short_inm,
	input wire [19:0] ex_address,
	input wire [9:0] ex_jmp_addr,
	input wire ex_read, ex_write, ex_s_mem_in, ex_s_addr, ex_s_pc,
	output reg mem_we3,
	output reg [15:0] mem_alu_res, mem_inm, mem_rd1, mem_rd2,
	output reg [3:0] mem_wa3,
	output reg [1:0] mem_s_wd3,
	output reg [7:0] mem_short_inm,
	output reg [19:0] mem_address,
	output reg [9:0] mem_jmp_addr,
	output reg mem_read, mem_write, mem_s_mem_in, mem_s_addr, mem_s_pc
	);

	always @(posedge clk) begin
		if (reset) begin
			mem_alu_res <= 0;
			mem_inm <= 0;
			mem_wa3 <= 0;
			mem_s_wd3 <= 0;
			mem_we3 <= 0;
			mem_short_inm <= 0;
			mem_address <= 0;
			mem_rd1 <= 0;
			mem_rd2 <= 0;
			mem_read <= 0;
			mem_write <= 0;
			mem_s_mem_in <= 0;
			mem_s_addr <= 0;
			mem_s_pc	<= 0;
			mem_jmp_addr <= 0;
		end else begin
			mem_alu_res <= ex_alu_res;
			mem_inm <= ex_inm;
			mem_wa3 <= ex_wa3;
			mem_s_wd3 <= ex_s_wd3;
			mem_we3 <= ex_we3;
			mem_short_inm <= ex_short_inm;
			mem_address <= ex_address;
			mem_rd1 <= ex_rd1;
			mem_rd2 <= ex_rd2;
			mem_read <= ex_read;
			mem_write <= ex_write;
			mem_s_mem_in <= ex_s_mem_in;
			mem_s_addr <= ex_s_addr;
			mem_s_pc	<= ex_s_pc;
			mem_jmp_addr <= ex_jmp_addr;
		end
	end
endmodule

// MEMORIA A WRITE BACK
module mem_wb (
	input wire clk, mem_we3, reset,
	input wire [15:0] mem_wd3,
	input wire [3:0] mem_wa3,
	output reg wb_we3,
	output reg [15:0] wb_wd3,
	output reg [3:0] wb_wa3
	);
	
	always @(posedge clk) begin
		if (reset) begin
			wb_wd3 <= 0;
			wb_wa3 <= 0;
			wb_we3 <= 0;
		end else begin
			wb_wd3 <= mem_wd3;
			wb_wa3 <= mem_wa3;
			wb_we3 <= mem_we3;
		end
	end

endmodule


module flush_ctrl (
    input wire clk, reset,
    input wire flush_if_in,
    input wire flush_dr_in,
    output wire flush_if_out,
    output wire flush_dr_out
);
	wire delay = flush_if_in && flush_dr_in;
	wire jmp_uncond = flush_if_in && ~flush_dr_in;
	
	reg flush_if_reg, flush_dr_reg;

   always @(posedge clk or posedge reset) begin
		if (reset) begin
		   flush_if_reg <= 0;
		   flush_dr_reg <= 0;
		end else begin
		if (jmp_uncond) begin
			flush_if_reg <= 0;
			flush_dr_reg <= 0;
		end else if (delay) begin
			// En el ciclo de delay activo, aplicamos ambos flush
			flush_if_reg <= 1;
			flush_dr_reg <= 1;
		end else begin
			// Caso normal: aplicar flush si uno solo está activo
			flush_if_reg <= flush_if_in;
			flush_dr_reg <= flush_dr_in;
			end
		end
   end
	
	assign flush_if_out = jmp_uncond | flush_if_reg;
	assign flush_dr_out = jmp_uncond | flush_dr_reg;
endmodule

