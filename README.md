<!-- SPDX-FileCopyrightText: 2024-2026 Josué Enrique Barredo Alamilla -->
<!-- SPDX-License-Identifier: CERN-OHL-S-2.0 -->

[![License: CERN OHL-S v2](https://img.shields.io/badge/License-CERN%20OHL--S%20v2-green?style=flat-square)](https://gitlab.com/ohwr/project/cernohl/-/wikis/Documents/CERN-OHL-version-2)


# BLAKE2S in VHDL
Accelerator core files have been added!
<--[A TIMING DIAGRAM WOULD LOOK GOOD HERE]-->
This repository is the appendix for a UNAM undergraduate thesis, which «translated» the reference BLAKE2s implementation in [RFC 7693](https://datatracker.ietf.org/doc/rfc7693/) into VHDL through RTL methodology, and deployed it on the ZYNQ-7000 FPGA (PYNQ-Z1 board).
Owing to the fact the design used no hard or soft IP, not even memory blocks, its standard VHDL should synthesize to virtually any FPGA, irrespective of vendor, though timing issues might arise.
The two shared variants both execute the four mixing «G» functions in a compression step concurrently, instead of one at a time, but differ in their internal handling of the individual «G» function:
- «Basé» (62.5 MHz): Its long combinational logic makes it slower but smaller.
- «Alternativa» (125 MHz): Registers break up the internal logic of the mixing round to achieve a higher clock frequency.

## Security Disclaimer
Because this is technically a cybersecurity topic, I feel obligated to advise you to not use this for anything that actually needs security. I wouldn't use this for anything other than a parlor trick until it gets a proper, secure interface, at least.

## Contents
- RTL Schematics: These vector graphics block diagrams can be found as PDF files in «[rtl_schematics](./rtl_schematics)», arranged in a directory structure analogous to the hierarchy of the original VHDL entities. The schematics were generated with Vivado's RTL analysis tool, before any synthesis or optimization was done to the chosen FPGA, to provide a simple overview of the code.
- VHDL sources: The VHDL files for both accelerator variants can be found in «[sources](./sources)».
- Constraints File: The Xilinx constraints file (.xdc) that defines pin assignments for the PYNQ-Z1 board is shared by both variants, and can be found in «[constraints_file](./constraints_file)».
- Python Script: The Python script «[blake2s_hash.py](./python_script/blake2s_hash.py)» interfaces a PC with the UART entities inside the FPGA and automatizes handling of message, hash and key. If running on Linux, one may only need to change the port definition. In the same directory «[python_script](./python_script)» housing it, some of the media and text files that were used to test it can be found. I claim no rights to none of these media files.

## Testing
To hash files, a Python script and two extra VHDL entities («Subsistema de Recepción» and «Subsistema de Transmisión») link the BLAKE2s accelerator to a PC via a USB-UART adapter (I used a generic one costing ~30 MXN). You will need to connect this adapter to the PC running the Python script and the FPGA with the synthesized design.
<--[A WIRING DIAGRAM O OR A PHOTO WOULD LOOK GOOD HERE]-->
Even though the accelerator supports keyed hashing (HMAC) of empty files, I chose not to support the keyless hashing of empty files, as there are only 32 possible unique digests for this case.
Additionally, even though the accelerator supports the maximum theoretical message size (~18.4 exabytes), the UART interface makes time the practical bottleneck--it runs at 2 million baud, which means transferring a 1 GB file takes 1 hour and 23 minutes.

## Using the script
The `blake2s_hash.py` script handles file reading, padding, and UART transmission to the FPGA. You can run it in two modes: interactive or command-line.
- Interactive Mode: Run the script without any arguments and it will launch a simple and verbose prompt, completely in Spanish, as this was used for a showcase video. It will ask for the file you want to hash (or default to `sleepy_betta_splendens.jpg` if you just press Enter), whether you want to use a key (defaulting to No), the path to that key file, and the desired digest size (defaulting to 32 bytes).
- Command Line Mode: This lets you pass up to three arguments: $ python `blake2s_hash.py <file_to_hash> <desired_digest_size> <key_file>`. If you pass only the first argument, you will get a 32 bytes-long keyless hash. The second argument is a number you type, (1 to 32 bytes, just type the number), while the third argument points to a file.
You can hash any file size from at least 1 byte, with or without a key. Note that hashing of empty files is possible only if you input a key as well. The key can be any file from 1 to 32 bytes. There is also support for custom digest size, from 1 to 32 bytes, per the RFC.

## Modification
If your FPGA runs at a different frequency, or if your PC or USB adapter needs a different baudrate, you'll have to edit several files: `blake2s_hash.py`, `uart_transmitter.vhd` and `uart_receiver.vhd`. The VHDL files need more involved modifications.
- UART Transmitter: First, you need to calculate a new constant by dividing your clock frequency by your desired baudrate and rounding the result. Then, set this new constant in binary (or hex) on line 46 of `uart_transmitter.vhd` (`constant baud_constant: std_logic_vector(5 downto 0) := "111110"; -- 62 en base 10`). As this new constant has to fit the vector it is compared against, you'll probably have to readjust the size of the `std_logic_vector` on lines 50 and 51 to match. The commented out lines 47-to-49 are already set for a 9600 baudrate with the same clock of 125 MHz.
- UART Receiver: It oversamples by a factor of 16, so the formula changes (line 12, `dvsr = (clock_freq)/(baudrate*16)`). Divide the last constant by 16 and update it (line 40,`constant DVSR: integer := 4;`) in `uart_receiver.vhd`. Similarly, you also have to increase the number of bits in `clk16_next` and `clk16_reg` from `unsigned(1 downto 0)` (line 32). For a clock of 125 MHz, the constant is 814, and the bit length is `unsigned(9 downto 0)`.
- Python Script: You only need to change a constant (line 12, BAUDRATE = 2000000) in `blake2s_hash.py`. If you run it in Linux, don't forget to swap `COM3` to `/dev/ttyUSB0`, or the appropriate port for your PC (line 124: `ser = serial.Serial(port='COM3', baudrate=BAUDRATE, timeout=1)`).

## Licensing
Unless otherwise noted, everything in this repository, including, but not limited to, VHDL, Python and constraint files, as well as block and RTL diagrams, and the directory structure itself, which mirrors the hierarchical architecture of the accelerators, is licensed under the version 2.0 of the strongly-reciprocal CERN Open Hardware License (CERN-OHL-S-2.0).
For details on compliance, refer to the full text of the [license](./LICENSE) and its [user guide](./LICENSE_USER_GUIDE.txt) included in this repository. Official copies for both the [license](https://gitlab.com/ohwr/project/cernohl/-/wikis/uploads/819d71bea3458f71fba6cf4fb0f2de6b/cern_ohl_s_v2.txt) and the [user guide](https://gitlab.com/ohwr/project/cernohl/-/wikis/uploads/b88fd806c337866bff655f2506f23d37/cern_ohl_s_v2_user_guide.txt) are available for download online as well.
