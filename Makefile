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

IVERILOG_TEMP_DIR = _iverilog_temp

.SILENT:

# Put it first so that "make" without argument is like "make help".
export COMMENT_EXTRACT

# Put it first so that "make" without argument is like "make help".
help:
	@${PYTHON_EXEC} -c "$$COMMENT_EXTRACT"

rtl_list:
# This command generates a list of RTL designs under a given specific benchmark suite name
# This list is used by regression test script as an input file
	echo "======== Create RTL file list for ${BENCHMARK_SUITE_NAME} ========"; \
	currDir=$${PWD} && cd ${BENCHMARK_SUITE_NAME} && \
	find . -name *.v > ${RTL_LIST_YAML} && \
	sed -i 's/$$/:/' ${RTL_LIST_YAML} && \
	cd $${currDir} \

compile:
# This command compiles the RTL designss under a given specific benchmark suite name
# This command uses the RTL list generated by the ``rtl_list`` target
	echo "======== Test RTL compilation for ${BENCHMARK_SUITE_NAME} ========"; \
	${PYTHON_EXEC} ${UTIL_SCRIPT_DIR}/run_compile_test.py --file ${RTL_LIST_YAML} --temp_dir ${IVERILOG_TEMP_DIR}

cocotb_test:
# This command run HDL simulations for the RTL designss with cocotb testbenches under a given specific benchmark suite name
# This command uses the RTL list generated by the ``rtl_list`` target
	echo "======== Run Cocotb tests for ${BENCHMARK_SUITE_NAME} ========"; \
	${PYTHON_EXEC} ${UTIL_SCRIPT_DIR}/run_cocotb_test.py --file ${RTL_LIST_YAML}

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

# Functions to extract comments from Makefiles
define COMMENT_EXTRACT
import re
with open ('Makefile', 'r' ) as f:
    matches = re.finditer('^([a-zA-Z-_]*):.*\n#(.*)', f.read(), flags=re.M)
    for _, match in enumerate(matches, start=1):
        header, content = match[1], match[2]
        print(f"  {header:10} {content}")
endef
