`timescale 1ns/1ps

`define DIVIDER_RESET 16'd613
`define DIVIDER_MIN 16'd200
`define DIVIDER_MAX 16'd2000
`define DIVIDER_STEP 16'd3

module Speed_controlled_tb();

    logic clk;
    logic speed_reset_event;
    logic speed_up_event;
    logic speed_down_event;
    logic [15:0] DIV_CONST;
    logic [15:0] ref_DIV_CONST;

    Speed_controller dut (
        .clk(clk),
        .speed_reset_event(speed_reset_event),
        .speed_up_event(speed_up_event),
        .speed_down_event(speed_down_event),
        .DIV_CONST(DIV_CONST)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    task automatic apply_reset();
        begin
            speed_reset_event = 1;
            speed_up_event = 0;
            speed_down_event = 0;
            @(posedge clk);
            speed_reset_event = 0;
            @(posedge clk);
        end
    endtask : apply_reset

    task automatic apply_speed_up();
        begin
            speed_up_event = 1;
            speed_reset_event = 0;
            speed_down_event = 0;
            @(posedge clk);
            speed_up_event = 0;
            @(posedge clk);
        end
    endtask : apply_speed_up

    task automatic apply_speed_down();
        begin
            speed_down_event = 1;
            speed_reset_event = 0;
            speed_up_event = 0;
            @(posedge clk);
            speed_down_event = 0;
            @(posedge clk);
        end
    endtask : apply_speed_down

    task automatic check_output(string testname);
        begin
            if (DIV_CONST !== ref_DIV_CONST) begin
                $display("FAIL: %s -- Expected: %0d, Got: %0d", testname, ref_DIV_CONST, DIV_CONST);
            end else begin
                $display("PASS: %s -- DIV_CONST: %0d", testname, DIV_CONST);
            end
        end
    endtask : check_output

    task automatic update_ref(input logic reset, input logic up, input logic down);
        begin
            if (reset) begin
                ref_DIV_CONST = `DIVIDER_RESET;
            end else if (up) begin
                if (ref_DIV_CONST > `DIVIDER_MIN)
                    ref_DIV_CONST = ref_DIV_CONST - `DIVIDER_STEP;
                else
                    ref_DIV_CONST = `DIVIDER_MIN;
            end else if (down) begin
                if (ref_DIV_CONST < `DIVIDER_MAX)
                    ref_DIV_CONST = ref_DIV_CONST + `DIVIDER_STEP;
                else
                    ref_DIV_CONST = `DIVIDER_MAX;
            end
        end
    endtask : update_ref

    initial begin
        speed_reset_event = 0;
        speed_up_event = 0;
        speed_down_event = 0;
        ref_DIV_CONST = `DIVIDER_RESET;

        repeat(2) @(posedge clk);

        apply_reset();
        update_ref(1,0,0);
        check_output("Reset");

        repeat(5) begin
            apply_speed_up();
            update_ref(0,1,0);
            check_output("Speed Up");
        end

        repeat(5) begin
            apply_speed_down();
            update_ref(0,0,1);
            check_output("Speed Down");
        end

        $display("All tests completed.");
        $finish;
    end

endmodule : Speed_controlled_tb
