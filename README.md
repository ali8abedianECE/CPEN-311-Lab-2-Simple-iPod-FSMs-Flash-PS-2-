# Simple iPod — CPEN 311 Lab 2

A small "iPod-style" audio player implementation that reads audio samples from on-board Flash memory and streams them to an audio DAC. Features PS/2 keyboard control for playback operations and on-board keys for speed control.

---

## Project Structure

- **Quartus/RTL** — Top-level module and sub-modules
- **sim/** — ModelSim testbenches with simulation screenshots
- **.SOF file** — Located in `rtl/` directory for programming the board

---

## Target Boards

### DE2 Board
- **Flash Interface**: Direct S29GL032N flash chip interface
- **Signals**: `FL_DQ`, `FL_ADDR`, `FL_WE_N`, `FL_RST_N`, `FL_OE_N`, `FL_CE_N`
- **Configuration**: Read-only mode (`FL_WE_N=1`, `FL_RST_N=1`)

### DE1-SoC Board
- **Flash Interface**: Altera Generic Quad SPI Flash controller via Avalon-MM
- **Signals**: `flash_mem_*` signals
- **Read Protocol**: Uses `waitrequest`/`readdatavalid` handshaking

---

## Controls

### PS/2 Keyboard Commands
| Key | Function |
|-----|----------|
| `E` | Play |
| `D` | Stop |
| `B` | Backward |
| `F` | Forward |
| `R` | Restart (Bonus Feature - +5%) |

### Board Keys
| Key | Function |
|-----|----------|
| `KEY0` | Speed Up |
| `KEY1` | Speed Down |
| `KEY2` | Reset to 22 kHz |

---

## Audio Specifications

- **Sample Rate**: 22,000 Hz (one sample every ~0.045 ms)
- **Clock Generation**: 22 kHz derived from `TD_CLK27` (27 MHz)
- **Synchronization**: Edge-detection of 22 kHz tick drives FSM (asynchronous to 50 MHz system clock)

---

## Flash Memory Layout

### DE2 Board
- **Address Unit**: Byte index (8-bit data)
- **16-bit Sample Storage**: Consecutive bytes (LSB at even address, MSB at odd address)
- **Address Range**: First sample at 0x0/0x1, last sample at 0x1FFFFE/0x1FFFFF

### DE1-SoC Board
- **Address Unit**: Word index (32-bit data)
- **Sample Packing**: Two 16-bit samples per word (lower 16 bits, then upper 16 bits)
- **Address Range**: First sample at word 0 (bits 15:0), last sample at word 0x7FFFF (bits 31:16)

---

## State machines (model used)

Below is the **Flash Read / Output FSM** as implemented (state names and transitions match the screenshot model).

### States
- `IDLE`
- `READ_REQ`
- `WAIT`
- `Lower_HALF_1`
- `Upper_HALF_1`
- `Lower_HALF_2`
- `Upper_HALF_2`

### Transitions 
- **Global**:  
  - From **any state** → **IDLE** if `reset_address` is asserted or `!play_enabled`.
- **IDLE**  
  - Default/entry via `reset_address`.  
  - `IDLE → READ_REQ` on `(Trigger && play_enabled)`.
- **READ_REQ**  
  - Self-loop while `flash_mem_waitrequest` is **1**.  
  - `READ_REQ → WAIT` when `!flash_mem_waitrequest`.
- **WAIT**  
  - `WAIT → Lower_HALF_1` when `flash_mem_readdatavalid` is **1**.
- **Lower_HALF_1**  
  - `Lower_HALF_1 → Upper_HALF_1` on `(Trigger && play_enabled)`.
- **Upper_HALF_1**  
  - `Upper_HALF_1 → Lower_HALF_2` on `(Trigger && play_enabled)`.
- **Lower_HALF_2**  
  - `Lower_HALF_2 → Upper_HALF_2` on `(Trigger && play_enabled)`.
- **Upper_HALF_2**  
  - `Upper_HALF_2 → IDLE` on `(Trigger && play_enabled)`.

### Diagram
```mermaid
stateDiagram-v2
    direction TB

    [*] --> IDLE

    state "READ_REQ" as READ_REQ
    state "WAIT" as WAIT
    state "Lower_HALF_1" as LOWER1
    state "Upper_HALF_1" as UPPER1
    state "Lower_HALF_2" as LOWER2
    state "Upper_HALF_2" as UPPER2

    %% Main flow
    IDLE --> READ_REQ: Trigger && play_enabled
    READ_REQ --> READ_REQ: flash_mem_waitrequest
    READ_REQ --> WAIT: !flash_mem_waitrequest
    WAIT --> LOWER1: flash_mem_readdatavalid
    LOWER1 --> UPPER1: Trigger && play_enabled
    UPPER1 --> LOWER2: Trigger && play_enabled
    LOWER2 --> UPPER2: Trigger && play_enabled
    UPPER2 --> IDLE:  Trigger && play_enabled

    %% Global return-to-IDLE (reset or pause)
    IDLE   --> IDLE: reset_address || !play_enabled
    READ_REQ --> IDLE: reset_address || !play_enabled
    WAIT   --> IDLE: reset_address || !play_enabled
    LOWER1 --> IDLE: reset_address || !play_enabled
    UPPER1 --> IDLE: reset_address || !play_enabled
    LOWER2 --> IDLE: reset_address || !play_enabled
    UPPER2 --> IDLE: reset_address || !play_enabled
