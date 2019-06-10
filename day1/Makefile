# Recreated from ZipCPU example Makefile

.PHONY: all
all: thruwire

VERILATOR_ROOT = /usr/local/share/verilator

thruwire: thruwire.cpp obj_dir/Vthruwire__ALL.a
	g++ -I${VERILATOR_ROOT}/include -Iobj_dir	\
		${VERILATOR_ROOT}/include/verilated.cpp \
		thruwire.cpp obj_dir/Vthruwire__ALL.a	\
		-o thruwire

obj_dir/Vthruwire.cpp: thruwire.v
	verilator -Wall -cc thruwire.v

obj_dir/Vthruwire__ALL.a: obj_dir/Vthruwire.cpp
	make -C obj_dir -f Vthruwire.mk

.PHONY: clean
clean:
	rm -rf obj_dir/ thruwire