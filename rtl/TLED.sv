module TLED(LEDS, clock_for_LED); 

    input clock_for_LED;
    output [7:0] LEDS;
    
    reg goBack;
    reg [7:0] LED;

    assign LEDS = LED[7:0];

    //LED toggeler uses if statments and is flip flops. 
    always_ff @(posedge clock_for_LED) begin 
        if(LED[7:0] == 8'b00000001) begin
            LED[7:0] <= 8'b00000010;
            goBack <= 1'b0;
        end else if(LED[7:0] == 8'b00000010 && ~goBack) begin
            LED[7:0] <= 8'b00000100;
            goBack <= 1'b0;
        end else if(LED[7:0] == 8'b00000100 && ~goBack) begin
            LED[7:0] <= 8'b00001000;
            goBack <= 1'b0;
        end else if(LED[7:0] == 8'b00001000 && ~goBack) begin
            LED[7:0] <= 8'b00010000;
            goBack <= 1'b0;
        end else if(LED[7:0] == 8'b00010000 && ~goBack) begin
            LED[7:0] <= 8'b00100000;
            goBack <= 1'b0;
        end else if(LED[7:0] == 8'b00100000 && ~goBack) begin
            LED[7:0] <= 8'b01000000;
            goBack <= 1'b0;
        end else if(LED[7:0] == 8'b01000000 && ~goBack) begin
            LED[7:0] <= 8'b10000000;
            goBack <= 1'b0;
        end else if(LED[7:0] == 8'b10000000) begin
            LED[7:0] <= 8'b01000000;
            goBack <= 1'b1;
        end else if(LED[7:0] == 8'b01000000 && goBack) begin 
            LED[7:0] <= 8'b00100000;
            goBack <= 1'b1;
        end else if(LED[7:0] == 8'b00100000 && goBack) begin 
            LED[7:0] <= 8'b00010000;
            goBack <= 1'b1;
        end else if(LED[7:0] == 8'b00010000 && goBack) begin 
            LED[7:0] <= 8'b00001000;
            goBack <= 1'b1;
        end else if(LED[7:0] == 8'b00001000 && goBack) begin 
            LED[7:0] <= 8'b00000100;
            goBack <= 1'b1;
        end else if(LED[7:0] == 8'b00000100 && goBack) begin 
            LED[7:0] <= 8'b00000010;
            goBack <= 1'b1; 
        end else if(LED[7:0] == 8'b00000010 && goBack) begin
            LED[7:0] <= 8'b00000001;
            goBack <= 1'b0;
        end else begin
            LED[7:0] <= 8'b00000001;
            goBack <= 1'b0;
        end
    end

endmodule : TLED