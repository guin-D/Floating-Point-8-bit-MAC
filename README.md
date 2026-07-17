# 8-bit Floating-Point MAC (Multiply-Accumulate) Unit

## 📌 Project Overview
This repository contains the RTL implementation of an **8-bit Floating-Point Multiply-Accumulate (MAC) unit**, written in Verilog/SystemVerilog. The MAC unit is a fundamental building block for modern digital signal processing (DSP) and hardware accelerators, particularly optimized for **Deep Learning and Artificial Intelligence (AI)** inference tasks where reduced-precision arithmetic (FP8) drastically minimizes memory bandwidth and power consumption.

## 🛠️ Technologies & Tools
*   **Hardware Description Language:** Verilog / SystemVerilog
*   **Simulation & Verification:** ModelSim / QuestaSim
*   **Synthesis Tools:** Xilinx Vivado / Intel Quartus (Target Independent)

## 🏗️ Hardware Architecture
The datapath of the FP8 MAC unit is meticulously designed to compute the operation $Y = A \times B + C$ (where $C$ is the accumulated value) in a highly pipelined and resource-efficient manner. 

### Core Microarchitecture Modules:
1.  **FP8 Multiplier:**
    *   **Sign Logic:** Computes the XOR of the input sign bits.
    *   **Exponent Adder:** Adds the biased exponents and subtracts the bias value.
    *   **Mantissa Multiplier:** Performs integer multiplication on the hidden-bit-appended mantissas.
2.  **FP8 Accumulator (Adder/Subtractor):**
    *   **Exponent Alignment:** Compares exponents and right-shifts the mantissa of the smaller operand to align the radix points.
    *   **Mantissa Addition/Subtraction:** Computes the sum or difference based on the sign bits.
    *   **Normalization:** Leading Zero Detection (LZD) logic is implemented to left-shift the result and adjust the exponent accordingly, ensuring standard IEEE-like format compliance.
3.  **Pipeline Registers:** Inserted strategically across the datapath to break critical paths and achieve high clock frequencies.

### 👥 Team Members

| Name | Role | 
| :--- | :--- | 
| **Vũ Anh Tuấn** | Core Member | 
| **Nguyễn Tiến Dũng** | Core Member |
| **Phạm Văn Duy** | Core Member |
