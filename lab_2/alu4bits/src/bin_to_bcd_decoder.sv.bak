module bin_to_bcd_decoder(
    input [3:0] bin_number,
    output reg [6:0] bcd_number
);

always @(*) begin
    case(bin_number)
        // Common anode segments (0=ON, 1=OFF)
        // Segment order: g f e d c b a
        0:  bcd_number = 7'b1000000; // 0
        1:  bcd_number = 7'b1111001; // 1
        2:  bcd_number = 7'b0100100; // 2
        3:  bcd_number = 7'b0110000; // 3
        4:  bcd_number = 7'b0011001; // 4
        5:  bcd_number = 7'b0010010; // 5
        6:  bcd_number = 7'b0000010; // 6
        7:  bcd_number = 7'b1111000; // 7
        8:  bcd_number = 7'b0000000; // 8
        9:  bcd_number = 7'b0010000; // 9
        default: bcd_number = 7'b1111111; // Off
    endcase
end

endmodule