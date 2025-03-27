module top_module(
    input logic CLOCK_50,
    input logic [9:0] SW,
    input logic [2:0] KEY,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0,
    output logic [9:0] LEDR
);
    // Internal signals
    logic [3:0] operand_a, operand_b, alu_result, result_reg;
    logic [1:0] operation;
    logic result_valid, mode, is_negative, overflow, div_by_zero, error_flag;
    logic key0_pressed, key1_pressed, key2_pressed;
    
    // Debouncers
    debounce db_key0(CLOCK_50, ~KEY[0], key0_pressed);
    debounce db_key1(CLOCK_50, ~KEY[1], key1_pressed);
    debounce db_key2(CLOCK_50, ~KEY[2], key2_pressed);
    
    // ALU
    alu calculator(
        .a(operand_a),
        .b(operand_b),
        .opcode(operation),
        .result(alu_result),
        .is_negative(is_negative),
        .overflow(overflow),
        .div_by_zero(div_by_zero)
    );
    
    // Control Unit
    control_unit ctrl(
        .clk(CLOCK_50),
        .key0_pressed(key0_pressed),
        .key1_pressed(key1_pressed),
        .key2_pressed(key2_pressed),
        .sw_high(SW[7:4]),
        .sw_low(SW[3:0]),
        .overflow(overflow),
        .div_by_zero(div_by_zero),
        .alu_result(alu_result),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operation(operation),
        .result_reg(result_reg),
        .result_valid(result_valid),
        .error_flag(error_flag),
        .mode(mode)
    );
    
    // Display drivers
    bin_to_bcd_decoder disp_a(.bin_number(operand_a), .bcd_number(HEX3));
    bin_to_bcd_decoder disp_b(.bin_number(operand_b), .bcd_number(HEX2));
    
    // Status display
    assign HEX1 = (error_flag) ? 7'b0000110 :       // 'E'
                 (is_negative) ? 7'b0111111 :       // '-'
                 7'b1111111;                        // blank
    
    // Result display
    bin_to_bcd_decoder disp_res(
        .bin_number(result_valid ? result_reg : 4'b1111),
        .bcd_number(HEX0)
    );
    
    // LED indicators
    assign LEDR[9] = mode;
    assign LEDR[8] = error_flag;
    assign LEDR[7] = overflow;
    assign LEDR[6] = div_by_zero;
    assign LEDR[5] = is_negative;
    assign LEDR[4:0] = {3'b0, operation};
endmodule