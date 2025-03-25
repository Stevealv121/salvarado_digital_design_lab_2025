module top_module(
    input logic [9:0] SW,
    output logic [6:0] HEX0,    // First operand display
    output logic [6:0] HEX1,    // Second operand display
    output logic [6:0] HEX2     // Result display
);

    // First operand display (SW[3:0])
    bin_to_bcd_decoder operand1_decoder(
        .bin_number(SW[3:0]),
        .bcd_number(HEX0)
    );
    
    // Second operand display (SW[7:4])
    bin_to_bcd_decoder operand2_decoder(
        .bin_number(SW[7:4]),
        .bcd_number(HEX1)
    );
    
    // Result display
    bin_to_bcd_decoder result_decoder(
        .bin_number(4'b0000),  //zero test
        .bcd_number(HEX2)
    );
	
endmodule
