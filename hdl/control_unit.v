module control_unit (
	input wire [5:0] opcode, 
	input wire z, s,
	input wire clk,
	input wire reset,
	input wire stall,
	output reg we3, we_flags,
	output reg enable_pc, enable_if,
	output reg s_mem_in, s_addr, s_pc,
	output reg [1:0] s_wd3,
	output reg [2:0] op_alu, 
	output reg read, 
	output reg write,
	output reg flush_if,
	output reg halted
	);

	
	parameter NOP = 6'b000000;
	parameter HALT = 6'b000001;
	parameter ALU = 6'b111???;
	parameter J = 6'b110000;
	parameter JPOS = 6'b110001;
	parameter JAL = 6'b11010?;
	parameter JR = 6'b11011?;
	parameter JZ = 6'b110011;
	parameter JNZ = 6'b110010;
	parameter LI = 6'b10100?;
	parameter LW_ADDR_R = 6'b1011??;
	parameter LW_R_R = 6'b101011;
	parameter SW_R_R = 6'b101010;
	parameter SW_ADDR_R = 6'b1000??;
	parameter STI = 6'b1001??;


	// Señales de control por instrucción
	always @* begin
		if (reset) begin
			s_wd3 <= 2'b00;
			s_mem_in <= 1'b0;
			s_addr <= 1'b0;
			s_pc <= 1'b0;
			we3 <= 1'b0;
			we_flags <= 1'b0;
			op_alu <= 3'b000;
			read <= 1'b0;
			write <= 1'b0;
			flush_if <= 1'b0;
			halted <= 1'b0;
		end
		else if (stall) begin
			enable_pc <= 1'b0;
			enable_if <= 1'b0;
			we3 <= 1'b0;
			we_flags <= 1'b0;
			read <= 1'b0;
			write <= 1'b0;
			flush_if <= 1'b0;
			halted <= 1'b0;
		end
		else begin
			enable_pc <= (opcode != HALT) ? 1'b1 : 1'b0;
			enable_if <= (opcode != HALT) ? 1'b1 : 1'b0;
			halted <= (opcode == HALT) ? 1'b1 : 1'b0;
			casez(opcode)
				NOP: begin 
					s_wd3 <= 2'b00;
					s_mem_in <= 1'b0;
					s_addr <= 1'b0;
					s_pc <= 1'b0;
					we3 <= 1'b0;
					we_flags <= 1'b0;
					op_alu <= 3'b000;
					read <= 1'b0;
					write <= 1'b0;
					flush_if <= 1'b0;
				end
				ALU: begin // ALU
					s_wd3 <= 2'b00;
					s_mem_in <= 1'b0;
					s_addr <= 1'b0;
					s_pc <= 1'b0;
					we3 <= 1'b1;
					we_flags <= 1'b1;
					op_alu <= opcode[2:0];
					read <= 1'b0;
					write <= 1'b0;
					flush_if <= 1'b0;
				end
				J: begin // J
					s_wd3 <= 2'b00;
					s_mem_in <= 1'b0;
					s_addr <= 1'b0;
					s_pc <= 1'b1;
					we3 <= 1'b0;
					we_flags <= 1'b0;
					op_alu <= 3'b000;
					read <= 1'b0;
					write <= 1'b0;
					flush_if <= 1'b1;
				end
				
				JPOS: begin // JPOS
					s_wd3 <= 2'b00;
					s_mem_in <= 1'b0;
					s_addr <= 1'b0;
					s_pc <= ~s && ~z; // PROBAR CON AMBOS
					we3 <= 1'b0;
					we_flags <= 1'b0;
					op_alu <= 3'b000; //don't care
					read <= 1'b0;
					write <= 1'b0;
					flush_if <= ~s && ~z;
				end
				
				JZ: begin // JZ
					s_wd3 <= 2'b00;
					s_mem_in <= 1'b0;
					s_addr <= 1'b0;
					s_pc <= z;
					we3 <= 1'b0;
					we_flags <= 1'b0;
					op_alu <= 3'b000; //don't care
					read <= 1'b0;
					write <= 1'b0;
					flush_if <= z;
				end
				
				JNZ: begin // JNZ
					s_wd3 <= 2'b00;
					s_mem_in <= 1'b0;
					s_addr <= 1'b0;
					s_pc <= ~z;
					we3 <= 1'b0;
					we_flags <= 1'b0;
					op_alu <= 3'b000; // don't care
					read <= 1'b0;
					write <= 1'b0;
					flush_if <= ~z;
				end
				
				LI: begin // LDI
					s_wd3 <= 2'b01;
					s_mem_in <= 1'b0;
					s_addr <= 1'b0;
					s_pc <= 1'b0;
					we3 <= 1'b1;
					we_flags <= 1'b0;
					op_alu <= 3'b000; // don't care
					read <= 1'b0;
					write <= 1'b0;
					flush_if <= 1'b0;
				end
				
				LW_ADDR_R: begin // LD -> carga lo que hay una dirección inmediata en un registro
					s_wd3 <= 2'b10;
					s_mem_in <= 1'b0;
					s_addr <= 1'b0;
					s_pc <= 1'b0;
					we3 <= 1'b1;
					we_flags <= 1'b0;
					op_alu <= 3'b000; // don't care
					read <= 1'b1;
					write <= 1'b0;
					flush_if <= 1'b0;
				end
				
				LW_R_R: begin // LD -> carga lo que hay una dirección DENTRO DE UN REGISTRO en otro registro
					s_wd3 <= 2'b10;
					s_mem_in <= 1'b0;
					s_addr <= 1'b1;
					s_pc <= 1'b0;
					we3 <= 1'b1;
					we_flags <= 1'b0;
					op_alu <= 3'b000; // don't care
					read <= 1'b1;
					write <= 1'b0;
					flush_if <= 1'b0;
				end
				
				SW_R_R: begin // STR de registro a memoria en un registro
					s_wd3 <= 2'b00;
					s_mem_in <= 1'b0;
					s_addr <= 1'b1;
					s_pc <= 1'b0;
					we3 <= 1'b0;
					we_flags <= 1'b0;
					op_alu <= 3'b000; // don't care
					read <= 1'b0;
					write <= 1'b1;
					flush_if <= 1'b0;
				end
				
				SW_ADDR_R: begin // STR
					s_wd3 <= 2'b00;
					s_mem_in <= 1'b0;
					s_addr <= 1'b0;
					s_pc <= 1'b0;
					we3 <= 1'b0;
					we_flags <= 1'b0;
					op_alu <= 3'b000; // don't care
					read <= 1'b0;
					write <= 1'b1;
					flush_if <= 1'b0;
				end
				
				STI: begin // STI
					s_wd3 <= 2'b00;
					s_mem_in <= 1'b1;
					s_addr <= 1'b0;
					s_pc <= 1'b0;
					we3 <= 1'b0;
					we_flags <= 1'b0;
					op_alu <= 3'b000; // don't care
					read <= 1'b0;
					write <= 1'b1;
					flush_if <= 1'b0;
				end
				
				default begin
					s_wd3 <= 2'b00;
					s_mem_in <= 1'b0;
					s_addr <= 1'b0;
					s_pc <= 1'b0;
					we3 <= 1'b0;
					we_flags <= 1'b0;
					op_alu <= 3'b000;
					read <= 1'b0;
					write <= 1'b0;
					flush_if <= 1'b0;
				end
			endcase
		end
	end

endmodule
