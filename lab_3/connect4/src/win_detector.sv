module win_detector(
  input logic [5:0][6:0] board,       // Tablero 6 filas x 7 columnas
  input logic [2:0] last_move_row,     // Fila del último movimiento
  input logic [2:0] last_move_col,     // Columna del último movimiento
  input logic [1:0] player,            // Jugador actual (1 o 2)
  output logic win                    // 1 si el jugador ha ganado
);

  function automatic logic check_diagonal_win(
    input logic [5:0][6:0] board,
    input logic [2:0] row,
    input logic [2:0] col,
    input logic [1:0] player,
    input logic direction // 0: diagonal \, 1: diagonal /
  );
    logic [3:0] count = 1; // Comienza en 1 porque contamos la pieza actual
    logic [2:0] i, j;
    
    // Verificar en ambas direcciones desde la pieza actual
    for (int offset = 1; offset < 4; offset++) begin
      if (!direction) begin
        // Diagonal \
        i = row - offset;
        j = col - offset;
        if (i >= 0 && j >= 0 && board[i][j] == player)
          count++;
        else
          break;
      end else begin
        // Diagonal /
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
        // Diagonal \
        i = row + offset;
        j = col + offset;
        if (i < 6 && j < 7 && board[i][j] == player)
          count++;
        else
          break;
      end else begin
        // Diagonal /
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

  // Variables para conteo
  logic [3:0] count;
  
  always_comb begin
    win = 0;
    
    // Verificar horizontal (izquierda y derecha)
count = 1;
// Izquierda
for (int offset = 1; offset < 4; offset++) begin
  if ((last_move_col >= offset) && (board[last_move_row][last_move_col - offset] == player))
    count++;
  else
    break;
end
// Derecha
for (int offset = 1; offset < 4; offset++) begin
  if ((last_move_col + offset < 7) && (board[last_move_row][last_move_col + offset] == player))
    count++;
  else
    break;
end
if (count >= 4) win = 1;

// Verificar vertical (hacia abajo)
if (!win) begin
  count = 1;
  for (int offset = 1; offset < 4; offset++) begin
    if ((last_move_row + offset < 6) && (board[last_move_row + offset][last_move_col] == player))
      count++;
    else
      break;
  end
  if (count >= 4) win = 1;
end
    
    // Verificar diagonal \
    if (!win) begin
      win = check_diagonal_win(board, last_move_row, last_move_col, player, 0);
    end
    
    // Verificar diagonal /
    if (!win) begin
      win = check_diagonal_win(board, last_move_row, last_move_col, player, 1);
    end
  end
endmodule
