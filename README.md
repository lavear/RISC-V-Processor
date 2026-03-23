# 5-Stage Pipelined RISC-V Processor

This repository contains a structural Verilog implementation of a 32-bit RISC-V (RV32I) processor. The design utilizes a 5-stage pipeline architecture with integrated units for hazard detection and data forwarding to optimize instruction throughput.

## Architecture Overview
The processor is divided into five distinct pipeline stages separated by architectural registers:
1. Instruction Fetch (IF): Retrieves machine code from the instruction memory based on the Program Counter.
2. Instruction Decode (ID): Extracts opcodes, reads from the Register File, and generates extended immediates.
3. Execute (EX): Performs arithmetic and logic operations via the ALU and calculates branch target addresses.
4. Memory Access (MEM): Interfaces with Data Memory for load and store operations.
5. Write Back (WB): Commits the final result (from ALU or Memory) back to the Register File.



## Hazard Resolution Logic
To maintain the integrity of the pipeline and minimize stalls, the following units are implemented:
* Forwarding Unit: Resolves Data Hazards (Read-After-Write) by providing a bypass path from the MEM and WB stages directly to the ALU inputs.
* Hazard Detection Unit: Identifies Load-Use hazards and manages pipeline stalls by disabling the PC and IF/ID updates while inserting NOPs into the ID/EX stage.
* Flush Logic: Manages Control Hazards by clearing the IF/ID and ID/EX registers when a branch is successfully taken, preventing the execution of incorrectly fetched instructions.

## Project Structure
The source code is organized into a modular tree for improved maintainability:
riscv_pipeline_cpu/
├── src/
│   ├── core/      (PC, Register File, ALU, Instruction/Data Memories)
│   ├── logic/     (Standard Muxes, Adders, and Boolean gates)
│   ├── control/   (Main Control Unit, ALU Control, Hazard and Forwarding Units)
│   ├── pipeline/  (IFID, IDEX, EXMEM, and MEMWB pipeline registers)
│   └── top.v      (The top-level structural netlist)
└── tb/
    └── tb_top.v   (Testbench for simulation and verification)

## Simulation and Verification
The design is intended for simulation in standard EDA environments such as QuestaSim, ModelSim, or Icarus Verilog.
1. Compile all source files in the src/ directory.
2. Load the tb_top.v testbench.
3. Run the simulation and observe the internal signals (Forwarding, Stalls, and Flush) in a waveform viewer like GTKWave.



## Supported Instructions
The current Instruction Memory configuration supports:
* R-Type: add, sub, and, or
* I-Type: addi, ori, lw
* S-Type: sw
* SB-Type: beq
