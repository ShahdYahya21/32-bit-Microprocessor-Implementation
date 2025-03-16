## Microprocessor Core Design Project

### Abstract  
This project involves designing a **microprocessor core** with an **ALU** and **Register File**. The ALU executes operations based on a **6-bit opcode**, while the Register File stores data synchronized to a clock. A testbench verifies correctness.

---

### Components  

#### ALU  
- Performs arithmetic & logic operations (ADD, SUB, AND, OR, XOR, etc.).  
- Operates on **two 32-bit inputs** with a **6-bit opcode**.  

#### Register File  
- **32x32-bit registers**, accessed via **5-bit addresses**.  
- Clock-synchronized to avoid data corruption.  

#### Other Modules  
- **Instruction Register**: Extracts opcode & addresses.  
- **Opcode Delay**: Ensures correct ALU synchronization.  

---

### Microprocessor Integration  
The **top module** connects:  
1. **Instruction Register** – Decodes instruction.  
2. **Register File** – Reads/writes data.  
3. **Opcode Delay** – Manages timing.  
4. **ALU** – Executes operations.  

---

### Results & Conclusion  
- A **testbench** was used for verification.  
- **Simulation waveforms** confirmed correctness.  
- This project provides insights into **microprocessor architecture** and **digital design**.  

### For more details, see the project report.







