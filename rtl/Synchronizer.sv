module Synchronizer(clk, in_signal, Trigger);
    input clk;         
    input in_signal;   

    output reg Trigger;

    reg sync1, sync2, sync3;

    always_ff @(posedge clk) begin
        sync1 <= in_signal;
        sync2 <= sync1;
        sync3 <= sync2;
        Trigger <= sync2 & ~sync3;
    end

endmodule : Synchronizer
