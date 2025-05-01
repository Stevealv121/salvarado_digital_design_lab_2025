module display_board(
    input logic clk_vga,
    input logic [9:0] x, y,         // Current pixel coordinates
    input logic [1:0] game_state,   // 00: menu, 01: playing, 10: game over (win), 11: draw
    input logic [1:0] board[5:0][6:0], // 6x7 Connect4 board (00: empty, 01: player1, 10: player2)
    input logic [3:0] turn_timer,
    input logic [1:0] current_player,
    input logic sync_blank,         // Active display area signal
    output logic [7:0] vga_r, vga_g, vga_b  // RGB output
);

    // Display constants
    localparam BOARD_X_START = 100;  // Board left edge position
    localparam BOARD_Y_START = 50;   // Board top edge position
    localparam CELL_SIZE = 60;       // Size of one cell (square)
    localparam HOLE_RADIUS = 25;     // Radius of the token holes
    
    // Colors
    localparam [23:0] BLUE_COLOR = 24'h0000FF;  // Board background (blue)
    localparam [23:0] RED_COLOR = 24'hFF0000;   // Player 1 tokens (red)
    localparam [23:0] YELLOW_COLOR = 24'hFFFF00; // Player 2 tokens (yellow)
    localparam [23:0] BLACK_COLOR = 24'h000000; // Empty holes (black)
    localparam [23:0] BG_COLOR = 24'h101040;    // Screen background
    
    // Current pixel's position relative to the board
    logic [9:0] rel_x, rel_y;
    logic [2:0] col;  // 0 to 6
    logic [2:0] row;  // 0 to 5
    
    // Distance calculation variables for circle drawing
    logic [9:0] center_x, center_y;
    logic [19:0] distance_squared;
    
    // Determine which part of the display we're drawing
    logic is_in_board_area;
    logic is_in_hole;
    logic [23:0] pixel_color;

    // Calculate the board cell position
    assign rel_x = x - BOARD_X_START;
    assign rel_y = y - BOARD_Y_START;
    assign col = rel_x / CELL_SIZE;
    assign row = rel_y / CELL_SIZE;
    
    // Check if we're in the board area
    assign is_in_board_area = (x >= BOARD_X_START) && 
                              (x < BOARD_X_START + 7 * CELL_SIZE) && 
                              (y >= BOARD_Y_START) && 
                              (y < BOARD_Y_START + 6 * CELL_SIZE);
                               
    // Calculate distance from center of the current cell
    always_comb begin
        // Center of the current cell
        center_x = BOARD_X_START + col * CELL_SIZE + CELL_SIZE/2;
        center_y = BOARD_Y_START + row * CELL_SIZE + CELL_SIZE/2;
        
        // Calculate squared distance (avoiding square root)
        distance_squared = (x - center_x) * (x - center_x) + 
                           (y - center_y) * (y - center_y);
                           
        // Check if point is inside the hole
        is_in_hole = (distance_squared <= HOLE_RADIUS * HOLE_RADIUS);
    end
    
    // Determine pixel color based on position and game state
    always_comb begin
        // Default background color
        pixel_color = BG_COLOR;
        
        if (is_in_board_area) begin
            if (col < 7 && row < 6) begin  // Valid board position
                if (is_in_hole) begin
                    // Draw hole/token color based on board state
                    case (board[row][col])
                        2'b00: pixel_color = BLACK_COLOR;  // Empty
                        2'b01: pixel_color = RED_COLOR;    // Player 1
                        2'b10: pixel_color = YELLOW_COLOR; // Player 2
                        default: pixel_color = BLACK_COLOR;
                    endcase
                end else begin
                    // Board color (blue)
                    pixel_color = BLUE_COLOR;
                end
            end
        end
    end
    
    // Output the color to VGA signals
    always_ff @(posedge clk_vga) begin
        if (sync_blank) begin
            // In active display area
            vga_r <= pixel_color[23:16];
            vga_g <= pixel_color[15:8];
            vga_b <= pixel_color[7:0];
        end else begin
            // In blanking area - must be black
            vga_r <= 8'h00;
            vga_g <= 8'h00;
            vga_b <= 8'h00;
        end
    end

endmodule