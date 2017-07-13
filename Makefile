RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32i

PUZZLE_WIDTH=3

BBQ_SRC = $(wildcard src/*.v)
TEST_OBJS = $(addprefix build/,$(addsuffix .o,$(basename $(wildcard tests/isa/*.S))))
FIRMWARE_OBJS = build/tests/firmware/start.o
FIRMWARE_OBJS += $(addprefix build/,$(addsuffix .o,$(basename $(wildcard tests/firmware/*.c))))
PUZZLE_OBJS = build/tests/puzzle/start.o build/tests/firmware/stats.o
PUZZLE_OBJS += build/tests/puzzle/main.o build/tests/puzzle/puzzle.o
GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv32-unknown-elf-

.PHONY: all build-dir test test_vcd imem_test clean

all: build-dir build/bbq.vvp build/tests/firmware.hex

build-dir:
	mkdir -p build/tests/isa
	mkdir -p build/tests/firmware

build/bbq.vvp: $(BBQ_SRC)
	iverilog -grelative-include -o $@ $^
	chmod -x $@

clean:
	rm -rf build bbq.vcd imem.hex dmem.hex

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
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32i -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<

build/tests/isa/%.o: tests/isa/%.S tests/isa/riscv_test.h tests/isa/test_macros.h
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<

############
#  puzzle  #
############

build/tests/puzzle.hex: build/tests/puzzle/puzzle.bin tests/firmware/makehex.py
	python3 tests/firmware/makehex.py $< 16384 > $@

build/tests/puzzle/puzzle.bin: build/tests/puzzle/puzzle.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

build/tests/puzzle/puzzle.elf: $(PUZZLE_OBJS) tests/firmware/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o $@ \
    -Wl,-Bstatic,-T,tests/firmware/sections.lds,-Map,build/tests/puzzle/puzzle.map,--strip-debug \
		$(PUZZLE_OBJS)  -lgcc
	chmod -x $@

build/tests/puzzle/main.o: tests/puzzle/main.c tests/puzzle/board.h tests/puzzle/print.h tests/puzzle/puzzle.h

build/tests/puzzle/puzzle.o: tests/puzzle/puzzle.c tests/puzzle/puzzle.h tests/puzzle/problem.h

tests/puzzle/problem.h:
	python3 tests/puzzle/generate-board.py --header $(PUZZLE_WIDTH) > $@

build/tests/puzzle/start.o: tests/puzzle/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32i -o $@ $<
