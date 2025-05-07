module move_validator(
  input logic [2:0] column,
  input logic [1:0] board[5:0][6:0],
  output logic valid,
  output logic [2:0] empty_row
);
  always_comb begin
    valid = 0;
    empty_row = 3'b111; // Default to invalid
    
    if (column < 7) begin
      // Check if column is not full
      if (board[0][column] == 2'b00) begin
        // Find first empty row from bottom
        for (int row = 5; row >= 0; row--) begin
          if (board[row][column] == 2'b00) begin
            valid = 1;
            empty_row = row;
            break;
          end
        end
      end
    end
  end

  // Enhanced debug
  always @* begin
    if (valid) begin
      if (empty_row > 5) begin
        $display("[ERROR] Invalid empty_row: %0d", empty_row);
      end
      else if (board[empty_row][column] != 2'b00) begin
        $display("[WARNING] Potential race condition:");
        $display("Validator says row %0d is empty but board shows %b", 
                empty_row, board[empty_row][column]);
      end
    end
  end
endmodule