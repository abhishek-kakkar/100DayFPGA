# Recreated from ZipCPU examples by Dan Gisselquist

.PHONY: all
.DELETE_ON_ERROR:

TOPMOD := helloworld
VLOGFIL := $(TOPMOD).v
VCDFILE := $(TOPMOD).vcd
SIMPROG := $(TOPMOD)_tb
SIMFILE := $(SIMPROG).cpp
VDIRFB := ./obj_dir
COSIMS := uartsim.cpp
all: $(VCDFILE)

# Compiler
CC := g++

# Flags to compiler
CFLAGS = -g -Wall -faligned-new -I$(VINC) -I(VDIRFB)

# Flags to Verilator
VFLAGS := -O3 -MMD --trace -Wall

# Gets the Verilator root from the command itself
VERILATOR_ROOT ?= $(shell bash -c '$(VERILATOR) -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')

