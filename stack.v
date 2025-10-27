// Módulo de pila
// Almacena datos usando la estructura LIFO
module stack (
	input wire push,
	input wire pop,
	input wire [9:0] in_data,
	output wire [9:0] out_data,
	input wire clk
);
	reg [8:0] sp = 9'b0; // stack pointer
	reg [9:0] buffer [255:0];
	
	wire full, empty;
	assign full = (sp == 256);
	assign empty = (sp == 0);
	
	// El stack pointer siempre apunta a la siguiente posición libre
	// El dato se obtiene de la posición anterior al stack pointer
	assign out_data = (!empty) ? buffer[sp - 1] : 10'b0;
	
	always @(posedge clk) begin
		if (push && !full) begin
			buffer[sp] <= in_data;
			sp = sp + 9'b1;
		end else if (pop && !empty) begin
			sp <= sp - 9'b1;
		end

	end

endmodule
