module single_port_ram #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 20,
    parameter INIT_FILE = ""
)(
    input  wire [ADDR_WIDTH-1:0] address,
    input  wire [DATA_WIDTH-1:0] data,
    input  wire rden,
    input  wire wren,
    input  wire clock,
    output reg  [DATA_WIDTH-1:0] q
);

    // bufferoria interna
    reg [DATA_WIDTH-1:0] buffer [(1<<ADDR_WIDTH)-1:0];

    // Inicialización opcional
    initial begin
        if (INIT_FILE != "") begin
            $readmemb(INIT_FILE, buffer);
        end
    end

    always @(posedge clock) begin
        // Escritura
        if (wren) begin
            buffer[address] <= data;
        end

        // Lectura
        if (rden) begin
            q <= buffer[address];
        end else begin
            q <= {DATA_WIDTH{1'bz}}; // High-Z cuando no se lee
        end
    end

endmodule