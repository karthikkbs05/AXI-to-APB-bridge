# AXI-to-APB-bridge
Welcome to the documentation for the AXI to APB Bridge project. Over the course of four months, our team embarked on a journey to create a basic AXI to APB Bridge with minimum signals, a fundamental piece in bridging the gap between different communication protocols within the realm of digital electronics.

## Quick links
.
.
.

## Project background
- In the realm of digital design and system-on-chip (SoC) development, different components often communicate using various communication protocols. One such vital communication interface is the Advanced eXtensible Interface (AXI) and Advanced Peripheral Bus (APB) protocols, commonly used in FPGA and SoC design. The AXI protocol is a high-performance, high-frequency interface that enables communication between various IP blocks and memory in modern systems, while the APB protocol is a lower-frequency interface typically used for interfacing with peripheral components. Bridging these two protocols is essential for achieving seamless communication and ensuring the interoperability of different modules within a digital system.
- You can check out the design of AXI and APB protocols here :
    - [AXI protocol and APB protocol designs](https://github.com/karthikkbs05/AMBA-Protocol)
- You can check out the design of basic communication protocols here :
    - [SPI,I2C and UART protocol designs](https://github.com/SanjanaHoskote/Internship_IERY)

## Understanding AXI to APB bridge 
This section provides an in-depth understanding of the bridge's architecture, functionality, and the core principles governing its operation.
### Bridge architecture
- **AXI Slave Interface:**
   - This interface connects to the AXI master, serving as the entry point for AXI transactions into the bridge. It adheres to the AXI protocol specifications, including the AXI Read and Write channels. AXI transactions initiated by the AXI master are received and processed by this interface.
- **APB Master Interface:**
   - On the other side, the APB Master interface connects to up to four APB slaves. It functions as the exit point for translated transactions, allowing the bridge to communicate with APB-compliant peripheral devices. This interface adheres to the APB protocol, facilitating APB Read and Write operations to the connected slaves.
- Figure below shows the architecture of AXI to APB bridge.
  
    <img width="285" alt="image" src="https://github.com/karthikkbs05/AXI-to-APB-bridge/assets/129792064/c26cd8da-8895-4012-986c-a15e1041a2fa">

  
### Core funtionality
- **Read Transactions:**
   - When the AXI master initiates a read transaction, the bridge interprets the AXI Read channel signals and converts them into an appropriate APB Read operation. The read data from the selected APB slave is then conveyed back to the AXI master.
- **Write Transactions:**
   - Similarly, for AXI write transactions, the bridge translates the AXI Write channel signals into an APB Write operation. The data to be written is converted into APB format and sent to the selected APB slave.
- **Address Decoding:**
   - The bridge includes address decoding logic that maps AXI addresses to the respective APB slaves. This mapping ensures that AXI transactions are correctly routed to the intended APB peripherals based on the address range.
- **Data width:**
   - In the design the data bus of AXI and APB are of same width.

## Design using verilog RTL 
- [bridge.v](bridge.v): Design module.
- [bridge_tb.v](bridge_tb.v): testbench module.
- Operation states.

    - Below figure shows the operation states of the bridge.

      <img width="258" alt="image" src="https://github.com/karthikkbs05/AXI-to-APB-bridge/assets/129792064/f75990f8-e18e-4e3d-a7f7-2c8826168b9d">

 
      

