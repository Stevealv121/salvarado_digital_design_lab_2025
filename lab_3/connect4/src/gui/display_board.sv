module display_board(
    input logic clk_vga,
    input logic [9:0] x, y,
    input logic [1:0] game_state,
    input logic [1:0] board[5:0][6:0],
    input logic [3:0] turn_timer,
    input logic [1:0] current_player,
    input logic [2:0] column_selected,
    input logic [2:0] win_positions_row[0:3],
    input logic [2:0] win_positions_col[0:3],
    input logic [1:0] win_type,
    input logic sync_blank,
    output logic [7:0] vga_r, vga_g, vga_b
);

    localparam BOARD_X_START = 100;
    localparam BOARD_Y_START = 50;
    localparam CELL_SIZE = 60;
    localparam HOLE_RADIUS = 25;
    localparam INDICATOR_HEIGHT = 15;
    localparam TEXT_HEIGHT = 30;
    localparam TEXT_Y_POS = 430;

    localparam [23:0] BLUE_COLOR = 24'h0000FF;
    localparam [23:0] RED_COLOR = 24'hFF0000;
    localparam [23:0] YELLOW_COLOR = 24'hFFFF00;
    localparam [23:0] BLACK_COLOR = 24'h000000;
    localparam [23:0] BG_COLOR = 24'h101040;
    localparam [23:0] P1_INDICATOR_COLOR = 24'hFF4040;
    localparam [23:0] P2_INDICATOR_COLOR = 24'hFFFF40;
    localparam [23:0] WHITE_COLOR = 24'hFFFFFF;
    localparam [23:0] HIGHLIGHT_COLOR = 24'h00FFFF;

    logic [9:0] rel_x, rel_y;
    logic [2:0] col, row;
    logic [9:0] center_x, center_y;
    logic [19:0] distance_squared;
    logic is_in_board_area;
    logic is_in_hole;
    logic is_in_column_indicator;
    logic is_in_winner_text;
    logic is_winning_position;
    logic [23:0] pixel_color;

    assign rel_x = x - BOARD_X_START;
    assign rel_y = y - BOARD_Y_START;
    assign col = rel_x / CELL_SIZE;
    assign row = rel_y / CELL_SIZE;

    assign is_in_board_area = (x >= BOARD_X_START) && 
                              (x < BOARD_X_START + 7 * CELL_SIZE) && 
                              (y >= BOARD_Y_START) && 
                              (y < BOARD_Y_START + 6 * CELL_SIZE);

    assign is_in_column_indicator = (x >= BOARD_X_START) && 
                                    (x < BOARD_X_START + 7 * CELL_SIZE) && 
                                    (y >= BOARD_Y_START - INDICATOR_HEIGHT) && 
                                    (y < BOARD_Y_START);

    assign is_in_winner_text = (y >= TEXT_Y_POS) && 
                               (y < TEXT_Y_POS + TEXT_HEIGHT);

    always_comb begin
        center_x = BOARD_X_START + col * CELL_SIZE + CELL_SIZE/2;
        center_y = BOARD_Y_START + row * CELL_SIZE + CELL_SIZE/2;

        distance_squared = (x - center_x) * (x - center_x) + 
                           (y - center_y) * (y - center_y);

        is_in_hole = (distance_squared <= HOLE_RADIUS * HOLE_RADIUS);
    end

    always_comb begin
	 is_winning_position = 1'b0;
        if ((game_state == 2'b10)) begin
            for (int i = 0; i < 4; i++) begin
                if (row == win_positions_row[i] && col == win_positions_col[i]) begin
                    is_winning_position = 1'b1;
                end
            end
        end
    end

    always_comb begin
        pixel_color = BG_COLOR;

        if (is_in_column_indicator && game_state == 2'b01) begin
            logic [2:0] indicator_col;
            indicator_col = rel_x / CELL_SIZE;

            if (indicator_col == column_selected) begin
                if (current_player == 2'b01)
                    pixel_color = P1_INDICATOR_COLOR;
                else if (current_player == 2'b10)
                    pixel_color = P2_INDICATOR_COLOR;
            end
        end else if (is_in_board_area) begin
            if (col < 7 && row < 6) begin
                if (is_in_hole) begin
                    case (board[row][col])
                        2'b00: pixel_color = BLACK_COLOR;
                        2'b01: pixel_color = RED_COLOR;
                        2'b10: pixel_color = YELLOW_COLOR;
                        default: pixel_color = BLACK_COLOR;
                    endcase

                    if ((game_state == 2'b10) && is_winning_position) begin
                        logic [19:0] inner_radius;
                        inner_radius = HOLE_RADIUS - 5;
                        if (distance_squared >= inner_radius * inner_radius && 
                            distance_squared <= HOLE_RADIUS * HOLE_RADIUS) begin
                            pixel_color = HIGHLIGHT_COLOR;
                        end
                    end
                end else begin
                    pixel_color = BLUE_COLOR;

                    if ((game_state == 2'b10) && is_winning_position) begin
                        logic [9:0] border_size;
                        border_size = 3;

                        if (rel_x % CELL_SIZE < border_size || 
                            rel_x % CELL_SIZE >= CELL_SIZE - border_size ||
                            rel_y % CELL_SIZE < border_size || 
                            rel_y % CELL_SIZE >= CELL_SIZE - border_size) begin
                            pixel_color = HIGHLIGHT_COLOR;
                        end
                    end
                end
            end
        end else if (is_in_winner_text) begin
            if (game_state == 2'b10) begin
                if (x >= BOARD_X_START + 50 && x < BOARD_X_START + 370) begin
                    if (current_player == 2'b01) begin  // Player 1 won
                        pixel_color = RED_COLOR;
                    end else if (current_player == 2'b10) begin  // Player 2 won
                        pixel_color = YELLOW_COLOR;
                    end
                end

            end
        end
    end

    always_ff @(posedge clk_vga) begin
        if (sync_blank) begin
            vga_r <= pixel_color[23:16];
            vga_g <= pixel_color[15:8];
            vga_b <= pixel_color[7:0];
        end else begin
            vga_r <= 8'h00;
            vga_g <= 8'h00;
            vga_b <= 8'h00;
        end
    end

endmodule