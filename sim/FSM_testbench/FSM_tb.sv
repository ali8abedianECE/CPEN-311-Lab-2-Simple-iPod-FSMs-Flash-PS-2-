`define STATE_IDLE         3'b000
`define STATE_READ_REQUEST 3'b001
`define STATE_WAIT_FOR_DATA 3'b010
`define STATE_LOWER_HALF   3'b011
`define STATE_UPPER_HALF   3'b100

module FSM_tb(); 

    reg err; 
    reg clk, Trigger, reset_address, reset_to_end, play_enabled, direction;
    reg [31:0] flash_mem_readdata;
    wire [15:0] audio_sample;
    wire [22:0] flash_mem_address;
    wire flash_mem_read;
    reg flash_mem_waitrequest, flash_mem_readdatavalid;
    reg [22:0] expected_address; 

    FSM uut (
        .clk(clk),
        .Trigger(Trigger),
        .reset_address(reset_address),
        .reset_to_end(reset_to_end),
        .play_enabled(play_enabled),
        .direction(direction),
        .audio_sample(audio_sample),
        .flash_mem_readdata(flash_mem_readdata),
        .flash_mem_address(flash_mem_address),
        .flash_mem_read(flash_mem_read),
        .flash_mem_waitrequest(flash_mem_waitrequest),
        .flash_mem_readdatavalid(flash_mem_readdatavalid)
    );

    task wait_for_state(input [2:0] exp_state);
        while (uut.STATE !== exp_state) @(posedge clk);
    endtask

    task wait_for_flash_mem_read();
        while (!flash_mem_read) @(posedge clk);
    endtask

    task wait_for_flash_mem_read_deassert();
        while (flash_mem_read) @(posedge clk);
    endtask

    task wait_for_audio_sample();
        reg [15:0] prev_sample;
        prev_sample = audio_sample;
        @(posedge clk);
        while (audio_sample === prev_sample) @(posedge clk);
    endtask

    task Triggerer();
        @(posedge clk);
        reset_address = 0;
        reset_to_end = 0;
        play_enabled = 1;
        Trigger = 1;
        @(posedge clk);
        Trigger = 0;
    endtask

    task transition_state_Data_To_Lower_Half(input [31:0] data);
        wait_for_state(`STATE_READ_REQUEST);
        flash_mem_waitrequest = 0;
        @(posedge clk);
        wait_for_state(`STATE_WAIT_FOR_DATA);
        flash_mem_readdatavalid = 1;
        flash_mem_readdata = data;
        @(posedge clk);
        flash_mem_readdatavalid = 0;
        wait_for_state(`STATE_LOWER_HALF);
        @(posedge clk);
        if (uut.DATA !== data) begin
            err = 1;
            $display("ERROR: DATA mismatch. Expected: %h, Got: %h", data, uut.DATA);
            $stop;
        end
        if (audio_sample !== data[15:0]) begin
            err = 1;
            $display("ERROR: audio_sample mismatch. Expected: %h, Got: %h", data[15:0], audio_sample);
            $stop;
        end
    endtask

    task transition_state_Lower_Half_To_Upper_Half();
        wait_for_state(`STATE_IDLE);
        Trigger = 1;
        @(posedge clk);
        Trigger = 0;
        wait_for_state(`STATE_UPPER_HALF);
        @(posedge clk); 
        if (audio_sample !== uut.DATA[31:16]) begin
            err = 1;
            $display("ERROR: audio_sample upper half mismatch. Expected: %h, Got: %h", uut.DATA[31:16], audio_sample);
            $stop;
        end
    endtask

    task check_address(input [22:0] exp_addr);
        if (uut.ADDRESS !== exp_addr) begin
            err = 1;
            $display("ERROR: ADDRESS mismatch. Expected: %h, Got: %h", exp_addr, uut.ADDRESS);
            $stop;
        end
    endtask

    initial begin 
        clk = 0;
        forever begin
            #5 clk = ~clk; 
        end
    end

    initial begin 
        err = 0; 
        reset_address = 1;
        reset_to_end = 0;
        play_enabled = 0;
        Trigger = 0;
        flash_mem_waitrequest = 0;
        flash_mem_readdatavalid = 0;
        flash_mem_readdata = 32'h00000000;
        direction = 1; 
        expected_address = 23'h000000;
        @(posedge clk);
        reset_address = 0;
        @(posedge clk);

        for (integer i = 0; i < 1000; i = i + 1) begin
            Triggerer();
            transition_state_Data_To_Lower_Half({i, i});
            check_address(expected_address);
            transition_state_Lower_Half_To_Upper_Half();
            wait_for_state(`STATE_IDLE);
            expected_address = expected_address + 1;
        end

        reset_address = 1;
        @(posedge clk);
        reset_address = 0;
        expected_address = 23'h000000;
        @(posedge clk);

        Triggerer();
        transition_state_Data_To_Lower_Half(32'h55AA55AA);
        check_address(expected_address);
        transition_state_Lower_Half_To_Upper_Half();
        wait_for_state(`STATE_IDLE);

        for (integer i = 0; i < 1000; i = i + 1) begin
            if (direction)
                expected_address = expected_address + 1;
            else
                expected_address = expected_address - 1;
            Triggerer();
            transition_state_Data_To_Lower_Half({i, i});
            check_address(expected_address);
            transition_state_Lower_Half_To_Upper_Half();
            wait_for_state(`STATE_IDLE);
        end

        reset_address = 1;
        reset_to_end = 1;
        @(posedge clk);
        reset_address = 0;
        reset_to_end = 0;
        expected_address = 23'h7FFFF;
        direction = 0; 
        @(posedge clk);

        Triggerer();
        transition_state_Data_To_Lower_Half(32'hA5A5A5A5);
        check_address(expected_address);
        transition_state_Lower_Half_To_Upper_Half();
        wait_for_state(`STATE_IDLE);

        for (integer i = 0; i < 1000; i = i + 1) begin
            if (direction)
                expected_address = expected_address + 1;
            else
                expected_address = expected_address - 1;
            Triggerer();
            transition_state_Data_To_Lower_Half({i, i});
            check_address(expected_address);
            transition_state_Lower_Half_To_Upper_Half();
            wait_for_state(`STATE_IDLE);
        end

        if (err == 0) begin
            $display("All tests passed.");
        end
        $stop;
    end

endmodule : FSM_tb
