# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


@cocotb.test()
async def test_project(dut):

    dut._log.info("Starting custom TT test for GPIO+PWM+7SEG")

    # Start clock (10 us period)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    # Apply reset
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # ------------------------------
    # Test 1: Write a value to GPIO
    # ------------------------------
    TEST_VALUE = 20

    dut.ui_in.value = TEST_VALUE
    dut.uio_in.value = 1   # write enable (bit0 = 1)
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0   # disable write
    await ClockCycles(dut.clk, 2)

    # GPIO must output the written value
    assert int(dut.uo_out.value) == TEST_VALUE, \
        f"GPIO write failed: expected {TEST_VALUE}, got {dut.uo_out.value}"

    # ------------------------------
    # Test 2: Another value
    # ------------------------------
    TEST_VALUE2 = 55

    dut.ui_in.value = TEST_VALUE2
    dut.uio_in.value = 1   # write enable again
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 2)

    assert int(dut.uo_out.value) == TEST_VALUE2, \
        f"GPIO write failed: expected {TEST_VALUE2}, got {dut.uo_out.value}"

    # ------------------------------
    # Test 3: PWM + 7-seg presence check
    # ------------------------------

    # Just make sure they are not X
    assert "x" not in dut.ui
