module OSC(CLOCK_50,
		oVGA_CLK,
		oVS,
		oHS,
		oBLANK_N,
		b_data,
		g_data,
		r_data,
		KEY,
		ifft_Isignal,
		ifft_Qsignal
			);
			
input KEY;
input wire [7:0] ifft_Isignal;
input wire [7:0] ifft_Qsignal;
input CLOCK_50;
output oVGA_CLK;
output oVS;
output oHS;
output oBLANK_N;
output reg [7:0] b_data;
output reg [7:0] g_data;  
output reg [7:0] r_data; 
      
       
               
///////// ////               
reg vga_clk_reg;
wire VGA_CLK_n;
wire iVGA_CLK;
wire [10:0] CX;
wire [9:0] CY;
wire [9:0] Val_CY;
reg [9:0] Val_CY_prev;

////////////////////////
//Variables to hold the captured values (section 5)
wire [9:0] ValforVGA; // Coordinate Y of the current Coordinate X
reg [9:0] oldValforVGA; // Coordinate Y of the previous Coordinate X


//////////////////////////
//// Implementation of the 12.5 MH Clock
always@(posedge CLOCK_50)
begin
	vga_clk_reg <= ~vga_clk_reg;
end

assign iVGA_CLK = vga_clk_reg;


/////////////////
///Output clock

assign oVGA_CLK = ~iVGA_CLK;

////////////////
//VGA Controller instance
VGA_Controller vga (1'b0, iVGA_CLK, oBLANK_N, oHS, oVS, CX, CY);


/////////////////////
//Signal generator instance

Signal_generator sg (CLOCK_50, VGA_CLK_n, oVS, oBLANK_N, Val_CY, KEY, ifft_Isignal, ifft_Qsignal);

/////////////////////

assign VGA_CLK_n = ~iVGA_CLK;


always@(posedge VGA_CLK_n)
	begin
	//Update the value of the Coordinate Y of the previous Coordinate X
	Val_CY_prev <= Val_CY;
	//Display the Coordinate Y of the current Coordinate X
	if (CY == Val_CY)
	begin
		b_data <= 8'h00;
		g_data <= 8'h00;
		r_data <= 8'hFF;	
	end	
	//Connect points with vertical lines (old value < current value)
	
	else if (Val_CY_prev < Val_CY && (CY < Val_CY && CY > Val_CY_prev))
	begin
		b_data <= 8'h00;
		g_data <= 8'h00;
		r_data <= 8'hFF;
	end
	//connect points with vertical lines (old value > current value)
	else if (Val_CY_prev > Val_CY && (CY > Val_CY && CY < Val_CY_prev))
	begin
		b_data <= 8'h00;
		g_data <= 8'h00;
		r_data <= 8'hFF;
	end
	
	//display the vertical guide lines
	else if (CY==60 || CY == 120 || CY == 180 || CY == 240 || CY == 300 || CY == 360 || CY == 420 || CY == 479)
	begin
		b_data <= 8'hFF;
		g_data <= 8'hFF;
		r_data <= 8'hFF;
	end
	//display the horizontal guide lines
	else if (CX==64 || CX==128 || CX==192 || CX==256 || CX==320 || CX==384 || CX==448 || CX == 512 || CX==576 || CX==639)
	begin
		b_data <= 8'hFF;
		g_data <= 8'hFF;
		r_data <= 8'hFF;
	end
	//Everything else is black
	else
	begin
		b_data <= 8'h00;
		g_data <= 8'h00;
		r_data <= 8'h00;
	end
end

endmodule
 	













