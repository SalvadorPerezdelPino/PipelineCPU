`timescale 1 ns / 10 ps

module tb_cpu;

	integer instances;
	real freq;
	
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
	
	/////// MEMORY ///////	
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

	reg [DATA_WIDTH-1:0] solution;
	integer mem_reads, mem_writes;
	real cycles, instructions, cpi;
	real avg_cycles, avg_reads, avg_writes, avg_instructions, avg_cpi;
	
	string output_filename = "C:/Users/Usuario/Documents/clase/inf/TFG/FPGA/DE10/CPU/Pipeline/test_files/outputs/pipeline.csv";
	integer output_fd;
	
	integer i, j;
	integer file;
	initial begin
		//$value$plusargs("instances=%d", instances);
		instances = 50; // Temporaly
		output_fd = $fopen(output_filename, "w");
		if (output_fd == 0) begin
			$fatal("No se pudo crear el fichero de resultados");
		end
		
		$fdisplay(output_fd, "test_id;expected_solution;hw_solution;cycles;instructions;cpi;memory_reads;memory_writes");

		avg_cycles = 0;
		avg_reads = 0;
		avg_writes = 0;
		avg_instructions = 0;
		avg_cpi = 0;
		for (i = 0; i < instances; i = i + 1) begin
			cycles = 0;
			mem_reads = 0;
			mem_writes = 0;
			instructions = 0;
			old_pc = -1;
			
			$display("TEST %0d", i);
			file = $fopen($sformatf("C:/Users/Usuario/Documents/clase/inf/TFG/FPGA/DE10/CPU/Pipeline/test_files/inputs/input%0d.mem", i), "r");
			for (j = 0; j < 2048; j = j + 1) begin
				$fscanf(file, "%b", mem1.buffer[j]);
			end
			$fclose(file);
			
			reset = 1;
			#70;
			reset = 0;
			
			while (!halted) begin
				@(posedge clk);
				cycles = cycles + 1;
				avg_cycles = avg_cycles + 1;
				if (read) begin
					mem_reads = mem_reads + 1;
					avg_reads = avg_reads + 1;
				end
				if (write) begin
					mem_writes = mem_writes + 1;
					avg_writes = avg_writes + 1;
				end
				if (pc != old_pc) begin
					instructions = instructions + 1;
					avg_instructions = avg_instructions + 1;
					old_pc = pc;
				end
			end
			
			file = $fopen($sformatf("C:/Users/Usuario/Documents/clase/inf/TFG/FPGA/DE10/CPU/Pipeline/test_files/solutions/solution%0d.mem", i), "r");
			$fscanf(file, "%b", solution);
			$fclose(file);
			if (solution == hw_solution) begin
				$display("Knapsack is CORRECT");
				$display("Total cycles: %d", cycles);
				$display("Total memory reads: %d", mem_reads);
				$display("Total memory writes: %d", mem_writes);
				$display("Total instructions: %d", instructions);
				cpi = cycles / instructions;
				$display("CPI: %.4f\n", cpi);
				$fdisplay(output_fd, "%0d;%0d;%0d;%0d;%0d;%0d,%0d;%0d;%0d", i, 
						solution, hw_solution, cycles, instructions, $rtoi(cpi), $rtoi((cpi - $rtoi(cpi)) * 10000), mem_reads, mem_writes);
			end
			else begin
				$display("Knapsack FAILED");
				$display("Expected solution: %d", solution);
				$display("Hardware solution: %d\n", hw_solution);
				$fclose(output_fd);
				$finish();
			end
				
			
		end

		avg_cycles = avg_cycles / instances;
		avg_reads = avg_reads / instances;
		avg_writes = avg_writes / instances;
		avg_instructions = avg_instructions / instances;
		avg_cpi = avg_cycles / avg_instructions;
		$display("ALL TEST ARE CORRECT");
		$display("Average cycles: %.4f", avg_cycles);
		$display("Average memory reads: %.4f", avg_reads);
		$display("Average memory writes: %.4f", avg_writes);
		$display("Average instructions: %.4f", avg_instructions);
		$display("Average CPI: %.4f", avg_cpi);
		$fclose(output_fd);
		$finish();
	end


endmodule