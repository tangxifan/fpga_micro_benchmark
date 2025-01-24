#####################################################################
# Test the functionality of 16 bit Counter
#####################################################################
import random
import numpy as np
import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge


@cocotb.test()
async def test_counterdown16_1clk_posedge_async_resetp(dut):

    ################################################################
    # Clock Generation
    CLK_PERIOD = 10  # [ns]
    cocotb.start_soon(Clock(dut.clock0, CLK_PERIOD, units="ns").start())

    ################################################################

    # Test all the cases
    test_cases = 1
    COUNTER_SIZE = 16
    num_cycles = pow(2, COUNTER_SIZE)
    COUNTER_MIN_VAL = 0
    assert_rst = 1
    deassert_rst = 0
    expected_count = 0xFFFF
    rst_counter_rand = random.randint(0, int((num_cycles * test_cases) / COUNTER_SIZE))

    dut.reset.value = assert_rst
    await ClockCycles(dut.clock0, 2)

    await RisingEdge(dut.clock0)
    await Timer(1, units="ns")
    dut.reset.value = deassert_rst

    await FallingEdge(dut.clock0)
    dut._log.info("Reset Test0:: count is %d", dut.count.value)
    dut._log.info("Reset Test0:: expected_count is %d", expected_count)
    assert dut.count.value == expected_count, "count does not match expected value!"

    await ClockCycles(dut.clock0, 20)
    await RisingEdge(dut.clock0)
    dut.reset.value = assert_rst
    await FallingEdge(dut.clock0)
    dut._log.info("Reset Test1:: count is %d", dut.count.value)
    dut._log.info("Reset Test1:: expected_count is %d", expected_count)
    assert dut.count.value == expected_count, "count does not match expected value!"
    await RisingEdge(dut.clock0)
    await Timer(1, units="ns")
    dut.reset.value = deassert_rst
    await FallingEdge(dut.clock0)

    for cycle in range(
        int((num_cycles * test_cases) / COUNTER_SIZE)
    ):  # Divided by COUNTER_SIZE just to reduce runtime
        if cycle == rst_counter_rand:
            dut.reset.value = assert_rst
            dut._log.info("Reset Test2:: Driving reset randomly!")
        else:
            dut.reset.value = deassert_rst

        await RisingEdge(dut.clock0)
        if expected_count == COUNTER_MIN_VAL or dut.reset.value == assert_rst:
            expected_count = 0xFFFF
        else:
            expected_count -= 1

        # expected_count = BinaryValue(expected_count, n_bits=COUNTER_SIZE, bigEndian=False).integer
        await FallingEdge(dut.clock0)
        dut._log.info("count is %d", dut.count.value)
        dut._log.info("expected_count is %d", expected_count)
        assert dut.count.value == expected_count, "count does not match expected value!"
