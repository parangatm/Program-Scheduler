################################################################################
# DESIGN COMPILER:  Logic Synthesis Tool                                       #
################################################################################
remove_design -all

# Add search paths for our technology libs.
set search_path "$search_path . ./verilog /w/apps2/public.2/tech/synopsys/32-28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm" 
set target_library "saed32rvt_ff1p16vn40c.db saed32rvt_ss0p95v125c.db"
set link_library "* saed32rvt_ff1p16vn40c.db saed32rvt_ss0p95v125c.db dw_foundation.sldb"
set synthetic_library "dw_foundation.sldb"

# Define work path (note: The work path must exist, so you need to create a folder WORK first)
define_design_lib WORK -path ./WORK
set alib_library_analysis_path "./alib-52/"

# Read the gate-level verilog files
analyze -format verilog {M216A_TopModule.v}
set DESIGN_NAME M216A_TopModule

elaborate $DESIGN_NAME
current_design $DESIGN_NAME
link

set_operating_conditions -min ff1p16vn40c -max ss0p95v125c

# Describe the clock waveform & setup operating conditions
set Tclk 0.15
set TCU  [expr 0.1*$Tclk]
set IN_DEL 0.03
set IN_DEL_MIN 0.02
set OUT_DEL 0.03
set OUT_DEL_MIN 0.02
set ALL_IN_BUT_CLK [remove_from_collection [all_inputs] "clk_i"]

# Clock Constraints
create_clock -name "clk_i" -period $Tclk [get_ports "clk_i"]
set_fix_hold clk_i
set_dont_touch_network [get_clocks "clk_i"]
set_clock_uncertainty $TCU [get_clocks "clk_i"]

# IO Constraints
set_input_delay $IN_DEL -clock "clk_i" $ALL_IN_BUT_CLK
set_input_delay -min $IN_DEL_MIN -clock "clk_i" $ALL_IN_BUT_CLK
set_output_delay $OUT_DEL -clock "clk_i" [all_outputs]
set_output_delay -min $OUT_DEL_MIN -clock "clk_i" [all_outputs]

current_design $DESIGN_NAME

# Target PPA
set_max_area 0.0
set_max_total_power 0.0

# Timing DRCs
set_load 1.000 [all_outputs]
set_max_fanout 1.000 [get_designs *]
set_max_transition 0.1 [get_designs *]

ungroup -flatten -all
uniquify

compile -only_design_rule
compile -map high
compile -boundary_optimization
compile -only_hold_time

# removing stale connections
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
remove_unconnected_ports -blast_buses [get_cells -hier]

# generating reports
report_timing -path full -delay min -max_paths 10 -nworst 2 -significant_digits 4 > Group-4.TimingHold
report_timing -path full -delay max -max_paths 10 -nworst 2 -significant_digits 4 > Group-4.TimingSetup
report_area -hierarchy > Group-4.Area
report_power > Group-4.Power
