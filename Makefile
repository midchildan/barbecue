RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32i

BBQ_SRC = $(wildcard src/*.v)
TEST_OBJS = $(addprefix build/,$(addsuffix .o,$(basename $(wildcard tests/isa/*.S))))
FIRMWARE_OBJS = build/tests/firmware/start.o
FIRMWARE_OBJS += $(addprefix build/,$(addsuffix .o,$(basename $(wildcard tests/firmware/*.c))))
GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv32-unknown-elf-

.PHONY: all build-dir test test_vcd imem_test clean

all: build-dir build/bbq.vvp build/tests/imem.dat

build-dir:
	mkdir -p build/tests/isa
	mkdir -p build/tests/firmware

test: build/bbq.vvp imem_test
	vvp -N $<

test_vcd: build/bbq.vvp imem_test
	vvp -N $< +vcd +verbose

imem_test: build/tests/imem.dat
	$(RM) imem.dat
	ln -s $< imem.dat

build/bbq.vvp: $(BBQ_SRC)
	iverilog -grelative-include -o $@ $^
	chmod -x $@

build/tests/imem.dat: build/tests/firmware/firmware.bin tests/firmware/makehex.py
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

clean:
	rm -rf build
