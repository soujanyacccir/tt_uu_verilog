# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start test")

    # Clock: 10 us
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # ---- TEST 1: Write 20 ----
    dut.ui_in.value = 20
    dut.uio_in.value = 1  # WE = bit0
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 3)

    assert int(dut.uo_out.value) == 20, f"uo_out={dut.uo_out.value} != 20"

    # ---- TEST 2: Write 15 ----
    dut.ui_in.value = 15
    dut.uio_in.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 3)

    assert int(dut.uo_out.value) == 15, f"uo_out={dut.uo_out.value} != 15"

    dut._log.info("TEST PASSED")
