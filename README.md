# Computer Architecture — VHDL Processor

Labs from the Computer Architecture course at UTFPR (Federal University of Technology — Paraná), Engineering in Computer Science program. The project consists of incrementally building a programmable processor from scratch in VHDL, simulated with GHDL and visualized with GTKWave.

## Project Overview

The processor is built across six labs, each adding a new layer of functionality. The final result is a fully working 15-bit instruction set processor with arithmetic operations, memory load, register transfers, unconditional and conditional jumps, and a programmable ROM.

**ISA highlights:**
- 15-bit instruction width
- 8 general-purpose registers (R0–R7)
- Orthogonal ISA — no accumulator
- Synchronous ROM
- 3-state pipeline: Fetch → Decode → Execute
- Flags: BLE (branch if less or equal) and BCC (branch if carry clear)

## Instruction Set

| Mnemonic | Opcode | Operation |
|----------|--------|-----------|
| NOP | 0000 | No operation |
| LD Rd, cte | 0001 | Rd = cte (5-bit immediate) |
| ADD Rd, Rs1, Rs2 | 0010 | Rd = Rs1 + Rs2 |
| SUBI Rd, Rs1, cte | 0011 | Rd = Rs1 − cte (two's complement) |
| MOV Rd, Rs1 | 0100 | Rd = Rs1 |
| BLE addr | 0101 | if BLE flag: PC = addr (absolute) |
| BCC addr | 0110 | if BCC flag: PC = addr (absolute) |
| JMP offset | 1111 | PC = PC + offset (relative, two's complement) |

**Instruction format (15 bits):**
```
[14:11] opcode  [10:8] Rd  [7:5] Rs1  [4:2] Rs2  [4:0] immediate  [10:0] address/offset
```

## Labs

| Lab | Title | Description |
|-----|-------|-------------|
| Lab 3 | Register Bank and ALU | 8×16-bit register file and arithmetic logic unit |
| Lab 4 | Rudimentary Control Unit | ROM, program counter, state machine, unconditional jump |
| Lab 5 | Programmable Calculator | Full integration of ALU, registers, and control unit |
| Lab 6 | Conditionals and Branches | Conditional branches using BLE and BCC flags |

## Repository Structure

```
.
├── lab3/
│   ├── reg16bits.vhd
│   ├── banco_regs.vhd
│   ├── banco_regs_tb.vhd
│   ├── ULA.vhd
│   ├── top_level.vhd
│   ├── top_level_tb.vhd
│   └── Makefile
├── lab4/
│   ├── flop_t.vhd
│   ├── pc.vhd
│   ├── ir.vhd
│   ├── rom.vhd
│   ├── uc.vhd
│   ├── top_level_uc.vhd
│   ├── top_level_uc_tb.vhd
│   └── Makefile
├── lab5/
│   ├── maq_estados.vhd
│   ├── uc5.vhd
│   ├── processador.vhd
│   ├── processador_tb.vhd
│   ├── rom.vhd
│   └── Makefile
├── lab6/
│   ├── reg1bit.vhd
│   ├── uc6.vhd
│   ├── processador6.vhd
│   ├── processador_tb.vhd
│   ├── rom.vhd
│   └── Makefile
└── README.md
```

## Requirements

- [GHDL](https://github.com/ghdl/ghdl) — VHDL simulator
- [GTKWave](https://gtkwave.sourceforge.net/) — waveform viewer

## Running a Lab

Each lab has its own Makefile. From inside any lab directory:

```bash
make          # compile and simulate
make wave     # open GTKWave with the result
make clean    # remove generated files
```

## Course Info

**Course:** Arquitetura de Computadores (Computer Architecture)  
**Institution:** UTFPR — Universidade Tecnológica Federal do Paraná  
**Program:** Engenharia de Computação (Computer Engineering)  
**Professor:** Juliano
# Computer-Architecture
