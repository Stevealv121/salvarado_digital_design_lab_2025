module win_detector(
  input logic [1:0] board[5:0][6:0],     // Cada celda tiene 2 bits (0 = vacío, 1 o 2 = jugador)
  input logic [2:0] last_move_row,
  input logic [2:0] last_move_col,
  input logic [1:0] player,
  output logic win
);

  function automatic logic check_diagonal_win(
    input logic [1:0] board[5:0][6:0],
    input logic [2:0] row,
    input logic [2:0] col,
    input logic [1:0] player,
    input logic direction // 0: diagonal \, 1: diagonal /
  );
    logic [3:0] count = 1;
    int i, j;

    for (int offset = 1; offset < 4; offset++) begin
      if (!direction) begin
        i = row - offset;
        j = col - offset;
        if (i >= 0 && j >= 0 && board[i][j] == player)
          count++;
        else
          break;
      end else begin
        i = row - offset;
        j = col + offset;
        if (i >= 0 && j < 7 && board[i][j] == player)
          count++;
        else
          break;
      end
    end

    for (int offset = 1; offset < 4; offset++) begin
      if (!direction) begin
        i = row + offset;
        j = col + offset;
        if (i < 6 && j < 7 && board[i][j] == player)
          count++;
        else
          break;
      end else begin
        i = row + offset;
        j = col - offset;
        if (i < 6 && j >= 0 && board[i][j] == player)
          count++;
        else
          break;
      end
    end

    return (count >= 4);
  endfunction

  logic [3:0] count;

  always_comb begin
    win = 0;

    // Horizontal
    count = 1;
    for (int offset = 1; offset < 4; offset++) begin
      if ((last_move_col >= offset) && (board[last_move_row][last_move_col - offset] == player))
        count++;
      else
        break;
    end
    for (int offset = 1; offset < 4; offset++) begin
      if ((last_move_col + offset < 7) && (board[last_move_row][last_move_col + offset] == player))
        count++;
      else
        break;
    end
    if (count >= 4) win = 1;

        // Vertical (hacia arriba y hacia abajo)
    if (!win) begin
      count = 1;
      // Hacia abajo
      for (int offset = 1; offset < 4; offset++) begin
        if ((last_move_row + offset < 6) && (board[last_move_row + offset][last_move_col] == player))
          count++;
        else
          break;
      end
      // Hacia arriba
      for (int offset = 1; offset < 4; offset++) begin
        if ((last_move_row >= offset) && (board[last_move_row - offset][last_move_col] == player))
          count++;
        else
          break;
      end
      if (count >= 4) win = 1;
    end

    // Diagonal \
    if (!win) begin
      win = check_diagonal_win(board, last_move_row, last_move_col, player, 0);
    end

    // Diagonal /
    if (!win) begin
      win = check_diagonal_win(board, last_move_row, last_move_col, player, 1);
    end
  end

endmodule
