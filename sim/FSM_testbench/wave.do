onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /FSM_tb/Trigger
add wave -noupdate -radix unsigned /FSM_tb/audio_sample
add wave -noupdate /FSM_tb/clk
add wave -noupdate /FSM_tb/direction
add wave -noupdate /FSM_tb/err
add wave -noupdate -radix unsigned /FSM_tb/expected_address
add wave -noupdate -radix unsigned /FSM_tb/flash_mem_address
add wave -noupdate /FSM_tb/flash_mem_read
add wave -noupdate -radix unsigned /FSM_tb/flash_mem_readdata
add wave -noupdate /FSM_tb/flash_mem_readdatavalid
add wave -noupdate /FSM_tb/flash_mem_waitrequest
add wave -noupdate /FSM_tb/play_enabled
add wave -noupdate /FSM_tb/reset_address
add wave -noupdate /FSM_tb/reset_to_end
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 213
configure wave -valuecolwidth 185
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1184 ps}
