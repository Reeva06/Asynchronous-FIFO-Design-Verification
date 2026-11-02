# Asynchronous FIFO Design and Verification (Verilog HDL)

## Overview
This project implements a parameterizable **Asynchronous FIFO (First-In, First-Out)** buffer designed to handle safe, reliable data transfer between two independent and asynchronous clock domains (Write Clock ≠ Read Clock).

## Key Architectural Features
- **Dual-Clock Domain (CDC):** Independent write clock (`wclk`) and read clock (`rclk`).
- **Metastability Mitigation:** Uses 2-stage flip-flop synchronizers to safely pass pointers across clock boundaries.
- **Gray Code Encoding:** Employs binary-to-Gray code conversion so only a single bit changes per count transition, preventing erroneous flag assertions.
- **Status Flags:** Accurate generation of full (`wfull`) and empty (`rempty`) flags.

## Module Parameters & Ports
- `DATA_WIDTH`: Width of input/output data bus (Default: 8 bits).
- `ADDR_WIDTH`: Address width defining FIFO depth (Depth = $2^{ADDR\_WIDTH}$, Default: 16 words).

## Simulation & Waveform Results
The design was verified using directed test vectors on EDA Playground using the Icarus Verilog simulator.

![FIFO Simulation Waveform](fifo_waveform.png)

### Verification Highlights:
1. **Reset Phase:** Correct initialization of pointers and assertion of `rempty = 1`.
2. **Write Phase:** Burst write transactions completed without data loss.
3. **Read Phase:** FIFO correctly recovered data in strict order (FIFO sequence verified).
4. **Flag Assertions:** Synchronizer delays safely handled status flags without causing read/write hazards.

## How to Run Simulation
Open the design and testbench on [EDA Playground](https://www.edaplayground.com/):
- **Simulator:** Icarus Verilog 10.0 / 12.0
- Check **Open EPWave after run**
- Run simulation to inspect waveforms.
