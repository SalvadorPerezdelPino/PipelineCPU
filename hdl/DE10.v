module DE10(
	input wire CLOCK_50,
	input wire [3:0] KEY,
	output wire [9:0] LEDR
);

	localparam ADDR_WIDTH = 20;
	localparam DATA_WIDTH = 16;
	localparam MEM_ADDR   = 20'h00000; // For possible peripherals

	wire [DATA_WIDTH-1:0] bus_data;
	wire [ADDR_WIDTH-1:0] bus_addr;
	wire read, write;
	wire clk;
	
	pll pll1 (
		.refclk	 (CLOCK_50),
		.rst		 (~KEY[0]),
		.outclk_0 (clk)
	);
	
	cpu #(
		.ADDR_WIDTH	(ADDR_WIDTH), 
		.DATA_WIDTH	(DATA_WIDTH)
	) cpu1 (
		.clk			(clk), 
		.reset		(~KEY[0]),
		.pc			(),
		.opcode		(),
		.bus_data	(bus_data),
		.bus_addr	(bus_addr),
		.mem_read	(read),
		.mem_write	(write),
		.halted		(),
		.solution	(LEDR)
	);
	
	data_memory #(
		.START_ADDRESS(MEM_ADDR),
		.SIZE(2048))
	mem1 (
		.bus_data	(bus_data),
		.bus_addr	(bus_addr),
		.write		(write),
		.read			(read),
		.clk			(clk)
	);
	
endmodule