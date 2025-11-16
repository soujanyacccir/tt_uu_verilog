# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Start clock: 10 us period
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 20
    dut.uio_in.value = 30

    # Wait a small time to let combinational logic settle
    await Timer(1, units="ns")  # << important for purely combinational logic

    # Check output
    assert dut.uo_out.value == 50, f"uo_out={dut.uo_out.value} != 50"

    # Test more input combinations
    dut.ui_in.value = 15
    dut.uio_in.value = 10
    await Timer(1, units="ns")
    assert dut.uo_out.value == 25, f"uo_out={dut.uo_out.value} != 25"
