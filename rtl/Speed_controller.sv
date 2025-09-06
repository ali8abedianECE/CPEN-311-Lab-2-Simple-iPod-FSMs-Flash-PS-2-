`define DIVIDER_RESET 16'd309
`define DIVIDER_MIN 16'd50
`define DIVIDER_MAX 16'd1500
`define DIVIDER_STEP 16'd2

module Speed_controller(clk, speed_reset_event, speed_up_event, speed_down_event, DIV_CONST);
    input clk;
    input speed_reset_event;
    input speed_up_event;
    input speed_down_event;

    output logic [15:0] DIV_CONST = `DIVIDER_RESET;

    always_ff @(posedge clk) begin
        if(speed_reset_event) begin
            DIV_CONST <= `DIVIDER_RESET;
        end else if(speed_up_event) begin
            if(DIV_CONST > `DIVIDER_MIN) begin 
                DIV_CONST <= DIV_CONST - `DIVIDER_STEP;
            end else begin
                DIV_CONST <= `DIVIDER_MIN; 
            end
        end else if(speed_down_event) begin
            if(DIV_CONST < `DIVIDER_MAX) begin 
                DIV_CONST <= DIV_CONST + `DIVIDER_STEP;
            end else begin
                DIV_CONST <= `DIVIDER_MAX; 
            end
        end else begin
            DIV_CONST <= DIV_CONST; 
        end
    end 

endmodule : Speed_controller