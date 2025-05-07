module win_detector(
  input logic [1:0] board[5:0][6:0],     // 6 rows x 7 columns (0=empty, 1=player1, 2=player2)
  input logic [2:0] last_move_row,       // Row of last move (0-5)
  input logic [2:0] last_move_col,       // Column of last move (0-6)
  input logic [1:0] player,              // Player to check (1 or 2)
  output logic win,                      // 1 if player won, 0 otherwise
  // Nuevas salidas para la línea ganadora
  output logic [2:0] win_positions_row[0:3],  // Filas de las posiciones ganadoras
  output logic [2:0] win_positions_col[0:3],  // Columnas de las posiciones ganadoras
  output logic [1:0] win_type             // Tipo de victoria: 0=horizontal, 1=vertical, 2=diagonal\, 3=diagonal/
);

  function automatic logic check_diagonal_win(
    input logic [1:0] board[5:0][6:0],
    input logic [2:0] row,
    input logic [2:0] col,
    input logic [1:0] player,
    input logic direction, // 0: diagonal \, 1: diagonal /
    output logic [2:0] win_rows[0:3],
    output logic [2:0] win_cols[0:3]
  );
    logic [3:0] count = 1;  // Start with current position
    logic [31:0] i, j;
    logic [31:0] index = 0;
    logic [2:0] temp_rows[0:3];
    logic [2:0] temp_cols[0:3];
    
    // Inicializar con la posición actual
    win_rows[0] = row;
    win_cols[0] = col;

    // Check in negative direction (up-left or up-right)
    for (int offset = 1; offset < 4; offset++) begin
      if (!direction) begin // Diagonal 
        i = row - offset;
        j = col - offset;
      end else begin        // Diagonal /
        i = row - offset;
        j = col + offset;
      end
      
      if (i >= 0 && j >= 0 && j < 7 && board[i][j] == player) begin
        count++;
        if (index < 3) begin
          index++;
          win_rows[index] = i;
          win_cols[index] = j;
        end
      end else
        break;
    end

    // Reset index para la otra dirección
    index = 0;
    
    // Initialize temporary arrays
    temp_rows[0] = row;
    temp_cols[0] = col;

    // Check in positive direction (down-right or down-left)
    for (int offset = 1; offset < 4; offset++) begin
      if (!direction) begin // Diagonal 
        i = row + offset;
        j = col + offset;
      end else begin        // Diagonal /
        i = row + offset;
        j = col - offset;
      end
      
      if (i < 6 && j >= 0 && j < 7 && board[i][j] == player) begin
        count++;
        if (index < 3) begin
          index++;
          temp_rows[index] = i;
          temp_cols[index] = j;
        end
      end else
        break;
    end
    
    // Si ganamos en esta dirección, pero necesitamos actualizar las posiciones
    // desde la segunda dirección (ya que el orden importa para la visualización)
    if (count >= 4 && index > 0) begin
      for (int k = 1; k <= index && k <= 3; k++) begin
        win_rows[3-(k-1)] = temp_rows[k];
        win_cols[3-(k-1)] = temp_cols[k];
      end
    end

    return (count >= 4);
  endfunction

  // Declare all variables outside always_comb
  logic [3:0] h_count, v_count;
  logic h_win, v_win, d1_win, d2_win;
  
  // Arrays temporales para cada dirección
  logic [2:0] h_rows[0:3], h_cols[0:3];
  logic [2:0] v_rows[0:3], v_cols[0:3];
  logic [2:0] d1_rows[0:3], d1_cols[0:3];
  logic [2:0] d2_rows[0:3], d2_cols[0:3];
  
  // Variables for indices
  logic [31:0] h_index, h_index_right, v_index, v_index_below;
  logic [2:0] h_rows_right[0:3], h_cols_right[0:3];
  logic [2:0] v_rows_below[0:3], v_cols_below[0:3];

  always_comb begin
    // Default values
    win = 0;
    h_count = 1;
    v_count = 1;
    h_win = 0;
    v_win = 0;
    d1_win = 0;
    d2_win = 0;
    win_type = 2'b00;
    
    // Initialize indices
    h_index = 0;
    h_index_right = 0;
    v_index = 0;
    v_index_below = 0;
    
    // Inicializar posiciones ganadoras con valores por defecto
    for (int i = 0; i < 4; i++) begin
      win_positions_row[i] = 3'b0;
      win_positions_col[i] = 3'b0;
      
      h_rows[i] = 3'b0;
      h_cols[i] = 3'b0;
      v_rows[i] = 3'b0;
      v_cols[i] = 3'b0;
      d1_rows[i] = 3'b0;
      d1_cols[i] = 3'b0;
      d2_rows[i] = 3'b0;
      d2_cols[i] = 3'b0;
      
      h_rows_right[i] = 3'b0;
      h_cols_right[i] = 3'b0;
      v_rows_below[i] = 3'b0;
      v_cols_below[i] = 3'b0;
    end
    
    // Only check if the position isn't empty
    if (board[last_move_row][last_move_col] == player) begin
      // Inicializar con la posición actual para todos los tipos
      h_rows[0] = last_move_row;
      h_cols[0] = last_move_col;
      v_rows[0] = last_move_row;
      v_cols[0] = last_move_col;
      
      // Check horizontal
      // Check left
      for (int offset = 1; offset < 4; offset++) begin
        if (last_move_col >= offset && 
            board[last_move_row][last_move_col - offset] == player) begin
          h_count++;
          if (h_index < 3) begin
            h_index++;
            h_rows[h_index] = last_move_row;
            h_cols[h_index] = last_move_col - offset;
          end
        end else
          break;
      end
      
      // Check right
      h_rows_right[0] = last_move_row;
      h_cols_right[0] = last_move_col;
      
      for (int offset = 1; offset < 4; offset++) begin
        if (last_move_col + offset < 7 && 
            board[last_move_row][last_move_col + offset] == player) begin
          h_count++;
          if (h_index_right < 3) begin
            h_index_right++;
            h_rows_right[h_index_right] = last_move_row;
            h_cols_right[h_index_right] = last_move_col + offset;
          end
        end else
          break;
      end
      
      h_win = (h_count >= 4);
      
      // Si hay victoria horizontal, asegurar que las posiciones estén en orden
      if (h_win) begin
        for (int k = 1; k <= h_index_right && k <= 3; k++) begin
          h_rows[3-(k-1)] = h_rows_right[k];
          h_cols[3-(k-1)] = h_cols_right[k];
        end
      end

      // Check vertical
      // Check above
      for (int offset = 1; offset < 4; offset++) begin
        if (last_move_row >= offset && 
            board[last_move_row - offset][last_move_col] == player) begin
          v_count++;
          if (v_index < 3) begin
            v_index++;
            v_rows[v_index] = last_move_row - offset;
            v_cols[v_index] = last_move_col;
          end
        end else
          break;
      end
      
      // Check below
      v_rows_below[0] = last_move_row;
      v_cols_below[0] = last_move_col;
      
      for (int offset = 1; offset < 4; offset++) begin
        if (last_move_row + offset < 6 && 
            board[last_move_row + offset][last_move_col] == player) begin
          v_count++;
          if (v_index_below < 3) begin
            v_index_below++;
            v_rows_below[v_index_below] = last_move_row + offset;
            v_cols_below[v_index_below] = last_move_col;
          end
        end else
          break;
      end
      
      v_win = (v_count >= 4);
      
      // Si hay victoria vertical, asegurar que las posiciones estén en orden
      if (v_win) begin
        for (int k = 1; k <= v_index_below && k <= 3; k++) begin
          v_rows[3-(k-1)] = v_rows_below[k];
          v_cols[3-(k-1)] = v_cols_below[k];
        end
      end

      // Check diagonals
      d1_win = check_diagonal_win(board, last_move_row, last_move_col, player, 0, d1_rows, d1_cols);
      d2_win = check_diagonal_win(board, last_move_row, last_move_col, player, 1, d2_rows, d2_cols);

      // Final win determination
      win = h_win || v_win || d1_win || d2_win;
      
      // Determinar tipo de victoria y asignar posiciones ganadoras
      if (h_win) begin
        win_type = 2'b00; // Horizontal
        for (int i = 0; i < 4; i++) begin
          win_positions_row[i] = h_rows[i];
          win_positions_col[i] = h_cols[i];
        end
      end else if (v_win) begin
        win_type = 2'b01; // Vertical
        for (int i = 0; i < 4; i++) begin
          win_positions_row[i] = v_rows[i];
          win_positions_col[i] = v_cols[i];
        end
      end else if (d1_win) begin
        win_type = 2'b10; // Diagonal
        for (int i = 0; i < 4; i++) begin
          win_positions_row[i] = d1_rows[i];
          win_positions_col[i] = d1_cols[i];
        end
      end else if (d2_win) begin
        win_type = 2'b11; // Diagonal /
        for (int i = 0; i < 4; i++) begin
          win_positions_row[i] = d2_rows[i];
          win_positions_col[i] = d2_cols[i];
        end
      end
    end
  end
endmodule