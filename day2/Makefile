# Recreated from ZipCPU example Makefile

.PHONY: all
all: blinky

VERILATOR_ROOT = /usr/local/share/verilator

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

.PHONY: clean
clean:
	rm -rf obj_dir/ blinky