# ecomender_eyrc

**Team ID:** 3800 | **Theme:** ecomender bot | **Competition:** e-Yantra Robotics Competition (eYRC)

**Team:** manny, priyank, yagnesh, sohum

An FPGA-based autonomous robot designed for the ecomender theme of eYRC. The robot navigates a grid, detects colored packages, picks them up using a gripper, and delivers them to target nodes — all controlled by a custom RISC-V CPU and hardware modules implemented in Verilog on Intel/Altera Quartus.

---

## Project Structure

```
├── CPU/                    # RISC-V CPU implementation
│   ├── components_clened/  # Individual CPU components (ALU, controller, datapath, etc.)
│   ├── Verilog_programs/   # Top-level CPU wrapper and memory modules
│   └── c_programs/         # C programs compiled to RISC-V hex for the CPU
├── COLOR_DETECTION/        # Color sensor interface and stable color detection
├── GRIPPER/                # Servo motor control for the gripper
├── LED_CONTROLLER/         # LED status indicator controller
├── LMD/                    # Line following and motor driver assembly
├── NODE_FINDER/            # Grid node detection and navigation logic
├── UART/                   # UART communication (TX, RX, message formatter)
├── world_FSM.v             # Top-level world finite state machine
├── clock_scaler.v          # Clock divider/scaler
├── freqscaling.v           # Frequency scaling module
└── task4one.v              # Task 4 top-level integration
```

---

## Modules

### CPU (`CPU/`)
A custom **RISC-V RV32I** CPU implemented in Verilog, integrated via `RISC_V_Wrapper.v`.

Key components:
| File | Description |
|------|-------------|
| `alu.v` | Arithmetic Logic Unit |
| `alu_decoder.v` | ALU operation decoder |
| `controller.v` | Main CPU controller (decode + ALU control) |
| `datapath.v` | CPU datapath connecting all components |
| `reg_file.v` | 32-register register file |
| `imm_extend.v` | Immediate value sign extender |
| `brancher.v` | Branch condition evaluator |
| `mux2/3/4.v` | Multiplexers |
| `data_mem.v` | Data memory |
| `instr_mem.v` | Instruction memory (loads `.hex` program) |

C programs in `CPU/c_programs/` are compiled to RISC-V hex and loaded into instruction memory for path planning and task execution.

---

### Color Detection (`COLOR_DETECTION/`)
Interfaces with a TCS color sensor to identify package colors.
- `color_detection.v` — top module; controls sensor filter selection (`s0–s3`) and reads color output
- `colordet.v` — raw color reading and classification
- `Stable_Color.v` — debounce/stabilization logic to avoid noisy readings

---

### Gripper (`GRIPPER/`)
- `servo_module.v` — PWM servo controller for opening/closing the gripper

---

### LED Controller (`LED_CONTROLLER/`)
- `led_controller.v` — drives status LEDs based on robot state

---

### Line Following & Motor Driver (`LMD/`)
Top module for autonomous line following and motor control.
| File | Description |
|------|-------------|
| `lmd.v` | Top-level motor driver assembly |
| `lfa_assembly.v` | Line follower sensor assembly |
| `ADC_controller.v` | SPI ADC interface for reading line sensors |
| `DeviationControl.v` | PID-style deviation correction |
| `upper_mdr_driver.v` / `lower_mdr_driver.v` | H-bridge motor driver halves |

---

### Node Finder (`NODE_FINDER/`)
Detects grid intersections and manages navigation commands.
- `nodeFinder.v` — parses UART messages, tracks current node, issues travel commands
- `interpretor.v` — decodes incoming path instructions
- `ship_master.v` — coordinates pickup/dropoff sequencing

---

### UART (`UART/`)
Serial communication with an external controller/PC.
- `uart_tx.v` / `uart_rx.v` — transmitter and receiver
- `uart_mod.v` — combined UART module
- `uart_scale.v` — baud rate clock scaler
- `message_formatter.v` — formats outgoing status messages
- `reader.v` — parses incoming command bytes

---

### World FSM (`world_FSM.v`)
Top-level finite state machine that coordinates all subsystems — navigation, color detection, gripper, and UART communication.

---

## Tools & Platform

- **FPGA:** Intel/Altera (Quartus project: `Clean_Babe.qpf`)
- **HDL:** Verilog
- **Simulation:** ModelSim (`simulation/modelsim/`)
- **CPU ISA:** RISC-V RV32I
- **Programming:** `.jic` file (`output_file.jic`) for FPGA flashing
