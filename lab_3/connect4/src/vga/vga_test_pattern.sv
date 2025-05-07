module vga_test_pattern(
    input logic [9:0] x_pos,
    input logic [9:0] y_pos,
    input logic blank_n,
    output logic [7:0] red,
    output logic [7:0] green,
    output logic [7:0] blue
);

  // Draw a white diagonal line from top-left to bottom-right
    always_comb begin
        if (blank_n) begin
            // Check if current pixel is on the diagonal line
            if (y_pos == x_pos / 2 ||  // Simple line equation
                y_pos == x_pos / 2 + 1 || // Make line 2 pixels thick
                y_pos == x_pos / 2 - 1) begin
                // White color
                red = 8'hFF;
                green = 8'hFF;
                blue = 8'hFF;
            end else begin
                // Black background
                red = 8'h00;
                green = 8'h00;
                blue = 8'h00;
            end
        end else begin
            // During blanking period, output black
            red = 8'h00;
            green = 8'h00;
            blue = 8'h00;
        end
    end
endmodule