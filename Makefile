RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32i

PUZZLE_WIDTH=3

BBQ_SRC = $(wildcard src/*.v)
BBQ_SIM_SRC = tests/simulation.v $(BBQ_SRC)
TEST_OBJS = $(addprefix build/,$(addsuffix .o,$(basename $(wildcard tests/isa/*.S))))
FIRMWARE_OBJS = build/tests/firmware/start.o
FIRMWARE_OBJS += $(addprefix build/,$(addsuffix .o,$(basename $(wildcard tests/firmware/*.c))))
PUZZLE_OBJS = build/tests/firmware/stats.o build/tests/firmware/print.o build/tests/syscalls.o
PUZZLE_OBJS += build/tests/puzzle/main.o build/tests/puzzle/puzzle.o
RISCV_CFLAGS = -march=rv32i -Os --std=gnu99 -MMD -MF build/deps/$(patsubst %.o,%.d,$(notdir $@))
RISCV_CFLAGS += -DENABLE_DEBUG
GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv32-unknown-elf-

PHONY_TARGETS =  all clean build-dir test test_vcd puzzle puzzle_vcd vpuzzle
PHONY_TARGETS += imem_test dmem_test imem_puzzle dmem_puzzle

.PHONY: $(PHONY_TARGETS)

all: build-dir build/bbq.vvp build/tests/firmware.hex

build-dir:
	mkdir -p build/deps
	mkdir -p build/tests/isa
	mkdir -p build/tests/firmware
	mkdir -p build/tests/puzzle
	mkdir -p build-vpuzzle

build/bbq.vvp: tests/testbench.v $(BBQ_SIM_SRC)
	iverilog -Isrc -o $@ $^
	chmod -x $@

build/tests/%.o: tests/%.c
	$(TOOLCHAIN_PREFIX)gcc -c $(RISCV_CFLAGS) -DBBQ_SIMULATION \
		$(GCC_WARNS) -o $@ $<

clean:
	rm -rf build build-vpuzzle bbq.vcd imem.hex dmem.hex

##########################
#  Firmware & ISA tests  #
##########################

test: build/bbq.vvp imem_test dmem_test
	vvp -N $<

test_vcd: build/bbq.vvp imem_test dmem_test
	vvp -N $< +vcd +verbose

imem_test: build/tests/firmware.hex
	$(RM) imem.hex
	ln -s $< imem.hex

dmem_test: build/tests/firmware.hex
	$(RM) dmem.hex
	ln -s $< dmem.hex

build/tests/firmware.hex: build/tests/firmware/firmware.bin tests/firmware/makehex.py
	python3 tests/firmware/makehex.py $< 16384 > $@

build/tests/firmware/firmware.bin: build/tests/firmware/firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

build/tests/firmware/firmware.elf: $(FIRMWARE_OBJS) $(TEST_OBJS) tests/firmware/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,tests/firmware/sections.lds,-Map,build/tests/firmware/firmware.map,--strip-debug \
		$(FIRMWARE_OBJS) $(TEST_OBJS) -lgcc
	chmod -x $@

build/tests/firmware/start.o: tests/firmware/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32i -o $@ $<

build/tests/firmware/%.o: tests/firmware/%.c
	$(TOOLCHAIN_PREFIX)gcc -c $(RISCV_CFLAGS) $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<

build/tests/isa/%.o: tests/isa/%.S tests/isa/riscv_test.h tests/isa/test_macros.h
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<

############
#  puzzle  #
############

puzzle: build/tests/puzzle/bbq.vvp imem_puzzle dmem_puzzle
	vvp -N $<

puzzle_vcd: build/tests/puzzle/bbq.vvp imem_puzzle dmem_puzzle
	vvp -N $< +vcd +verbose

vpuzzle: build/tests/puzzle/vpuzzle imem_puzzle dmem_puzzle
	$<

imem_puzzle: build/tests/puzzle.hex
	$(RM) imem.hex
	ln -s $< imem.hex

dmem_puzzle: build/tests/puzzle.hex
	$(RM) dmem.hex
	ln -s $< dmem.hex

build/tests/puzzle/bbq.vvp: tests/puzzle/testbench.v $(BBQ_SIM_SRC)
	iverilog -Isrc -o $@ $^
	chmod -x $@

build/tests/puzzle/vpuzzle: tests/puzzle/verilator.v tests/puzzle/verilator_tb.cc $(BBQ_SIM_SRC)
	verilator --cc -Wno-lint -Isrc -Mdir build-vpuzzle -o vpuzzle \
		tests/puzzle/verilator.v $(BBQ_SIM_SRC) \
		--exe tests/puzzle/verilator_tb.cc
	$(MAKE) -C build-vpuzzle -f Vverilator.mk
	mv build-vpuzzle/vpuzzle $@

build/tests/puzzle.hex: build/tests/puzzle/puzzle.bytes tools/byte2word
	python3 tools/byte2word $< > $@

build/tests/puzzle/puzzle.bytes: build/tests/puzzle/puzzle.elf
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $< $@
	chmod -x $@

build/tests/puzzle/puzzle.elf: $(PUZZLE_OBJS) tests/firmware/riscv.ld
	$(TOOLCHAIN_PREFIX)gcc -Os -o $@ \
		-Wl,-Bstatic,-T,tests/firmware/riscv.ld,-Map,build/tests/puzzle/puzzle.map,--strip-debug \
		$(PUZZLE_OBJS)  -lgcc -lc -lnosys
	chmod -x $@

build/tests/puzzle/main.o: tests/puzzle/main.c tests/puzzle/problem.h
	$(TOOLCHAIN_PREFIX)gcc -c $(RISCV_CFLAGS) -DBBQ_SIMULATION \
		$(GCC_WARNS) -o $@ $<

build/tests/puzzle/%.o: tests/puzzle/%.c
	$(TOOLCHAIN_PREFIX)gcc -c $(RISCV_CFLAGS) -DBBQ_SIMULATION \
		$(GCC_WARNS) -o $@ $<

tests/puzzle/problem.h:
	python3 tests/puzzle/generate-board.py --header $(PUZZLE_WIDTH) > $@

-include build/deps/*.d
