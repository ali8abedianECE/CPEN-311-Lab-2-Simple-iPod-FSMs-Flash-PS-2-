module Keyboard_controller(clk, kbd_data_ready, kbd_received_ascii_code, play_enabled,  direction,  reset_address, reset_to_end);

    parameter character_D = 8'h44;
    parameter character_E = 8'h45;
    parameter character_F = 8'h46;
    parameter character_B = 8'h42;
    parameter character_R = 8'h52;

    input clk;
    input kbd_data_ready;
    input [7:0] kbd_received_ascii_code;

    output reg play_enabled;
    output logic direction = 1'b1; 
    output reg reset_address;
    output reg reset_to_end;

    always_ff @(posedge clk) begin
        if(kbd_data_ready) begin
            case(kbd_received_ascii_code)
                character_D: begin
                    play_enabled <= 1'b0;
                    direction <= direction;
                    reset_address <= 1'b0;
                    reset_to_end <= 1'b0;
                end
                character_E: begin
                    play_enabled <= 1'b1;
                    direction <= direction;
                    reset_address <= 1'b0;
                    reset_to_end <= 1'b0;
                end
                character_F: begin
                    play_enabled <= play_enabled;
                    direction <= 1'b1;
                    reset_address <= 1'b0;
                    reset_to_end <= 1'b0;
                end
                character_B: begin
                    play_enabled <= play_enabled;
                    direction <= 1'b0;
                    reset_address <= 1'b0;
                    reset_to_end <= 1'b0;
                end
                character_R: begin
                    play_enabled <= play_enabled;
                    direction <= direction;
                    reset_address <= 1'b1;
                    reset_to_end <= ~direction;
                end
                default: begin
                    play_enabled <= play_enabled;
                    direction <= direction;
                    reset_address <= 1'b0;
                    reset_to_end <= 1'b0;
                end
            endcase
        end else begin
            play_enabled <= play_enabled;
            direction <= direction;
            reset_address <= 1'b0;
            reset_to_end <= 1'b0;
        end
    end

endmodule : Keyboard_controller