# Simplified 8085 Microprocessor (Verilog)

A structural/behavioral Verilog implementation of a simplified 8-bit Intel 8085 microprocessor core. The design models the classic 8085 pin interface and internal datapath — ALU, general-purpose registers, program counter, stack pointer, instruction register, flag register — driven by a finite-state-machine control unit that fetches, decodes, and executes a core subset of the 8085 instruction set.

## Features

- **8085-compatible pin interface**: `CLK`, `RST_`, `READY`, `HOLD`/`HLDA`, `ALE`, `IO/M_`, `S0`/`S1`, `RD_`/`WR_`, `INTR`/`INTA_`, `RST5.5`/`RST6.5`/`RST7.5`, `TRAP`, `SID`/`SOD`, and a multiplexed 8-bit `ADDRDATA` bus with a separate high-order `ADDR` bus — matching the real 8085's demultiplexed AD0–AD7 / A8–A15 scheme.
- **Register file**: B, C, D, E, H, L, and A registers, each backed by a `register` + `buffer` pair for tri-state access onto the internal data bus, plus the H-L register pair usable as a 16-bit address pointer.
- **Temporary W/Z registers** for holding intermediate address bytes during multi-byte instructions (e.g. `LDA`/`STA`/`JMP`/`CALL`).
- **16-bit Program Counter and Stack Pointer**, each with dedicated increment/decrement units.
- **ALU module** supporting arithmetic and logical operations with flag updates (zero, carry, parity, auxiliary carry flags).
- **Dedicated increment/decrement units** (`incdec`, `incdec2`) for PC/SP and address arithmetic, separate from the main ALU.
- **Finite-state-machine control unit** with three primary machine states:
  - `state_of` — opcode fetch
  - `state_mr` — memory read
  - `state_mw` — memory write

  Each state steps through sub-cycles (T-states) that drive `ALE`, `RD_`, `WR_`, and internal read/write enables in sequence, mirroring the 8085's machine-cycle/T-state timing model.
- **Instruction decoding** for a core subset of the 8085 instruction set, grouped by opcode pattern:
  - **Data transfer**: `MOV` (reg↔reg, reg↔memory), `MVI`, `LXI`, `LDA`, `STA`
  - **Arithmetic/logic**: `ADC`, `SBB`, `ANA`, `CMP`, `ACI`
  - **Branching/flow control**: `JMP`, `JC` (conditional jump on carry), `CALL`, `CZ` (conditional call on zero), `RET`, `RZ` (conditional return on zero)
- **Reset logic** that initializes all registers, the PC, SP, flags, and internal temp registers on `RST_`.
- **Testbench** (`my8085tb.v`) and a sample memory image (`mem.txt`) for simulating instruction execution end-to-end.

## Repository structure

| File | Description |
|---|---|
| `my8085.v` | Top-level module: instantiates the register file, ALU, incdec units, and buffers; implements instruction decode and the FSM control unit. |
| `alu.v` | Arithmetic Logic Unit — performs the arithmetic/logic operations and produces updated flag bits. |
| `register.v` | Generic parameterized register module (used for GP registers, PC, SP, IR, flag register, W/Z, temp registers). |
| `buffer.v` | Tri-state buffer module used to gate register/PC/SP outputs onto shared internal and external buses. |
| `incdec.v` | Increment/decrement unit (used for PC/SP stepping). |
| `incdec2.v` | Second increment/decrement unit for address-pointer arithmetic. |
| `my8085tb.v` | Testbench driving the processor with a clock, reset, and memory model to verify instruction execution. |
| `mem.txt` | Sample program/memory contents loaded during simulation. |

## Getting started

### Prerequisites

Any Verilog simulator capable of handling `` `include `` directives and hierarchical module instantiation, for example:

- Xilinx Vivado (Simulator)
- Icarus Verilog (`iverilog` + `vvp`)
- ModelSim/QuestaSim

### Running the simulation

**Using Vivado:**
1. Create a new Vivado project (or a simulation-only project) and add `my8085.v`, `alu.v`, `register.v`, `buffer.v`, `incdec.v`, `incdec2.v`, and `my8085tb.v` as design/simulation sources.
2. Set `my8085tb` as the simulation top module.
3. Run Behavioral Simulation and inspect the waveform viewer for `CLK`, `ADDRDATA`, `ADDR`, `RD_`, `WR_`, `ALE`, and internal register/flag signals.

**Using Icarus Verilog:**
```bash
iverilog -o sim my8085tb.v
vvp sim
```
(The `` `include `` directives in `my8085.v` will pull in `alu.v`, `incdec.v`, `incdec2.v`, `register.v`, and `buffer.v` automatically — no need to list them separately.)

View the resulting waveform (if a `.vcd` dump is enabled in the testbench) with GTKWave or Vivado's waveform viewer.

## How it works

1. **Reset**: On `RST_` assertion, all registers, the PC, SP, IR, and flags are cleared and the FSM enters the opcode-fetch state.
2. **Opcode fetch (`state_of`)**: The PC drives the address bus via `ALE`, the opcode is read into the instruction register (`IR`), and the PC increments.
3. **Decode**: Combinational logic splits the opcode into high/middle/low bit-groups to classify it into one of four instruction families (data transfer, register move, ALU op, or stack/branch/control) and further decodes the exact instruction.
4. **Execute / memory access**: Depending on the decoded instruction, the FSM transitions into `state_mr` (additional operand or address bytes, or memory reads for `MOV`/`LDA`) or `state_mw` (memory writes for `STA`/`CALL`/stack pushes), stepping through the required number of machine cycles before returning to opcode fetch for the next instruction.
5. **ALU / flag update**: For arithmetic and logic instructions, operands are routed through the ALU and the result and updated flags are written back to the accumulator and flag register.

## Limitations

This is an educational/simplified implementation, not a cycle-accurate or fully compliant 8085:
- Only a core subset of the full 8085 instruction set is implemented (see the instruction list above).
- Interrupt handling (`INTR`, `TRAP`, `RST5.5/6.5/7.5`), serial I/O (`SID`/`SOD`), and `HOLD`/`HLDA` bus-sharing logic are exposed on the pin interface but are not fully implemented in the control logic.
- Timing is simplified relative to the real 8085's exact T-state counts per machine cycle.

## Possible extensions

- Add the remaining data-transfer, arithmetic, logic, and I/O instructions (`ADD`, `SUB`, `ANI`, `ORI`, `XRI`, `IN`/`OUT`, `PUSH`/`POP`, unconditional/conditional variants, etc.)
- Implement interrupt servicing and the `HOLD`/`HLDA` DMA handshake.
- Add an assembler or opcode-to-`mem.txt` generator to make writing test programs easier.
- Expand the testbench into a self-checking suite (expected register/flag values asserted per instruction).

## Author

[Souparnoo](https://github.com/Souparnoo)
