// Módulo de memoria externa
// Lectura asíncrona y escritura síncrona
module data_memory #(
	parameter START_ADDRESS=0,
	parameter SIZE=1) (
	inout wire [15:0] bus_data,
	input wire [19:0] bus_addr,
	input wire read,
	input wire write,
	input wire clk
);
	wire selected;
	assign selected = (START_ADDRESS <= bus_addr) && (START_ADDRESS + SIZE - 1 >= bus_addr);
	
	wire [19:0] local_addr = bus_addr - START_ADDRESS; // Posición relativa en memoria
	
	reg [15:0] buffer [SIZE-1:0];
	
	assign bus_data = (read && selected) ? buffer[local_addr] : 16'bz;
	
	localparam path = "C:/Users/Usuario/Documents/clase/inf/TFG/FPGA/DE10/CPU/Pipeline/data.mem";
	
	initial
	begin
		$readmemb(path, buffer); // Inicialización de la memoria
	end
	
	always @(posedge clk) begin
		if (write && selected) begin
			buffer[local_addr] <= bus_data;
		end
	end
	
endmodule
