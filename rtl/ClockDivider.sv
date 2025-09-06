module ClockDivider(clk_in, clk_out, n, reset); 
    parameter N = 25; 
    input clk_in, reset;
    output reg clk_out;
    input [N-1:0] n; 

    reg [N-1:0] counter; 

    always_ff @(posedge clk_in or posedge reset) begin 
        if(reset) begin 
            clk_out <= 0;
            counter <= 0;
        end else if(counter >= n - 1) begin 
            clk_out <= ~clk_out; 
            counter <= 0; 
        end else begin 
            counter <= counter + 1; 
            clk_out <= clk_out; 
        end 
    end 

endmodule : ClockDivider 