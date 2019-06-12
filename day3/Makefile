# Recreated from ZipCPU example Makefile

.PHONY: all
all: chaser

VERILATOR_ROOT = /usr/local/share/verilator
TOP = top
DEVICE = lp8k

chaser: chaser.cpp obj_dir/Vchaser__ALL.a
	g++ -I${VERILATOR_ROOT}/include -Iobj_dir	\
		${VERILATOR_ROOT}/include/verilated.cpp \
		${VERILATOR_ROOT}/include/verilated_vcd_c.cpp \
		chaser.cpp obj_dir/Vchaser__ALL.a	\
		-o chaser

obj_dir/Vchaser.cpp: chaser.v
	verilator -Wall --trace -GWIDTH=12 -cc chaser.v

obj_dir/Vchaser__ALL.a: obj_dir/Vchaser.cpp
	make -C obj_dir -f Vchaser.mk

.PHONY: clean
clean:
	rm -rf obj_dir/ chaser