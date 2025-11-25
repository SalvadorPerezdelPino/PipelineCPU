// ALU
module alu (
	input wire [15:0] a, b,
   input wire [2:0] op_alu,
   output wire [15:0] y,
   output wire zero,
	output wire sign,
	output wire carry,
	output wire overflow
	);

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
	
	wire [16:0] sum_ext = {1'b0, a} + {1'b0, b};
   wire [16:0] sub_ext = {1'b0, a} - {1'b0, b};

	assign zero = ~(|y);
	assign sign = y[15];
	assign carry = (op_alu == 3'b010) ? sum_ext[16] : (op_alu == 3'b011) ? sub_ext[16] : 1'b0;
	assign overflow = (op_alu == 3'b010) ? ((a[15] == b[15]) && (y[15] != a[15])) : 
		(op_alu == 3'b011) ? ((a[15] != b[15]) && (y[15] != a[15])) : 1'b0;


endmodule
