# Recreated from ZipCPU example Makefile

.PHONY: all
all: blinky

VERILATOR_ROOT = /usr/local/share/verilator
TOP = top
DEVICE = lp8k

blinky: blinky.cpp obj_dir/Vblinky__ALL.a
	g++ -I${VERILATOR_ROOT}/include -Iobj_dir	\
		${VERILATOR_ROOT}/include/verilated.cpp \
		${VERILATOR_ROOT}/include/verilated_vcd_c.cpp \
		blinky.cpp obj_dir/Vblinky__ALL.a	\
		-o blinky

obj_dir/Vblinky.cpp: blinky.v
	verilator -Wall --trace -GWIDTH=12 -cc blinky.v

obj_dir/Vblinky__ALL.a: obj_dir/Vblinky.cpp
	make -C obj_dir -f Vblinky.mk

yosys: blinky.json
blinky.json: top.v blinky.v
	yosys -p 'synth_ice40 -top $(TOP) -json $@' $^

%.asc: %.json tinyfpga_bx.pcf
	nextpnr-ice40 --$(DEVICE) --package cm81 --freq 16 --pcf tinyfpga_bx.pcf --json $< --asc $@

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

.PHONY: clean
clean:
	rm -rf obj_dir/ blinky blinky.json blinky.asc blinky.bin blinky.rpt