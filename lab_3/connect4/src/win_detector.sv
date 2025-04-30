module win_detector(
  input logic [1:0] board[5:0][6:0],     // 6 rows x 7 columns (0=empty, 1=player1, 2=player2)
  input logic [2:0] last_move_row,       // Row of last move (0-5)
  input logic [2:0] last_move_col,       // Column of last move (0-6)
  input logic [1:0] player,              // Player to check (1 or 2)
  output logic win                       // 1 if player won, 0 otherwise
);

  function automatic logic check_diagonal_win(
    input logic [1:0] board[5:0][6:0],
    input logic [2:0] row,
    input logic [2:0] col,
    input logic [1:0] player,
    input logic direction // 0: diagonal \, 1: diagonal /
  );
    logic [3:0] count = 1;  // Start with current position
    int i, j;

    // Check in negative direction (up-left or up-right)
    for (int offset = 1; offset < 4; offset++) begin
      if (!direction) begin // Diagonal \
        i = row - offset;
        j = col - offset;
      end else begin        // Diagonal /
        i = row - offset;
        j = col + offset;
      end
      
      if (i >= 0 && j >= 0 && j < 7 && board[i][j] == player)
        count++;
      else
        break;
    end

    // Check in positive direction (down-right or down-left)
    for (int offset = 1; offset < 4; offset++) begin
      if (!direction) begin // Diagonal \
        i = row + offset;
        j = col + offset;
      end else begin        // Diagonal /
        i = row + offset;
        j = col - offset;
      end
      
      if (i < 6 && j >= 0 && j < 7 && board[i][j] == player)
        count++;
      else
        break;
    end

    return (count >= 4);
  endfunction

  // Declare all variables outside always_comb
  logic [3:0] h_count, v_count;
  logic h_win, v_win, d1_win, d2_win;

  always_comb begin
    // Default values
    win = 0;
    h_count = 1;
    v_count = 1;
    h_win = 0;
    v_win = 0;
    d1_win = 0;
    d2_win = 0;
    
    // Only check if the position isn't empty
    if (board[last_move_row][last_move_col] == player) begin
      // Check horizontal
      // Check left
      for (int offset = 1; offset < 4; offset++) begin
        if (last_move_col >= offset && 
            board[last_move_row][last_move_col - offset] == player)
          h_count++;
        else
          break;
      end
      // Check right
      for (int offset = 1; offset < 4; offset++) begin
        if (last_move_col + offset < 7 && 
            board[last_move_row][last_move_col + offset] == player)
          h_count++;
        else
          break;
      end
      h_win = (h_count >= 4);

      // Check vertical
      // Check above
      for (int offset = 1; offset < 4; offset++) begin
        if (last_move_row >= offset && 
            board[last_move_row - offset][last_move_col] == player)
          v_count++;
        else
          break;
      end
      // Check below
      for (int offset = 1; offset < 4; offset++) begin
        if (last_move_row + offset < 6 && 
            board[last_move_row + offset][last_move_col] == player)
          v_count++;
        else
          break;
      end
      v_win = (v_count >= 4);

      // Check diagonals
      d1_win = check_diagonal_win(board, last_move_row, last_move_col, player, 0);
      d2_win = check_diagonal_win(board, last_move_row, last_move_col, player, 1);

      // Final win determination
      win = h_win || v_win || d1_win || d2_win;
    end
  end
endmodule