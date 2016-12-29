module call(clk,
            reset_n,
				output_sink_error,
				output_sink_sop,
				output_sink_eop,
				output_fftpts_in,
				output_fftpts_out
    	);
			input clk;
			output reset_n;
			output wire [1:0] output_sink_error;
			output wire [3:0] output_fftpts_in;
			output wire [3:0] output_fftpts_out;
			output reg output_sink_eop;
			output reg output_sink_sop;
			
			reg [30:0] counter;
			
assign output_sink_error = 2'b00;

always @ (negedge clk)
    begin                                                                                         
      if(reset_n==1'b0)
        begin
		  counter <= counter + 1;   
		  end 
		   if(counter==1)
		    output_sink_sop<=1'b1;
		     if(counter>=30)
           begin
			  output_sink_eop<=1'b1;
		     counter <= 0;
           end
			  else
           counter <= 0;
    end           

assign output_fftpts_out = 4'b1000;
assign output_fftpts_in  = 4'b1000;
endmodule
	  

		
	        		