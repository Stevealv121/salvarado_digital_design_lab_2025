module top_module(
    input logic CLOCK_50,
    input logic [9:0] SW,
    input logic [2:0] KEY,
    output logic [6:0] HEX3,  // Operand A (SW[7:4])
    output logic [6:0] HEX2,  // Operand B (SW[3:0])
    output logic [6:0] HEX1,  // Negative sign
    output logic [6:0] HEX0,  // Result
    output logic [9:0] LEDR
);
    // Internal signals
    logic [3:0] operand_a, operand_b, operation;
    logic [3:0] alu_result;
    logic result_valid, mode, alu_is_negative;
    logic key0_pressed, key1_pressed, key2_pressed;
    
    // Debouncers
    debounce db_key0(CLOCK_50, ~KEY[0], key0_pressed);
    debounce db_key1(CLOCK_50, ~KEY[1], key1_pressed);
    debounce db_key2(CLOCK_50, ~KEY[2], key2_pressed);
    
    // Control Unit (now only manages state)
    control_unit ctrl(
        .clk(CLOCK_50),
        .key0_pressed(key0_pressed),
        .key1_pressed(key1_pressed),
        .key2_pressed(key2_pressed),
        .sw_high(SW[7:4]),
        .sw_low(SW[3:0]),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operation(operation),
        .result_valid(result_valid),
        .mode(mode)
    );
    
    // ALU (only computes results)
    alu calculator(
        .a(operand_a),
        .b(operand_b),
        .opcode(operation),
        .result(alu_result),
        .is_negative(alu_is_negative)
    );
    
    // Display drivers
    bin_to_bcd_decoder disp_a(.bin_number(operand_a), .bcd_number(HEX3));
    bin_to_bcd_decoder disp_b(.bin_number(operand_b), .bcd_number(HEX2));
    assign HEX1 = (alu_is_negative & result_valid) ? 7'b0111111 : 7'b1111111;
    bin_to_bcd_decoder disp_res(.bin_number(result_valid ? alu_result : 4'b1111), .bcd_number(HEX0));
    
    // LED indicators
    assign LEDR[9] = mode;
    assign LEDR[4] = alu_is_negative & result_valid;
    assign LEDR[3:0] = operation;
endmodule