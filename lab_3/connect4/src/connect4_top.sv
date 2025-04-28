module connect4_top (
  input logic clk,
  input logic rst_switch,
  input logic [6:0] player1_buttons, // Un botón por columna
  input logic uart_rx,               // Datos del Arduino
  input logic player1_start_button,
  input logic player2_start_button,
  output logic [6:0] display_units,
  output logic [6:0] display_tens,
  output logic CLK_VGA, 
  output logic SYNC_H, SYNC_V, SYNC_B, SYNC_BLANK, 
  output logic [7:0] vga_red, vga_green, vga_blue
);
  // Señales internas
  logic [2:0] player1_move, player2_move;
  logic [1:0] game_state;
  logic [5:0][6:0] board;
  logic [3:0] turn_timer;
  logic [1:0] current_player;
  
  // Decodificar botones del jugador 1 (prioridad si múltiples botones)
  always_comb begin
    player1_move = 0;
    for (int i = 0; i < 7; i++) begin
      if (player1_buttons[i]) 
        player1_move = i;
    end
  end
  
  // UART para comunicación con Arduino
  //uart_receiver uart(
  //  .clk(clk),
  //  .rx(uart_rx),
  //  .data(player2_move)
  //);
  
  // Instancia del juego Connect 4
  connect4 game(
    .clk(clk),
    .rst(rst_switch),
    .player1_move(player1_move),
    .player2_move(player2_move),
    .player1_start(player1_start_button),
    .player2_start(player2_start_button),
    .game_state(game_state),
    .board(board),
    .turn_timer(turn_timer),
    .current_player(current_player)
  );
  
  // Controlador VGA
  vga_controller vga(
    .clk(clk),
    .board(board),
    .game_state(game_state),
    .current_player(current_player),
    .turn_timer(turn_timer),
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
  //bin_to_bcd_decoder timer_display(
  //  .bin_number(turn_timer),
  //  .bcd_number({display_tens, display_units})
  //);
endmodule