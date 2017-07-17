barbecue
========

A simple processor based on RISC-V

## Features

- RV32I ISA
- single cycle
- exceptions, traps, and interrupts are not supported

## Requirements

- icarus verilog
- RISC-V GNU Compiler Toolchain
- Python 3

To run the testbenches, you would need to install the RV32I toolchain as
follows:

```console
# On Ubuntu
$ sudo apt install autoconf automake autotool-dev curl libmpc-dev libmpfr-dev \
    libgmp-dev gawk build-essential bison flex texinfo gperf libtool \
    patchutils bc zlib1g-dev git

# On Fedora/CentOS/RHEL
$ sudo yum install autoconf automake libmpc-devel mpfr-devel gmp-devel gawk \
    bison flex texinfo patchutils gcc gcc-c++ zlib-devel git

# On macOS
$ brew install gawk gnu-sed gmp mpfr libmpc isl zlib

# Clone repository
$ git clone https://github.com/riscv/riscv-gnu-toolchain.git
$ cd riscv-gnu-toolchain
$ git submodule update --init --recursive

# build
$ mkdir build
$ cd build
$ ../configure --with-arch=rv32i --prefix=/opt/riscv32i
$ make -j$(nproc)
```

## Running the testbench

```console
# Build
$ make

# Run ISA tests from riscv/riscv-tests
$ make test

# Get a detailed log and vcd output for the ISA tests
$ make test_vcd

# Run a sliding puzzle program
$ make puzzle

# Get a detailed log and vcd output for the puzzle
$ make puzzle_vcd
```

## Authors

### Team Barbecue

- [midchildan](https://github.com/midchildan)
- [shimayu](https://github.com/shimayu)
- [yoshitaka](https://github.com/yoshitaka)
- [fortemovehalf](https://github.com/fortemovehalf)
- [yoshikonu](https://github.com/yoshikonu)

## License

barbecue is available under the MIT license. See [LICENSE](LICENSE) for more
info.
