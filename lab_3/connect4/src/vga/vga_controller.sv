module vga_controller( 
    input logic clk,         // 50MHz clock
    output logic SYNC_H,  // VGA HSYNC
    output logic SYNC_V,  // VGA VSYNC
	 output logic SYNC_B,
	 output logic SYNC_BLANK,
	 output logic CLK_VGA,
    output logic [7:0] vga_red, // VGA Red
    output logic [7:0] vga_green, // VGA Green
    output logic [7:0] vga_blue  // VGA Blue
);

	 logic[9:0] x,y;
	 logic rst,locked;
	 pll vgapll(.refclk(clk), .rst(rst), .locked(locked), .outclk_0(CLK_VGA));
	 
	 vga_synchronizer#(.HACTIVE(640), .HFP(16), .HSYN(96), .HBP(48), .VACTIVE(480), .VFP(11), .VSYN(2), .VBP(32))
        vga_synchronizer(CLK_VGA, SYNC_H, SYNC_V, SYNC_B, SYNC_BLANK, x, y);

	 // Simple pattern generator
    always_ff @(posedge CLK_VGA) begin
        if (SYNC_BLANK) begin
            // Active display area - draw a white diagonal line
            if (y == x >> 1) begin  // Simple line equation (y = x/2)
                vga_red <= 8'hFF;
                vga_green <= 8'hFF;
                vga_blue <= 8'hFF;
            end else begin
                // Black background
                vga_red <= 8'h00;
                vga_green <= 8'h00;
                vga_blue <= 8'h00;
            end
        end else begin
            // Blanking area - must output black
            vga_red <= 8'h00;
            vga_green <= 8'h00;
            vga_blue <= 8'h00;
        end
    end
	 
endmodule