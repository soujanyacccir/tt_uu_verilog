# test/test.py
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start test")

    # Start clock (10 us period)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Initialize and reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 6)    # ensure flops see reset
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 6)    # let GL nets settle after reset

    # TEST 1: write value 20 (pulse WE for one cycle)
    TEST1 = 20
    dut.ui_in.value = TEST1
    dut.uio_in.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 3)    # extra cycles for GLS

    assert int(dut.uo_out.value) == TEST1, f"uo_out={dut.uo_out.value} != {TEST1}"

    # TEST 2: write value 15
    TEST2 = 15
    dut.ui_in.value = TEST2
    dut.uio_in.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 3)

    assert int(dut.uo_out.value) == TEST2, f"uo_out={dut.uo_out.value} != {TEST2}"

    dut._log.info("TEST PASSED")
