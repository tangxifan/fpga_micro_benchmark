# 
# Top Makefile
# ============
# 
# This is the top-level makefile of the project
# 
SHELL = bash
PYTHON_EXEC ?= python3
BENCHMARK_SUITE_NAME = simple_gates
UTIL_DIR = utils
UTIL_SCRIPT_DIR = ${UTIL_DIR}/scripts
UTIL_TASK_DIR = ${UTIL_DIR}/tasks
RTL_LIST_YAML = ${UTIL_TASK_DIR}/${BENCHMARK_SUITE_NAME}_rtl_list.yaml

NUM_JOBS=4
IVERILOG_TEMP_DIR = _iverilog_temp

# VexRiscV
TMP_VEXRISC5 = _tmp_vexrisc5
VEXRISC5_GIT_URL = https://github.com/SpinalHDL/VexRiscv.git
VEXRISC5_RTL = VexRiscv.v
VEXRISC5_LDIR_PREFIX = ${PWD}/processors/VexRiscv
VEXRISC5S_LDIR= ${VEXRISC5_LDIR_PREFIX}_small/rtl/
VEXRISC5F_LDIR= ${VEXRISC5_LDIR_PREFIX}_full/rtl/
VEXRISC5_MURAX_RTL = Murax.v
VEXRISC5_MURAX_LDIR= ${VEXRISC5_LDIR_PREFIX}_murax/rtl/

# Verilog-SPI
TMP_VSPI = _tmp_vspi
VSPI_GIT_URL = https://github.com/janschiefer/verilog_spi.git
VSPI_LDIR_PREFIX = ${PWD}/interface/verilog_spi
VSPI_RTL_FLIST = "clock_divider.v" "neg_edge_det.v" "pos_edge_det.v" "spi2.v" "spi_module.v"
VSPI_TB_FLIST = "testbench.v"
VSPI_MISC_FLIST = "README.md" "LICENSE"
VSPI_LDIR_RTL = ${VSPI_LDIR_PREFIX}/rtl/
VSPI_LDIR_TB = ${VSPI_LDIR_PREFIX}/testbench/

# DSP filters
TMP_DSPFLT = _tmp_dspfilter
DSPFLT_GIT_URL = https://github.com/ZipCPU/dspfilters.git
DSPFLT_LDIR_PREFIX = ${PWD}/dsp/dspfilters
DSPFLT_RTL_FLIST = "boxcar.v" "delayw.v" "fastfir.v" "genericfir.v" "iiravg.v" "lfsr_gal.v" "ratfil.v" "slowfil_srl.v" "slowsymf.v" "subfildown.v" "cheapspectral.v" "dspswitch.v" "firtap.v" "histogram.v" "lfsr_fib.v" "lfsr.v" "shalfband.v" "slowfil.v" "smplfir.v"
DSPFLT_MISC_FLIST = "README.md"
DSPFLT_LDIR_RTL = ${DSPFLT_LDIR_PREFIX}/rtl/

# CORDIC
TMP_CORDIC = _tmp_cordic
CORDIC_GIT_URL = https://github.com/ZipCPU/cordic.git
CORDIC_LDIR_PREFIX = ${PWD}/dsp/cordic
CORDIC_RTL_FLIST = "cordic.v" "quadtbl_ltbl.hex" "quadtbl.v" "quarterwav.v" "seqpolar.v" "sintable.v" "quadtbl_ctbl.hex" "quadtbl_qtbl.hex" "quarterwav.hex" "seqcordic.v" "sintable.hex" "topolar.v"
CORDIC_MISC_FLIST = "README.md"
CORDIC_LDIR_RTL = ${CORDIC_LDIR_PREFIX}/rtl/

.SILENT:

# Put it first so that "make" without argument is like "make help".
export COMMENT_EXTRACT

# Put it first so that "make" without argument is like "make help".
help:
	@${PYTHON_EXEC} -c "$$COMMENT_EXTRACT"

compile:
# This command compiles the RTL designss under a given specific benchmark suite name
# This command uses the RTL list generated by the ``rtl_list`` target
	echo "======== Test RTL compilation for ${BENCHMARK_SUITE_NAME} ========"; \
	${PYTHON_EXEC} ${UTIL_SCRIPT_DIR}/run_compile_test.py --file ${RTL_LIST_YAML} --temp_dir ${IVERILOG_TEMP_DIR}

cocotb_test:
# This command run HDL simulations for the RTL designss with cocotb testbenches under a given specific benchmark suite name
# This command uses the RTL list generated by the ``rtl_list`` target
	echo "======== Run Cocotb tests for ${BENCHMARK_SUITE_NAME} ========"; \
	${PYTHON_EXEC} ${UTIL_SCRIPT_DIR}/run_cocotb_test.py --file ${RTL_LIST_YAML} --new_thread_wait_time 0.1 --j ${NUM_JOBS}

clean:
# This command removes all the intermediate files during rtl compilation and cocotb verification 
	echo "======== Remove all the iverilog outputs ========"; \
	find . -name '*.o' -delete
	rm -rf ${IVERILOG_TEMP_DIR}
	echo "======== Remove all the cocotb tests ========"; \
	find . -type f -name '__pycache__' -delete
	find . -name 'results.xml' -delete
	find . -name 'cocotb_sim.log' -delete
	find . -type f -name 'sim_build' -delete

vexriscv:
# This command will checkout the latest VexRiscV, then update RTL and testbenches
	echo "==== Clone latest VexRiscV from github repo: ${VEXRISC5_GIT_URL} ====" && \
	currDir=$${PWD} && rm -rf ${TMP_VEXRISC5} && \
	git clone ${VEXRISC5_GIT_URL} ${TMP_VEXRISC5} && \
    cd ${TMP_VEXRISC5} && \
	echo "==== Generate VexRiscV small version and update local copy ====" && \
	sbt "runMain vexriscv.demo.GenSmallest" && mkdir -p ${VEXRISC5S_LDIR} && cp ${VEXRISC5_RTL} ${VEXRISC5S_LDIR} && \
	echo "==== Generate VexRiscV full version and update local copy ====" && \
	sbt "runMain vexriscv.demo.GenFull" && mkdir -p ${VEXRISC5F_LDIR} && cp ${VEXRISC5_RTL} ${VEXRISC5F_LDIR} && \
	echo "==== Generate VexRiscV Murax and update local copy ====" && \
	sbt "runMain vexriscv.demo.Murax" && mkdir -p ${VEXRISC5_MURAX_LDIR} && cp ${VEXRISC5_MURAX_RTL} ${VEXRISC5_MURAX_LDIR} && \
	cd $${currDir} && \
	echo "==== Update git track list ====" && \
	git add ${VEXRISC5_LDIR_PREFIX}* && \
	echo "==== Done ====" || exit 1;

verilog-spi:
# This command will checkout the latest SPI, then update RTL and testbenches
	echo "==== Clone latest verilog-spi from github repo: ${VSPI_GIT_URL} ====" && \
	currDir=$${PWD} && rm -rf ${TMP_VSPI} && \
	git clone ${VSPI_GIT_URL} ${TMP_VSPI} && \
    cd ${TMP_VSPI} && \
	echo "==== Update RTL ====" && \
	mkdir -p ${VSPI_LDIR_RTL} && \
	for f in ${VSPI_RTL_FLIST} ; \
	do cp $${f} ${VSPI_LDIR_RTL} || exit 1; \
	done && \
	echo "==== Update Testbench ====" && \
	mkdir -p ${VSPI_LDIR_TB} && \
	for f in ${VSPI_TB_FLIST} ; \
	do cp $${f} ${VSPI_LDIR_TB} || exit 1; \
	done && \
	echo "==== Update Documentation ====" && \
	mkdir -p ${VSPI_LDIR_PREFIX} && \
	for f in ${VSPI_MISC_FLIST} ; \
	do cp $${f} ${VSPI_LDIR_PREFIX} || exit 1; \
	done && \
	echo `git rev-parse HEAD` > ${VSPI_LDIR_PREFIX}/VERSION.md && \
	cd $${currDir} && \
	echo "==== Update git track list ====" && \
	git add ${VSPI_LDIR_PREFIX} && \
	echo "==== Done ====" || exit 1;

dspfilters:
# This command will checkout the latest DSP filters, then update RTL and testbenches
	echo "==== Clone latest dspfilters from github repo: ${DSPFLT_GIT_URL} ====" && \
	currDir=$${PWD} && rm -rf ${TMP_DSPFLT} && \
	git clone ${DSPFLT_GIT_URL} ${TMP_DSPFLT} && \
    cd ${TMP_DSPFLT}/rtl && \
	echo "==== Update RTL ====" && \
	mkdir -p ${DSPFLT_LDIR_RTL} && \
	for f in ${DSPFLT_RTL_FLIST}; \
	do cp $${f} ${DSPFLT_LDIR_RTL} || exit 1; \
	done && cd $${currDir} && \
	echo "==== Update Documentation ====" && \
    cd ${TMP_DSPFLT} && \
	mkdir -p ${DSPFLT_LDIR_PREFIX} && \
	for f in ${DSPFLT_MISC_FLIST} ; \
	do cp $${f} ${DSPFLT_LDIR_PREFIX} || exit 1; \
	done && \
	echo `git rev-parse HEAD` > ${DSPFLT_LDIR_PREFIX}/VERSION.md && \
	cd $${currDir} && \
	echo "==== Update git track list ====" && \
	git add ${DSPFLT_LDIR_PREFIX} && \
	echo "==== Done ====" || exit 1;

cordic:
# This command will checkout the latest cordic designs, then update RTL and testbenches
	echo "==== Clone latest cordic from github repo: ${CORDIC_GIT_URL} ====" && \
	currDir=$${PWD} && rm -rf ${TMP_CORDIC} && \
	git clone ${CORDIC_GIT_URL} ${TMP_CORDIC} && \
    cd ${TMP_CORDIC}/rtl && \
	echo "==== Update RTL ====" && \
	mkdir -p ${CORDIC_LDIR_RTL} && \
	for f in ${CORDIC_RTL_FLIST}; \
	do cp $${f} ${CORDIC_LDIR_RTL} || exit 1; \
	done && cd $${currDir} && \
	echo "==== Update Documentation ====" && \
	mkdir -p ${CORDIC_LDIR_PREFIX} && \
	for f in ${CORDIC_MISC_FLIST} ; \
	do cp $${f} ${CORDIC_LDIR_PREFIX} || exit 1; \
	done && \
	echo `git rev-parse HEAD` > ${CORDIC_LDIR_PREFIX}/VERSION.md && \
	cd $${currDir} && \
	echo "==== Update git track list ====" && \
	git add ${CORDIC_LDIR_PREFIX} && \
	echo "==== Done ====" || exit 1;


# Functions to extract comments from Makefiles
define COMMENT_EXTRACT
import re
with open ('Makefile', 'r' ) as f:
    matches = re.finditer('^([a-zA-Z-_]*):.*\n#(.*)', f.read(), flags=re.M)
    for _, match in enumerate(matches, start=1):
        header, content = match[1], match[2]
        print(f"  {header:10} {content}")
endef
