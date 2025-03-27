module control_unit(
    input logic clk,
    input logic key0_pressed,
    input logic key1_pressed,
    input logic key2_pressed,
    input logic [3:0] sw_high,
    input logic [3:0] sw_low,
    output logic [3:0] operand_a,
    output logic [3:0] operand_b,
    output logic [3:0] operation,
    output logic result_valid,
    output logic mode
);
    always_ff @(posedge clk) begin
        if (key2_pressed) begin  // AC reset
            operand_a <= 4'b0;
            operand_b <= 4'b0;
            operation <= 4'b0;
            result_valid <= 1'b0;
            mode <= 1'b0;
        end
        else begin
            if (key0_pressed) begin
                mode <= ~mode;
                result_valid <= 1'b0;  // Clear result when changing modes
            end
            
            // Store calculation result when KEY1 is pressed
            if (key1_pressed && mode) begin
                result_valid <= 1'b1;
            end
            
            if (~mode) begin
                operand_a <= sw_high;  // SW[7:4]
                operand_b <= sw_low;   // SW[3:0]
            end 
            else begin
                operation <= sw_low;   // SW[3:0]
            end
        end
    end
endmodule