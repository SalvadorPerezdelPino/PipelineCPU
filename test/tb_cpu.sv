`timescale 1 ns / 10 ps

module tb_cpu;
	reg clk;
	reg reset;
	wire [9:0] pc;
	reg [9:0] old_pc;
	
	always begin
		clk = 1'b1;
		#10;
		clk = 1'b0;
		#10;
	end
	
	
	localparam ADDR_WIDTH = 20;
	localparam DATA_WIDTH = 16;
	
	wire read;
	wire write;
	wire halted;
	wire [DATA_WIDTH-1:0] hw_solution;
	wire [ADDR_WIDTH-1:0] bus_addr;
	wire [DATA_WIDTH-1:0] bus_data;
	
	
	// Address map
	localparam MEM_ADDR   = 20'h00000;
	
	cpu cpu1 (
		.clk   		(clk),
		.reset 		(reset), 
		.pc    		(pc),
		.bus_addr	(bus_addr),
		.bus_data	(bus_data),
		.mem_read	(read),
		.mem_write	(write),
		.halted		(halted),
		.solution	(hw_solution)
	);
	
	data_memory #(
		.START_ADDRESS(MEM_ADDR),
		.SIZE(1024))
	mem1 (
		.bus_data	(bus_data),
		.bus_addr	(bus_addr),
		.write		(write),
		.read			(read),
		.clk			(clk)
	);

	reg [DATA_WIDTH-1:0] expected_solution;
	integer mem_reads, mem_writes;
	real cycles, instructions, cpi;
	
	string dir;
	string input_filename;
	string expected_filename;
	string csv_filename;
	string wave_filename;
	integer input_fd;
	integer expected_fd;
	integer csv_fd;
	
	string id;
	integer j;
	integer file;
	initial begin
		// Get test parameters
		$value$plusargs("DIR=%s", dir);
		$value$plusargs("ID=%s", id);
		input_filename = {dir, "/input_", id, ".mem"};
		expected_filename = {dir, "/expected_", id, ".mem"};
		csv_filename = {dir, "/data_", id, ".csv"};

		// Check file openings
		input_fd = $fopen(input_filename, "r");
		expected_fd = $fopen(expected_filename, "r");
		csv_fd = $fopen(csv_filename, "w");
		if (input_fd == 0) begin
			$fatal("Error opening input file: %s", input_filename);
		end
		if (expected_fd == 0) begin
			$fatal("Error opening expected file: %s", expected_filename);
		end
		if (csv_fd == 0) begin
			$fatal("Error opening CSV file: %s", csv_filename);
		end

		$display("Current directory: %s", dir);
		$display("Test ID: %0d", id);
		
		// Start values
		cycles = 0;
		mem_reads = 0;
		mem_writes = 0;
		instructions = 0;
		old_pc = -1;
		
		// Read input memory
		for (j = 0; j < 1024; j = j + 1) begin
			$fscanf(input_fd, "%b", mem1.buffer[j]);
		end
		
		reset = 1;
		#10;
		reset = 0;
		
		// Run device until halted
		while (!halted) begin
			@(posedge clk);
			cycles = cycles + 1;
			if (read) begin
				mem_reads = mem_reads + 1;
			end
			if (write) begin
				mem_writes = mem_writes + 1;
			end
			if (pc != old_pc) begin
				instructions = instructions + 1;
				old_pc = pc;
			end
		end
		
		// Read expected solution and compare with hardware solution
		$fscanf(expected_fd, "%b", expected_solution);

		if (expected_solution == hw_solution) begin
			$fdisplay(csv_fd, "test_id;expected_solution;hw_solution;cycles;instructions;cpi;memory_reads;memory_writes");
			$display("Problem is CORRECT");
			$display("Total cycles: %d", cycles);
			$display("Total memory reads: %d", mem_reads);
			$display("Total memory writes: %d", mem_writes);
			$display("Total instructions: %d", instructions);
			cpi = cycles / instructions;
			$display("CPI: %.4f\n", cpi);
			$fdisplay(csv_fd, "%0d;%0d;%0d;%0d;%0d;%0d,%0d;%0d;%0d", id, 
					expected_solution, hw_solution, cycles, instructions, $rtoi(cpi), $rtoi((cpi - $rtoi(cpi)) * 10000), mem_reads, mem_writes);
		end
		else begin
			$display("Problem FAILED");
			$display("Expected solution: %d", expected_solution);
			$display("Hardware solution: %d\n", hw_solution);
			$display("Total cycles: %d", cycles);
			$display("Total memory reads: %d", mem_reads);
			$display("Total memory writes: %d", mem_writes);
			$display("Total instructions: %d", instructions);
			cpi = cycles / instructions;
			$display("CPI: %.4f\n", cpi);
			$finish(1);
		end

		// Close files and finish
		$fclose(input_fd);
		$fclose(expected_fd);
		$fclose(csv_fd);
		$finish();
	end


endmodule