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

.PHONY: clean
clean:
	rm -rf obj_dir/ chaser_wb