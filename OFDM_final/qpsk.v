module qpsk (CLOCK_50,
				parallel_out,
				Iz_signal,
				Qz_signal,
				iVGA_CLK);
				
input CLOCK_50;

parameter serial_bits=8;
reg [serial_bits-1:0]serial_in = 8'b00110011;
reg [serial_bits-1:0] i=0;

reg signed [1:0] I_signal=2'b00;
reg signed [1:0] Q_signal=2'b00;

output iVGA_CLK;
//output reg signed [7:0] Iz_signal;
//output reg signed [7:0] Qz_signal;

output wire signed [7:0] Iz_signal;
output wire signed [7:0] Qz_signal;

parameter parallel_bits=2;
output reg [parallel_bits-1:0] parallel_out;

reg signed [1:0] constellation_0=2'b01;
reg signed [1:0] constellation_1=2'b11;

reg vga_clk_reg;
wire iVGA_CLK;

always @(posedge CLOCK_50) 
begin
	vga_clk_reg <= ~vga_clk_reg;
end

assign iVGA_CLK = vga_clk_reg;

always @(posedge iVGA_CLK)
begin
	parallel_out[0]<=serial_in[i];
	parallel_out[1]<=parallel_out[0];
			
	if(i >= 7)
		begin	
			i<=0;
		end
	else
		begin
			i<=i+1;
		end

	I_signal<=parallel_out[0] == 1'b1 ? constellation_0 : constellation_1;
	Q_signal<=parallel_out[1] == 1'b1 ? constellation_0 : constellation_1;
	
//	Iz_signal <= {2'b00,{2{I_signal}},2'b00};
//	Qz_signal <= {2'b00,{2{Q_signal}},2'b00};
end

assign Iz_signal = {2'b00,{2{I_signal}},2'b00};
assign Qz_signal = {2'b00,{2{Q_signal}},2'b00};
endmodule