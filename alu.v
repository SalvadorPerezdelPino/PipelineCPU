// ALU
module alu (
	input wire [15:0] a, b,
   input wire [2:0] op_alu,
   output wire [15:0] y,
   output wire zero,
	output wire sign);

	reg [15:0] s;		   
				
	always @(a, b, op_alu)
	begin
	  case (op_alu)              
		 3'b000: s = a;
		 3'b001: s = ~a;
		 3'b010: s = a + b;
		 3'b011: s = a - b;
		 3'b100: s = a & b;
		 3'b101: s = a | b;
		 3'b110: s = -a;
		 3'b111: s = a*b;
		default: s = 16'bx; //desconocido en cualquier otro caso para posibles ampliaciones
	  endcase
	end

	assign y = s;

	assign zero = ~(|y);   // Flag de cero
	assign sign = y[15];	  // Flag de signo

endmodule
