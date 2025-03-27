module control_unit(
    input logic clk,
    input logic key0_pressed,
    input logic key1_pressed,
    input logic key2_pressed,
    input logic [3:0] sw_high,
    input logic [3:0] sw_low,
    input logic overflow,
    input logic div_by_zero,
    input logic [3:0] alu_result,
    output logic [3:0] operand_a,
    output logic [3:0] operand_b,
    output logic [1:0] operation,
    output logic [3:0] result_reg,
    output logic result_valid,
    output logic error_flag,
    output logic mode
);
    always_ff @(posedge clk) begin
        if (key2_pressed) begin  // AC reset
            operand_a <= 4'b0;
            operand_b <= 4'b0;
            operation <= 2'b0;
            result_reg <= 4'b0;
            result_valid <= 1'b0;
            error_flag <= 1'b0;
            mode <= 1'b0;
        end
        else begin
            if (key0_pressed) begin
                mode <= ~mode;
                result_valid <= 1'b0;
                error_flag <= 1'b0;
            end
            
            if (key1_pressed && mode) begin
                result_reg <= alu_result;
                result_valid <= 1'b1;
                error_flag <= overflow | div_by_zero;
            end
            
            if (~mode) begin
                operand_a <= sw_high;
                operand_b <= sw_low;
            end 
            else begin
                operation <= sw_low[1:0];
            end
        end
    end
endmodule