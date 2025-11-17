import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start test")

    # Clock: 10 us (TinyTapeout default)
    cocotb.start_soon(Clock(dut.clk, 10, units="us").start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 20)   # <-- longer for gate-level

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 40)   # <-- REQUIRED FOR GATE LEVEL

    # Helper to write into GPIO register
    async def write(val):
        dut.ui_in.value = val
        dut.uio_in.value = 1  # write enable
        await ClockCycles(dut.clk, 1)
        dut.uio_in.value = 0
        await ClockCycles(dut.clk, 20)  # <-- stabilizing time for GL

    # TEST 1
    await write(20)
    assert int(dut.uo_out.value.binstr.replace('x','0'), 2) == 20

    # TEST 2
    await write(15)
    assert int(dut.uo_out.value.binstr.replace('x','0'), 2) == 15

    dut._log.info("TEST PASSED")
