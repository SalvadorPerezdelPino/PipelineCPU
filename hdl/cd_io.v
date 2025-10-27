// Driver de la CPU al bus de datos
// Hace de puerto de entrada y salida, enviando o recibiendo datos
module cd_io #(parameter WIDTH=16) (
					inout wire  [WIDTH-1:0] bus_data, 
					input wire  [WIDTH-1:0] data_from_cpu, 
					output wire [WIDTH-1:0] data_to_cpu, 
					input wire 	read,
					input wire  write);
					
	assign bus_data = (write && !read) ? data_from_cpu : {WIDTH{1'bz}};
	assign data_to_cpu = (read && !write) ? bus_data : {WIDTH{1'b0}};
	
endmodule
