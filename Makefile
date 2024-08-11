root_dir := $(PWD)
src_dir := ./src
syn_dir := ./syn
pr_dir := ./pr
inc_dir := ./include
sim_dir := ./sim
vip_dir := $(PWD)/vip
bld_dir := ./build
lib_dir := /usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog

FSDB_DEF :=
ifeq ($(FSDB),1)
FSDB_DEF := +FSDB
else ifeq ($(FSDB),2)
FSDB_DEF := +FSDB_ALL
endif
maxpend :=
ifeq ($(pend),1)
	maxpend := 1
else ifeq ($(pend),2) 
	maxpend := 2
else
	maxpend := 0
endif
$(info maxpend=$(maxpend))

export vip_dir
export maxpend

$(bld_dir):
	mkdir -p $(bld_dir)

$(syn_dir):
	mkdir -p $(syn_dir)

$(pr_dir):
	mkdir -p $(pr_dir)

$(bld_dir):
	mkdir -p $(bld_dir)

# AXI simulation
vip_b: clean | $(bld_dir)
	cd $(bld_dir); \
	jg ../script/jg_bridge.tcl &

# TA use this to check result
TA_run: 
  
##################
# RTL simulation #
##################
rtl_all: rtl0 

# SOC 
# rtl0: | clean $(bld_dir)
# 	make -C $(sim_dir)/prog0/; \
# 	cd $(bld_dir); \
# 	vcs -R -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64  \
# 	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
# 	+define+prog0$(FSDB_DEF) \
# 	+prog_path=$(root_dir)/$(sim_dir)/prog0 \
#   +rdcycle=1

rtl0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog0 \
    +nc64bit


# Convolution ALL
###############################
#SOC
# conv_all: | $(bld_dir)
# 	make -C $(sim_dir)/conv_all/; \
# 	cd $(bld_dir); \
# 	vcs -R -sverilog $(root_dir)/$(sim_dir)/top_tb_predicted.sv -debug_access+all -full64  \
# 	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
# 	+define+conv_all$(FSDB_DEF) \
# 	+prog_path=$(root_dir)/$(sim_dir)/conv_all \

conv_all: | $(bld_dir)
	 @if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/conv_all/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_predicted.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+conv_all$(FSDB_DEF) \
	+access+r \
	+nc64bit \
	+prog_path=$(root_dir)/$(sim_dir)/conv_all \


# Convolution layer
####################
#SOC  #not done
conv0: | clean $(bld_dir)
	 make -C $(sim_dir)/conv0/; \
	 cd $(bld_dir); \
	 vcs -R -sverilog $(root_dir)/$(sim_dir)/top_tb_conv.sv -debug_access+all -full64  \
	 +incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	 +define+conv0$(FSDB_DEF) \
	 +prog_path=$(root_dir)/$(sim_dir)/conv0 \

# conv0: | $(bld_dir)
# 	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
# 		echo "Cycle time shouldn't exceed 20"; \
# 		exit 1; \
# 	fi; \
# 	make -C $(sim_dir)/conv0/; \
# 	cd $(bld_dir); \
# 	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
# 	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
# 	+define+conv0$(FSDB_DEF) \
# 	+access+r \
# 	+nc64bit \
# 	+prog_path=$(root_dir)/$(sim_dir)/conv0 \


#SOC
conv1: | $(bld_dir)
	make -C $(sim_dir)/conv1/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/top_tb_conv.sv -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+conv1$(FSDB_DEF) \
	+access+r \
	+nc64bit \
	+prog_path=$(root_dir)/$(sim_dir)/conv1 \

# conv1: | $(bld_dir)
# 	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
# 		echo "Cycle time shouldn't exceed 20"; \
# 		exit 1; \
# 	fi; \
# 	make -C $(sim_dir)/conv1/; \
# 	cd $(bld_dir); \
# 	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
# 	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
# 	+define+conv1$(FSDB_DEF) \
# 	+access+r \
# 	+nc64bit \
# 	+prog_path=$(root_dir)/$(sim_dir)/conv1 \


# Maxpooling
#################
#SOC  #not done
pool0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/pool0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+pool0$(FSDB_DEF) \
	+access+r \
	+nc64bit \
	+prog_path=$(root_dir)/$(sim_dir)/pool0 \

# pool0: | $(bld_dir)
# 	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
# 		echo "Cycle time shouldn't exceed 20"; \
# 		exit 1; \
# 	fi; \
# 	make -C $(sim_dir)/pool0/; \
# 	cd $(bld_dir); \
# 	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
# 	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
# 	+define+pool0$(FSDB_DEF) \
# 	+access+r \
# 	+nc64bit \
# 	+prog_path=$(root_dir)/$(sim_dir)/pool0 \


#SOC  # not done
pool1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/pool1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+pool1$(FSDB_DEF) \
	+access+r \
	+nc64bit \
	+prog_path=$(root_dir)/$(sim_dir)/pool1 \

# pool1: | $(bld_dir)
# 	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
# 		echo "Cycle time shouldn't exceed 20"; \
# 		exit 1; \
# 	fi; \
# 	make -C $(sim_dir)/pool1/; \
# 	cd $(bld_dir); \
# 	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
# 	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
# 	+define+pool1$(FSDB_DEF) \
# 	+access+r \
# 	+nc64bit \
# 	+prog_path=$(root_dir)/$(sim_dir)/pool1 \


# Conv before fc
##################
#SOC
# none

conv_all_beforeFC: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/conv_all_beforeFC/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+conv_all_beforeFC$(FSDB_DEF) \
	+access+r \
	+nc64bit \
	+prog_path=$(root_dir)/$(sim_dir)/conv_all_beforeFC \


# Fully connect 
#################
#SOC # not done
fc0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/fc0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_predicted.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+fc0$(FSDB_DEF) \
	+access+r \
	+nc64bit \
	+prog_path=$(root_dir)/$(sim_dir)/fc0 \

# fc0: | $(bld_dir)
# 	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
# 		echo "Cycle time shouldn't exceed 20"; \
# 		exit 1; \
# 	fi; \
# 	make -C $(sim_dir)/fc0/; \
# 	cd $(bld_dir); \
# 	irun $(root_dir)/$(sim_dir)/top_tb_predicted.sv \
# 	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
# 	+define+fc0$(FSDB_DEF) \
# 	+access+r \
# 	+nc64bit \
# 	+prog_path=$(root_dir)/$(sim_dir)/fc0 \


################################
# Post-Synthesis simulation
################################
syn_all: syn0 

#SOC 
# syn0: | clean $(bld_dir)
# make -C $(sim_dir)/prog0/; \
# cd $(bld_dir); \
# vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/fsa0m_a_generic_core_21.lib.src  $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
# +incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
# +define+SYN+prog0$(FSDB_DEF) \
# +no_notifier \
# +prog_path=$(root_dir)/$(sim_dir)/prog0 \
# +rdcycle=1

syn0: | clean $(bld_dir)
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	irun -sv +neg_tchk -negdelay -v $(lib_dir)/fsa0m_a_generic_core_21.lib.src  $(root_dir)/$(sim_dir)/top_tb.sv -access +rwc -64bit -sdf_verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+prog0$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/prog0 \
  +rdcycle=1
	

# Convolution layer
####################
#SOC
# syn_conv_all: | $(bld_dir)
# 	make -C $(sim_dir)/conv_all/; \
# 	cd $(bld_dir); \
# 	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/fsa0m_a_generic_core_21.lib.src  $(root_dir)/$(sim_dir)/top_tb_predicted.sv -debug_access+all -full64 -diag=sdf:verbose \
# 	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
# 	+define+SYN+conv_all$(FSDB_DEF) \
# 	+no_notifier \
# 	+prog_path=$(root_dir)/$(sim_dir)/conv_all \

# syn_conv_all: | $(bld_dir)
# 	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
# 		echo "Cycle time shouldn't exceed 20"; \
# 		exit 1; \
# 	fi; \
# 	make -C $(sim_dir)/conv_all/; \
# 	cd $(bld_dir); \
# 	irun $(root_dir)/$(sim_dir)/top_tb_predicted.sv \
# 	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
# 	+define+conv_all$(FSDB_DEF) \
# 	+access+r \
# 	+nc64bit \
# 	+prog_path=$(root_dir)/$(sim_dir)/conv_all \

syn_conv_all: | clean $(bld_dir)
	make -C $(sim_dir)/conv_all/; \
	cd $(bld_dir); \
	irun -sv +neg_tchk -negdelay -v $(lib_dir)/fsa0m_a_generic_core_21.lib.src  $(root_dir)/$(sim_dir)/top_tb_predicted.sv -access +rwc -64bit -sdf_verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+conv_all$(FSDB_DEF) \
	+no_notifier \
	+prog_path=$(root_dir)/$(sim_dir)/conv_all \
  +rdcycle=1


#SOC  #not done
syn_conv0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/conv0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+conv0$(FSDB_DEF) \
	+access+r \
	+nc64bit \
	+prog_path=$(root_dir)/$(sim_dir)/conv0 \

# syn_conv0: | $(bld_dir)
# 	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
# 		echo "Cycle time shouldn't exceed 20"; \
# 		exit 1; \
# 	fi; \
# 	make -C $(sim_dir)/conv0/; \
# 	cd $(bld_dir); \
# 	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
# 	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
# 	+define+conv0$(FSDB_DEF) \
# 	+access+r \
# 	+nc64bit \
# 	+prog_path=$(root_dir)/$(sim_dir)/conv0 \


syn_conv1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/conv1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+conv1$(FSDB_DEF) \
	+access+r \
	+nc64bit \
	+prog_path=$(root_dir)/$(sim_dir)/conv1 \

# Maxpooling
####################
syn_pool0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/pool0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+pool0$(FSDB_DEF) \
	+access+r \
	+nc64bit \
	+prog_path=$(root_dir)/$(sim_dir)/pool0 \


syn_pool1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/pool1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+pool1$(FSDB_DEF) \
	+access+r \
	+nc64bit \
	+prog_path=$(root_dir)/$(sim_dir)/pool1 \

# Fully Connect
####################
syn_fc0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/fc0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_predicted.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+fc0$(FSDB_DEF) \
	+access+r \
	+nc64bit \
	+prog_path=$(root_dir)/$(sim_dir)/fc0 \


##########################
# Post-Layout simulation #
##########################
pr_all: pr0 

pr0: | clean $(bld_dir)
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/fsa0m_a_generic_core_21.lib.src  $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog0$(FSDB_DEF) \
	+no_notifier \
	+maxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/prog0 \

pr_conv0: clean | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/conv0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+conv0$(FSDB_DEF) \
	+access+r \
	+ncmaxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/conv0

pr_conv1: clean | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/conv1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+conv1$(FSDB_DEF) \
	+access+r \
	+ncmaxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/conv1

pr_pool0: clean | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/pool0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+pool0$(FSDB_DEF) \
	+access+r \
	+ncmaxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/pool0

pr_pool1: clean | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/pool1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_conv.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+pool1$(FSDB_DEF) \
	+access+r \
	+ncmaxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/pool1

pr_fc0: clean | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/fc0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb_predicted.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+fc0$(FSDB_DEF) \
	+access+r \
	+ncmaxdelays \
	+prog_path=$(root_dir)/$(sim_dir)/fc0

# Utilities
nWave: | $(bld_dir)
	cd $(bld_dir); \
	nWave top.fsdb &

verdi: | $(bld_dir)
	cd $(bld_dir); \
	verdi -ssf top.fsdb &

superlint: | $(bld_dir)
	cd $(bld_dir); \
	jg -superlint ../script/superlint.tcl &

dv: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -gui -no_home_init &

synthesize: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -no_home_init -f ../script/synthesis.tcl | tee syn_compile.log

innovus: | $(bld_dir) $(pr_dir)
	cd $(bld_dir); \
	innovus

icc2: | $(pr_dir)
	rm -rf ./pr/u18_cell_lib || exit; \
	rm -rf ./pr/run || exit; \
	mkdir -p ./pr/run; \
	cd ./pr/run; \
	icc2_lm_shell -file ../script/icc2lm_create_cell_lib.tcl
	cd ./pr/run; \
	icc2_shell -file ../script/apr.tcl

icc2_gui: | $(pr_dir)
	rm -rf ./pr/u18_cell_lib || exit; \
	rm -rf ./pr/run || exit; \
	mkdir -p ./pr/run; \
	cd ./pr/run; \
	icc2_lm_shell -file ../script/icc2lm_create_cell_lib.tcl
	cd ./pr/run; \
	icc2_shell  -file ../script/design_setup.tcl -gui

spyglass: | $(bld_dir)
	cd $(bld_dir); \
	spyglass -tcl ../script/Spyglass_CDC.tcl &

# Check file structure
BLUE=\033[1;34m
RED=\033[1;31m
NORMAL=\033[0m

check: clean
	@if [ -f StudentID ]; then \
		STUDENTID=$$(grep -v '^$$' StudentID); \
		if [ -z "$$STUDENTID" ]; then \
			echo -e "$(RED)Student ID number is not provided$(NORMAL)"; \
			exit 1; \
		else \
			ID_LEN=$$(expr length $$STUDENTID); \
			if [ $$ID_LEN -eq 9 ]; then \
				if [[ $$STUDENTID =~ ^[A-Z][A-Z0-9][0-9]+$$ ]]; then \
					echo -e "$(BLUE)Student ID number pass$(NORMAL)"; \
				else \
					echo -e "$(RED)Student ID number should be one capital letter and 8 numbers (or 2 capital letters and 7 numbers)$(NORMAL)"; \
					exit 1; \
				fi \
			else \
				echo -e "$(RED)Student ID number length isn't 9$(NORMAL)"; \
				exit 1; \
			fi \
		fi \
	else \
		echo -e "$(RED)StudentID file is not found$(NORMAL)"; \
		exit 1; \
	fi; \
	if [ -f StudentID2 ]; then \
		STUDENTID2=$$(grep -v '^$$' StudentID2); \
		if [ -z "$$STUDENTID2" ]; then \
			echo -e "$(RED)Second student ID number is not provided$(NORMAL)"; \
			exit 1; \
		else \
			ID2_LEN=$$(expr length $$STUDENTID2); \
			if [ $$ID2_LEN -eq 9 ]; then \
				if [[ $$STUDENTID2 =~ ^[A-Z][A-Z0-9][0-9]+$$ ]]; then \
					echo -e "$(BLUE)Second student ID number pass$(NORMAL)"; \
				else \
					echo -e "$(RED)Second student ID number should be one capital letter and 8 numbers (or 2 capital letters and 7 numbers)$(NORMAL)"; \
					exit 1; \
				fi \
			else \
				echo -e "$(RED)Second student ID number length isn't 9$(NORMAL)"; \
				exit 1; \
			fi \
		fi \
	fi; \
	if [ $$(ls -1 *.docx 2>/dev/null | wc -l) -eq 0 ]; then \
		echo -e "$(RED)Report file is not found$(NORMAL)"; \
		exit 1; \
	elif [ $$(ls -1 *.docx 2>/dev/null | wc -l) -gt 1 ]; then \
		echo -e "$(RED)More than one docx file is found, please delete redundant file(s)$(NORMAL)"; \
		exit 1; \
	elif [ ! -f $${STUDENTID}.docx ]; then \
		echo -e "$(RED)Report file name should be $$STUDENTID.docx$(NORMAL)"; \
		exit 1; \
	else \
		echo -e "$(BLUE)Report file name pass$(NORMAL)"; \
	fi; \
	if [ $$(basename $(PWD)) != $$STUDENTID ]; then \
		echo -e "$(RED)Main folder name should be \"$$STUDENTID\"$(NORMAL)"; \
		exit 1; \
	else \
		echo -e "$(BLUE)Main folder name pass$(NORMAL)"; \
	fi

tar: check
	STUDENTID=$$(basename $(PWD)); \
	cd ..; \
	tar cvf $$STUDENTID.tar $$STUDENTID

.PHONY: clean

clean:
	rm -rf $(bld_dir); \
	rm -rf $(sim_dir)/prog*/result*.txt; \
	make -C $(sim_dir)/prog0/ clean; \
