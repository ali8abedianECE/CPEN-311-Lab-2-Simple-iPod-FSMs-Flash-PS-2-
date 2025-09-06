`timescale 1ns/1ps

module Keyboard_controller_tb();

    localparam character_D = 8'h44;
    localparam character_E = 8'h45;
    localparam character_F = 8'h46;
    localparam character_B = 8'h42;
    localparam character_R = 8'h52;

    reg clk;
    reg kbd_data_ready;
    reg [7:0] kbd_received_ascii_code;

    wire play_enabled;
    wire direction;
    wire reset_address;
    wire reset_to_end;

    Keyboard_controller dut (
        .clk(clk),
        .kbd_data_ready(kbd_data_ready),
        .kbd_received_ascii_code(kbd_received_ascii_code),
        .play_enabled(play_enabled),
        .direction(direction),
        .reset_address(reset_address),
        .reset_to_end(reset_to_end)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    task check_outputs(
        input string testname,
        input expected_play_enabled,
        input expected_direction,
        input expected_reset_address,
        input expected_reset_to_end
    );
        #1;
        if (play_enabled !== expected_play_enabled ||
            direction !== expected_direction ||
            reset_address !== expected_reset_address ||
            reset_to_end !== expected_reset_to_end) begin
            $display("FAIL: %s | Got: play_enabled=%b, direction=%b, reset_address=%b, reset_to_end=%b",
                testname, play_enabled, direction, reset_address, reset_to_end);
        end else begin
            $display("PASS: %s", testname);
        end
    endtask

    task send_key(
        input [7:0] ascii_code
    );
        kbd_received_ascii_code = ascii_code;
        kbd_data_ready = 1;
        @(posedge clk);
        kbd_data_ready = 0;
        @(posedge clk);
    endtask

    initial begin
        kbd_data_ready = 0;
        kbd_received_ascii_code = 0;

        @(posedge clk);

        send_key(character_D);
        check_outputs("D", 0, 1, 0, 0);

        send_key(character_E);
        check_outputs("E", 1, 1, 0, 0);

        send_key(character_F);
        check_outputs("F", 1, 1, 0, 0);

        send_key(character_B);
        check_outputs("B", 1, 0, 0, 0);

        send_key(character_R);
        check_outputs("R", 1, 0, 0, 0);

        send_key(8'h41);
        check_outputs("Default", 0, 1, 0, 0);

        $finish;
    end

endmodule