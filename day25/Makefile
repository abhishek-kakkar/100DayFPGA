# Recreated from ZipCPU examples by Dan Gisselquist

.PHONY: all
.DELETE_ON_ERROR:

TOPMOD := thedesign
VLOGFIL := $(TOPMOD).v
VCDFILE := $(TOPMOD).vcd
SIMPROG := $(TOPMOD)_tb
SIMFILE := $(SIMPROG).cpp
DEVICE = lp8k
VDIRFB := ./obj_dir
COSIMS := uartsim.cpp
all: $(VCDFILE)

# Compiler
CC := g++

# Flags to compiler
CFLAGS = -g -Wall -faligned-new -I$(VINC) -I$(VDIRFB)

# Flags to Verilator
VERILATOR = verilator
VFLAGS := -O3 -MMD --trace -Wall
VDEFS  := $(shell ./vversion.sh)

# Gets the Verilator root from the command itself
VERILATOR_ROOT ?= $(shell bash -c '$(VERILATOR) -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')
VINC := $(VERILATOR_ROOT)/include

$(VDIRFB)/V$(TOPMOD).cpp: $(VLOGFIL)
	$(VERILATOR) $(VFLAGS) -cc $(VLOGFIL)

$(VDIRFB)/V$(TOPMOD)__ALL.a: $(VDIRFB)/V$(TOPMOD).cpp
	make --no-print-directory -C $(VDIRFB) -f V$(TOPMOD).mk

$(SIMPROG): $(SIMFILE) $(VDIRFB)/V$(TOPMOD)__ALL.a $(COSIMS)
	$(CC) $(CFLAGS) $(VDEFS) $(VINC)/verilated.cpp				\
		$(VINC)/verilated_vcd_c.cpp $(SIMFILE) $(COSIMS)	\
		$(VDIRFB)/V$(TOPMOD)__ALL.a -o $(SIMPROG) -lncurses

test: $(VCDFILE)

$(VCDFILE): $(SIMPROG)
	./$(SIMPROG)

yosys: thedesign.json
thedesign.json: top.v thedesign.v chgdetector.v counter.v txdata.v usb/*.v pll.v
	yosys -p 'synth_ice40 -top top -json $@' $^

pll.v:
	icepll -i 16 -o 48 -m -f $@

%.asc: %.json tinyfpga_bx.pcf
	nextpnr-ice40 --$(DEVICE) --package cm81 --freq 16 --pcf tinyfpga_bx.pcf --json $< --asc $@

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $@

.PHONY: clean
clean:
	rm -rf $(VDIRFB)/ $(SIMPROG) $(VCDFILE)

# Find all dependencies
DEPS := $(wildcard $(VDIRFB)/*.d)

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(DEPS),)
include $(DEPS)
endif
endif
