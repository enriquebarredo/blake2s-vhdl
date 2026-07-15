<!--- SPDX-FileCopyrightText: 2024-2026 Josué Enrique Barredo Alamilla --->
<!--- SPDX-License-Identifier: CERN-OHL-S-2.0 --->

[![License: CERN OHL-S v2](https://img.shields.io/badge/License-CERN%20OHL--S%20v2-green?style=flat-square)](https://gitlab.com/ohwr/project/cernohl/-/wikis/Documents/CERN-OHL-version-2)

# BLAKE2S in VHDL
This is a pure VHDL implementation of the BLAKE2s cryptographic hash function, synthesized for the ZYNQ-7000 in the PYNQ-Z1 board. It uses no soft cores, memory blocks or any propietary tools other than generic VHDL. Through the included Python script and UART interface, it is possible to hash any computer file of at least 1 byte, if given enough time...

## Licensing
Everything in this repository, including, but not limited to, VHDL, Python and constraint files, as well as block and RTL diagrams, and the directory structure itself, which mirrors the hierarchical architecture of the accelerators, is licensed under the version 2.0 of the strongly-reciprocal CERN Open Hardware License (CERN-OHL-S-2.0).
For details on compliance, refer to the full text of the [license](./LICENSE) and its [user guide](./LICENSE_USER_GUIDE.txt) included in this repository. Official copies for both the [license](https://gitlab.com/ohwr/project/cernohl/-/wikis/uploads/819d71bea3458f71fba6cf4fb0f2de6b/cern_ohl_s_v2.txt) and the [user guide](https://gitlab.com/ohwr/project/cernohl/-/wikis/uploads/b88fd806c337866bff655f2506f23d37/cern_ohl_s_v2_user_guide.txt) are available for download online as well.
