<!-- SPDX-FileCopyrightText: 2024-2026 Josué Enrique Barredo Alamilla -->
<!-- SPDX-License-Identifier: CERN-OHL-S-2.0 -->

[![License: CERN OHL-S v2](https://img.shields.io/badge/License-CERN%20OHL--S%20v2-green?style=flat-square)](https://gitlab.com/ohwr/project/cernohl/-/wikis/Documents/CERN-OHL-version-2)

# BLAKE2S in VHDL
This repository is basically an appendix and annex for an academic work [IN PROGRESS, STILL UPLOADING].
This is a pure VHDL implementation of the BLAKE2s cryptographic hash function, synthesized for the ZYNQ-7000 in the PYNQ-Z1 board. It uses no soft cores, memory blocks or any propietary tools other than generic VHDL. Through the included Python script and UART interface, it is possible to hash any computer file of at least 1 byte, if given enough time...
There are two variants, «Base» and «Alternativa». The former runs at 62.5 MHz, while the latter runs at 125 MHz.

## Contents
- RTL Schematics: These vector graphics block diagrams can be found as PDF files in «[rtl_schematics](./rtl_schematics)», arranged in a directory structure analogous to the hierarchy of the original VHDL entities. The schematics were generated with Vivado's RTL analysis tool, before any synthesis or optimization was done to the chosen FPGA, to provide a simple overview of the code.
- VHDL sources: The VHDL files for both accelerator variants can be found in «[vhdl_sources_placeholder](./vhdl_sources_placeholder)», organized with the same hierarchy in the RTL schematics above.
- Constraints File: The Xilinx constraints file (.xdc) that defines pin assignments for the PYNQ-Z1 board is shared by both variants, and can be found in «[constraints_file](./constraints_file)».
- Python Script: The Python script «[blake2s_hash.py](./python_script/blake2s_hash.py)» interfaces a PC with the UART entities inside the FPGA and automatizes handling of message, hash and key. If running on Linux, one may only need to change the port definition. In the same directory «[python_script](./python_script)» housing it, some of the media and text files that were used to test it can be found. I claim no rights to none of these media files.

## Licensing
Unless otherwise noted, everything in this repository, including, but not limited to, VHDL, Python and constraint files, as well as block and RTL diagrams, and the directory structure itself, which mirrors the hierarchical architecture of the accelerators, is licensed under the version 2.0 of the strongly-reciprocal CERN Open Hardware License (CERN-OHL-S-2.0).
For details on compliance, refer to the full text of the [license](./LICENSE) and its [user guide](./LICENSE_USER_GUIDE.txt) included in this repository. Official copies for both the [license](https://gitlab.com/ohwr/project/cernohl/-/wikis/uploads/819d71bea3458f71fba6cf4fb0f2de6b/cern_ohl_s_v2.txt) and the [user guide](https://gitlab.com/ohwr/project/cernohl/-/wikis/uploads/b88fd806c337866bff655f2506f23d37/cern_ohl_s_v2_user_guide.txt) are available for download online as well.
