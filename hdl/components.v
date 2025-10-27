//Componentes varios

//Banco de registros de dos salidas y una entrada
module regfile #(parameter WIDTH=8) (input  wire clk, 
               input  wire        we3,           //se�al de habilitaci�n de escritura
               input  wire [3:0]  ra1, ra2, wa3, //direcciones de regs leidos y reg a escribir
               input  wire [WIDTH-1:0]  wd3, 			 //dato a escribir
               output wire [WIDTH-1:0]  rd1, rd2);     //datos leidos

  reg [WIDTH-1:0] regb[0:15]; 

  initial
  begin
    $readmemb("C:/Users/Usuario/Documents/clase/inf/TFG/FPGA/DE10/CPU/Pipeline/mem/regfile.mem",regb); // inicializa los registros a valores conocidos
  end  
  
  // El registro 0 siempre es cero
  // se leen dos reg combinacionalmente
  // y la escritura del tercero ocurre en flanco de subida del reloj
  
  always @(posedge clk)
    if (we3) regb[wa3] <= wd3;	
  
  assign rd1 = (ra1 != 0) ? regb[ra1] : 8'b0;
  assign rd2 = (ra2 != 0) ? regb[ra2] : 8'b0;

endmodule

//Banco de registros de dos salidas y una entrada
module regfilesync #(parameter WIDTH=8) (input  wire clk, 
               input  wire        we3,           //se�al de habilitaci�n de escritura
               input  wire [3:0]  ra1, ra2, wa3, //direcciones de regs leidos y reg a escribir
               input  wire [WIDTH-1:0]  wd3, 			 //dato a escribir
               output reg [WIDTH-1:0]  rd1, rd2);     //datos leidos

  reg [WIDTH-1:0] regb[0:15]; 

  initial
  begin
    $readmemb("C:/Users/Usuario/Documents/clase/inf/TFG/FPGA/DE10/CPU/Multicycle/regfile.mem",regb); // inicializa los registros a valores conocidos
  end  
  
  // El registro 0 siempre es cero
  // se leen dos reg combinacionalmente
  // y la escritura del tercero ocurre en flanco de subida del reloj
  
	always @(posedge clk) begin
		if (we3) regb[wa3] <= wd3;
		
		rd1 <= regb[ra1];
		rd2 <= regb[ra2];
	end

endmodule

//modulo sumador  
module sum(input  wire [9:0] a, b,
             output wire [9:0] y);

  assign y = a + b;

endmodule

//modulo registro para modelar el PC, cambia en cada flanco de subida de reloj o de reset
module registro #(parameter WIDTH = 8)
              (input wire             clk, reset,
               input wire [WIDTH-1:0] d, 
					input wire enable,
               output reg [WIDTH-1:0] q);

  always @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else if (enable) q <= d;

endmodule

//modulo multiplexor, si s=1 sale d1, s=0 sale d0
module mux2 #(parameter WIDTH = 16)
             (input  wire [WIDTH-1:0] d0, d1, 
              input  wire             s, 
              output wire [WIDTH-1:0] y);

   assign y = s ? d1 : d0; 

endmodule

//modulo multiplexor, si s=1 sale d1, s=0 sale d0
module mux4 #(parameter WIDTH = 16)
             (input  wire [WIDTH-1:0] d0, d1, d2, d3,
              input  wire [1:0]       s, 
              output wire [WIDTH-1:0] y);

	assign y = (s == 2'b00) ? d0 :
              (s == 2'b01) ? d1 :
              (s == 2'b10) ? d2 : d3;

endmodule

//Biestable para el flag de cero
//Biestable tipo D s�ncrono con reset as�ncrono por flanco y entrada de habilitaci�n de carga
module ffd(input wire clk, reset, d, carga, output reg q);

  always @(posedge clk, posedge reset)
    if (reset)
	    q <= 1'b0;
	  else
	    if (carga)
	      q <= d;

endmodule 

