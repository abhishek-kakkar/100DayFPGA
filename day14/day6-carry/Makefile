# Recreated from ZipCPU example Makefile

.PHONY: all
all: chaser_wb_tb

VERILATOR_ROOT = /usr/local/share/verilator
TOP = top
DEVICE = lp8k

chaser_wb_tb: chaser_wb.cpp obj_dir/Vchaser_wb__ALL.a
	g++ -I${VERILATOR_ROOT}/include -Iobj_dir	\
		${VERILATOR_ROOT}/include/verilated.cpp \
		${VERILATOR_ROOT}/include/verilated_vcd_c.cpp \
		chaser_wb.cpp obj_dir/Vchaser_wb__ALL.a	\
		-o chaser_wb_tb

obj_dir/Vchaser_wb.cpp: chaser_wb.v
	verilator -Wall --trace -GWIDTH=12 -cc chaser_wb.v

obj_dir/Vchaser_wb__ALL.a: obj_dir/Vchaser_wb.cpp
	make -C obj_dir -f Vchaser_wb.mk

yosys: chaser_wb.json
chaser_wb.json: top.v driver.v chaser_wb.v
	yosys -p 'synth_ice40 -top $(TOP) -json $@' $^

%.asc: %.json tinyfpga_bx.pcf
	nextpnr-ice40 --$(DEVICE) --package cm81 --freq 16 --pcf tinyfpga_bx.pcf --json $< --asc $@

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

.PHONY: clean
clean:
	rm -rf obj_dir/ chaser_wb