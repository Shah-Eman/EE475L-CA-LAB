# Lab 11 - Icarus Verilog build/run helper.
# Targets:
#   make hex    - (re)assemble the insertion-sort program into program/*.hex
#   make sort   - run the insertion-sort functional verification testbench
#   make top    - run the top-level (processor + display) integration test
#   make clean  - remove build artifacts

IV      := iverilog -g2012 -I ../include
VVP     := vvp
RTL     := rtl/cpu.sv rtl/IF_STAGE.sv rtl/pc.sv rtl/instr_mem.sv \
           rtl/if_id_reg.sv rtl/hazard_unit.sv rtl/ID_EX.sv \
           rtl/main_controller.sv rtl/imm_gen.sv rtl/reg_file.sv \
           rtl/alu_controller.sv rtl/alu.sv rtl/id_mem_reg.sv \
           rtl/MEM_WB.sv rtl/data_mem.sv
TOP_RTL := rtl/lab11_top.sv rtl/seven_seg_display.sv \
           rtl/clk_delay_display.sv rtl/t_ff.sv $(RTL)

.PHONY: hex sort top clean

hex:
	cd program && python3 assemble.py

sort:
	$(IV) -o build_sort.vvp tb/insertion_sort_tb.sv $(RTL)
	$(VVP) build_sort.vvp

top:
	$(IV) -o build_top.vvp tb/lab11_top_tb.sv $(TOP_RTL)
	$(VVP) build_top.vvp

clean:
	rm -f *.vvp *.vcd
