module memdata (
	input wire clk, we,
	input wire [8:0] address,
	input wire [15:0] data_in,
	output wire [15:0] data_out
	);

	reg [15:0] buffer [2048:0];
	assign data_out = buffer[address];
	
	localparam path = "C:/Users/Usuario/Documents/clase/inf/TFG/FPGA/DE10/pipeline/data.mem";
	
	initial
	begin
		$readmemb(path, buffer); // Inicialización de la memoria
	end
	
	always @(posedge clk) begin
		if (we) begin
			buffer[address] <= data_in;
		end
	end

endmodule
