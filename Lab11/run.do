# QuestaSim/ModelSim run script for Lab 11
# Usage from the Lab11/ directory:
#   vsim -do run.do                                   (insertion-sort verification)
#   vsim -do "set TB lab11_top_tb; do run.do"         (top + display integration)
#
# +incdir+../include resolves the opcode.vh / alu_ops.vh macros.
# The $readmemh paths in the testbenches are relative to this folder, so
# launch QuestaSim from Lab11/.

if {![info exists TB]} { set TB insertion_sort_tb }

vlib work
vmap work work

vlog -sv +incdir+../include rtl/*.sv tb/$TB.sv

vsim -c -voptargs=+acc work.$TB -do "run -all; quit -f"
