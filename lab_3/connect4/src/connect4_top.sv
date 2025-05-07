module connect4_top (
  input logic clk,
  input logic rst_switch,
  // Switches para seleccionar columna (3 bits = 8 posibilidades, usamos 7)
  input logic [2:0] column_select_switches,
  input logic move_confirm_button,
  // Botones para iniciar el juego
  input logic player1_start_button,
  input logic player2_start_button,
  // Outputs para displays y VGA
  output logic [6:0] display_units,
  output logic [6:0] display_tens,
  output logic CLK_VGA, 
  output logic SYNC_H, SYNC_V, SYNC_B, SYNC_BLANK, 
  output logic [7:0] vga_red, vga_green, vga_blue,
  // Señales de debug
  output logic debug_win_signal,
  output logic [2:0] debug_last_row,
  output logic [2:0] debug_last_col
);
  // Señales internas
  logic [2:0] player1_move, player2_move;
  logic player1_move_valid, player2_move_valid;
  logic [1:0] game_state;
  logic [1:0] board[5:0][6:0];
  logic [3:0] turn_timer;
  logic [1:0] current_player;
  
  // Señales para la línea ganadora
  logic [2:0] win_positions_row[0:3];
  logic [2:0] win_positions_col[0:3];
  logic [1:0] win_type;
  
  // Señales debounced
  logic reset_debounced;
  logic move_confirm_debounced;
  logic player1_start_debounced;
  logic player2_start_debounced;
  
  // Debounce para todas las entradas
  debounce reset_debounce(
    .clk(clk),
    .button(rst_switch),
    .pressed(reset_debounced)
  );
  
  debounce move_confirm_debounce(
    .clk(clk),
    .button(move_confirm_button),
    .pressed(move_confirm_debounced)
  );
  
  debounce player1_start_debounce(
    .clk(clk),
    .button(player1_start_button),
    .pressed(player1_start_debounced)
  );
  
  debounce player2_start_debounce(
    .clk(clk),
    .button(player2_start_button),
    .pressed(player2_start_debounced)
  );
  
  // Lógica para manejar los movimientos de los jugadores
  always_ff @(posedge clk) begin
    // Reset
    if (reset_debounced) begin
      player1_move <= 3'b000;
      player2_move <= 3'b000;
      player1_move_valid <= 1'b0;
      player2_move_valid <= 1'b0;
    end 
    else begin
      // Por defecto, invalidamos los movimientos en cada ciclo
      player1_move_valid <= 1'b0;
      player2_move_valid <= 1'b0;
      
      // Un solo botón para confirmar el movimiento, según el jugador actual
      if (move_confirm_debounced) begin
        if (current_player == 2'b01) begin
          // Turno del jugador 1
          player1_move <= column_select_switches;
          player1_move_valid <= 1'b1;
        end
        else if (current_player == 2'b10) begin
          // Turno del jugador 2
          player2_move <= column_select_switches;
          player2_move_valid <= 1'b1;
        end
      end
    end
  end
  
  // Instancia del juego Connect 4
  connect4 game(
    .clk(clk),
    .rst(reset_debounced),
    .player1_move(player1_move),
    .player2_move(player2_move),
    .player1_move_valid(player1_move_valid),
    .player2_move_valid(player2_move_valid),
    .player1_start(player1_start_debounced),
    .player2_start(player2_start_debounced),
    .game_state(game_state),
    .board(board),
    .turn_timer(turn_timer),
    .current_player(current_player),
    .debug_win_signal(debug_win_signal),
    .debug_last_row(debug_last_row),
    .debug_last_col(debug_last_col),
    .win_positions_row(win_positions_row),
    .win_positions_col(win_positions_col),
    .win_type(win_type)
  );
  
  // Controlador VGA
  vga_controller vga(
    .clk(clk),
    .board(board),
    .game_state(game_state),
    .current_player(current_player),
    .turn_timer(turn_timer),
    .column_selected(column_select_switches),
    .win_positions_row(win_positions_row),
    .win_positions_col(win_positions_col),
    .win_type(win_type),
    .CLK_VGA(CLK_VGA),
    .SYNC_H(SYNC_H),
    .SYNC_V(SYNC_V),
    .SYNC_B(SYNC_B),
    .SYNC_BLANK(SYNC_BLANK),
    .vga_red(vga_red),
    .vga_green(vga_green),
    .vga_blue(vga_blue)
  );
  
  // Display 7 segmentos para el temporizador
  timer_to_display timer_display(
    .timer_value(turn_timer),
    .display_units(display_units),
    .display_tens(display_tens)
  );
  
endmodule