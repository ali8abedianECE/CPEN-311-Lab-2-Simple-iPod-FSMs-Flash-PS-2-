# Simple iPod — CPEN 311 Lab 2

Small “iPod-style” Lab: read audio samples from on board Flash and stream them to the audio DAC, with PS/2 keyboard for play/stop/direction plus on-board keys for speed. :contentReference[oaicite:0]{index=0}

---

## Inside this repo
- **Quartus/RTL** (top + modules)
- **sim/** ModelSim testbenches & screenshots
- **.SOF** lives under `rtl/` (project builds/loads) :contentReference[oaicite:1]{index=1}

---

## Target boards
- **DE2** — direct flash chip (S29GL032N) interface signals: `FL_DQ, FL_ADDR, FL_WE_N, FL_RST_N, FL_OE_N, FL_CE_N` (read-only: tie `FL_WE_N=1`, `FL_RST_N=1`) :contentReference[oaicite:2]{index=2}
- **DE1-SoC** — Altera Generic Quad SPI Flash controller via Avalon-MM (`flash_mem_*` signals, reads use `waitrequest`/`readdatavalid`) :contentReference[oaicite:3]{index=3}

---

## Controls (as per lab)
**PS/2 keyboard:**
- `E` → Play | `D` → Stop | `B` → Backward | `F` → Forward  
- `R` → Restart (bonus, optional) :contentReference[oaicite:4]{index=4}

**Board keys:**
- `KEY0` Speed up | `KEY1` Speed down | `KEY2` Reset to **22 kHz** :contentReference[oaicite:5]{index=5}

---

## Audio rate / clocks (lab spec)
- **22,000 Hz** sample rate ⇒ one new sample every **~0.045 ms**  
- Generate 22 kHz from `TD_CLK27` (asynchronous to 50 MHz FSM clock); edge-detect the 22 kHz tick when driving the FSM(s) :contentReference[oaicite:6]{index=6}

---

## Flash data layout (lab spec)
- **DE2**: address = **byte** index (8-bit data). 16-bit samples are at consecutive bytes (LSB at even addr, MSB at next odd addr). First sample at addrs **0/1**, last at **0x1FFFFE/0x1FFFFF**. :contentReference[oaicite:7]{index=7}  
- **DE1-SoC**: address = **word** index (32-bit data). Two 16-bit samples per word (lower 16 then upper 16). First sample at word **0 (bits 15:0)**, last sample at word **0x7FFFF (bits 31:16)**. :contentReference[oaicite:8]{index=8}

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

**Notes**
- The two “HALF_1” states output the first 16-bit sample from the fetched word (DE1-SoC: lower then upper 16; DE2: the two bytes you assembled).  
- The two “HALF_2” states output the next 16-bit sample.  
- Direction and wrapping are handled alongside address control (increment/decrement on play; hold on stop; restart snaps to start/end).
---

## Run
1) Open the Quartus project from the template, compile, and program the board.  
2) Attach PS/2 keyboard + audio output.  
3) Press `E/D/B/F` to control playback/direction; `R` to restart (bonus).  
4) Use `KEY0/1/2` to change/reset speed to **22 kHz**. :contentReference[oaicite:26]{index=26}

---

## Notes
- There’s an **optional bonus** which were both implemented the **R** (+5%) and **8-bit @ 44 kHz** (+5%). :contentReference[oaicite:29]{index=29}
