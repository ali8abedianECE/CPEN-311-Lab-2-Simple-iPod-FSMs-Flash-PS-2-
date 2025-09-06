`define STATE_IDLE 3'b000
`define STATE_READ_REQUEST 3'b001
`define STATE_WAIT_FOR_DATA 3'b010
`define STATE_LOWER_HALF 3'b011
`define STATE_UPPER_HALF 3'b100

module FSM(clk, Trigger, reset_address, reset_to_end, play_enabled, direction, 
            audio_sample, 
            flash_mem_readdata, flash_mem_address, 
            flash_mem_read, flash_mem_waitrequest, flash_mem_readdatavalid);

    input clk;
    input Trigger;

    input reset_address;
    input reset_to_end;
    input play_enabled;
    input direction;
        
    input flash_mem_waitrequest;
    input flash_mem_readdatavalid;
    input [31:0] flash_mem_readdata;

    output reg [15:0] audio_sample;
    output reg [22:0] flash_mem_address;
    output reg flash_mem_read;

    reg [2:0] STATE;
    reg [31:0] DATA;
    reg [22:0] ADDRESS;
    reg new_word_need_flag;

    always_ff @(posedge clk or posedge reset_address) begin
        if(reset_address) begin
            ADDRESS <= reset_to_end ? 23'h7FFFF : 23'd0;
            STATE <= `STATE_IDLE;
            new_word_need_flag <= 1'b1;
            flash_mem_read <= 1'b0;
        end else if(!play_enabled) begin
            STATE <= `STATE_IDLE;
            flash_mem_read <= 1'b0;
        end else begin
            case(STATE)
                `STATE_IDLE: begin
                    if(Trigger && play_enabled) begin
                        if(new_word_need_flag) begin
                            flash_mem_read <= 1'b1;
                            flash_mem_address <= ADDRESS;
                            STATE <= `STATE_READ_REQUEST;
                        end else begin
                            STATE <= `STATE_UPPER_HALF;
                        end
                    end else begin
                        STATE <= `STATE_IDLE;
                        flash_mem_read <= 1'b0;
                    end
                end

                `STATE_READ_REQUEST: begin
                    if(!flash_mem_waitrequest) begin
                        flash_mem_read <= 1'b0;
                        STATE <= `STATE_WAIT_FOR_DATA;
                    end else begin
                        flash_mem_read <= 1'b1;
                        flash_mem_address <= ADDRESS;
                        STATE <= `STATE_READ_REQUEST;
                    end
                end

                `STATE_WAIT_FOR_DATA: begin
                    if(flash_mem_readdatavalid) begin
                        DATA <= flash_mem_readdata;
                        STATE <= `STATE_LOWER_HALF;
                    end else begin
                        STATE <= `STATE_WAIT_FOR_DATA;
                    end
                end

                `STATE_LOWER_HALF: begin
                    audio_sample <= DATA[15:0];
                    new_word_need_flag <= 1'b0;
                    STATE <= `STATE_IDLE;
                end

                `STATE_UPPER_HALF: begin
                    audio_sample <= DATA[31:16];
                    new_word_need_flag <= 1'b1;
                    if(direction) begin
                        if(ADDRESS >= 23'h7FFFF) begin 
                            ADDRESS <= 0;
                        end else begin 
                            ADDRESS <= ADDRESS + 1;
                        end 
                    end else begin
                        if(ADDRESS == 0) begin 
                            ADDRESS <= 23'h7FFFF;
                        end else begin 
                            ADDRESS <= ADDRESS - 1;
                        end 
                    end
                    STATE <= `STATE_IDLE;
                end
            endcase
        end
    end

endmodule : FSM
