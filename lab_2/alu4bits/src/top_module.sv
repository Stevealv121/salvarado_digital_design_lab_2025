module top_module(
    input logic [9:0] SW,
    output logic [6:0] HEX0,
);

	 bin_to_bcd_decoder uut(
        .bin_number(SW[3:0]),
        .bcd_number(HEX0)
	 );
	
endmodule
